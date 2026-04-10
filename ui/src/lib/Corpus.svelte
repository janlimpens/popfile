<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';

  let { buckets = $bindable([]) } = $props();

  let newName = $state('');
  let newColor = $state('#888888');
  let renameFrom = $state('');
  let renameTo = $state('');
  let status = $state('');
  let wordSearch = $state('');
  let wordBucket = $state('');
  let words = $state([]);
  let stopwords = $state([]);
  let candidates = $state([]);
  let candidateRatio = $state(2.0);
  let candidatesLoaded = $state(false);

  async function refresh() {
    const res = await fetch('/api/v1/buckets');
    if (res.ok) buckets = await res.json();
  }

  async function createBucket() {
    if (!newName.trim()) return;
    const res = await fetch('/api/v1/buckets', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newName.trim(), color: newColor }),
    });
    if (res.ok) {
      status = `Created "${newName}"`;
      newName = '';
      newColor = '#888888';
      refresh();
    } else {
      const data = await res.json().catch(() => ({}));
      status = data.error ?? 'Error';
    }
  }

  async function deleteBucket(name) {
    if (!confirm(`Delete bucket "${name}"?`)) return;
    const res = await fetch(`/api/v1/buckets/${name}`, { method: 'DELETE' });
    status = res.ok ? `Deleted "${name}"` : 'Error';
    refresh();
  }

  async function renameBucket() {
    if (!renameFrom || !renameTo.trim()) return;
    const res = await fetch(`/api/v1/buckets/${renameFrom}/rename`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ new_name: renameTo.trim() }),
    });
    status = res.ok ? `Renamed to "${renameTo}"` : 'Error';
    renameTo = '';
    refresh();
  }

  async function clearBucket(name) {
    if (!confirm(`Clear all words from "${name}"?`)) return;
    const res = await fetch(`/api/v1/buckets/${name}/words`, { method: 'DELETE' });
    status = res.ok ? `Cleared "${name}"` : 'Error';
    refresh();
  }

  async function setColor(name, color) {
    await fetch(`/api/v1/buckets/${name}/params`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ color }),
    });
    refresh();
  }

  async function searchWords() {
    if (!wordBucket || !wordSearch.trim()) return;
    const res = await fetch(`/api/v1/buckets/${wordBucket}/words?prefix=${encodeURIComponent(wordSearch.trim())}`);
    if (res.ok) words = await res.json();
  }

  async function loadStopwords() {
    const res = await fetch('/api/v1/stopwords');
    if (res.ok) stopwords = await res.json();
  }

  async function removeStopword(word) {
    await fetch(`/api/v1/stopwords/${encodeURIComponent(word)}`, { method: 'DELETE' });
    loadStopwords();
  }

  async function loadCandidates() {
    const res = await fetch(`/api/v1/stopword-candidates?ratio=${candidateRatio}`);
    if (res.ok) { candidates = await res.json(); candidatesLoaded = true; }
  }

  async function addCandidateAsStopword(word) {
    const res = await fetch('/api/v1/stopwords', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ word }),
    });
    if (res.ok) { loadStopwords(); loadCandidates(); }
  }

  onMount(() => { refresh(); loadStopwords(); });
</script>

<div class="page">

<h2>{t('NavCorpus')}</h2>

{#if status}
  <p class="status" class:error={status.startsWith('invalid') || status === 'bucket already exists'}>{status}</p>
{/if}

<section>
  <h3>{t('Corpus_BucketList')}</h3>
  <table>
    <thead><tr><th>Name</th><th>Words</th><th>{t('Corpus_Color')}</th><th>{t('Corpus_Actions')}</th></tr></thead>
    <tbody>
      {#each buckets as b (b.name)}
        <tr>
          <td><span class="dot" style="background:{b.color}"></span>{b.name}</td>
          <td>{b.word_count ?? 0}</td>
          <td>
            <input
              type="color"
              value={b.color || '#666666'}
              onchange={e => setColor(b.name, e.target.value)}
            />
          </td>
          <td>
            {#if !b.pseudo}
              <button class="btn-danger" onclick={() => deleteBucket(b.name)}>{t('Delete')}</button>
              <button onclick={() => clearBucket(b.name)}>{t('Corpus_Clear')}</button>
            {/if}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</section>

<section>
  <h3>{t('Bucket_CreateBucket')}</h3>
  <div class="row">
    <input type="color" bind:value={newColor} />
    <input type="text" placeholder="my-bucket-1" pattern="[a-z0-9_-]+" title="lowercase letters, digits, - and _ only" bind:value={newName} />
    <button onclick={createBucket}>{t('Create')}</button>
  </div>
</section>

<section>
  <h3>{t('Bucket_RenameBucket')}</h3>
  <div class="row">
    <select bind:value={renameFrom}>
      <option value="">— select —</option>
      {#each buckets.filter(b => !b.pseudo) as b}
        <option value={b.name}>{b.name}</option>
      {/each}
    </select>
    <input type="text" placeholder="new name" bind:value={renameTo} />
    <button onclick={renameBucket}>{t('Rename')}</button>
  </div>
</section>

<section>
  <h3>{t('Bucket_Lookup')}</h3>
  <div class="row">
    <select bind:value={wordBucket}>
      <option value="">— bucket —</option>
      {#each buckets as b}
        <option value={b.name}>{b.name}</option>
      {/each}
    </select>
    <input type="text" placeholder="prefix…" bind:value={wordSearch} />
    <button onclick={searchWords}>{t('Corpus_Search')}</button>
  </div>
  {#if words.length}
    <ul class="word-list">
      {#each words as w}<li>{w.word}: {w.count}</li>{/each}
    </ul>
  {/if}
</section>

<section>
  <h3>{t('Corpus_StopwordsTitle')}</h3>
  <p class="desc">{t('Corpus_StopwordsDesc')}</p>
  {#if stopwords.length}
    <ul class="word-list">
      {#each stopwords as w}
        <li>{w} <button class="btn-small btn-danger" onclick={() => removeStopword(w)}>{t('Corpus_RemoveStopword')}</button></li>
      {/each}
    </ul>
  {/if}
</section>

<section>
  <h3>{t('Corpus_StopwordCandidates')}</h3>
  <p class="desc">{t('Corpus_StopwordCandidatesDesc')}</p>
  <div class="row">
    <label>{t('Corpus_StopwordRatio')}
      <input type="number" min="1.01" max="100" step="0.1" bind:value={candidateRatio} />
    </label>
    <button onclick={loadCandidates}>{t('Corpus_LoadCandidates')}</button>
  </div>
  {#if candidatesLoaded}
    {#if candidates.length}
      <ul class="word-list">
        {#each candidates as c}
          <li>{c.word} ({c.ratio.toFixed(2)}) <button class="btn-small" onclick={() => addCandidateAsStopword(c.word)}>{t('Corpus_AddStopword')}</button></li>
        {/each}
      </ul>
    {:else}
      <p class="desc">{t('Corpus_NoCandidates')}</p>
    {/if}
  {/if}
</section>

</div>

<style>
  .page { padding: 1.75rem 2rem; max-width: 760px; }
  section { margin: 1.5rem 0; }
  h3 { margin-bottom: 0.5rem; font-size: 1rem; color: var(--text); }
  .row { display: flex; gap: 0.5rem; align-items: center; }
  button { padding: 0.35rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .btn-danger { color: var(--danger); border-color: var(--danger); }
  .status { color: var(--success); font-weight: 500; }
  .status.error { color: var(--danger); }
  .word-list { column-count: 3; margin-top: 0.5rem; font-size: 0.85rem; }
  .word-list li { margin-bottom: 0.2rem; }
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.4rem; vertical-align: middle; }
  .desc { font-size: 0.85rem; color: var(--text-muted, #888); margin: 0.25rem 0 0.5rem; }
  .btn-small { padding: 0.1rem 0.4rem; font-size: 0.75rem; }
  input[type=number] { width: 5rem; padding: 0.25rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); }
</style>
