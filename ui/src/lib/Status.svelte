<script>
  import { onMount } from 'svelte';

  let checks = $state([]);
  let loading = $state(false);
  let error = $state('');

  async function load() {
    loading = true;
    error = '';
    const res = await fetch('/api/v1/status');
    loading = false;
    if (res.ok) {
      const data = await res.json();
      checks = data.checks ?? [];
    } else {
      error = 'Failed to load status';
    }
  }

  onMount(load);
</script>

<div class="page">
  <div class="page-header">
    <div>
      <h2>Status</h2>
      <p>Health checks for POPFile services.</p>
    </div>
    <button class="btn" onclick={load} disabled={loading}>
      {loading ? 'Checking…' : 'Refresh'}
    </button>
  </div>

  {#if error}
    <p class="msg-err">{error}</p>
  {/if}

  <section class="card">
    <h3>IMAP</h3>
    {#if loading && checks.length === 0}
      <p class="hint">Checking…</p>
    {:else if checks.length === 0}
      <p class="hint">No checks available.</p>
    {:else}
      <ul class="check-list">
        {#each checks as check (check.id)}
          <li class="check-row">
            <span class="indicator {check.status}" title={check.status}></span>
            <div class="check-body">
              <span class="check-label">{check.label}</span>
              <span class="check-detail">{check.detail}</span>
            </div>
            <span class="badge {check.status}">{check.status}</span>
          </li>
        {/each}
      </ul>
    {/if}
  </section>
</div>

<style>
  .page {
    padding: 1.75rem 2rem;
    max-width: 760px;
  }

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
    margin-bottom: 1.75rem;
  }
  .page-header h2 { margin: 0 0 0.25rem; }
  .page-header p { margin: 0; font-size: 0.875rem; }

  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 1.25rem 1.5rem;
    margin-bottom: 1.25rem;
  }
  .card h3 { margin: 0 0 1rem; font-size: 1rem; font-weight: 600; }
  .hint { font-size: 0.85rem; color: var(--text-muted); }
  .msg-err { color: var(--danger); font-size: 0.875rem; }

  .check-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.6rem;
  }

  .check-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.6rem 0.75rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 7px;
  }

  .indicator {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
  }
  .indicator.ok    { background: var(--success); }
  .indicator.warn  { background: #f5a623; }
  .indicator.error { background: var(--danger); }

  .check-body {
    display: flex;
    flex-direction: column;
    gap: 0.1rem;
    flex: 1;
  }
  .check-label { font-size: 0.875rem; font-weight: 500; color: var(--text); }
  .check-detail { font-size: 0.8rem; color: var(--text-muted); }

  .badge {
    font-size: 0.72rem;
    font-weight: 600;
    text-transform: uppercase;
    padding: 0.15rem 0.45rem;
    border-radius: 4px;
    flex-shrink: 0;
  }
  .badge.ok    { background: rgba(158,206,106,.15); color: var(--success); }
  .badge.warn  { background: rgba(245,166,35,.15);  color: #f5a623; }
  .badge.error { background: rgba(247,118,142,.15); color: var(--danger); }

  .btn {
    padding: 0.4rem 1rem;
    background: var(--accent);
    color: var(--accent-fg);
    border: none;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: opacity .15s;
    white-space: nowrap;
  }
  .btn:disabled { opacity: .4; cursor: default; }
  .btn:not(:disabled):hover { opacity: .85; }
</style>
