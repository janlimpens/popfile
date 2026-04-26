<script>
  import { onMount } from 'svelte';
  import BucketSelect from './BucketSelect.svelte';
  import { t } from './locale.svelte.js';

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
    status = res.ok ? t('Magnet_Created') : 'Error';
    newText = '';
    load();
  }

  async function remove(bucket, type, value) {
    const res = await fetch('/api/v1/magnets', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ bucket, type, value }),
    });
    status = res.ok ? t('Magnet_Deleted') : 'Error';
    load();
  }

  onMount(load);
</script>

<div class="page">

<h2>{t('NavMagnets')}</h2>

{#if status}<p class="status">{status}</p>{/if}

<section>
  <h3>{t('Magnet_CreateNew')}</h3>
  <div class="row">
    <BucketSelect
      {buckets}
      bind:value={newBucket}
      placeholder="— bucket —"
      filter={b => !b.pseudo}
    />
    <select bind:value={newType}>
      <option value="">— type —</option>
      {#each Object.entries(magnetTypes) as [type, header]}
        <option value={type}>{header}</option>
      {/each}
    </select>
    <input type="text" placeholder="match text" bind:value={newText} />
    <button onclick={create}>{t('Add')}</button>
  </div>
</section>

<section>
  <h3>{t('Magnet_CurrentMagnets')}</h3>
  {#each Object.entries(byBucket) as [bucket, types]}
    {@const bc = buckets.find(b => b.name === bucket)}
    <div class="bucket-block">
      <h4>
        <span class="dot" style="background:{bc?.color ?? '#888'}"></span>{bucket}
      </h4>
      {#each Object.entries(types) as [type, values]}
        <div class="type-row">
          <strong>{magnetTypes[type] ?? type}:</strong>
          {#each values as val}
            <span class="magnet">
              {val}
              <button class="remove" onclick={() => remove(bucket, type, val)}><span class="icon">close</span></button>
            </span>
          {/each}
        </div>
      {/each}
    </div>
  {/each}
</section>

</div>

<style>
  .page { padding: 1.75rem 2rem; max-width: 760px; }
  .page { padding: 1.75rem 2rem; max-width: 760px; }
  .row { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 1rem; }
  button { padding: 0.35rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
  .bucket-block { margin: 1.25rem 0; }
  .bucket-block h4 { font-size: 0.95rem; color: var(--text); margin-bottom: 0.4rem; display: flex; align-items: center; }
  .type-row { display: flex; flex-wrap: wrap; gap: 0.4rem; align-items: center; margin: 0.25rem 0 0.25rem 1.2rem; }
  .magnet { display: inline-flex; align-items: center; gap: 0.2rem; background: var(--surface); border: 1px solid var(--border); border-radius: 3px; padding: 0.15rem 0.4rem; font-size: 0.85rem; }
  .remove { border: none; background: none; cursor: pointer; color: var(--text-muted); padding: 0; font-size: 0.9rem; }
  .remove:hover { color: var(--danger); }
  .dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 0.5rem; flex-shrink: 0; }
  .status { color: var(--success); font-weight: 500; }
</style>
