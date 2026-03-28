<script>
  import { onMount } from 'svelte';

  let { buckets = [] } = $props();

  // ── Connection config ─────────────────────────────────────────────────
  let cfg     = $state({});
  let watched  = $state([]);    // string[]
  let mappings = $state([]);    // {bucket, folder}[]

  // ── Edit state ────────────────────────────────────────────────────────
  let cfgDirty      = $state(false);
  let foldersDirty  = $state(false);
  let cfgStatus     = $state('');
  let foldersStatus = $state('');
  let newWatch      = $state('');
  let newMapBucket = $state('');
  let newMapFolder = $state('');
  let saving = $state(false);
  let serverFolders = $state([]);
  let fetchingFolders = $state(false);
  let fetchError = $state('');

  let connectionReady = $derived(
    !!cfg.imap_hostname?.trim() &&
    !!cfg.imap_port &&
    !cfgDirty
  );

  // ── Load ──────────────────────────────────────────────────────────────
  async function load() {
    const [cfgRes, folRes] = await Promise.all([
      fetch('/api/v1/config'),
      fetch('/api/v1/imap/folders'),
    ]);
    if (cfgRes.ok) cfg = await cfgRes.json();
    if (folRes.ok) {
      const data = await folRes.json();
      watched  = data.watched  ?? [];
      mappings = data.mappings ?? [];
    }
  }

  // ── Save connection settings ──────────────────────────────────────────
  async function saveCfg() {
    saving = true;
    const res = await fetch('/api/v1/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(cfg),
    });
    saving = false;
    cfgStatus = res.ok ? 'ok' : 'error';
    if (res.ok) { cfgDirty = false; setTimeout(() => cfgStatus = '', 2500); }
  }

  // ── Save folder config ────────────────────────────────────────────────
  async function saveFolders() {
    saving = true;
    const res = await fetch('/api/v1/imap/folders', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ watched, mappings }),
    });
    saving = false;
    foldersStatus = res.ok ? 'ok' : 'error';
    if (res.ok) { foldersDirty = false; setTimeout(() => foldersStatus = '', 2500); }
  }

  // ── Watched folder helpers ────────────────────────────────────────────
  function addWatched() {
    const f = newWatch.trim();
    if (!f || watched.includes(f)) return;
    watched = [...watched, f];
    newWatch = '';
    foldersDirty = true;
  }
  function removeWatched(f) {
    watched = watched.filter(w => w !== f);
    foldersDirty = true;
  }

  // ── Bucket mapping helpers ─────────────────────────────────────────────
  function addMapping() {
    if (!newMapBucket || !newMapFolder.trim()) return;
    mappings = mappings.filter(m => m.bucket !== newMapBucket);
    mappings = [...mappings, { bucket: newMapBucket, folder: newMapFolder.trim() }];
    newMapBucket = '';
    newMapFolder = '';
    foldersDirty = true;
  }
  function removeMapping(bucket) {
    mappings = mappings.filter(m => m.bucket !== bucket);
    foldersDirty = true;
  }

  async function fetchServerFolders() {
    fetchingFolders = true;
    fetchError = '';
    const res = await fetch('/api/v1/imap/server-folders');
    fetchingFolders = false;
    if (res.ok) {
      serverFolders = await res.json();
    } else {
      fetchError = 'Could not connect to server';
    }
  }

  function markCfg() { cfgDirty = true; cfgStatus = ''; }

  onMount(load);
</script>

<div class="page">
  <div class="page-header">
    <div>
      <h2>IMAP Service</h2>
      <p>Monitor IMAP folders and automatically classify incoming messages.</p>
    </div>
  </div>

  <!-- ── Connection settings ──────────────────────────────────────────── -->
  <section class="card">
    <h3>Connection</h3>
    <div class="fields">
      {#each [
        ['imap_hostname',        'Hostname',        'text'],
        ['imap_port',            'Port',            'number'],
        ['imap_login',           'Username',        'text'],
        ['imap_password',        'Password',        'password'],
        ['imap_update_interval', 'Poll Interval (s)','number'],
      ] as [key, label, type]}
        <div class="field-row">
          <label for={key}>{label}</label>
          <input
            id={key}
            {type}
            bind:value={cfg[key]}
            oninput={markCfg}
          />
        </div>
      {/each}

      <div class="field-row">
        <label for="imap_use_ssl">Use SSL / TLS</label>
        <input id="imap_use_ssl" class="switch" type="checkbox"
          checked={cfg.imap_use_ssl == 1}
          onchange={(e) => { cfg.imap_use_ssl = e.target.checked ? 1 : 0; markCfg(); }}
        />
      </div>

      <div class="field-row">
        <label for="imap_expunge">Expunge after move</label>
        <input id="imap_expunge" class="switch" type="checkbox"
          checked={cfg.imap_expunge == 1}
          onchange={(e) => { cfg.imap_expunge = e.target.checked ? 1 : 0; markCfg(); }}
        />
      </div>
    </div>

    <footer class="card-footer">
      {#if cfgStatus === 'ok'}  <span class="msg-ok">✓ Saved</span>
      {:else if cfgStatus === 'error'}<span class="msg-err">✗ Error</span>
      {/if}
      <button class="btn" onclick={saveCfg} disabled={!cfgDirty || saving}>
        {saving ? 'Saving…' : 'Save Connection'}
      </button>
    </footer>
  </section>

  <!-- ── Service settings ─────────────────────────────────────────────── -->
  <section class="card">
    <h3>Service</h3>
    <div class="fields">
      <div class="field-row">
        <label for="imap_enabled">Enable IMAP service</label>
        <input id="imap_enabled" class="switch" type="checkbox"
          checked={cfg.imap_enabled == 1}
          disabled={!connectionReady}
          onchange={(e) => { cfg.imap_enabled = e.target.checked ? 1 : 0; saveCfg(); }}
        />
      </div>
      <div class="field-row">
        <label for="imap_training_mode">Training mode</label>
        <input id="imap_training_mode" class="switch" type="checkbox"
          checked={cfg.imap_training_mode == 1}
          onchange={(e) => { cfg.imap_training_mode = e.target.checked ? 1 : 0; saveCfg(); }}
        />
      </div>
    </div>
    <p class="hint" style="margin-top:0.75rem">
      Training mode scans existing archive folders and trains the classifier on their contents.
      The flag resets automatically when training completes.
    </p>
  </section>

  <!-- ── Watched folders ──────────────────────────────────────────────── -->
  <section class="card">
    <h3>Watched Folders</h3>
    <p class="hint">POPFile monitors these IMAP folders for new messages to classify.</p>

    <ul class="tag-list">
      {#each watched as f (f)}
        <li>
          <span class="tag">{f}</span>
          <button class="btn-remove" onclick={() => removeWatched(f)} title="Remove">×</button>
        </li>
      {/each}
      {#if watched.length === 0}
        <li class="empty">No folders watched yet.</li>
      {/if}
    </ul>

    <div class="add-row">
      <input
        type="text"
        placeholder="INBOX.Folder"
        bind:value={newWatch}
        onkeydown={(e) => e.key === 'Enter' && addWatched()}
      />
      <button class="btn" onclick={addWatched} disabled={!newWatch.trim()}>Add</button>
    </div>
  </section>

  <!-- ── Bucket → folder mappings ─────────────────────────────────────── -->
  <section class="card">
    <div class="section-header">
      <h3>Bucket → Folder Mappings</h3>
      <button class="btn btn-sm" onclick={fetchServerFolders}
        disabled={!connectionReady || fetchingFolders}>
        {fetchingFolders ? 'Fetching…' : 'Fetch Folders'}
      </button>
    </div>
    <p class="hint">
      Classified messages are moved to the specified IMAP folder.
      Leave unmapped buckets empty to skip moving.
    </p>
    {#if fetchError}<p class="msg-err">{fetchError}</p>{/if}

    {#if mappings.length > 0}
      <table>
        <thead>
          <tr><th>Bucket</th><th>IMAP Folder</th><th></th></tr>
        </thead>
        <tbody>
          {#each mappings as m (m.bucket)}
            <tr>
              <td>
                <span class="bucket-dot" style="background:{getBucketColor(m.bucket, buckets)}"></span>
                {m.bucket}
              </td>
              <td class="folder-cell">
                {m.folder}
                {#if serverFolders.length > 0 && !serverFolders.includes(m.folder)}
                  <span class="warn" title="Folder not found on server">⚠</span>
                {/if}
              </td>
              <td>
                <button class="btn-remove" onclick={() => removeMapping(m.bucket)} title="Remove">×</button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    {:else}
      <p class="empty">No mappings defined.</p>
    {/if}

    <div class="add-row">
      <select bind:value={newMapBucket}>
        <option value="">— bucket —</option>
        {#each buckets.filter(b => !b.pseudo) as b}
          <option value={b.name}>{b.name}</option>
        {/each}
      </select>
      <span class="arrow">→</span>
      {#if serverFolders.length > 0}
        <select bind:value={newMapFolder}>
          <option value="">— folder —</option>
          {#each serverFolders as f}
            <option value={f}>{f}</option>
          {/each}
        </select>
      {:else}
        <input
          type="text"
          placeholder="INBOX.Classified"
          bind:value={newMapFolder}
          onkeydown={(e) => e.key === 'Enter' && addMapping()}
        />
      {/if}
      <button class="btn" onclick={addMapping} disabled={!newMapBucket || !newMapFolder.trim()}>
        Add
      </button>
    </div>

    <footer class="card-footer">
      {#if foldersStatus === 'ok'}  <span class="msg-ok">✓ Saved</span>
      {:else if foldersStatus === 'error'}<span class="msg-err">✗ Error</span>
      {/if}
      <button class="btn" onclick={saveFolders} disabled={!foldersDirty || saving}>
        {saving ? 'Saving…' : 'Save Folders'}
      </button>
    </footer>
  </section>

</div>

<script module>
  function getBucketColor(name, buckets) {
    const b = buckets.find(b => b.name === name);
    return b?.color ?? '#888';
  }
</script>

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
  .page-header p  { margin: 0; font-size: 0.875rem; }

  /* ── Cards ── */
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 1.25rem 1.5rem;
    margin-bottom: 1.25rem;
  }
  .card h3 { margin: 0 0 1rem; font-size: 1rem; font-weight: 600; color: var(--text); }
  .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
  .section-header h3 { margin: 0; }
  .btn-sm { padding: 0.25rem 0.65rem; font-size: 0.8rem; }
  .warn { color: var(--danger); margin-left: 0.3rem; font-size: 0.85rem; cursor: default; }
  .hint { margin: -0.5rem 0 1rem; font-size: 0.8rem; color: var(--text-muted); }

  /* ── Field rows (inside cards) ── */
  .fields { display: flex; flex-direction: column; gap: 0.75rem; }
  .field-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }
  .field-row label:not(.toggle), .field-row span {
    font-size: 0.875rem;
    color: var(--text);
    font-weight: 500;
    min-width: 140px;
    cursor: default;
  }
  .field-row input[type="text"],
  .field-row input[type="number"],
  .field-row input[type="password"] {
    width: 220px;
    padding: 0.4rem 0.65rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-size: 0.875rem;
    transition: border-color .15s;
    box-sizing: border-box;
  }
  .field-row input:focus { outline: none; border-color: var(--accent); }

  /* ── Toggle switch ── */
  .switch {
    appearance: none;
    -webkit-appearance: none;
    width: 2.4em;
    height: 1.3em;
    border-radius: 0.65em;
    background: var(--border);
    position: relative;
    cursor: pointer;
    flex-shrink: 0;
    transition: background .2s;
  }
  .switch::before {
    content: '';
    position: absolute;
    width: 0.9em;
    height: 0.9em;
    border-radius: 50%;
    background: #fff;
    top: 0.2em;
    left: 0.2em;
    transition: transform .2s;
    box-shadow: 0 1px 2px rgba(0,0,0,.3);
  }
  .switch:checked { background: var(--accent); }
  .switch:checked::before { transform: translateX(1.1em); }

  /* ── Watched folder tags ── */
  .tag-list {
    list-style: none;
    margin: 0 0 0.75rem;
    padding: 0;
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  .tag-list li { display: flex; align-items: center; gap: 0.3rem; }
  .tag {
    background: var(--accent-subtle);
    color: var(--accent);
    border: 1px solid var(--accent-ring);
    border-radius: 4px;
    padding: 0.2rem 0.55rem;
    font-size: 0.82rem;
    font-weight: 500;
  }
  .empty { font-size: 0.85rem; color: var(--text-muted); font-style: italic; }

  /* ── Add row ── */
  .add-row {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-top: 0.75rem;
  }
  .add-row input {
    flex: 1;
    max-width: 280px;
    padding: 0.4rem 0.65rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-size: 0.875rem;
  }
  .add-row input:focus { outline: none; border-color: var(--accent); }
  .add-row select {
    padding: 0.4rem 0.65rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-size: 0.875rem;
  }
  .arrow { color: var(--text-muted); font-size: 1rem; }

  /* ── Table ── */
  table { margin-bottom: 0.75rem; }
  td { font-size: 0.875rem; color: var(--text); }
  .bucket-dot {
    display: inline-block;
    width: 8px; height: 8px;
    border-radius: 50%;
    margin-right: 0.4rem;
    vertical-align: middle;
  }
  .folder-cell { color: var(--text-muted); font-family: monospace; font-size: 0.82rem; }

  /* ── Buttons ── */
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

  .btn-remove {
    background: none;
    border: none;
    color: var(--text-muted);
    cursor: pointer;
    font-size: 1rem;
    padding: 0 0.2rem;
    line-height: 1;
    border-radius: 3px;
    transition: color .15s, background .15s;
  }
  .btn-remove:hover { color: var(--danger); background: rgba(247,118,142,.12); }

  /* ── Footer ── */
  .card-footer {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-top: 1.25rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border);
  }
  .msg-ok  { font-size: 0.82rem; color: var(--success); font-weight: 500; }
  .msg-err { font-size: 0.82rem; color: var(--danger);  font-weight: 500; }
</style>
