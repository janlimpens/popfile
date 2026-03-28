<script>
  import { onMount } from 'svelte';

  let { buckets = $bindable([]) } = $props();

  let newName = $state('');
  let renameFrom = $state('');
  let renameTo = $state('');
  let status = $state('');
  let wordSearch = $state('');
  let wordBucket = $state('');
  let words = $state([]);

  async function refresh() {
    const res = await fetch('/api/v1/buckets');
    if (res.ok) buckets = await res.json();
  }

  async function createBucket() {
    if (!newName.trim()) return;
    const res = await fetch('/api/v1/buckets', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newName.trim() }),
    });
    status = res.ok ? `Created "${newName}"` : 'Error';
    newName = '';
    refresh();
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

  onMount(refresh);
</script>

<h2>Corpus</h2>

{#if status}
  <p class="status">{status}</p>
{/if}

<section>
  <h3>Buckets</h3>
  <table>
    <thead><tr><th>Name</th><th>Words</th><th>Color</th><th>Actions</th></tr></thead>
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
              <button class="btn-danger" onclick={() => deleteBucket(b.name)}>Delete</button>
              <button onclick={() => clearBucket(b.name)}>Clear</button>
            {/if}
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
</section>

<section>
  <h3>Create bucket</h3>
  <div class="row">
    <input type="text" placeholder="bucket-name" bind:value={newName} />
    <button onclick={createBucket}>Create</button>
  </div>
</section>

<section>
  <h3>Rename bucket</h3>
  <div class="row">
    <select bind:value={renameFrom}>
      <option value="">— select —</option>
      {#each buckets.filter(b => !b.pseudo) as b}
        <option value={b.name}>{b.name}</option>
      {/each}
    </select>
    <input type="text" placeholder="new name" bind:value={renameTo} />
    <button onclick={renameBucket}>Rename</button>
  </div>
</section>

<section>
  <h3>Word lookup</h3>
  <div class="row">
    <select bind:value={wordBucket}>
      <option value="">— bucket —</option>
      {#each buckets as b}
        <option value={b.name}>{b.name}</option>
      {/each}
    </select>
    <input type="text" placeholder="prefix…" bind:value={wordSearch} />
    <button onclick={searchWords}>Search</button>
  </div>
  {#if words.length}
    <ul class="word-list">
      {#each words as w}<li>{w.word}: {w.count}</li>{/each}
    </ul>
  {/if}
</section>

<style>
  section { margin: 1.5rem 0; }
  h3 { margin-bottom: 0.5rem; font-size: 1rem; color: var(--text-h); }
  table { border-collapse: collapse; width: 100%; }
  th, td { padding: 0.4rem 0.7rem; border-bottom: 1px solid var(--border); text-align: left; }
  th { background: var(--code-bg); }
  .row { display: flex; gap: 0.5rem; align-items: center; }
  input[type=text], select { padding: 0.35rem 0.6rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); }
  button { padding: 0.35rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .btn-danger { color: #c0392b; border-color: #c0392b; }
  .status { color: #27ae60; font-weight: 500; }
  .word-list { column-count: 3; margin-top: 0.5rem; font-size: 0.85rem; }
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.4rem; vertical-align: middle; }
</style>
