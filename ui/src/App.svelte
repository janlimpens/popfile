<script>
  import { onMount } from 'svelte';
  import History  from './lib/History.svelte';
  import Corpus   from './lib/Corpus.svelte';
  import IMAP     from './lib/IMAP.svelte';
  import Magnets  from './lib/Magnets.svelte';
  import Settings from './lib/Settings.svelte';
  import Status   from './lib/Status.svelte';

  let page    = $state(window.location.hash.slice(1) || 'history');
  let buckets = $state([]);
  let theme   = $state(localStorage.getItem('pf-theme') || 'dark');

  $effect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('pf-theme', theme);
  });

  onMount(async () => {
    const res = await fetch('/api/v1/buckets');
    if (res.ok) buckets = await res.json();
    window.addEventListener('hashchange', () => {
      page = window.location.hash.slice(1) || 'history';
    });
  });

  const NAV = [
    ['history',  'History'],
    ['corpus',   'Corpus'],
    ['magnets',  'Magnets'],
    ['imap',     'IMAP'],
    ['status',   'Status'],
    ['settings', 'Settings'],
  ];

  function toggleTheme() {
    theme = theme === 'dark' ? 'light' : 'dark';
  }
</script>

<nav>
  <span class="logo">POPFile</span>
  <div class="nav-links">
    {#each NAV as [id, label]}
      <a href="#{id}" class:active={page === id}>{label}</a>
    {/each}
  </div>
  <button class="theme-btn" onclick={toggleTheme} title="Toggle theme">
    {theme === 'dark' ? '☀' : '🌙'}
  </button>
</nav>

<main>
  {#if page === 'history'}
    <History {buckets} />
  {:else if page === 'corpus'}
    <Corpus bind:buckets />
  {:else if page === 'magnets'}
    <Magnets {buckets} />
  {:else if page === 'imap'}
    <IMAP {buckets} />
  {:else if page === 'status'}
    <Status />
  {:else if page === 'settings'}
    <Settings />
  {/if}
</main>

<style>
  /* ── Theme tokens ── */
  :global(html[data-theme="dark"]) {
    --bg:            #1a1b26;
    --sidebar-bg:    #16161e;
    --surface:       #24283b;
    --surface-hover: #2e3347;
    --border:        #383c52;
    --text:          #c0caf5;
    --text-muted:    #787c99;
    --accent:        #7aa2f7;
    --accent-fg:     #1a1b26;
    --accent-subtle: rgba(122,162,247,0.12);
    --accent-ring:   rgba(122,162,247,0.25);
    --success:       #9ece6a;
    --danger:        #f7768e;
    --nav-bg:        #16161e;
    --nav-fg:        #c0caf5;
    --nav-active:    rgba(122,162,247,0.18);
    color-scheme: dark;
  }

  :global(html[data-theme="light"]) {
    --bg:            #f6f8fa;
    --sidebar-bg:    #eef0f4;
    --surface:       #ffffff;
    --surface-hover: #eef0f4;
    --border:        #d0d4de;
    --text:          #1f2335;
    --text-muted:    #6b6f8a;
    --accent:        #2563eb;
    --accent-fg:     #ffffff;
    --accent-subtle: rgba(37,99,235,0.09);
    --accent-ring:   rgba(37,99,235,0.2);
    --success:       #16a34a;
    --danger:        #dc2626;
    --nav-bg:        #1f2335;
    --nav-fg:        #e0e4f0;
    --nav-active:    rgba(255,255,255,0.12);
    color-scheme: light;
  }

  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: var(--bg);
    color: var(--text);
  }

  /* ── Nav ── */
  nav {
    display: flex;
    align-items: center;
    padding: 0 1.25rem;
    height: 48px;
    background: var(--nav-bg);
    position: sticky;
    top: 0;
    z-index: 100;
    box-shadow: 0 1px 4px rgba(0,0,0,.4);
  }

  .logo {
    font-weight: 700;
    font-size: 1.05rem;
    color: var(--accent);
    letter-spacing: .03em;
    margin-right: 1.5rem;
    flex-shrink: 0;
  }

  .nav-links {
    display: flex;
    align-items: stretch;
    flex: 1;
    height: 100%;
  }

  nav a {
    display: flex;
    align-items: center;
    padding: 0 1rem;
    color: rgba(255,255,255,.6);
    text-decoration: none;
    font-size: 0.875rem;
    border-bottom: 2px solid transparent;
    transition: color .15s, border-color .15s, background .15s;
  }
  nav a:hover  { color: #fff; background: var(--nav-active); }
  nav a.active { color: #fff; border-bottom-color: var(--accent); }

  .theme-btn {
    margin-left: auto;
    background: none;
    border: none;
    color: var(--nav-fg);
    cursor: pointer;
    padding: 0.35rem 0.5rem;
    border-radius: 6px;
    font-size: 1.1rem;
    opacity: .7;
    transition: opacity .15s, background .15s;
  }
  .theme-btn:hover { opacity: 1; background: var(--nav-active); }

  main { min-height: calc(100vh - 48px); }

  /* ── Global helpers consumed by all components ── */
  :global(table)  { border-collapse: collapse; width: 100%; }
  :global(th, td) {
    padding: 0.45rem 0.8rem;
    text-align: left;
    border-bottom: 1px solid var(--border);
  }
  :global(th) {
    font-weight: 600;
    color: var(--text-muted);
    font-size: 0.78rem;
    text-transform: uppercase;
    letter-spacing: .05em;
    background: var(--surface);
  }
  :global(h2) { color: var(--text); margin-top: 0; }
  :global(h3) { color: var(--text); }
  :global(p)  { color: var(--text-muted); }

  /* Ensure form controls respect the theme even in non-Settings pages */
  :global(input[type="text"]),
  :global(input[type="number"]),
  :global(input[type="password"]),
  :global(select) {
    background: var(--surface);
    color: var(--text);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 0.35rem 0.6rem;
    font-size: 0.875rem;
  }
</style>
