<script>
  import { onMount } from 'svelte';

  let { buckets } = $props();

  let items = $state([]);
  let total = $state(0);
  let page  = $state(1);
  let search = $state('');
  let loading = $state(false);
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

  async function reclassify(slot, bucket) {
    await fetch(`/api/v1/history/${slot}/reclassify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucket }),
    });
    load();
  }

  onMount(load);
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
        <th>Date</th><th>From</th><th>Subject</th><th>Bucket</th><th>Reclassify</th>
      </tr>
    </thead>
    <tbody>
      {#each items as item (item.slot)}
        <tr>
          <td>{item.date}</td>
          <td class="trunc">{item.from}</td>
          <td class="trunc">{item.subject}</td>
          <td>
            <span class="bucket-badge">
              <span class="dot" style="background:{item.color}"></span>{item.bucket}
            </span>
          </td>
          <td>
            <select onchange={e => reclassify(item.slot, e.target.value)}>
              <option value="">— move to —</option>
              {#each buckets as b}
                <option value={b.name} selected={b.name === item.bucket}>{b.name}</option>
              {/each}
            </select>
          </td>
        </tr>
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
  th { background: var(--code-bg); font-weight: 600; }
  .trunc { max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .bucket-badge { font-weight: 500; display: inline-flex; align-items: center; }
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.4rem; flex-shrink: 0; }
  .pagination { display: flex; align-items: center; gap: 1rem; margin-top: 1rem; }
  button { padding: 0.3rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  button:disabled { opacity: 0.4; cursor: default; }
</style>
