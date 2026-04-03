<script>
  import { connectivity, reconnectNow } from './connectivity.svelte.js';
</script>

{#if connectivity.offline}
  <div class="overlay">
    <div class="modal">
      <h3>Connection lost</h3>
      <p>The backend is not reachable. Trying to reconnect…</p>

      {#if connectivity.responseBody}
        <pre class="body">{connectivity.responseBody}</pre>
        <button class="btn-dismiss" onclick={() => { connectivity.offline = false; }}>
          Dismiss
        </button>
      {/if}

      <div class="actions">
        <button onclick={reconnectNow}>Reconnect now</button>
        <span class="countdown">
          {#if connectivity.nextRetryIn > 0}
            Retrying in {connectivity.nextRetryIn}s
          {:else}
            Connecting…
          {/if}
        </span>
      </div>
    </div>
  </div>
{/if}

<style>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }
  .modal {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 1.5rem 2rem;
    min-width: 320px;
    max-width: 520px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  }
  .modal h3 { margin: 0 0 0.5rem; color: var(--danger); }
  .modal p { margin: 0 0 1rem; color: var(--text-muted); font-size: 0.875rem; }
  .body {
    font-family: monospace;
    font-size: 0.8rem;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 0.6rem;
    max-height: 200px;
    overflow-y: auto;
    white-space: pre-wrap;
    word-break: break-word;
    margin-bottom: 0.75rem;
    color: var(--text);
  }
  .actions {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-top: 0.75rem;
  }
  .countdown { font-size: 0.82rem; color: var(--text-muted); }
  button {
    padding: 0.4rem 1rem;
    background: var(--accent);
    color: var(--accent-fg);
    border: none;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: opacity 0.15s;
  }
  button:hover { opacity: 0.85; }
  .btn-dismiss {
    background: var(--bg);
    color: var(--text);
    border: 1px solid var(--border);
    margin-bottom: 0;
  }
</style>
