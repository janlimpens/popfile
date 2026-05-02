<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';
  import WordSearch from './WordSearch.svelte';

  let { buckets = $bindable([]), initialBucket = '', wordSearchBucket = '' } = $props();

  let newName = $state('');
  let newColor = $state('#888888');
  let renameFrom = $state('');
  let renameTo = $state('');
  let status = $state('');

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

  async function deleteBucket(id, name) {
    if (!confirm(`Delete bucket "${name}"?`)) return;
    const res = await fetch(`/api/v1/buckets/${id}`, { method: 'DELETE' });
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

  async function clearBucket(id, name) {
    if (!confirm(`Clear all words from "${name}"?`)) return;
    const res = await fetch(`/api/v1/buckets/${id}/words`, { method: 'DELETE' });
    status = res.ok ? `Cleared "${name}"` : 'Error';
    refresh();
  }

  async function setColor(id, color) {
    await fetch(`/api/v1/buckets/${id}/params`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ color }),
    });
    refresh();
  }

  onMount(refresh);
</script>

<div class="page">

{#if initialBucket.startsWith('words')}
  <WordSearch bucket={wordSearchBucket} />
{:else if !initialBucket}

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
              onchange={e => setColor(b.id, e.target.value)}
            />
          </td>
          <td>
            <a class="btn-link" href="#corpus/words/{b.name}">{t('NavWordSearch')}</a>
            {#if !b.pseudo}
              <button class="btn-danger" onclick={() => deleteBucket(b.id, b.name)}>{t('Delete')}</button>
              <button onclick={() => clearBucket(b.id, b.name)}>{t('Corpus_Clear')}</button>
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
    <input type="text" placeholder="my-bucket-1" bind:value={newName}
      onkeydown={e => e.key === 'Enter' && createBucket()} />
    <button onclick={createBucket}>{t('Create')}</button>
  </div>
</section>

<section>
  <h3>{t('Bucket_RenameBucket')}</h3>
  <div class="row">
    <select bind:value={renameFrom}>
      <option value="">— select —</option>
      {#each buckets.filter(b => !b.pseudo) as b}
        <option value={b.id}>{b.name}</option>
      {/each}
    </select>
    <input type="text" placeholder="new name" bind:value={renameTo}
      onkeydown={e => e.key === 'Enter' && renameBucket()} />
    <button onclick={renameBucket}>{t('Rename')}</button>
  </div>
</section>

<section>
  <a class="btn-link words-link" href="#corpus/words">{t('NavWordSearch')} (all buckets) →</a>
</section>

{/if}
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
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.4rem; vertical-align: middle; }
  .words-link { font-size: 0.9rem; }
  .btn-link { font-size: 0.8rem; color: var(--accent); text-decoration: none; padding: 0.2rem 0.4rem; border-radius: 4px; }
  .btn-link:hover { text-decoration: underline; }
</style>
