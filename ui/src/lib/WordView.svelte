<script>
  import { untrack } from 'svelte';
  import { t } from './locale.svelte.js';

  let { buckets = [], initialBucket = '' } = $props();

  let selectedBucket = $state('');
  let words = $state([]);
  let total = $state(0);
  let page = $state(1);
  let perPage = $state(50);
  let sortBy = $state('relevance');
  let sortDir = $state('desc');
  let loading = $state(false);
  let status = $state('');

  async function loadWords() {
    if (!selectedBucket) return;
    loading = true;
    status = '';
    const res = await fetch(
      `/api/v1/corpus/${encodeURIComponent(selectedBucket)}/words?page=${page}&per_page=${perPage}&sort=${sortBy}&dir=${sortDir}`
    );
    if (res.ok) {
      const data = await res.json();
      words = data.words ?? [];
      total = data.total ?? 0;
    }
    loading = false;
  }

  $effect(() => {
    const bucket = initialBucket;
    untrack(() => {
      selectedBucket = bucket;
      page = 1;
      words = [];
      total = 0;
      if (bucket) loadWords();
    });
  });

  function onBucketChange() {
    page = 1;
    words = [];
    total = 0;
    loadWords();
  }

  function toggleSort(col, defaultDir = 'desc') {
    if (sortBy === col) {
      sortDir = sortDir === 'asc' ? 'desc' : 'asc';
    } else {
      sortBy = col;
      sortDir = defaultDir;
    }
    page = 1;
    loadWords();
  }

  function totalPages() {
    return Math.max(1, Math.ceil(total / perPage));
  }

  async function gotoPage(p) {
    page = p;
    await loadWords();
  }

  async function removeWord(word) {
    if (!confirm(`Remove "${word}" from "${selectedBucket}"?`)) return;
    const res = await fetch(
      `/api/v1/corpus/${encodeURIComponent(selectedBucket)}/word/${encodeURIComponent(word)}`,
      { method: 'DELETE' }
    );
    status = res.ok ? `Removed "${word}"` : 'Error';
    if (res.ok) loadWords();
  }

  async function moveWord(word, to) {
    if (!to) return;
    const res = await fetch(
      `/api/v1/corpus/${encodeURIComponent(selectedBucket)}/word/${encodeURIComponent(word)}/move`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ to }),
      }
    );
    status = res.ok ? `Moved "${word}" to "${to}"` : 'Error';
    if (res.ok) loadWords();
  }

  let moveTo = $state({});
</script>

<div class="page">

<h2>{t('WordView_Title')}</h2>

{#if status}
  <p class="status">{status}</p>
{/if}

<div class="toolbar">
  <select bind:value={selectedBucket} onchange={onBucketChange}>
    <option value="">— {t('WordView_SelectBucket')} —</option>
    {#each buckets.filter(b => !b.pseudo) as b}
      <option value={b.name}>{b.name}</option>
    {/each}
  </select>
  <span class="total-label">{#if selectedBucket && !loading}{total} {t('WordView_Words')}{/if}</span>
</div>

{#if loading}
  <p class="desc">{t('WordView_Loading')}</p>
{:else if selectedBucket && total === 0}
  <p class="desc">{t('WordView_Empty')}</p>
{:else if words.length}
  <table>
    <thead>
      <tr>
        <th class="sortable" class:sort-active={sortBy === 'word'} title={t('WordView_ColWord')} onclick={() => toggleSort('word', 'asc')}>
          {t('WordView_ColWord')}{sortBy === 'word' ? (sortDir === 'asc' ? ' ↑' : ' ↓') : ''}
        </th>
        <th class="sortable" class:sort-active={sortBy === 'count'} title={t('WordView_TipCount')} onclick={() => toggleSort('count')}>
          {t('WordView_ColCount')}{sortBy === 'count' ? (sortDir === 'asc' ? ' ↑' : ' ↓') : ''}
        </th>
        <th class="sortable" class:sort-active={sortBy === 'total'} title={t('WordView_TipTotal')} onclick={() => toggleSort('total')}>
          {t('WordView_ColTotal')}{sortBy === 'total' ? (sortDir === 'asc' ? ' ↑' : ' ↓') : ''}
        </th>
        <th class="sortable" class:sort-active={sortBy === 'relevance'} title={t('WordView_TipAccuracy')} onclick={() => toggleSort('relevance')}>
          {t('WordView_ColAccuracy')}{sortBy === 'relevance' ? (sortDir === 'asc' ? ' ↑' : ' ↓') : ''}
        </th>
        <th>{t('WordView_ColActions')}</th>
      </tr>
    </thead>
    <tbody>
      {#each words as w (w.word)}
        <tr>
          <td class="word-cell">{w.word}</td>
          <td>{w.count}</td>
          <td>{w.total}</td>
          <td>
            <span class="accuracy" style="--pct:{Math.round(w.accuracy * 100)}%">
              {(w.accuracy * 100).toFixed(1)}%
            </span>
          </td>
          <td class="actions">
            <button class="btn-small btn-danger" onclick={() => removeWord(w.word)}>
              {t('WordView_Remove')}
            </button>
            <select
              bind:value={moveTo[w.word]}
              onchange={() => { moveTo[w.word] = moveTo[w.word]; }}
            >
              <option value="">— {t('WordView_MoveTo')} —</option>
              {#each buckets.filter(b => !b.pseudo && b.name !== selectedBucket) as b}
                <option value={b.name}>{b.name}</option>
              {/each}
            </select>
            <button
              class="btn-small"
              onclick={() => { moveWord(w.word, moveTo[w.word]); moveTo[w.word] = ''; }}
              disabled={!moveTo[w.word]}
            >
              {t('WordView_Move')}
            </button>
          </td>
        </tr>
      {/each}
    </tbody>
  </table>

  <div class="pagination">
    <button onclick={() => gotoPage(1)} disabled={page <= 1}>«</button>
    <button onclick={() => gotoPage(page - 1)} disabled={page <= 1}>‹</button>
    <span>{page} / {totalPages()}</span>
    <button onclick={() => gotoPage(page + 1)} disabled={page >= totalPages()}>›</button>
    <button onclick={() => gotoPage(totalPages())} disabled={page >= totalPages()}>»</button>
  </div>
{/if}

</div>

<style>
  .page { padding: 1.75rem 2rem; max-width: 900px; }
  .toolbar { display: flex; gap: 1rem; align-items: center; margin-bottom: 1rem; }
  .total-label { font-size: 0.85rem; color: var(--text-muted); }
  .desc { font-size: 0.85rem; color: var(--text-muted); }
  .status { font-weight: 500; color: var(--success); }
  .word-cell { font-family: monospace; font-size: 0.875rem; }
  th.sortable { cursor: pointer; user-select: none; white-space: nowrap; }
  th.sortable:hover { color: var(--accent); }
  th.sort-active { color: var(--accent); }
  .accuracy {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    font-variant-numeric: tabular-nums;
  }
  .accuracy::before {
    content: '';
    display: inline-block;
    width: 50px;
    height: 6px;
    border-radius: 3px;
    background: linear-gradient(to right, var(--accent) var(--pct), var(--border) var(--pct));
  }
  .actions { display: flex; gap: 0.4rem; align-items: center; flex-wrap: nowrap; }
  .btn-small { padding: 0.15rem 0.5rem; font-size: 0.78rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .btn-small:disabled { opacity: 0.4; cursor: default; }
  .btn-danger { color: var(--danger); border-color: var(--danger); }
  .pagination { display: flex; gap: 0.4rem; align-items: center; margin-top: 1rem; }
  .pagination button { padding: 0.25rem 0.6rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .pagination button:disabled { opacity: 0.4; cursor: default; }
  .pagination span { font-size: 0.85rem; color: var(--text-muted); padding: 0 0.25rem; }
</style>
