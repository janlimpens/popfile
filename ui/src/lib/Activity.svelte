<script>
  import { onMount, onDestroy } from 'svelte';
  import { t } from './locale.svelte.js';

  let activeTab = $state('live');
  let events = $state([]);
  let logLines = $state([]);
  let logFile = $state('');
  let logError = $state('');
  let eventSource = $state(null);
  let scrolledToBottom = $state(true);
  let logScrolledToBottom = $state(true);
  let containerEl = $state(null);
  let logContainerEl = $state(null);
  let levelFilter = $state({ info: true, warn: true, error: true });
  let paused = $state(false);

  const TABS = [
    ['live', 'Live Activity'],
    ['logs', 'Log Files'],
  ];

  async function loadInitialEvents() {
    const res = await fetch('/api/v1/activity?since=0');
    if (res.ok) events = await res.json();
  }

  function connectSSE() {
    const es = new EventSource('/api/v1/activity/stream');
    es.addEventListener('activity', (msg) => {
      const event = JSON.parse(msg.data);
      if (paused) return;
      events = [...events, event];
      if (events.length > 1000) events = events.slice(-500);
    });
    es.onerror = () => {};
    eventSource = es;
  }

  async function loadLogs() {
    try {
      const res = await fetch('/api/v1/logs/tail?lines=200');
      if (!res.ok) { logError = 'Cannot load logs'; return }
      const data = await res.json();
      logLines = data.lines || [];
      logFile = data.file || '';
      logError = '';
    } catch(e) { logError = 'Cannot load logs' }
  }

  function downloadLogs() {
    window.open('/api/v1/logs/download', '_blank');
  }

  function checkScroll() {
    if (!containerEl) return;
    const { scrollTop, scrollHeight, clientHeight } = containerEl;
    scrolledToBottom = scrollHeight - scrollTop - clientHeight < 80;
  }

  function checkLogScroll() {
    if (!logContainerEl) return;
    const { scrollTop, scrollHeight, clientHeight } = logContainerEl;
    logScrolledToBottom = scrollHeight - scrollTop - clientHeight < 80;
  }

  function scrollToBottom() {
    if (containerEl) containerEl.scrollTop = containerEl.scrollHeight;
    scrolledToBottom = true;
  }

  function scrollLogToBottom() {
    if (logContainerEl) logContainerEl.scrollTop = logContainerEl.scrollHeight;
    logScrolledToBottom = true;
  }

  $effect(() => {
    if (scrolledToBottom && containerEl && events.length) {
      containerEl.scrollTop = containerEl.scrollHeight;
    }
  });

  let logTimer;
  onMount(() => {
    loadInitialEvents();
    connectSSE();
    loadLogs();
    logTimer = setInterval(loadLogs, 3000);
    return () => {
      if (eventSource) eventSource.close();
      clearInterval(logTimer);
    };
  });

  function levelClass(level) {
    return level === 'error' ? 'evt-error' : level === 'warn' ? 'evt-warn' : 'evt-info';
  }

  function formatTime(ts) {
    const d = new Date(ts * 1000);
    return d.toLocaleTimeString();
  }

  function indentFor(event) {
    if (!event.parent_id) return 0;
    let depth = 1;
    let current = event;
    for (let i = 0; i < 20; i++) {
      const parent = events.find(e => e.id === current.parent_id);
      if (!parent || !parent.parent_id) return depth;
      depth++;
      current = parent;
    }
    return depth;
  }

  function getFiltered() {
    return events.filter(e => levelFilter[e.level]);
  }
</script>

<div class="page">
  <div class="page-header">
    <h2>Activity</h2>
    <div class="tab-bar">
      {#each TABS as [key, label]}
        <button class="tab" class:active={activeTab === key} onclick={() => activeTab = key}>
          {label}
        </button>
      {/each}
    </div>
  </div>

  <div class="tab-content" class:hidden={activeTab !== 'live'}>
    <div class="toolbar">
      <label class="filter-toggle"><input type="checkbox" bind:checked={levelFilter.info} /> Info</label>
      <label class="filter-toggle"><input type="checkbox" bind:checked={levelFilter.warn} /> Warn</label>
      <label class="filter-toggle"><input type="checkbox" bind:checked={levelFilter.error} /> Error</label>
      <div class="spacer"></div>
      <label class="filter-toggle"><input type="checkbox" bind:checked={paused} /> Pause</label>
      <button class="btn-sm" onclick={() => events = []}>Clear</button>
    </div>

    <div class="stream" bind:this={containerEl} onscroll={checkScroll}>
      {#each getFiltered() as evt (evt.id)}
        {@const depth = indentFor(evt)}
        <div class="evt-row {levelClass(evt.level)}" style="padding-left: {0.5 + depth * 1.25}rem">
          <span class="evt-time">{formatTime(evt.ts)}</span>
          <span class="evt-task">{evt.task}</span>
          <span class="evt-msg">{evt.message}</span>
        </div>
      {/each}
      {#if getFiltered().length === 0}
        <div class="empty">No activity yet. Waiting for events…</div>
      {/if}
    </div>

    {#if !scrolledToBottom}
      <button class="jump-btn" onclick={scrollToBottom} title="Jump to latest">
        <span class="icon">arrow_downward</span>
      </button>
    {/if}
  </div>
  <div class="tab-content" class:hidden={activeTab !== 'logs'}>
    <div class="toolbar">
      <span class="log-file">{logFile || 'popfile.log'}</span>
      <div class="spacer"></div>
      <button class="btn-sm" onclick={loadLogs}>Refresh</button>
      <button class="btn-sm" onclick={downloadLogs}>Download</button>
    </div>

    {#if logError}
      <div class="log-error">{logError}</div>
    {/if}

    <div class="stream log-stream" bind:this={logContainerEl} onscroll={checkLogScroll}>
      {#each logLines as line, i (i)}
        <div class="log-row"><span class="log-num">{i + 1}</span><span class="log-line">{line}</span></div>
      {/each}
      {#if logLines.length === 0}
        <div class="empty">No log entries</div>
      {/if}
    </div>

    {#if !logScrolledToBottom}
      <button class="jump-btn" onclick={scrollLogToBottom} title="Jump to latest">
        <span class="icon">arrow_downward</span>
      </button>
    {/if}
  </div>
</div>

<style>
  .page {
    display: flex;
    flex-direction: column;
    height: calc(100vh - 48px);
    padding: 0;
  }

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1rem 1.5rem 0;
  }
  .page-header h2 { margin: 0; font-size: 1.1rem; }

  .tab-bar {
    display: flex;
    gap: 0;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 7px;
    overflow: hidden;
  }
  .tab {
    padding: 0.4rem 1rem;
    background: none;
    border: none;
    color: var(--text-muted);
    font-size: 0.85rem;
    cursor: pointer;
    transition: background .15s, color .15s;
  }
  .tab.active { background: var(--accent); color: var(--accent-fg); }
  .tab-content.hidden { display: none; }
  .tab:not(.active):hover { background: var(--surface-hover); }

  .toolbar {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.6rem 1.5rem;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
  }
  .filter-toggle {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.8rem;
    color: var(--text-muted);
    cursor: pointer;
  }
  .filter-toggle input { accent-color: var(--accent); }
  .spacer { flex: 1; }
  .log-file { font-size: 0.8rem; color: var(--text-muted); font-family: monospace; }
  .log-error { padding: 0.5rem 1.5rem; color: var(--danger); font-size: 0.85rem; }

  .stream {
    flex: 1;
    overflow-y: auto;
    padding: 0.25rem 0;
    font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
    font-size: 0.8rem;
    line-height: 1.6;
    position: relative;
  }

  .evt-row {
    display: flex;
    gap: 0.75rem;
    padding: 0.15rem 1.5rem;
    border-left: 3px solid transparent;
    transition: background .1s;
  }
  .evt-row:hover { background: var(--surface-hover); }
  .evt-info { border-left-color: var(--accent); color: var(--text); }
  .evt-warn { border-left-color: #f5a623; color: var(--text); background: rgba(245,166,35,.04); }
  .evt-error { border-left-color: var(--danger); color: var(--text); background: rgba(247,118,142,.06); }

  .evt-time { color: var(--text-muted); flex-shrink: 0; min-width: 5rem; }
  .evt-task { color: var(--accent); font-weight: 600; flex-shrink: 0; min-width: 8rem; }
  .evt-msg { color: var(--text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

  .log-stream { font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace; }
  .log-row {
    display: flex;
    gap: 0.75rem;
    padding: 0 1.5rem;
    line-height: 1.55;
  }
  .log-row:hover { background: var(--surface-hover); }
  .log-num { color: var(--text-muted); flex-shrink: 0; min-width: 3rem; text-align: right; user-select: none; }
  .log-line { color: var(--text); white-space: pre; overflow: hidden; text-overflow: ellipsis; }

  .empty {
    padding: 3rem 1.5rem;
    text-align: center;
    color: var(--text-muted);
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 0.9rem;
  }

  .jump-btn {
    position: absolute;
    bottom: 1rem;
    right: 1.5rem;
    width: 2.5rem;
    height: 2.5rem;
    border-radius: 50%;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--text);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 8px rgba(0,0,0,.25);
    z-index: 10;
    transition: background .15s;
  }
  .jump-btn:hover { background: var(--surface-hover); }
  .jump-btn .icon { font-size: 1.2rem; }

  .btn-sm {
    padding: 0.25rem 0.75rem;
    background: var(--accent);
    color: var(--accent-fg);
    border: none;
    border-radius: 5px;
    font-size: 0.8rem;
    cursor: pointer;
    transition: opacity .15s;
  }
  .btn-sm:hover { opacity: .85; }
</style>
