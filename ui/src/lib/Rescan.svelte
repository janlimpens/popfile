<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';

  let folders = $state([]);
  let watched = $state([]);
  let mappings = $state([]);
  let loading = $state(true);
  let limit = $state(100);

  let verifyBusy = $state(false);
  let verifyResult = $state(null);
  let verifySelected = $state(new Set());
  let verifyMoving = $state(false);
  let verifyLoadingFolder = $state('');

  let folderInfo = $derived(
    folders.map(f => {
      let status = [];
      if (watched.includes(f)) status.push({ label: 'Watched', cls: 'tag-green' });
      let mapping = mappings.find(m => m.folder === f);
      if (mapping) status.push({ label: '→ ' + mapping.bucket, cls: 'tag-blue' });
      return { name: f, status };
    })
  );

  async function load() {
    loading = true;
    try {
      let [sfRes, fRes] = await Promise.all([
        fetch('api/v1/imap/server-folders'),
        fetch('api/v1/imap/folders'),
      ]);
      if (sfRes.ok) folders = await sfRes.json();
      if (fRes.ok) {
        let data = await fRes.json();
        watched = data.watched ?? [];
        mappings = data.mappings ?? [];
      }
    } catch (e) {}
    loading = false;
  }

  async function scanFolder(folder) {
    verifyBusy = true;
    verifyResult = null;
    verifyLoadingFolder = folder;
    try {
      let res = await fetch('api/v1/imap/reclassify-preview', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ folder, limit }),
      });
      let ct = res.headers.get('content-type') || '';
      if (!ct.includes('application/json')) {
        verifyResult = { folder, messages: [], note: 'Server error: ' + res.status };
      } else if (!res.ok) {
        let body = await res.json();
        verifyResult = { folder, messages: [], note: body.error || body.message || 'Error ' + res.status };
      } else {
        verifyResult = await res.json();
        verifySelected = new Set();
      }
    } catch (e) {
      verifyResult = { folder, messages: [], note: 'Connection error: ' + e.message };
    }
    verifyBusy = false;
  }

  function toggleVerifyMsg(hash) {
    let s = new Set(verifySelected);
    s.has(hash) ? s.delete(hash) : s.add(hash);
    verifySelected = s;
  }

  function toggleAllVerify() {
    verifySelected = verifySelected.size === verifyResult.messages.length
      ? new Set() : new Set(verifyResult.messages.map(m => m.hash));
  }

  async function moveSelectedMessages() {
    if (verifySelected.size === 0) return;
    verifyMoving = true;
    let moves = verifyResult.messages
      .filter(m => verifySelected.has(m.hash))
      .map(m => ({ hash: m.hash, bucket: m.classified_bucket, mid: m.mid, source_folder: verifyResult.folder }));
    await fetch('api/v1/imap/move-messages', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ moves }),
    });
    verifyMoving = false;
    verifyResult = null;
  }

  onMount(async () => {
    await load();
  });
</script>

<div class="page">
  <div class="page-header">
    <div>
      <h2>{t('Rescan_Title') === 'Rescan_Title' ? 'Rescan' : t('Rescan_Title')}</h2>
      <p>{t('Rescan_Description') === 'Rescan_Description' ? 'Scan IMAP folders and reclassify messages' : t('Rescan_Description')}</p>
    </div>
  </div>

  <div class="limit-row">
    <label for="rescan-limit">Messages per scan</label>
    <input id="rescan-limit" type="number" min="1" max="500" bind:value={limit} />
  </div>

  {#if loading}
    <p class="empty">Loading folders...</p>
  {:else if folders.length === 0}
    <p class="empty">No folders found on server. Check your IMAP connection.</p>
  {:else}
    <table>
      <thead>
        <tr>
          <th>Folder</th>
          <th>Status</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {#each folderInfo as f (f.name)}
          <tr>
            <td class="folder-name">{f.name}</td>
            <td class="status-cell">
              {#each f.status as s}
                <span class="tag {s.cls}">{s.label}</span>
              {/each}
              {#if f.status.length === 0}
                <span class="tag tag-muted">unmapped</span>
              {/if}
            </td>
            <td class="row-actions">
              <button class="btn-scan" onclick={() => scanFolder(f.name)} disabled={verifyBusy} title={t('Rescan_Scan') === 'Rescan_Scan' ? 'Scan' : t('Rescan_Scan')}>
                <span class="icon">refresh</span>
              </button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>

<!-- ── Loading overlay ── -->
{#if verifyBusy && !verifyResult}
  <div class="modal-overlay"></div>
  <div class="modal" style="min-width:280px;max-width:320px;text-align:center">
    <h3>Scanning {verifyLoadingFolder}...</h3>
    <p style="color:var(--text-muted);margin:1rem 0">This may take a while.</p>
    <span class="spinner"></span>
  </div>
{/if}

<!-- ── Results modal ── -->
{#if verifyResult}
  <div class="modal-overlay" role="dialog" tabindex="-1" onclick={() => verifyResult = null} onkeydown={(e) => e.key === 'Escape' && (verifyResult = null)}></div>
  <div class="modal" style="min-width:620px;max-width:90vw;resize:both;overflow:auto">
    <h3><span class="icon">find_in_page</span> {verifyResult.folder}</h3>
    {#if verifyResult.note}
      <p>{verifyResult.note}</p>
      <footer class="card-footer">
        <button class="btn" onclick={() => verifyResult = null}>Close</button>
      </footer>
    {:else if verifyResult.messages.length === 0}
      <p style="color:var(--success)">All messages are in the correct folder.</p>
      <footer class="card-footer">
        <button class="btn" onclick={() => verifyResult = null}>Close</button>
      </footer>
    {:else}
      <p style="margin-bottom:0.5rem">{verifyResult.messages.length} message(s) should be moved elsewhere:</p>
      <div class="verify-grid">
        <div class="verify-header">
          <label>
            <input type="checkbox" checked={verifySelected.size === verifyResult.messages.length}
              onchange={toggleAllVerify} />
          </label>
          <span>Subject</span>
          <span>From</span>
          <span>Classified</span>
        </div>
        {#each verifyResult.messages as m (m.hash)}
          <label class="verify-row">
            <input type="checkbox" checked={verifySelected.has(m.hash)}
              onchange={() => toggleVerifyMsg(m.hash)} />
            <span class="verify-subject" title={m.subject}>{m.subject}</span>
            <span class="verify-from">{m.from}</span>
            <span class="tag tag-blue">{m.classified_bucket}</span>
          </label>
        {/each}
      </div>
      <footer class="card-footer">
        <button class="btn btn-secondary" onclick={() => verifyResult = null}>Cancel</button>
        <button class="btn" onclick={moveSelectedMessages}
          disabled={verifySelected.size === 0 || verifyMoving}>
          {verifyMoving ? 'Moving...' : `Move ${verifySelected.size} selected`}
        </button>
      </footer>
    {/if}
  </div>
{/if}

<style>
  .page {
    max-width: 760px;
  }

  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
    margin-bottom: 1rem;
  }
  .page-header h2 { margin: 0 0 0.25rem; font-size: 1.25rem; font-weight: 600; }
  .page-header p  { margin: 0; font-size: 0.875rem; }

  .limit-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1.25rem;
  }
  .limit-row label { font-size: 0.875rem; color: var(--text-muted); }
  .limit-row input { width: 80px; }

  .empty { font-size: 0.85rem; color: var(--text-muted); font-style: italic; }

  table { margin-bottom: 0.75rem; }
  td { font-size: 0.875rem; color: var(--text); }
  .folder-name { font-family: monospace; font-size: 0.85rem; }
  .status-cell { display: flex; gap: 0.35rem; flex-wrap: wrap; align-items: center; }

  .tag {
    display: inline-block;
    border-radius: 4px;
    padding: 0.15rem 0.5rem;
    font-size: 0.78rem;
    font-weight: 500;
  }
  .tag-green { background: rgba(158,206,106,0.15); color: var(--success); border: 1px solid rgba(158,206,106,0.3); }
  .tag-blue { background: var(--accent-subtle); color: var(--accent); border: 1px solid var(--accent-ring); }
  .tag-muted { background: transparent; color: var(--text-muted); border: 1px solid var(--border); }

  .row-actions { display: flex; gap: 0.4rem; align-items: center; }

  .btn-scan {
    background: none;
    border: none;
    color: var(--text-muted);
    cursor: pointer;
    font-size: 0.9rem;
    padding: 0 0.2rem;
    line-height: 1;
    border-radius: 3px;
    transition: color .15s;
  }
  .btn-scan:hover { color: var(--accent); }
  .btn-scan:disabled { opacity: .4; cursor: default; }

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
  .btn-secondary {
    background: var(--bg);
    color: var(--text);
    border: 1px solid var(--border);
  }

  .card-footer {
    display: flex;
    gap: 0.75rem;
    justify-content: flex-end;
    flex-wrap: wrap;
    align-items: center;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border);
  }

  /* ── Modal ── */
  .modal-overlay {
    position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 200;
  }
  .modal {
    position: fixed; top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    background: var(--surface); border: 1px solid var(--border);
    border-radius: 10px; padding: 1.5rem;
    min-width: 360px; max-width: 480px; z-index: 201;
    box-shadow: 0 8px 32px rgba(0,0,0,.3);
  }
  .modal h3 { display: flex; align-items: center; gap: 0.5rem; margin: 0 0 0.75rem; }

  /* ── Verify grid ── */
  .verify-grid { max-height: 50vh; overflow-y: auto; margin-bottom: 0.75rem; }
  .verify-header {
    display: grid;
    grid-template-columns: 24px 1fr 200px 140px;
    gap: 0.5rem;
    align-items: center;
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--text-muted);
    padding: 0.25rem 0.25rem 0.4rem;
    border-bottom: 1px solid var(--border);
    margin-bottom: 0.25rem;
  }
  .verify-header span { text-transform: uppercase; letter-spacing: 0.03em; }
  .verify-row {
    display: grid;
    grid-template-columns: 24px 1fr 200px 140px;
    gap: 0.5rem;
    align-items: center;
    font-size: 0.8rem;
    padding: 0.35rem 0.25rem;
    cursor: pointer;
    border-radius: 4px;
  }
  .verify-row:hover { background: var(--surface); }
  .verify-subject { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .verify-from { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: var(--text-muted); }

  .spinner {
    display: inline-block;
    width: 2rem;
    height: 2rem;
    border: 3px solid var(--border);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
  }
  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
