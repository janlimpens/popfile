<script>
  import { onMount } from 'svelte';
  import { initLocale } from './locale.svelte.js';

  let config = $state({});
  let active = $state('ui');
  let status = $state('');
  let dirty = $state(false);
  let saving = $state(false);
  let settingsSearch = $state('');
  let availableLocales = $state([]);

  // ─── Section / field schema ─────────────────────────────────────────────
  const SECTIONS = [
    {
      id: 'ui', label: 'User Interface', icon: '⚙',
      settings: [
        { key: 'mojo_ui_port',             label: 'HTTP Port',         type: 'number',
          desc: 'Port the web UI listens on. Requires restart.' },
        { key: 'mojo_ui_local',            label: 'Local Only',        type: 'bool',
          desc: 'Restrict the web UI to localhost connections.' },
        { key: 'mojo_ui_page_size',        label: 'Items Per Page',    type: 'number',
          desc: 'Rows shown per page in History and Magnets.' },
        { key: 'mojo_ui_date_format',      label: 'Date Format',       type: 'text',
          desc: 'strftime format string. Leave empty for locale default.' },
        { key: 'mojo_ui_session_dividers', label: 'Session Dividers',  type: 'bool',
          desc: 'Show dividers between browsing sessions in History.' },
        { key: 'mojo_ui_wordtable_format', label: 'Word Table',        type: 'select',
          options: [['','Hidden'],['freq','Frequencies'],['prob','Probabilities'],['score','Log Scores']],
          desc: 'What to display in the word probability table.' },
        { key: 'mojo_ui_locale', label: 'Language', type: 'locale',
          desc: 'UI display language. Leave empty to auto-detect from browser.' },
      ],
    },
    {
      id: 'security', label: 'Security', icon: '🔒',
      settings: [
        { key: 'mojo_ui_password', label: 'Admin Password', type: 'password',
          desc: 'Leave empty to disable password protection.' },
      ],
    },
    {
      id: 'pop3', label: 'POP3 Proxy', icon: '📬',
      settings: [
        { key: 'pop3_port',          label: 'Listen Port',      type: 'number',
          desc: 'Port POPFile listens on for POP3 (default 1110).' },
        { key: 'pop3_separator',     label: 'Server Separator', type: 'text',
          desc: 'Character that separates user from server (e.g. user:mailhost).' },
        { key: 'pop3_local',         label: 'Local Only',       type: 'bool',
          desc: 'Only accept POP3 connections from localhost.' },
        { key: 'pop3_force_fork',    label: 'Force Fork',       type: 'bool',
          desc: 'Fork a new process for each connection.' },
        { key: 'pop3_toptoo',        label: 'TOP Fetches Body', type: 'bool',
          desc: 'Also retrieve message body with the TOP command.' },
        { key: 'pop3_secure_server', label: 'SSL Chain Server', type: 'text',
          desc: 'Upstream SSL POP3 server hostname for SSL chaining.' },
        { key: 'pop3_secure_port',   label: 'SSL Chain Port',   type: 'number',
          desc: 'Upstream SSL POP3 server port.' },
      ],
    },
    {
      id: 'smtp', label: 'SMTP Proxy', icon: '📤',
      settings: [
        { key: 'smtp_port',         label: 'Listen Port',   type: 'number',
          desc: 'Port POPFile listens on for SMTP (default 25).' },
        { key: 'smtp_chain_server', label: 'Chain Server',  type: 'text',
          desc: 'Upstream SMTP server hostname.' },
        { key: 'smtp_chain_port',   label: 'Chain Port',    type: 'number',
          desc: 'Upstream SMTP server port.' },
        { key: 'smtp_local',        label: 'Local Only',    type: 'bool',
          desc: 'Only accept SMTP connections from localhost.' },
        { key: 'smtp_force_fork',   label: 'Force Fork',    type: 'bool',
          desc: 'Fork a new process for each connection.' },
      ],
    },
    {
      id: 'nntp', label: 'NNTP Proxy', icon: '📰',
      settings: [
        { key: 'nntp_port',       label: 'Listen Port',      type: 'number',
          desc: 'Port POPFile listens on for NNTP (default 119).' },
        { key: 'nntp_separator',  label: 'Server Separator', type: 'text',
          desc: 'Character separating user from server.' },
        { key: 'nntp_local',      label: 'Local Only',       type: 'bool',
          desc: 'Only accept NNTP connections from localhost.' },
        { key: 'nntp_force_fork', label: 'Force Fork',       type: 'bool',
          desc: 'Fork a new process for each connection.' },
        { key: 'nntp_headtoo',    label: 'HEAD Fetches Body', type: 'bool',
          desc: 'Retrieve full article with the HEAD command.' },
      ],
    },
    {
      id: 'classifier', label: 'Classifier', icon: '🧠',
      settings: [
        { key: 'bayes_hostname',           label: 'Listen Address',     type: 'text',
          desc: 'IP address to bind to. Empty = all interfaces.' },
        { key: 'bayes_message_cutoff',     label: 'Message Cutoff',     type: 'number',
          desc: 'Maximum words analysed per message (0 = unlimited).' },
        { key: 'bayes_unclassified_weight', label: 'Unclassified Weight', type: 'number',
          desc: 'Probability threshold below which mail is "unclassified".' },
        { key: 'bayes_subject_mod_left',   label: 'Subject Tag Left',   type: 'text',
          desc: 'Prefix inserted into Subject header, e.g. [SPAM].' },
        { key: 'bayes_subject_mod_right',  label: 'Subject Tag Right',  type: 'text',
          desc: 'Suffix appended to Subject header.' },
        { key: 'bayes_subject_mod_pos',    label: 'Tag Position',       type: 'select',
          options: [['0','Front'],['1','End']], desc: 'Where to place the subject tag.' },
        { key: 'bayes_sqlite_tweaks',      label: 'SQLite Tweaks',      type: 'number',
          desc: 'Bitmask: 1 = faster writes (less safe), 2 = periodic backup.' },
        { key: 'bayes_sqlite_journal_mode', label: 'SQLite Journal Mode', type: 'select',
          options: [['delete','delete'],['truncate','truncate'],['persist','persist'],['memory','memory'],['off','off']],
          desc: 'SQLite journal / WAL mode.' },
        { key: 'wordmangle_stemming', label: 'Word Stemming', type: 'bool',
          desc: 'Reduce words to their stem before classification (e.g. "running" → "run"). Improves recall for morphologically rich languages at ~10% latency cost.' },
        { key: 'wordmangle_auto_detect_language', label: 'Auto-detect Language', type: 'bool',
          desc: 'Detect the language of each message and apply matching stopwords and stemmer. Adds ~130% classify latency; useful for mixed-language mailboxes.' },
      ],
    },
    {
      id: 'history', label: 'History', icon: '🗂',
      settings: [
        { key: 'history_history_days',    label: 'Retention (days)',    type: 'number',
          desc: 'How many days to keep message history.' },
        { key: 'history_archive',         label: 'Archive Messages',    type: 'bool',
          desc: 'Save a copy of every classified message to disk.' },
        { key: 'history_archive_dir',     label: 'Archive Directory',   type: 'text',
          desc: 'Directory for archived messages (relative to user dir).' },
        { key: 'history_archive_classes', label: 'Archive Sub-dirs',    type: 'number',
          desc: 'Split archive into N sub-directories (0 = disabled).' },
      ],
    },
    {
      id: 'logging', label: 'Logging', icon: '📋',
      settings: [
        { key: 'logger_level',  label: 'Log Level',      type: 'select',
          options: [['0','Errors only'],['1','Warnings'],['2','Info'],['3','Debug']],
          desc: 'Verbosity of log output.' },
        { key: 'logger_logdir', label: 'Log Directory',  type: 'text',
          desc: 'Directory for log files. Empty = popfile root.' },
        { key: 'logger_log_to_stdout', label: 'Log to stdout', type: 'bool',
          desc: 'Mirror log output to stdout in addition to the log file.' },
        { key: 'logger_log_sql', label: 'Log SQL to stdout', type: 'bool',
          desc: 'Print every SQL statement with bound values to stdout. Only active when "Log to stdout" is also enabled.',
          disabledWhen: (cfg) => cfg.logger_log_to_stdout != 1 },
      ],
    },
  ];

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
      fetch('/api/v1/i18n'),
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
      await initLocale(config.mojo_ui_locale || '');
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
          <span class="nav-icon">{s.icon}</span>
          <span class="nav-label">{s.label}</span>
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
        placeholder="Search settings…"
        bind:value={settingsSearch}
        oninput={() => { if (settingsSearch) active = ''; }}
      />
      {#if settingsSearch}
        <button class="clear-btn" onclick={() => { settingsSearch = ''; active = active || 'ui'; }} aria-label="Clear search">×</button>
      {/if}
    </div>
    {#if settingsSearch}
      {#each SECTIONS.filter(matchesSearch) as section (section.id)}
        <div class="section">
          <header>
            <h2>{section.label}</h2>
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
                      <option value="">Auto-detect</option>
                      {#each availableLocales as l}
                        <option value={l.name}>{l.name}</option>
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
          <div class="section">
            <header>
              <h2>{section.label}</h2>
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
                        <option value="">Auto-detect</option>
                        {#each availableLocales as l}
                          <option value={l.name}>{l.name}</option>
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
      {/each}
    {/if}

    <footer class="section-footer">
      {#if status === 'ok'}
        <span class="msg-ok">✓ Saved</span>
      {:else if status === 'error'}
        <span class="msg-err">✗ Error saving</span>
      {/if}
      <button class="btn-save" onclick={save} disabled={!dirty || saving}>
        {saving ? 'Saving…' : 'Save Changes'}
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
