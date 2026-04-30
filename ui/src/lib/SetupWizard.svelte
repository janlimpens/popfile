<script>
  import { t } from './locale.svelte.js';

  let step = $state(1);
  let email = $state('');
  let detecting = $state(false);

  // Server settings — pre-filled by auto-detect or empty for manual
  let server = $state('');
  let port = $state(993);
  let encryption = $state('SSL');
  let login = $state('');
  let password = $state('');
  let testResult = $state(null);
  let testing = $state(false);

  // Folder mapping (step 4)
  let folders = $state([]);
  let selected = $state(new Set());
  let wizardDone = $state([]);

  function startDetection() {
    if (!email.trim()) return;
    detecting = true;
    // TODO: auto-detect in next commit
    detecting = false;
    step = 3;
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
</script>

<div class="wizard-overlay">
  <div class="wizard-card">

    <!-- Step 1: Welcome + email -->
    {#if step === 1}
      <h2>POPFile</h2>
      <p class="wizard-desc">{t('Imap_Description')}</p>
      <div class="wizard-field">
        <label for="wiz-email">{t('Imap_Login')}</label>
        <input id="wiz-email" type="email" bind:value={email}
          placeholder="you@example.com"
          onkeydown={(e) => e.key === 'Enter' && startDetection()} />
      </div>
      <footer class="wizard-footer">
        <button class="btn" onclick={startDetection} disabled={!email.trim()}>
          Find settings
        </button>
      </footer>

    <!-- Step 2: detecting -->
    {:else if step === 2}
      <h2>{t('Imap_Testing')}</h2>
      <p class="wizard-desc">Trying to discover your mail server settings…</p>

    <!-- Step 3: server settings (pre-filled or manual) -->
    {:else if step === 3}
      <h2>Mail Server</h2>
      <div class="wizard-fields">
        <div class="wizard-field">
          <label for="wiz-server">{t('Imap_Server')}</label>
          <input id="wiz-server" type="text" bind:value={server} />
        </div>
        <div class="wizard-field">
          <label>{t('Imap_Port')}</label>
          <input type="number" bind:value={port} />
        </div>
        <div class="wizard-field">
          <label>Encryption</label>
          <select bind:value={encryption}>
            <option value="SSL">SSL/TLS</option>
            <option value="STARTTLS">STARTTLS</option>
            <option value="none">None</option>
          </select>
        </div>
        <div class="wizard-field">
          <label for="wiz-login">{t('Imap_Login')}</label>
          <input id="wiz-login" type="text" bind:value={login} />
        </div>
        <div class="wizard-field">
          <label for="wiz-pass">{t('Imap_Password')}</label>
          <input id="wiz-pass" type="password" bind:value={password} />
        </div>
      </div>
      <footer class="wizard-footer">
        <button class="btn" onclick={() => step = 4}>{t('Imap_WizardApply')}</button>
      </footer>
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
    padding: 2rem 2.5rem;
    min-width: 420px;
    max-width: 520px;
    box-shadow: 0 12px 40px rgba(0,0,0,.4);
  }
  .wizard-card h2 { margin: 0 0 0.75rem; font-size: 1.25rem; }
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
</style>
