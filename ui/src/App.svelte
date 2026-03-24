<script>
  import { onMount } from 'svelte';
  import History from './lib/History.svelte';
  import Corpus from './lib/Corpus.svelte';
  import Magnets from './lib/Magnets.svelte';
  import Security from './lib/Security.svelte';

  let page = $state(window.location.hash.slice(1) || 'history');
  let buckets = $state([]);

  onMount(async () => {
    const res = await fetch('/api/v1/buckets');
    if (res.ok) buckets = await res.json();
    window.addEventListener('hashchange', () => {
      page = window.location.hash.slice(1) || 'history';
    });
  });

  function nav(p) {
    window.location.hash = p;
  }
</script>

<nav>
  <span class="logo">POPFile</span>
  {#each [['history','History'],['corpus','Corpus'],['magnets','Magnets'],['security','Security']] as [id, label]}
    <a href="#{id}" class:active={page === id}>{label}</a>
  {/each}
</nav>

<main>
  {#if page === 'history'}
    <History {buckets} />
  {:else if page === 'corpus'}
    <Corpus bind:buckets />
  {:else if page === 'magnets'}
    <Magnets {buckets} />
  {:else if page === 'security'}
    <Security />
  {/if}
</main>

<style>
  nav {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem 1.5rem;
    background: #2a2d3a;
    color: #fff;
  }
  .logo {
    font-weight: 700;
    font-size: 1.2rem;
    margin-right: 1rem;
    color: #7eb8f7;
  }
  nav a {
    color: #ccd;
    text-decoration: none;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
  }
  nav a:hover { background: #3d4259; }
  nav a.active { background: #4a6fa5; color: #fff; }

  main {
    padding: 1.5rem;
    max-width: 1200px;
    margin: 0 auto;
  }
</style>
