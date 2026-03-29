<script>
  import { onMount } from 'svelte';

  let { buckets } = $props();

  let items = $state([]);
  let total = $state(0);
  let page  = $state(1);
  let search = $state('');
  let loading = $state(false);

  let selected = $state(null);
  let highlight = $state(true);
  let detailLoading = $state(false);

  const PAGE_SIZE = 25;

  async function load() {
    loading = true;
    const params = new URLSearchParams({ page, per_page: PAGE_SIZE, search });
    const res = await fetch('/api/v1/history?' + params);
    if (res.ok) {
      const data = await res.json();
      items = data.items;
      total = data.total;
    }
    loading = false;
  }

  async function select(slot) {
    if (selected?.slot === slot) {
      selected = null;
      return;
    }
    detailLoading = true;
    selected = { slot };
    const res = await fetch(`/api/v1/history/${slot}`);
    if (res.ok) {
      const data = await res.json();
      selected = { slot, body: data.body, word_colors: data.word_colors };
    }
    detailLoading = false;
  }

  async function reclassify(slot, bucket) {
    await fetch(`/api/v1/history/${slot}/reclassify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucket }),
    });
    load();
  }

  function formatDate(ts) {
    if (!ts) return '—';
    return new Date(ts * 1000).toLocaleString(undefined, {
      year: 'numeric', month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit',
    });
  }

  function renderBody(body, word_colors) {
    if (!body) return '';
    const colors = highlight ? word_colors : {};
    return body
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/(\w+)/g, (match) => {
        const color = colors[match.toLowerCase()];
        return color
          ? `<mark style="background:${color}66;color:inherit;border-radius:2px;padding:0 1px">${match}</mark>`
          : match;
      });
  }

  onMount(() => {
    load();
    const interval = setInterval(() => {
      if (page === 1 && !search) load();
    }, 10000);
    return () => clearInterval(interval);
  });
  $effect(() => { page; search; load(); });
</script>

<div class="page">

<h2>History</h2>

<div class="toolbar">
  <input
    type="search"
    placeholder="Search…"
    bind:value={search}
    oninput={() => { page = 1; }}
  />
  <span>{total} messages</span>
</div>

{#if loading}
  <p>Loading…</p>
{:else}
  <table>
    <thead>
      <tr>
        <th></th><th>Date</th><th>From</th><th>Subject</th><th>Bucket</th><th>Reclassify</th>
      </tr>
    </thead>
    <tbody>
      {#each items as item (item.slot)}
        <tr
          class="row"
          class:active={selected?.slot === item.slot}
          onclick={() => select(item.slot)}
        >
          <td class="expander">{selected?.slot === item.slot ? '▾' : '▸'}</td>
          <td class="date">{formatDate(item.date)}</td>
          <td class="trunc">{item.from}</td>
          <td class="trunc">{item.subject}</td>
          <td>
            <span class="bucket-badge">
              <span class="dot" style="background:{item.color}"></span>{item.bucket}
            </span>
          </td>
          <td onclick={e => e.stopPropagation()}>
            <select onchange={e => reclassify(item.slot, e.target.value)}>
              <option value="">— move to —</option>
              {#each buckets as b}
                <option value={b.name} selected={b.name === item.bucket}>{b.name}</option>
              {/each}
            </select>
          </td>
        </tr>
        {#if selected?.slot === item.slot}
          <tr class="detail-row">
            <td colspan="6">
              {#if detailLoading}
                <p class="detail-msg">Loading…</p>
              {:else if selected.body !== undefined}
                <div class="detail">
                  <label class="toggle">
                    <input type="checkbox" bind:checked={highlight} />
                    Highlight words by bucket
                  </label>
                  <div class="body">{@html renderBody(selected.body, selected.word_colors)}</div>
                </div>
              {/if}
            </td>
          </tr>
        {/if}
      {/each}
    </tbody>
  </table>

  <div class="pagination">
    <button disabled={page <= 1} onclick={() => page--}>← Prev</button>
    <span>Page {page} / {Math.ceil(total / PAGE_SIZE)}</span>
    <button disabled={page * PAGE_SIZE >= total} onclick={() => page++}>Next →</button>
  </div>
{/if}

</div>

<style>
  .page { padding: 1.75rem 2rem; max-width: 960px; }
  .toolbar { display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem; }
  input[type=search] { padding: 0.4rem 0.6rem; border: 1px solid var(--border); border-radius: 4px; width: 280px; background: var(--bg); color: var(--text); }
  table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
  th, td { padding: 0.4rem 0.6rem; border-bottom: 1px solid var(--border); text-align: left; }
  .trunc { max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .date { white-space: nowrap; font-size: 0.85rem; color: var(--text-muted); }
  .bucket-badge { font-weight: 500; display: inline-flex; align-items: center; }
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.4rem; flex-shrink: 0; }
  .pagination { display: flex; align-items: center; gap: 1rem; margin-top: 1rem; }
  button { padding: 0.3rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  button:disabled { opacity: 0.4; cursor: default; }
  .expander { width: 1rem; color: var(--text-muted); font-size: 0.7rem; padding-right: 0; }
  .row { cursor: pointer; }
  .row:hover { background: var(--surface); }
  .row.active { background: var(--surface); }
  .detail-row > td { padding: 0; border-bottom: 2px solid var(--border); }
  .detail { padding: 0.75rem 1rem; }
  .detail-msg { padding: 0.5rem 0; color: var(--text-muted); margin: 0; font-size: 0.9rem; }
  .toggle { display: inline-flex; align-items: center; gap: 0.4rem; font-size: 0.85rem; margin-bottom: 0.6rem; cursor: pointer; user-select: none; color: var(--text-muted); }
  .body { font-family: monospace; font-size: 0.85rem; white-space: pre-wrap; word-break: break-word; background: var(--bg); border: 1px solid var(--border); border-radius: 4px; padding: 0.75rem; max-height: 400px; overflow-y: auto; }
</style>
