<script>
  import { onMount } from 'svelte';
  import { t } from './locale.svelte.js';
  import { wizardOpen } from './wizard.svelte.js';

  const PROVIDERS = {
    'gmail.com':      { host: 'imap.gmail.com',         port: 993, enc: 'SSL',     hint: 'Use an app password: https://myaccount.google.com/apppasswords' },
    'googlemail.com': { host: 'imap.gmail.com',         port: 993, enc: 'SSL',     hint: 'Use an app password: https://myaccount.google.com/apppasswords' },
    'outlook.com':    { host: 'outlook.office365.com',  port: 993, enc: 'SSL' },
    'hotmail.com':    { host: 'outlook.office365.com',  port: 993, enc: 'SSL' },
    'live.com':       { host: 'outlook.office365.com',  port: 993, enc: 'SSL' },
    'yahoo.com':      { host: 'imap.mail.yahoo.com',    port: 993, enc: 'SSL',     hint: 'Use an app password: https://account.yahoo.com/security' },
    'icloud.com':     { host: 'imap.mail.me.com',       port: 993, enc: 'SSL',     hint: 'Use an app-specific password: https://appleid.apple.com' },
    'me.com':         { host: 'imap.mail.me.com',       port: 993, enc: 'SSL',     hint: 'Use an app-specific password: https://appleid.apple.com' },
    'gmx.net':        { host: 'imap.gmx.net',           port: 993, enc: 'SSL' },
    'gmx.de':         { host: 'imap.gmx.net',           port: 993, enc: 'SSL' },
    'web.de':         { host: 'imap.web.de',            port: 993, enc: 'SSL' },
    'zoho.com':       { host: 'imap.zoho.com',          port: 993, enc: 'SSL' },
    'fastmail.com':   { host: 'imap.fastmail.com',      port: 993, enc: 'SSL' },
    'mailbox.org':    { host: 'imap.mailbox.org',       port: 993, enc: 'SSL' },
    'posteo.de':      { host: 'imap.posteo.de',         port: 993, enc: 'SSL' },
    'proton.me':      { host: '127.0.0.1',              port: 1143, enc: 'none',   hint: 'Requires Proton Mail Bridge: https://proton.me/mail/bridge' },
    'protonmail.com': { host: '127.0.0.1',              port: 1143, enc: 'none',   hint: 'Requires Proton Mail Bridge: https://proton.me/mail/bridge' },
  };

  let step = $state(1);
  let email = $state('');
  let provider = $state(null);
  let detecting = $state(false);

  // Server settings
  let login = $state('');
  let password = $state('');
  let server = $state('');
  let encryption = $state('SSL');
  let port = $state(993);
  let protocol = $state('IMAP');  // IMAP or POP3
  let testResult = $state(null);
  let testing = $state(false);
  let exitPrompt = $state(false);

  // Folder mapping (step 3)
  let folders = $state([]);
  let folderSelected = $state(new Set());
  let fetchingFolders = $state(false);

  async function testConnection() {
    testing = true;
    const res = await fetch('/api/v1/imap/test-connection', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ hostname: server, port, login, password, use_ssl: encryption === 'SSL' ? 1 : 0 }),
    });
    testing = false;
    testResult = await res.json();
  }

  async function fetchFolders() {
    // Save config first — server-folders reads from stored config
    await fetch('/api/v1/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        imap_hostname: server, imap_port: port,
        imap_login: login, imap_password: password,
        imap_use_ssl: encryption === 'SSL' ? 1 : 0,
      }),
    });
    if (protocol === 'POP3') {
      await applySettings();
      step = 4;
      return
    }
    fetchingFolders = true;
    const res = await fetch('/api/v1/imap/server-folders');
    fetchingFolders = false;
    if (res.ok) {
      const all = await res.json();
      const defaults = new Set(['INBOX', 'Trash', 'Sent', 'Drafts', 'Junk', 'Archive', 'Templates',
        'Papierkorb', 'Gesendet', 'Entwürfe', 'Spam', 'Vorlagen',
        'Entw&APw-rfe', 'Spam PF', 'unclassified']);
      folders = all.filter(f => !defaults.has(f) && !f.startsWith('INBOX/'));
      folderSelected = new Set(folders);
      step = 3;
    }
  }

  function folderToBucket(f) {
    let name = f.replace(/^INBOX\./, '')
      .replace(/&APY-/g, 'ö').replace(/&APw-/g, 'ü')
      .replace(/&AOQ-/g, 'ä').replace(/&AN8-/g, 'ß')
      .replace(/&AME-/g, 'é').replace(/&APE-/g, 'è')
      .replace(/&AMg-/g, 'ê').replace(/&AMQ-/g, 'ë')
      .replace(/&AMk-/g, 'í').replace(/&AM0-/g, 'ó')
      .replace(/&APU-/g, 'ú').replace(/&AM8-/g, 'ñ')
      .replace(/&AMM-/g, 'ç')
      .replace(/&[A-Za-z0-9+\/]+-/g, '')
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s_-]/gi, '').replace(/\s+/g, '').toLowerCase();
    return name || f.replace(/[^a-z0-9]/gi, '').toLowerCase();
  }

  function toggleFolder(f) {
    const s = new Set(folderSelected);
    s.has(f) ? s.delete(f) : s.add(f);
    folderSelected = s;
  }

  async function applySettings() {
    await fetch('/api/v1/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        imap_hostname: server, imap_port: port,
        imap_login: login, imap_password: password,
        imap_use_ssl: encryption === 'SSL' ? 1 : 0,
        imap_enabled: protocol === 'IMAP' ? 1 : 0,
        pop3_enabled: protocol === 'POP3' ? 1 : 0,
        pop3_port: protocol === 'POP3' ? 1110 : undefined,
      }),
    });
    dismiss();
  }

  async function applyFolders() {
    const selected = [...folderSelected];
    const mappings = selected.map(f => ({ bucket: folderToBucket(f), folder: f }));
    for (const m of mappings) {
      await fetch('/api/v1/buckets', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: m.bucket }),
      });
    }
    await fetch('/api/v1/imap/folders', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ watched: [], mappings }),
    });
    await applySettings();
    step = 4;
  }

  function handleKeydown(e) {
    if (e.key === 'Escape') { exitPrompt = true }
  }

  function startDetection() {
    if (!email.trim()) return;
    const domain = email.split('@')[1]?.toLowerCase();
    provider = PROVIDERS[domain] || null;
    login = email;
    if (provider) {
      server = provider.host;
      port = provider.port;
      encryption = provider.enc;
    } else {
      port = protocol === 'IMAP' ? 993 : 995;
    }
    step = 2;
  }

  function dismiss() { wizardOpen.set(false) }
</script>

<svelte:window onkeydown={handleKeydown} />

<div class="wizard-overlay">
  <div class="wizard-card">
    <button class="wizard-close" onclick={() => exitPrompt = true}
      title="Close (Esc)">
      <span class="icon">close</span>
    </button>

    <div class="wizard-steps">
      <span class="step-dot" class:active={step === 1}><span class="icon">mail</span></span>
      <span class="step-line"></span>
      <span class="step-dot" class:active={step === 2}><span class="icon">cloud</span></span>
      <span class="step-line"></span>
      <span class="step-dot" class:active={step >= 3 && protocol === 'IMAP'}><span class="icon">folder</span></span>
      {#if protocol === 'IMAP'}
        <span class="step-line"></span>
        <span class="step-dot" class:active={step >= 4}><span class="icon">check</span></span>
      {/if}
    </div>

    <!-- Step 1: Welcome + email -->
    {#if step === 1}
      <h2>POPFile</h2>
      <p class="wizard-desc">{t('Wizard_Welcome')}</p>
      <div class="wizard-field">
        <label for="wiz-proto">Protocol</label>
        <select id="wiz-proto" bind:value={protocol}
          onchange={() => port = protocol === 'IMAP' ? 993 : 995}>
          <option value="IMAP">IMAP (recommended)</option>
          <option value="POP3">POP3 (less common)</option>
        </select>
      </div>
      <div class="wizard-field">
        <label for="wiz-email">{t('Wizard_Username')}</label>
        <input id="wiz-email" type="email" bind:value={email}
          placeholder="you@example.com"
          onkeydown={(e) => e.key === 'Enter' && startDetection()} />
      </div>
      <footer class="wizard-footer">
        <button class="btn btn-secondary" onclick={dismiss}>Skip</button>
        <button class="btn" onclick={startDetection} disabled={!email.trim()}>
          {t('Wizard_Next')}
        </button>
      </footer>

    <!-- Step 2: provider found or manual -->
    {:else if step === 2}
      {#if provider}
        <h2>{protocol} — {t('Imap_Connected')}</h2>
        <p class="wizard-desc">
          Pre-configured for <strong>{provider.host}</strong>.
          {#if provider.hint}<br /><em>{provider.hint}</em>{/if}
        </p>
      {:else}
        <h2>{protocol} — {t('Wizard_Manual')}</h2>
        <p class="wizard-desc">{t('Wizard_ManualDesc')}</p>
      {/if}

      {#if testResult?.ok}
        <p class="msg-ok"><span class="icon">check</span> Connected</p>
      {:else if testResult && !testResult.ok}
        <p class="msg-err"><span class="icon">close</span> {testResult.error || 'Connection failed'}</p>
      {/if}
      <div class="wizard-fields">
        <div class="wizard-field">
          <label for="wiz-login">{t('Wizard_Username')}</label>
          <input id="wiz-login" type="text" bind:value={login} />
        </div>
        <div class="wizard-field">
          <label for="wiz-server">Server</label>
          <input id="wiz-server" type="text" bind:value={server} />
        </div>
        <div class="wizard-field">
          <label for="wiz-pass">Password</label>
          <input id="wiz-pass" type="password" bind:value={password} />
        </div>
        <div class="wizard-field">
          <label for="wiz-enc">{t('Wizard_Encryption')}</label>
          <select id="wiz-enc" bind:value={encryption}>
            <option value="SSL">SSL/TLS</option>
            <option value="STARTTLS">STARTTLS</option>
            <option value="none">{t('Wizard_None')}</option>
          </select>
        </div>
        <div class="wizard-field">
          <label for="wiz-port">Port</label>
          <input id="wiz-port" type="number" bind:value={port} />
        </div>
      </div>
      <footer class="wizard-footer">
        <button class="btn btn-secondary" onclick={() => step = 1}>Back</button>
        <button class="btn btn-secondary" onclick={testConnection} disabled={testing || !server.trim() || !login.trim() || !password.trim()}>
          {testing ? 'Testing…' : t('Imap_TestConnection')}
        </button>
        <button class="btn" onclick={fetchFolders} disabled={!testResult?.ok || fetchingFolders}>
          {fetchingFolders ? '…' : protocol === 'POP3' ? t('Imap_WizardClose') : t('Wizard_Next')}
        </button>
      </footer>

    <!-- Step 3: folder mapping -->
    {:else if step === 3}
      <h2>{t('Imap_Wizard')}</h2>
      <p class="wizard-desc">{t('Imap_WizardDesc')}</p>
      {#if folders.length > 0}
        <div class="wizard-folder-list">
          {#each folders as f}
            {@const bucket = folderToBucket(f)}
            <label class="wizard-folder-row">
              <input type="checkbox" checked={folderSelected.has(f)}
                onchange={() => toggleFolder(f)} />
              <span class="tag">{f}</span> → <span class="tag bucket-tag">{bucket}</span>
            </label>
          {/each}
        </div>
      {/if}
      <footer class="wizard-footer">
        <button class="btn btn-secondary" onclick={() => step = 2}>Back</button>
        <button class="btn btn-secondary" onclick={applySettings}>Save &amp; finish</button>
        <button class="btn" onclick={applyFolders} disabled={folderSelected.size === 0}>
          {t('Imap_WizardApply')}
        </button>
      </footer>

    <!-- Step 4: Done -->
    {:else if step === 4}
      <h2>{t('Wizard_Done')}</h2>
      {#if protocol === 'IMAP'}
        <p class="wizard-desc">
          POPFile is now watching your inbox. New messages will be classified
          and sorted into the folders you picked.
        </p>
        <p class="wizard-desc">
          <strong>It's still learning, though.</strong> At first, everything lands in
          <em>unclassified</em> — that's normal. Head to the History page, click a message,
          and tell POPFile where it belongs. Every correction makes it sharper.
          You'll see it pick up the drift pretty quickly — watch it learn!
        </p>
      {:else}
        <p class="wizard-desc">
          POPFile is ready. Point your mail client at the machine running POPFile
          (port 1110) instead of your usual mail server. POPFile will add an
          <code>X-Text-Classification</code> header to every message it sees.
        </p>
        <p class="wizard-desc">
          <strong>POP3 doesn't move messages around</strong> — the History page is your
          only interface. That's where you tag messages and teach the classifier.
          Once POPFile is reliably labelling your mail, set up filters in your
          email client to act on the <code>X-Text-Classification</code> header
          (move to folders, mark as read, etc.).
        </p>
        <p class="wizard-desc">
          Start by creating a few buckets on the Corpus page — work, personal,
          newsletters, whatever fits. Then head to History and start tagging.
          POPFile learns from every one.
        </p>
      {/if}
      <footer class="wizard-footer">
        <button class="btn" onclick={dismiss}>{t('Imap_WizardClose')}</button>
      </footer>
    {/if}

    {#if exitPrompt}
      <div class="exit-overlay">
        <div class="exit-dialog">
          <p>Exit the setup wizard?</p>
          <footer class="wizard-footer">
            <button class="btn" onclick={dismiss}>Yes</button>
            <button class="btn btn-secondary" onclick={() => exitPrompt = false}>No</button>
          </footer>
        </div>
      </div>
    {/if}
  </div>
</div>

<style>
  .wizard-overlay {
    position: fixed; inset: 0;
    background: rgba(0,0,0,.6);
    display: flex; align-items: center; justify-content: center;
    z-index: 300;
  }
  .wizard-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    position: relative;
    padding: 2rem 2.5rem;
    min-width: 420px;
    max-width: 520px;
    box-shadow: 0 12px 40px rgba(0,0,0,.4);
  }
  .wizard-card h2 { margin: 0 0 0.75rem; font-size: 1.25rem; }
  .wizard-close {
    position: absolute; top: 0.75rem; right: 0.75rem;
    background: none; border: none;
    color: var(--text-muted); cursor: pointer;
    font-size: 1.2rem; padding: 0.25rem;
    border-radius: 50%; width: 2rem; height: 2rem;
    display: flex; align-items: center; justify-content: center;
    transition: background .15s, color .15s;
  }
  .wizard-close:hover { background: var(--border); color: var(--text); }
  .wizard-steps {
    display: flex; align-items: center; justify-content: center;
    gap: 0; margin-bottom: 1.5rem;
  }
  .step-dot {
    width: 2rem; height: 2rem; border-radius: 50%;
    background: var(--border);
    display: flex; align-items: center; justify-content: center;
    font-size: 0.9rem; color: var(--text-muted);
    transition: background .2s, color .2s;
  }
  .step-dot.active { background: var(--accent); color: var(--accent-fg); }
  .step-line { width: 2.5rem; height: 2px; background: var(--border); }
  .wizard-desc { margin: 0 0 1.5rem; font-size: 0.875rem; color: var(--text-muted); line-height: 1.5; }
  .wizard-fields { display: flex; flex-direction: column; gap: 0.75rem; }
  .wizard-field { display: flex; flex-direction: column; gap: 0.25rem; }
  .wizard-field label { font-size: 0.85rem; font-weight: 500; color: var(--text); }
  .wizard-field input, .wizard-field select {
    padding: 0.45rem 0.65rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-size: 0.875rem;
  }
  .wizard-field input:focus, .wizard-field select:focus {
    outline: none; border-color: var(--accent);
  }
  .wizard-footer {
    margin-top: 1.5rem;
    display: flex; justify-content: flex-end; gap: 0.75rem;
  }
  .btn {
    padding: 0.45rem 1.2rem;
    background: var(--accent);
    color: var(--accent-fg);
    border: none; border-radius: 6px;
    font-size: 0.875rem; font-weight: 500;
    cursor: pointer;
  }
  .btn:disabled { opacity: 0.4; cursor: default; }

  .exit-overlay {
    position: absolute; inset: 0;
    background: rgba(0,0,0,.5);
    display: flex; align-items: center; justify-content: center;
    border-radius: 12px;
  }
  .exit-dialog {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 1.5rem;
    text-align: center;
  }
  .exit-dialog p { margin: 0 0 1rem; font-size: 0.95rem; color: var(--text); }

  .wizard-folder-list { max-height: 18rem; overflow-y: auto; margin-bottom: 1rem; }
  .wizard-folder-row {
    display: flex; align-items: center; gap: 0.5rem;
    padding: 0.4rem 0; cursor: pointer;
    font-size: 0.85rem; border-bottom: 1px solid var(--border);
  }
  .wizard-folder-row:hover { background: var(--surface-hover); }
  .tag {
    background: var(--bg); color: var(--text);
    border: 1px solid var(--border); border-radius: 4px;
    padding: 0.15rem 0.45rem; font-size: 0.82rem;
  }
  .bucket-tag { background: var(--accent-subtle); color: var(--accent); }
  .msg-ok  { font-size: 0.85rem; color: var(--success); margin: 0.5rem 0 0; }
  .msg-err { font-size: 0.85rem; color: var(--danger);  margin: 0.5rem 0 0; }
</style>
