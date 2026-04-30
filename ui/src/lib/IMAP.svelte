<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';

  let { buckets = [] } = $props();
  let loadedBuckets = $state([]);
  let allBuckets = $derived(loadedBuckets.length ? loadedBuckets : buckets);

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
  let testStatus = $state(null);
  let testing = $state(false);
  let saveAnyway = $state(false);
  let showAdvanced = $state(false);
  let wizardOpen = $state(false);
  let wizardFolders = $state([]);
  let wizardLoading = $state(false);
  let wizardSelected = $state(new Set());
  let wizardStep = $state(1);
  let wizardDone = $state([]);  // [{folder, bucket}]

  function folderToBucket(f) {
    // Decode IMAP modified UTF-7 patterns
    let name = f.replace(/^INBOX\./, '')
      .replace(/&APY-/g, 'ö').replace(/&APw-/g, 'ü')
      .replace(/&AOQ-/g, 'ä').replace(/&AN8-/g, 'ß')
      .replace(/&AME-/g, 'é').replace(/&APE-/g, 'è')
      .replace(/&AMg-/g, 'ê').replace(/&AMQ-/g, 'ë')
      .replace(/&AMk-/g, 'í').replace(/&AM0-/g, 'ó')
      .replace(/&APU-/g, 'ú').replace(/&AM8-/g, 'ñ')
      .replace(/&AMM-/g, 'ç')
      .replace(/&[A-Za-z0-9+\/]+-/g, '')  // strip remaining UTF-7
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')  // strip combining accents
      .replace(/[^a-z0-9\s_-]/gi, '').replace(/\s+/g, '').toLowerCase();
    return name || f.replace(/[^a-z0-9]/gi, '').toLowerCase();
  }

  let connectionReady = $derived(
    !!cfg.imap_hostname?.trim() &&
    !!cfg.imap_port &&
    !cfgDirty
  );

  // ── Load ──────────────────────────────────────────────────────────────
  async function load() {
    const [cfgRes, folRes, bucketRes] = await Promise.all([
      fetch('/api/v1/config'),
      fetch('/api/v1/imap/folders'),
      fetch('/api/v1/buckets'),
    ]);
    if (cfgRes.ok) cfg = await cfgRes.json();
    if (folRes.ok) {
      const data = await folRes.json();
      watched  = data.watched  ?? [];
      mappings = data.mappings ?? [];
    }
    if (bucketRes.ok) loadedBuckets = await bucketRes.json();
    if (cfg.imap_hostname && cfg.imap_port) fetchServerFolders();
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

  let trainStatus = $state('');
  async function triggerTrain(allBuckets) {
    const body = allBuckets.length ? { buckets: allBuckets } : { all: true };
    const res = await fetch('/api/v1/imap/train', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    trainStatus = res.ok ? t('Imap_TrainQueued') : t('Error');
    setTimeout(() => trainStatus = '', 4000);
  }

  async function fetchServerFolders() {
    fetchingFolders = true;
    fetchError = '';
    const res = await fetch('/api/v1/imap/server-folders');
    fetchingFolders = false;
    if (res.ok) {
      serverFolders = await res.json();
    } else {
      fetchError = t('Imap_NoConnectionMessage');
    }
  }

  async function testConnection() {
    testing = true;
    testStatus = null;
    const res = await fetch('/api/v1/imap/test-connection', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        hostname: cfg.imap_hostname,
        port: cfg.imap_port,
        login: cfg.imap_login,
        password: cfg.imap_password,
        use_ssl: cfg.imap_use_ssl ?? 0,
      }),
    });
    testing = false;
    testStatus = await res.json();
  }

  function markCfg() { cfgDirty = true; cfgStatus = ''; testStatus = null; saveAnyway = false; }

  function onPortInput() {
    markCfg();
    if (cfg.imap_port == 993) cfg.imap_use_ssl = 1;
    else if (cfg.imap_port == 143) cfg.imap_use_ssl = 0;
  }

  function onSslChange(e) {
    cfg.imap_use_ssl = e.target.checked ? 1 : 0;
    if (cfg.imap_use_ssl && (!cfg.imap_port || cfg.imap_port == 143))
      cfg.imap_port = 993;
    else if (!cfg.imap_use_ssl && (!cfg.imap_port || cfg.imap_port == 993))
      cfg.imap_port = 143;
    markCfg();
  }

  async function runWizard() {
    wizardStep = 1;
    wizardSelected = new Set();
    wizardDone = [];
    wizardOpen = true;
    wizardLoading = true;
    const res = await fetch('/api/v1/imap/server-folders');
    wizardLoading = false;
    if (!res.ok) { wizardOpen = false; return }
    const allFolders = await res.json();
    const defaults = new Set(['INBOX', 'Trash', 'Sent', 'Drafts', 'Junk', 'Archive', 'Templates',
      'Papierkorb', 'Gesendet', 'Entwürfe', 'Spam', 'Vorlagen',
      'Entw&APw-rfe', 'Spam PF', 'unclassified']);
    wizardFolders = allFolders.filter(f => !defaults.has(f) && !f.startsWith('INBOX/'));
  }

  function toggleWizard(f) {
    const s = new Set(wizardSelected);
    s.has(f) ? s.delete(f) : s.add(f);
    wizardSelected = s;
  }

  function toggleAllWizard() {
    wizardSelected = wizardSelected.size === wizardFolders.length
      ? new Set() : new Set(wizardFolders);
  }

  async function confirmWizard() {
    const selected = [...wizardSelected];
    wizardDone = [];
    for (const folder of selected) {
      const bucket = folderToBucket(folder);
      if (!allBuckets.find(b => b.name === bucket)) {
        await fetch('/api/v1/buckets', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: bucket }),
        });
      }
      if (!mappings.find(m => m.folder === folder)) {
        mappings = [...mappings.filter(m => m.bucket !== bucket), { bucket, folder }];
      }
      wizardDone = [...wizardDone, { folder, bucket }];
    }
    foldersDirty = true;
    await load();  // reload buckets + mappings
    wizardStep = 2;
  }

  async function trainWizardFolders() {
    const names = wizardDone.map(d => d.bucket);
    await fetch('/api/v1/imap/train', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ buckets: names }),
    });
    wizardOpen = false;
  }

  onMount(load);
</script>

<div class="page">
  <div class="page-header">
    <div>
      <h2>{t('NavIMAP')}</h2>
      <p>{t('Imap_Description')}</p>
    </div>
  </div>

  <!-- ── Enable toggle ───────────────────────────────────────────────── -->
  <section class="card">
    <div class="fields">
      <div class="field-row">
        <label for="imap_enabled">{t('Settings_EnableService')}</label>
        <input id="imap_enabled" class="switch" type="checkbox"
          checked={cfg.imap_enabled == 1}
          disabled={!connectionReady}
          onchange={(e) => { cfg.imap_enabled = e.target.checked ? 1 : 0; saveCfg(); }}
        />
      </div>
    </div>
  </section>

  <!-- ── Connection settings ──────────────────────────────────────────── -->
  <section class="card">
    <h3>{t('Imap_Connection')}</h3>
    <div class="fields">
      {#each [
        ['imap_hostname',        t('Imap_Server'),   'text'],
        ['imap_login',           t('Imap_Login'),    'text'],
        ['imap_password',        t('Imap_Password'), 'password'],
        ['imap_update_interval', t('Imap_Interval'), 'number'],
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
        <label for="imap_use_ssl">{t('Imap_Use_SSL')}</label>
        <input id="imap_use_ssl" class="switch" type="checkbox"
          checked={cfg.imap_use_ssl == 1}
          onchange={onSslChange}
        />
      </div>

      <div class="field-row">
        <label for="imap_port">{t('Imap_Port')}</label>
        <input id="imap_port" type="number" bind:value={cfg.imap_port} oninput={onPortInput} />
      </div>

      <div class="field-row">
        <label for="imap_expunge">{t('Imap_Expunge')}</label>
        <input id="imap_expunge" class="switch" type="checkbox"
          checked={cfg.imap_expunge == 1}
          onchange={(e) => { cfg.imap_expunge = e.target.checked ? 1 : 0; markCfg(); }}
        />
      </div>
    </div>

    <footer class="card-footer">
      {#if testStatus?.ok}
        <span class="msg-ok"><span class="icon">check</span> {t('Imap_Connected')}</span>
      {:else if testStatus && !testStatus.ok}
        <span class="msg-err"><span class="icon">close</span> {testStatus.error ?? t('Imap_ConnectionFailed')}</span>
        <label class="save-anyway">
          <input type="checkbox" bind:checked={saveAnyway} />
          {t('Imap_SaveAnyway')}
        </label>
      {/if}
      {#if cfgStatus === 'ok'}  <span class="msg-ok"><span class="icon">check</span> {t('Update')}</span>
      {:else if cfgStatus === 'error'}<span class="msg-err"><span class="icon">close</span> Error</span>
      {/if}
      <button class="btn btn-secondary" onclick={testConnection} disabled={testing}>
        {testing ? t('Imap_Testing') : t('Imap_TestConnection')}
      </button>
      <button class="btn" onclick={saveCfg}
        disabled={!cfgDirty || saving || (testStatus != null && !testStatus.ok && !saveAnyway)}>
        {saving ? t('Imap_Saving') : t('Imap_SaveConnection')}
      </button>
    </footer>
  </section>

  <!-- ── Watched folders ──────────────────────────────────────────────── -->
  <section class="card">
    <h3>{t('Imap_WatchedFolders')}</h3>
    <p class="hint">{t('Imap_WatchedHint')}</p>

    <ul class="tag-list">
      {#each watched as f (f)}
        <li>
          <span class="tag">{f}</span>
          <button class="btn-remove" onclick={() => removeWatched(f)} title={t('Remove')}><span class="icon">close</span></button>
        </li>
      {/each}
      {#if watched.length === 0}
        <li class="empty">{t('Imap_NoFoldersWatched')}</li>
      {/if}
    </ul>

    <div class="add-row">
      <input
        type="text"
        placeholder="INBOX.Folder"
        bind:value={newWatch}
        onkeydown={(e) => e.key === 'Enter' && addWatched()}
      />
      <button class="btn" onclick={addWatched} disabled={!newWatch.trim()}>{t('Add')}</button>
    </div>
  </section>

  <!-- ── Bucket → folder mappings ─────────────────────────────────────── -->
  <section class="card">
    <div class="section-header">
      <h3>{t('Imap_BucketFolderMappings')}</h3>
      <button class="btn btn-sm" onclick={fetchServerFolders}
        disabled={!connectionReady || fetchingFolders}>
        {fetchingFolders ? t('Imap_Fetching') : t('Imap_FetchFolders')}
      </button>
      <button class="btn btn-sm" onclick={runWizard}
        disabled={!connectionReady}
        title={t('Imap_Wizard')}>
        <span class="icon">auto_fix_high</span>
      </button>
    </div>
    <p class="hint">{t('Imap_MappingsHint')}</p>
    {#if fetchError}<p class="msg-err">{fetchError}</p>{/if}

    {#if mappings.length > 0}
      <table>
        <thead>
          <tr><th>Bucket</th><th>{t('Imap_IMAFFolder')}</th><th></th></tr>
        </thead>
        <tbody>
          {#each mappings as m (m.bucket)}
            <tr>
              <td>
                <span class="bucket-dot" style="background:{getBucketColor(m.bucket, allBuckets)}"></span>
                {m.bucket}
              </td>
              <td class="folder-cell">
                {m.folder}
                {#if serverFolders.length > 0 && !serverFolders.includes(m.folder)}
                  <span class="warn icon" title="Folder not found on server">warning</span>
                {/if}
              </td>
              <td class="row-actions">
                <button class="btn-train" onclick={() => triggerTrain([m.bucket])}>{t('Imap_Train')}</button>
                <button class="btn-remove" onclick={() => removeMapping(m.bucket)} title={t('Remove')}><span class="icon">close</span></button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    {:else}
      <p class="empty">{t('Imap_NoMappings')}</p>
    {/if}

    {#if mappings.length > 0}
      <div class="train-row">
        <button onclick={() => triggerTrain([])}>{t('Imap_TrainAll')}</button>
        {#if trainStatus}<span class="train-status">{trainStatus}</span>{/if}
      </div>
    {/if}

    <div class="add-row">
      <select bind:value={newMapBucket}>
        <option value="">— bucket —</option>
        {#each allBuckets.filter(b => !b.pseudo && !mappings.some(m => m.bucket === b.name)) as b}
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
        {t('Add')}
      </button>
    </div>

    <footer class="card-footer">
      {#if foldersStatus === 'ok'}  <span class="msg-ok"><span class="icon">check</span> {t('Update')}</span>
      {:else if foldersStatus === 'error'}<span class="msg-err"><span class="icon">close</span> Error</span>
      {/if}
      <button class="btn" onclick={saveFolders} disabled={!foldersDirty || saving}>
        {saving ? t('Imap_Saving') : t('Imap_SaveFolders')}
      </button>
    </footer>
  </section>

  <!-- ── Advanced: training ──────────────────────────────────────────── -->
  <button class="advanced-toggle" onclick={() => showAdvanced = !showAdvanced}>
    <span>{t('Imap_Advanced')}</span>
    <span class="icon">{showAdvanced ? 'expand_less' : 'expand_more'}</span>
  </button>

  {#if showAdvanced}
  <section class="card">
    <div class="fields">
      <div class="field-row">
        <label for="imap_training_mode">{t('Imap_TrainingMode')}</label>
        <input id="imap_training_mode" class="switch" type="checkbox"
          checked={cfg.imap_training_mode == 1}
          onchange={(e) => { cfg.imap_training_mode = e.target.checked ? 1 : 0; saveCfg(); }}
        />
      </div>
      <div class="field-row">
        <label for="imap_training_limit">{t('Imap_TrainingLimit')}</label>
        <input id="imap_training_limit" type="number" min="0"
          bind:value={cfg.imap_training_limit}
          onchange={saveCfg}
        />
      </div>
    </div>
    <p class="hint" style="margin-top:0.75rem">{t('Imap_TrainingHint')}</p>
  </section>
  {/if}

  <!-- ── Wizard modal ───────────────────────────────────────────────── -->
  {#if wizardOpen}
    <div class="modal-overlay" role="dialog" onclick={() => wizardOpen = false} onkeydown={(e) => e.key === 'Escape' && (wizardOpen = false)}></div>
    <div class="modal">
      <h3><span class="icon">auto_fix_high</span> {t('Imap_Wizard')}</h3>
      {#if wizardStep === 1}
        <p>{t('Imap_WizardDesc')}</p>
        {#if wizardLoading}
          <p class="hint">{t('Imap_Fetching')}</p>
        {:else if wizardFolders.length > 0}
          <label class="wizard-toggle-all">
            <input type="checkbox" checked={wizardSelected.size === wizardFolders.length}
              onchange={toggleAllWizard} />
            {wizardSelected.size === wizardFolders.length ? t('Imap_WizardDeselectAll') : t('Imap_WizardSelectAll')}
          </label>
          <ul class="wizard-list">
            {#each wizardFolders as f}
              {@const bucket = folderToBucket(f)}
              <li>
                <label>
                  <input type="checkbox" checked={wizardSelected.has(f)}
                    onchange={() => toggleWizard(f)} />
                  <span class="tag">{f}</span> → <span class="tag bucket-tag">{bucket}</span>
                </label>
              </li>
            {/each}
          </ul>
        {:else}
          <p class="hint">{t('Imap_WizardEmpty')}</p>
        {/if}
        <footer class="card-footer">
          <button class="btn btn-secondary" onclick={() => wizardOpen = false}>{t('Imap_Cancel')}</button>
          <button class="btn" onclick={confirmWizard}
            disabled={wizardLoading || wizardSelected.size === 0}>{t('Imap_WizardApply')}</button>
        </footer>
      {:else}
        <p>{t('Imap_WizardDone', { count: wizardDone.length })}</p>
        <ul class="wizard-list">
          {#each wizardDone as d}
            <li><span class="tag">{d.folder}</span> → <span class="tag bucket-tag">{d.bucket}</span></li>
          {/each}
        </ul>
        <footer class="card-footer">
          <button class="btn btn-secondary" onclick={() => wizardOpen = false}>{t('Imap_WizardClose')}</button>
          <button class="btn" onclick={trainWizardFolders}>{t('Imap_WizardTrain')}</button>
        </footer>
      {/if}
    </div>
  {/if}

</div>

<script module>
  function getBucketColor(name, allBuckets) {
    const b = allBuckets.find(b => b.name === name);
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

  /* ── Advanced toggle ── */
  .advanced-toggle {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.5rem 0;
    margin: 1rem 0 0.5rem;
    background: none;
    border: none;
    color: var(--text-muted);
    font-size: 0.82rem;
    cursor: pointer;
    transition: color 0.15s;
  }
  .advanced-toggle:hover { color: var(--text); }

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
  .field-row label:not(.toggle) {
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
  .btn-train { font-size: 0.78rem; padding: 0.15rem 0.5rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .btn-train:hover { border-color: var(--accent); color: var(--accent); }
  .row-actions { display: flex; gap: 0.4rem; align-items: center; }
  .train-row { display: flex; gap: 0.75rem; align-items: center; margin-top: 0.5rem; }
  .train-status { font-size: 0.85rem; color: var(--success); }

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
  .btn-secondary {
    background: var(--bg);
    color: var(--text);
    border: 1px solid var(--border);
  }
  .btn-secondary:not(:disabled):hover { opacity: .75; }
  .save-anyway {
    display: flex;
    align-items: center;
    gap: 0.35rem;
    font-size: 0.82rem;
    color: var(--text-muted);
    cursor: pointer;
  }

  /* ── Wizard modal ── */
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
  .wizard-list { list-style: none; margin: 0 0 1rem; padding: 0; display: flex; flex-direction: column; gap: 0.4rem; }
  .wizard-list li { display: flex; align-items: center; gap: 0.4rem; font-size: 0.85rem; }
  .bucket-tag { background: var(--accent-subtle); color: var(--accent); }
  .card-footer { display: flex; gap: 0.75rem; justify-content: flex-end; margin-top: 1rem; padding-top: 1rem; border-top: 1px solid var(--border); }
</style>
