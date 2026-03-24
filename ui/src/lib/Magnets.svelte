<script>
  import { onMount } from 'svelte';

  let { buckets } = $props();

  let magnetTypes = $state({});
  let byBucket = $state({});
  let newBucket = $state('');
  let newType = $state('');
  let newText = $state('');
  let status = $state('');

  async function load() {
    const [typesRes, bucketsWithRes] = await Promise.all([
      fetch('/api/v1/magnet-types'),
      fetch('/api/v1/magnets'),
    ]);
    if (typesRes.ok) magnetTypes = await typesRes.json();
    if (bucketsWithRes.ok) byBucket = await bucketsWithRes.json();
  }

  async function create() {
    if (!newBucket || !newType || !newText.trim()) return;
    const res = await fetch('/api/v1/magnets', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucket: newBucket, type: newType, value: newText.trim() }),
    });
    status = res.ok ? 'Magnet created' : 'Error';
    newText = '';
    load();
  }

  async function remove(bucket, type, value) {
    const res = await fetch('/api/v1/magnets', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucket, type, value }),
    });
    status = res.ok ? 'Magnet deleted' : 'Error';
    load();
  }

  onMount(load);
</script>

<h2>Magnets</h2>

{#if status}<p class="status">{status}</p>{/if}

<section>
  <h3>Add magnet</h3>
  <div class="row">
    <select bind:value={newBucket}>
      <option value="">— bucket —</option>
      {#each buckets.filter(b => !b.pseudo) as b}
        <option value={b.name}>{b.name}</option>
      {/each}
    </select>
    <select bind:value={newType}>
      <option value="">— type —</option>
      {#each Object.entries(magnetTypes) as [type, header]}
        <option value={type}>{header}</option>
      {/each}
    </select>
    <input type="text" placeholder="match text" bind:value={newText} />
    <button onclick={create}>Add</button>
  </div>
</section>

<section>
  <h3>Existing magnets</h3>
  {#each Object.entries(byBucket) as [bucket, types]}
    <div class="bucket-block">
      <h4>{bucket}</h4>
      {#each Object.entries(types) as [type, values]}
        <div class="type-row">
          <strong>{magnetTypes[type] ?? type}:</strong>
          {#each values as val}
            <span class="magnet">
              {val}
              <button class="remove" onclick={() => remove(bucket, type, val)}>×</button>
            </span>
          {/each}
        </div>
      {/each}
    </div>
  {/each}
</section>

<style>
  .row { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 1rem; }
  input[type=text], select { padding: 0.35rem 0.6rem; border: 1px solid #ccc; border-radius: 4px; }
  button { padding: 0.35rem 0.8rem; border: 1px solid #ccc; border-radius: 4px; cursor: pointer; }
  .bucket-block { margin: 1rem 0; }
  .bucket-block h4 { font-size: 0.95rem; color: #555; margin-bottom: 0.3rem; }
  .type-row { display: flex; flex-wrap: wrap; gap: 0.4rem; align-items: center; margin: 0.2rem 0; }
  .magnet { display: inline-flex; align-items: center; gap: 0.2rem; background: #e8f0fe; border-radius: 3px; padding: 0.15rem 0.4rem; font-size: 0.85rem; }
  .remove { border: none; background: none; cursor: pointer; color: #888; padding: 0; font-size: 0.9rem; }
  .status { color: #27ae60; font-weight: 500; }
</style>
