<script>
  import { t } from './locale.svelte.js';

  const NAME_RE = /^[a-z0-9_-]+$/;

  let {
    buckets,
    value = $bindable(''),
    placeholder = '— select —',
    filter = null,
    onchange = null,
    oncreated = null,
  } = $props();

  let extra = $state([]);
  let adding = $state(false);
  let newName = $state('');
  let err = $state('');
  let busy = $state(false);

  let visible = $derived(
    [...buckets, ...extra.filter(e => !buckets.find(b => b.name === e.name))]
      .filter(b => filter ? filter(b) : true)
  );

  function handleChange(e) {
    const v = e.target.value;
    if (v === '__add_new__') {
      adding = true;
      newName = '';
      err = '';
      return;
    }
    value = v;
    onchange?.(v);
  }

  async function confirm() {
    const name = newName.trim();
    if (!name) { err = t('BucketSelect_NameRequired'); return; }
    if (!NAME_RE.test(name)) { err = t('BucketSelect_InvalidName'); return; }
    busy = true;
    const res = await fetch('/api/v1/buckets', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name }),
    });
    busy = false;
    if (res.status === 409) { err = t('BucketSelect_AlreadyExists'); return; }
    if (!res.ok) { err = t('BucketSelect_CreateError'); return; }
    const created = { name };
    extra = [...extra, created];
    value = name;
    onchange?.(name);
    adding = false;
    err = '';
    oncreated?.(created);
  }

  function cancel() {
    adding = false;
    err = '';
  }

  function keydown(e) {
    if (e.key === 'Enter') confirm();
    if (e.key === 'Escape') cancel();
  }
</script>

{#if adding}
  <span class="inline-add">
    <input
      type="text"
      bind:value={newName}
      placeholder="bucket-name"
      onkeydown={keydown}
      disabled={busy}
    />
    <button onclick={confirm} disabled={busy}>OK</button>
    <button class="cancel" onclick={cancel} disabled={busy}><span class="icon">close</span></button>
    {#if err}<span class="err">{err}</span>{/if}
  </span>
{:else}
  <select {value} onchange={handleChange}>
    <option value="">{placeholder}</option>
    {#each visible as b}
      <option value={b.name}>{b.name}</option>
    {/each}
    <option value="__add_new__">{t('BucketSelect_AddNew')}</option>
  </select>
{/if}

<style>
  .inline-add {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
  }
  .inline-add input {
    padding: 0.3rem 0.5rem;
    font-size: 0.875rem;
    border: 1px solid var(--border);
    border-radius: 4px;
    background: var(--bg);
    color: var(--text);
    width: 9rem;
  }
  .inline-add button {
    padding: 0.25rem 0.55rem;
    font-size: 0.8rem;
    border: 1px solid var(--border);
    border-radius: 4px;
    cursor: pointer;
    background: var(--bg);
    color: var(--text);
  }
  .cancel { color: var(--text-muted); }
  .err { font-size: 0.78rem; color: var(--danger); white-space: nowrap; }
</style>
