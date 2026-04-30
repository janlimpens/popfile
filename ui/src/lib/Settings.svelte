<script>
  import { onMount } from 'svelte';
  import { initLocale, t } from './locale.svelte.js';
  import IMAP from './IMAP.svelte';

  let config = $state({});
  let active = $state('ui');
  let status = $state('');
  let dirty = $state(false);
  let saving = $state(false);
  let settingsSearch = $state('');
  let availableLocales = $state([]);

  // ─── Section / field schema ─────────────────────────────────────────────
  const SECTIONS = $derived([
    {
      id: 'ui', label: t('Settings_SectionUI'), icon: 'settings',
      settings: [
        { key: 'api_port', label: t('Settings_HTTPPort'), type: 'number',
          desc: t('Settings_DescHTTPPort') },
        { key: 'api_page_size', label: t('Settings_ItemsPerPage'), type: 'number',
          desc: t('Settings_DescItemsPerPage') },
        { key: 'api_open_browser', label: t('Settings_OpenBrowser'), type: 'bool',
          desc: t('Settings_DescOpenBrowser') },
        { key: 'api_session_dividers', label: t('Settings_SessionDividers'), type: 'bool',
          desc: t('Settings_DescSessionDividers') },
        { key: 'api_wordtable_format', label: t('Settings_WordTable'), type: 'select',
          options: [['', t('Settings_OptHidden')], ['freq', t('Settings_OptFrequencies')], ['prob', t('Settings_OptProbabilities')], ['score', t('Settings_OptLogScores')]],
          desc: t('Settings_DescWordTable') },
        { key: 'api_locale', label: t('Configuration_Language'), type: 'locale',
          desc: t('Settings_DescLanguage') },
      ],
    },
    {
      id: 'security', label: t('Settings_SectionSecurity'), icon: 'lock',
      settings: [
        { key: 'api_password', label: t('Settings_AdminPassword'), type: 'password',
          desc: t('Settings_DescAdminPassword') },
        { key: 'api_local', label: t('Settings_LocalOnly'), type: 'bool',
          desc: t('Settings_DescLocalOnly_UI'),
          disabledWhen: (c) => c.api_local == 1 && (!c.api_password || c.api_password === '') },
      ],
    },
    {
      id: 'imap', label: t('Settings_SectionIMAP'), icon: 'cloud', serviceKey: 'imap_enabled',
      component: 'IMAP',
      settings: [],
    },
    {
      id: 'pop3', label: t('Settings_SectionPOP3'), icon: 'mail', serviceKey: 'pop3_enabled',
      desc: t('Settings_DescPOP3'),
      settings: [
        { key: 'pop3_enabled', label: t('Settings_EnableService'), type: 'bool',
          desc: t('Settings_DescEnableProxy') },
        { key: 'pop3_port', label: t('Settings_ListenPort'), type: 'number',
          desc: t('Settings_DescPOP3Port') },
        { key: 'pop3_separator', label: t('Settings_ServerSeparator'), type: 'text',
          desc: t('Settings_DescPOP3Separator') },
        { key: 'pop3_local', label: t('Settings_LocalOnly'), type: 'bool',
          desc: t('Settings_DescPOP3LocalOnly') },
        { key: 'pop3_force_fork', label: t('Settings_ForceFork'), type: 'bool',
          desc: t('Settings_DescForceFork') },
        { key: 'pop3_toptoo', label: t('Settings_TOPFetchesBody'), type: 'bool',
          desc: t('Settings_DescTOPFetchesBody') },
        { key: 'pop3_secure_server', label: t('Settings_SSLChainServer'), type: 'text',
          desc: t('Settings_DescSSLChainServer') },
        { key: 'pop3_secure_port', label: t('Settings_SSLChainPort'), type: 'number',
          desc: t('Settings_DescSSLChainPort') },
      ],
    },
    {
      id: 'smtp', label: t('Settings_SectionSMTP'), icon: 'outbox', serviceKey: 'smtp_enabled',
      desc: t('Settings_DescSMTP'),
      settings: [
        { key: 'smtp_enabled', label: t('Settings_EnableService'), type: 'bool',
          desc: t('Settings_DescEnableProxy') },
        { key: 'smtp_port', label: t('Settings_ListenPort'), type: 'number',
          desc: t('Settings_DescSMTPPort') },
        { key: 'smtp_chain_server', label: t('Settings_ChainServer'), type: 'text',
          desc: t('Settings_DescChainServer') },
        { key: 'smtp_chain_port', label: t('Settings_ChainPort'), type: 'number',
          desc: t('Settings_DescChainPort') },
        { key: 'smtp_local', label: t('Settings_LocalOnly'), type: 'bool',
          desc: t('Settings_DescSMTPLocalOnly') },
        { key: 'smtp_force_fork', label: t('Settings_ForceFork'), type: 'bool',
          desc: t('Settings_DescForceFork') },
      ],
    },
    {
      id: 'nntp', label: t('Settings_SectionNNTP'), icon: 'article', serviceKey: 'nntp_enabled',
      desc: t('Settings_DescNNTP'),
      settings: [
        { key: 'nntp_enabled', label: t('Settings_EnableService'), type: 'bool',
          desc: t('Settings_DescEnableProxy') },
        { key: 'nntp_port', label: t('Settings_ListenPort'), type: 'number',
          desc: t('Settings_DescNNTPPort') },
        { key: 'nntp_separator', label: t('Settings_ServerSeparator'), type: 'text',
          desc: t('Settings_DescNNTPSeparator') },
        { key: 'nntp_local', label: t('Settings_LocalOnly'), type: 'bool',
          desc: t('Settings_DescNNTPLocalOnly') },
        { key: 'nntp_force_fork', label: t('Settings_ForceFork'), type: 'bool',
          desc: t('Settings_DescForceFork') },
        { key: 'nntp_headtoo', label: t('Settings_HEADFetchesBody'), type: 'bool',
          desc: t('Settings_DescHEADFetchesBody') },
      ],
    },
    {
      id: 'classifier', label: t('Settings_SectionClassifier'), icon: 'psychology',
      settings: [
        { key: 'bayes_hostname', label: t('Settings_ListenAddress'), type: 'text',
          desc: t('Settings_DescListenAddress') },
        { key: 'bayes_message_cutoff', label: t('Settings_MessageCutoff'), type: 'number',
          desc: t('Settings_DescMessageCutoff') },
        { key: 'bayes_unclassified_weight', label: t('Settings_UnclassifiedWeight'), type: 'number',
          desc: t('Settings_DescUnclassifiedWeight') },
        { key: 'bayes_subject_mod_left', label: t('Settings_SubjectTagLeft'), type: 'text',
          desc: t('Settings_DescSubjectTagLeft') },
        { key: 'bayes_subject_mod_right', label: t('Settings_SubjectTagRight'), type: 'text',
          desc: t('Settings_DescSubjectTagRight') },
        { key: 'bayes_subject_mod_pos', label: t('Settings_TagPosition'), type: 'select',
          options: [['0', t('Settings_OptFront')], ['1', t('Settings_OptEnd')]],
          desc: t('Settings_DescTagPosition') },
        { key: 'bayes_sqlite_fast_writes', label: t('Settings_SQLiteFastWrites'), type: 'bool',
          desc: t('Settings_DescSQLiteFastWrites') },
        { key: 'bayes_sqlite_backup', label: t('Settings_SQLiteBackup'), type: 'bool',
          desc: t('Settings_DescSQLiteBackup') },
        { key: 'bayes_sqlite_journal_mode', label: t('Settings_SQLiteJournalMode'), type: 'select',
          options: [['delete','delete'],['truncate','truncate'],['persist','persist'],['memory','memory'],['off','off']],
          desc: t('Settings_DescSQLiteJournal') },
        { key: 'wordmangle_stemming', label: t('Settings_WordStemming'), type: 'bool',
          desc: t('Settings_DescWordStemming') },
        { key: 'wordmangle_auto_detect_language', label: t('Settings_AutoDetectLanguage'), type: 'bool',
          desc: t('Settings_DescAutoDetectLang') },
      ],
    },
    {
      id: 'history', label: t('Settings_SectionHistory'), icon: 'folder_open',
      settings: [
        { key: 'history_history_days', label: t('Settings_RetentionDays'), type: 'number',
          desc: t('Settings_DescRetentionDays') },
        { key: 'history_archive', label: t('Settings_ArchiveMessages'), type: 'bool',
          desc: t('Settings_DescArchiveMessages') },
        { key: 'history_archive_dir', label: t('Settings_ArchiveDirectory'), type: 'text',
          desc: t('Settings_DescArchiveDir') },
        { key: 'history_archive_classes', label: t('Settings_ArchiveSubdirs'), type: 'number',
          desc: t('Settings_DescArchiveSubdirs') },
      ],
    },
    {
      id: 'logging', label: t('Settings_SectionLogging'), icon: 'assignment',
      settings: [
        { key: 'logger_level', label: t('Settings_LogLevel'), type: 'select',
          options: [['0', t('Settings_OptErrorsOnly')], ['1', t('Settings_OptWarnings')], ['2', t('Settings_OptInfo')], ['3', t('Settings_OptDebug')]],
          desc: t('Settings_DescLogLevel') },
        { key: 'logger_logdir', label: t('Settings_LogDirectory'), type: 'text',
          desc: t('Settings_DescLogDirectory') },
        { key: 'logger_log_to_stdout', label: t('Settings_LogToStdout'), type: 'bool',
          desc: t('Settings_DescLogToStdout') },
        { key: 'logger_log_sql', label: t('Settings_LogSQLToStdout'), type: 'bool',
          desc: t('Settings_DescLogSQLToStdout') },
        { key: 'logger_format', label: t('Settings_LogFormat'), type: 'select',
          options: [['default', 'Default'], ['tabbed', 'Tabbed'], ['csv', 'CSV'], ['plain', 'Plain']],
          desc: t('Settings_DescLogFormat') },
      ],
    },
  ]);

  // ─── Search filter ──────────────────────────────────────────────────────
  function matchesSearch(section) {
    const q = settingsSearch.toLowerCase();
    if (!q) return true;
    if (section.label.toLowerCase().includes(q)) return true;
    return section.settings.some(f =>
      f.label.toLowerCase().includes(q) || f.desc.toLowerCase().includes(q)
    );
  }

  function visibleFields(section) {
    const q = settingsSearch.toLowerCase();
    if (!q) return section.settings;
    if (section.label.toLowerCase().includes(q)) return section.settings;
    return section.settings.filter(f =>
      f.label.toLowerCase().includes(q) || f.desc.toLowerCase().includes(q)
    );
  }

  // ─── Load / save ────────────────────────────────────────────────────────
  async function load() {
    const [cfgRes, localeRes] = await Promise.all([
      fetch('/api/v1/config'),
      fetch('/api/v1/languages'),
    ]);
    if (cfgRes.ok) config = await cfgRes.json();
    if (localeRes.ok) availableLocales = await localeRes.json();
  }

  async function save() {
    saving = true;
    status = '';
    const res = await fetch('/api/v1/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config),
    });
    saving = false;
    if (res.ok) {
      status = 'ok';
      dirty = false;
      setTimeout(() => { status = ''; }, 2500);
      await initLocale(config.api_locale || '');
    } else {
      status = 'error';
    }
  }

  function mark() { dirty = true; status = ''; }

  onMount(load);
</script>

<div class="settings-wrap">

  <!-- ── Sidebar ── -->
  <nav class="sidebar">
    {#each SECTIONS as s}
      {#if !settingsSearch || matchesSearch(s)}
        <button
          class="nav-item"
          class:active={active === s.id}
          onclick={() => { active = s.id; settingsSearch = ''; }}
        >
          <span class="icon nav-icon">{s.icon}</span>
          <span class="nav-label">{s.label}</span>
          {#if s.serviceKey}
            <span class="nav-status" class:on={config[s.serviceKey] == 1}></span>
          {/if}
        </button>
      {/if}
    {/each}
  </nav>

  <!-- ── Main panel ── -->
  <div class="panel">
    <div class="panel-search-wrap">
      <input
        class="panel-search"
        type="search"
        placeholder={t('Settings_Search')}
        bind:value={settingsSearch}
        oninput={() => { if (settingsSearch) active = ''; }}
      />
      {#if settingsSearch}
        <button class="clear-btn" onclick={() => { settingsSearch = ''; active = active || 'ui'; }} aria-label="Clear search"><span class="icon">close</span></button>
      {/if}
    </div>
    {#if settingsSearch}
      {#each SECTIONS.filter(matchesSearch) as section (section.id)}
        <div class="section">
          <header>
            <h2>{section.label}</h2>
            {#if section.desc}<p class="section-desc">{section.desc}</p>{/if}
          </header>
          <div class="fields">
            {#each visibleFields(section) as f (f.key)}
              <div class="field-row">
                <div class="field-meta">
                  <label for={f.key}>{f.label}</label>
                  <p class="desc">{f.desc}</p>
                </div>
                <div class="field-input">
                  {#if f.type === 'bool'}
                    <label class="toggle" class:disabled={f.disabledWhen?.(config)}>
                      <input
                        type="checkbox"
                        checked={config[f.key] == 1}
                        disabled={f.disabledWhen?.(config)}
                        onchange={(e) => { config[f.key] = e.target.checked ? 1 : 0; mark(); }}
                      />
                      <span class="track"></span>
                    </label>
                  {:else if f.type === 'select'}
                    <select
                      id={f.key}
                      bind:value={config[f.key]}
                      onchange={mark}
                    >
                      {#each f.options as [val, lbl]}
                        <option value={val}>{lbl}</option>
                      {/each}
                    </select>
                  {:else if f.type === 'locale'}
                    <select
                      id={f.key}
                      bind:value={config[f.key]}
                      onchange={mark}
                    >
                      <option value="">{t('Settings_AutoDetect')}</option>
                      {#each availableLocales as l}
                        <option value={l.code}>{l.name}</option>
                      {/each}
                    </select>
                  {:else}
                    <input
                      id={f.key}
                      type={f.type}
                      bind:value={config[f.key]}
                      oninput={mark}
                    />
                  {/if}
                </div>
              </div>
            {/each}
          </div>

        </div>
      {/each}
    {:else}
      {#each SECTIONS as section (section.id)}
        {#if active === section.id}
          {#if section.component === 'IMAP'}
            <IMAP />
          {:else}
          <div class="section">
            <header>
              <h2>{section.label}</h2>
              {#if section.desc}<p class="section-desc">{section.desc}</p>{/if}
            </header>
            <div class="fields">
              {#each section.settings as f (f.key)}
                <div class="field-row">
                  <div class="field-meta">
                    <label for={f.key}>{f.label}</label>
                    <p class="desc">{f.desc}</p>
                  </div>
                  <div class="field-input">
                    {#if f.type === 'bool'}
                      <label class="toggle" class:disabled={f.disabledWhen?.(config)}>
                        <input
                          type="checkbox"
                          checked={config[f.key] == 1}
                          disabled={f.disabledWhen?.(config)}
                          onchange={(e) => { config[f.key] = e.target.checked ? 1 : 0; mark(); }}
                        />
                        <span class="track"></span>
                      </label>
                    {:else if f.type === 'select'}
                      <select
                        id={f.key}
                        bind:value={config[f.key]}
                        onchange={mark}
                      >
                        {#each f.options as [val, lbl]}
                          <option value={val}>{lbl}</option>
                        {/each}
                      </select>
                    {:else if f.type === 'locale'}
                      <select
                        id={f.key}
                        bind:value={config[f.key]}
                        onchange={mark}
                      >
                        <option value="">{t('Settings_AutoDetect')}</option>
                        {#each availableLocales as l}
                          <option value={l.code}>{l.name}</option>
                        {/each}
                      </select>
                    {:else}
                      <input
                        id={f.key}
                        type={f.type}
                        bind:value={config[f.key]}
                        oninput={mark}
                      />
                    {/if}
                  </div>
                </div>
              {/each}
            </div>
          </div>
          {/if}
        {/if}
      {/each}
    {/if}

    <footer class="section-footer">
      {#if status === 'ok'}
        <span class="msg-ok"><span class="icon">check</span> {t('Settings_Saved')}</span>
      {:else if status === 'error'}
        <span class="msg-err"><span class="icon">close</span> {t('Settings_ErrorSaving')}</span>
      {/if}
      <button class="btn-save" onclick={save} disabled={!dirty || saving}>
        {saving ? t('Settings_Saving') : t('Settings_SaveChanges')}
      </button>
    </footer>
  </div>
</div>

<style>
  .settings-wrap {
    display: flex;
    height: 100%;
    min-height: calc(100vh - 48px);
    background: var(--bg);
  }

  /* ── Sidebar ── */
  .sidebar {
    width: 220px;
    flex-shrink: 0;
    background: var(--sidebar-bg);
    border-right: 1px solid var(--border);
    padding: 1rem 0;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .panel-search-wrap { position: relative; display: flex; align-items: center; margin-bottom: 1.5rem; }
  .panel-search { width: 100%; padding: 0.45rem 2rem 0.45rem 0.75rem; border: 1px solid var(--border); border-radius: 6px; background: var(--surface); color: var(--text); font-size: 0.875rem; box-sizing: border-box; -webkit-appearance: none; }
  .panel-search:focus { outline: none; border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-ring); }
  .panel-search::-webkit-search-cancel-button { display: none; }
  .clear-btn { position: absolute; right: 0.5rem; background: none; border: none; color: var(--text-muted); font-size: 1rem; line-height: 1; padding: 0 0.2rem; cursor: pointer; }
  .clear-btn:hover { color: var(--text); }

  .nav-item {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    padding: 0.55rem 1.1rem;
    background: none;
    border: none;
    border-radius: 0;
    cursor: pointer;
    color: var(--text-muted);
    font-size: 0.875rem;
    text-align: left;
    transition: background 0.12s, color 0.12s;
    width: 100%;
  }
  .nav-item:hover {
    background: var(--surface-hover);
    color: var(--text);
  }
  .nav-item.active {
    background: var(--accent-subtle);
    color: var(--accent);
    font-weight: 600;
  }
  .nav-icon { font-size: 1rem; width: 1.25rem; text-align: center; }
  .nav-label { flex: 1; }
  .nav-status {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: var(--border);
    flex-shrink: 0;
    transition: background 0.2s;
  }
  .nav-status.on { background: var(--success); }

  /* ── Panel ── */
  .panel {
    flex: 1;
    overflow-y: auto;
    padding: 2rem 2.5rem;
    max-width: 720px;
  }

  .section header {
    margin-bottom: 1.75rem;
    border-bottom: 1px solid var(--border);
    padding-bottom: 0.75rem;
  }
  .section header h2 {
    margin: 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--text);
  }

  .section-desc {
    margin: 0.25rem 0 0;
    font-size: 0.875rem;
    color: var(--text-muted);
    line-height: 1.5;
  }

  /* ── Field rows ── */
  .fields {
    display: flex;
    flex-direction: column;
    gap: 0;
  }

  .field-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
    padding: 0.9rem 0;
    border-bottom: 1px solid var(--border);
  }
  .field-row:last-child { border-bottom: none; }

  .field-meta {
    flex: 1;
    min-width: 0;
  }
  .field-meta label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: var(--text);
    margin-bottom: 0.2rem;
    cursor: default;
  }
  .desc {
    margin: 0;
    font-size: 0.78rem;
    color: var(--text-muted);
    line-height: 1.4;
  }

  .field-input {
    flex-shrink: 0;
    width: 220px;
  }

  input[type="text"],
  input[type="number"],
  input[type="password"],
  select {
    width: 100%;
    padding: 0.4rem 0.65rem;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-size: 0.875rem;
    transition: border-color 0.15s, box-shadow 0.15s;
    box-sizing: border-box;
  }
  input:focus, select:focus {
    outline: none;
    border-color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-ring);
  }

  /* ── Toggle switch ── */
  .toggle {
    display: inline-flex;
    align-items: center;
    cursor: pointer;
    position: relative;
    width: 44px;
    height: 24px;
  }
  .toggle input { opacity: 0; width: 0; height: 0; position: absolute; }
  .track {
    width: 44px;
    height: 24px;
    background: var(--border);
    border-radius: 12px;
    transition: background 0.2s;
    position: relative;
  }
  .track::after {
    content: '';
    position: absolute;
    top: 3px;
    left: 3px;
    width: 18px;
    height: 18px;
    background: #fff;
    border-radius: 50%;
    transition: transform 0.2s;
    box-shadow: 0 1px 3px rgba(0,0,0,.3);
  }
  .toggle input:checked + .track { background: var(--accent); }
  .toggle input:checked + .track::after { transform: translateX(20px); }
  .toggle.disabled { opacity: 0.45; cursor: default; }

  /* ── Footer ── */
  .section-footer {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-top: 1.5rem;
    padding-top: 1.25rem;
    border-top: 1px solid var(--border);
  }

  .btn-save {
    padding: 0.45rem 1.2rem;
    background: var(--accent);
    color: var(--accent-fg);
    border: none;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: opacity 0.15s;
  }
  .btn-save:disabled { opacity: 0.45; cursor: default; }
  .btn-save:not(:disabled):hover { opacity: 0.88; }

  .msg-ok   { font-size: 0.85rem; color: var(--success); font-weight: 500; }
  .msg-err  { font-size: 0.85rem; color: var(--danger);  font-weight: 500; }
</style>
