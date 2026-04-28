<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';

  let query = $state('');
  let sort = $state('word');
  let dir = $state('asc');
  let page = $state(1);
  let perPage = $state(50);
  let words = $state([]);
  let buckets = $state([]);
  let total = $state(0);
  let loading = $state(false);
  let stopwords = $state([]);
  let stopwordsOpen = $state(false);

  const PAGE_SIZES = [25, 50, 100, 200];

  async function search() {
    page = 1;
    await loadWords();
  }

  async function loadWords() {
    loading = true;
    const params = new URLSearchParams({
      q: query,
      sort,
      dir,
      page: String(page),
      per_page: String(perPage),
    });
    const res = await fetch(`/api/v1/words/search?${params}`);
    if (res.ok) {
      const data = await res.json();
      words = data.words ?? [];
      buckets = data.buckets ?? [];
      total = data.total ?? 0;
    }
    loading = false;
  }

  function toggleSort(col) {
    if (sort === col) {
      dir = dir === 'asc' ? 'desc' : 'asc';
    } else {
      sort = col;
      dir = col === 'word' ? 'asc' : 'desc';
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

  async function loadStopwords() {
    const res = await fetch('/api/v1/stopwords');
    if (res.ok) stopwords = await res.json();
  }

  async function addStopword(word) {
    const res = await fetch('/api/v1/stopwords', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ word }),
    });
    if (res.ok) {
      await loadStopwords();
      loadWords();
    }
  }

  async function removeStopword(word) {
    await fetch(`/api/v1/stopwords/${encodeURIComponent(word)}`, { method: 'DELETE' });
    await loadStopwords();
    loadWords();
  }

  function sortIndicator(col) {
    return sort === col ? (dir === 'asc' ? ' ▲' : ' ▼') : '';
  }

  onMount(() => {
    loadStopwords();
  });
</script>

<div class="page">
  <h2>{t('WordSearch_Title')}</h2>

  <div class="search-bar">
    <input
      type="text"
      placeholder={t('WordSearch_Placeholder')}
      bind:value={query}
      onkeydown={e => e.key === 'Enter' && search()}
    />
    <button onclick={search}>{t('WordSearch_Search')}</button>
    <select value={perPage} onchange={e => { perPage = parseInt(e.target.value); search(); }}>
      {#each PAGE_SIZES as n}
        <option value={n}>{n}</option>
      {/each}
    </select>
    {#if total > 0}
      <span class="total-label">{total} {t('WordSearch_Total')}</span>
    {/if}
  </div>

  {#if loading}
    <p class="desc">{t('WordSearch_Loading')}</p>
  {:else if words.length}
    <table>
      <thead>
        <tr>
          <th class="sortable" class:active={sort === 'word'} onclick={() => toggleSort('word')}>
            {t('WordSearch_ColumnWord')}{sortIndicator('word')}
          </th>
          {#each buckets as b}
            <th class="sortable num" class:active={sort === b} onclick={() => toggleSort(b)}>
              {b}{sortIndicator(b)}
            </th>
          {/each}
          <th class="sortable num" class:active={sort === 'coverage'} onclick={() => toggleSort('coverage')}>
            {t('WordSearch_ColumnBuckets')}{sortIndicator('coverage')}
          </th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {#each words as w (w.word)}
          <tr class:stopword-row={w.is_stopword}>
            <td class="word-col">
              {w.word}
              {#if w.is_stopword}
                <span class="tag-stop">{t('WordSearch_IsStopword')}</span>
              {/if}
            </td>
            {#each buckets as b}
              <td class="num">{w.buckets[b] ?? 0}</td>
            {/each}
            <td class="num">{w.coverage}/{buckets.length}</td>
            <td class="actions">
              {#if w.is_stopword}
                <button class="btn-small btn-danger" onclick={() => removeStopword(w.word)}>
                  {t('WordSearch_RemoveStopword')} ✕
                </button>
              {:else}
                <button class="btn-small" onclick={() => addStopword(w.word)}>
                  {t('WordSearch_AddStopword')}
                </button>
              {/if}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>

    {#if totalPages() > 1}
      <div class="pagination">
        <button disabled={page === 1} onclick={() => gotoPage(page - 1)}>{t('Previous')}</button>
        <span>{page} / {totalPages()}</span>
        <button disabled={page === totalPages()} onclick={() => gotoPage(page + 1)}>{t('Next')}</button>
      </div>
    {/if}
  {:else if query}
    <p class="desc">{t('WordSearch_NoResults')}</p>
  {/if}

  <section class="stopword-section">
    <h3>
      <button class="collapsible" onclick={() => stopwordsOpen = !stopwordsOpen}>
        {t('WordSearch_StopwordList')} {stopwordsOpen ? '▲' : '▼'}
      </button>
    </h3>
    {#if stopwordsOpen}
      {#if stopwords.length}
        <div class="tag-list">
          {#each stopwords as sw}
            <span class="tag">
              {sw}
              <button class="tag-remove" onclick={() => removeStopword(sw)}>✕</button>
            </span>
          {/each}
        </div>
      {:else}
        <p class="desc">{t('WordSearch_NoStopwords')}</p>
      {/if}
    {/if}
  </section>
</div>

<style>
  .page { padding: 1.75rem 2rem; max-width: 960px; }
  h2 { margin-bottom: 1rem; }
  .search-bar { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; }
  .search-bar input { padding: 0.35rem 0.6rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); flex: 1; min-width: 10rem; }
  .search-bar select { padding: 0.25rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); }
  .total-label { font-size: 0.85rem; color: var(--text-muted); }
  button { padding: 0.35rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  button:disabled { opacity: 0.4; cursor: default; }
  .btn-small { padding: 0.1rem 0.4rem; font-size: 0.75rem; }
  .btn-danger { color: var(--danger); border-color: var(--danger); }
  table { width: 100%; border-collapse: collapse; font-size: 0.85rem; margin-bottom: 1rem; }
  th { text-align: left; padding: 0.4rem 0.5rem; border-bottom: 1px solid var(--border); color: var(--text-muted); font-weight: 500; }
  td { padding: 0.3rem 0.5rem; border-bottom: 1px solid var(--border, #eee); }
  .sortable { cursor: pointer; user-select: none; white-space: nowrap; }
  .sortable:hover { color: var(--accent); }
  .sortable.active { color: var(--accent); }
  .num { text-align: right; }
  .word-col { font-family: monospace; }
  .actions { text-align: right; white-space: nowrap; }
  .stopword-row td { color: var(--text-muted); }
  .tag-stop { font-size: 0.7rem; background: var(--accent, #666); color: #fff; border-radius: 3px; padding: 0.05rem 0.3rem; margin-left: 0.3rem; }
  .pagination { display: flex; gap: 0.75rem; align-items: center; justify-content: center; margin: 1rem 0; }
  .stopword-section { margin-top: 2rem; border-top: 1px solid var(--border); padding-top: 1rem; }
  h3 { margin: 0 0 0.5rem; }
  .collapsible { background: none; border: none; font-size: 1rem; font-weight: 600; color: var(--text); cursor: pointer; padding: 0; }
  .tag-list { display: flex; flex-wrap: wrap; gap: 0.4rem; margin-top: 0.5rem; }
  .tag { display: flex; align-items: center; gap: 0.25rem; background: var(--border, #ddd); border-radius: 3px; padding: 0.15rem 0.4rem; font-size: 0.8rem; }
  .tag-remove { background: none; border: none; cursor: pointer; padding: 0; font-size: 0.75rem; color: var(--text-muted); line-height: 1; }
  .tag-remove:hover { color: var(--danger); }
  .desc { font-size: 0.85rem; color: var(--text-muted, #888); }
</style>
