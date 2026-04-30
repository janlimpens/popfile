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
  let testResult = $state(null);
  let testing = $state(false);
  let exitPrompt = $state(false);

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
      <span class="step-dot" class:active={step >= 3}><span class="icon">folder</span></span>
    </div>

    <!-- Step 1: Welcome + email -->
    {#if step === 1}
      <h2>POPFile</h2>
      <p class="wizard-desc">{t('Wizard_Welcome')}</p>
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
        <h2>{t('Imap_Connected')}</h2>
        <p class="wizard-desc">
          Pre-configured for <strong>{provider.host}</strong>.
          {#if provider.hint}<br /><em>{provider.hint}</em>{/if}
        </p>
      {:else}
        <h2>{t('Wizard_Manual')}</h2>
        <p class="wizard-desc">{t('Wizard_ManualDesc')}</p>
      {/if}
      <div class="wizard-fields">
        <div class="wizard-field">
          <label for="wiz-login">{t('Wizard_Username')}</label>
          <input id="wiz-login" type="text" bind:value={login} />
        </div>
        <div class="wizard-field">
          <label for="wiz-pass">{t('Imap_Password')}</label>
          <input id="wiz-pass" type="password" bind:value={password} />
        </div>
        <div class="wizard-field">
          <label for="wiz-server">{t('Imap_Server')}</label>
          <input id="wiz-server" type="text" bind:value={server} />
        </div>
        <div class="wizard-field">
          <label for="wiz-enc">{t('Wizard_Encryption')}</label>
          <select id="wiz-enc" bind:value={encryption}>
            <option value="SSL">{t('Wizard_SSL')}</option>
            <option value="STARTTLS">{t('Wizard_STARTTLS')}</option>
            <option value="none">{t('Wizard_None')}</option>
          </select>
        </div>
        <div class="wizard-field">
          <label for="wiz-port">{t('Imap_Port')}</label>
          <input id="wiz-port" type="number" bind:value={port} />
        </div>
      </div>
      <footer class="wizard-footer">
        <button class="btn btn-secondary" onclick={() => step = 1}>Back</button>
        <button class="btn" onclick={() => step = 3}>{t('Imap_WizardApply')}</button>
      </footer>

    <!-- Step 3: folder mapping (placeholder) -->
    {:else if step === 3}
      <h2>{t('Imap_Wizard')}</h2>
      <p class="wizard-desc">Folder mapping will go here.</p>
      <footer class="wizard-footer">
        <button class="btn btn-secondary" onclick={() => step = 2}>Back</button>
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
</style>
