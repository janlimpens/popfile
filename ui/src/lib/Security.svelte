<script>
  import { onMount } from 'svelte';

  let config = $state({});
  let status = $state('');

  const FIELDS = [
    { key: 'html_port',       label: 'UI Port',        type: 'number' },
    { key: 'html_password',   label: 'Admin Password', type: 'password' },
    { key: 'bayes_hostname',  label: 'Listen address', type: 'text' },
    { key: 'logger_level',    label: 'Log level (0-2)', type: 'number' },
  ];

  async function load() {
    const res = await fetch('/api/v1/config');
    if (res.ok) config = await res.json();
  }

  async function save() {
    const res = await fetch('/api/v1/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(config),
    });
    status = res.ok ? 'Saved' : 'Error saving';
  }

  onMount(load);
</script>

<h2>Security &amp; Configuration</h2>

{#if status}<p class="status">{status}</p>{/if}

<form onsubmit={e => { e.preventDefault(); save(); }}>
  <table>
    <tbody>
      {#each FIELDS as f}
        <tr>
          <th>{f.label}</th>
          <td>
            <input
              type={f.type}
              bind:value={config[f.key]}
            />
          </td>
        </tr>
      {/each}
    </tbody>
  </table>
  <button type="submit">Save</button>
</form>

<style>
  table { border-collapse: collapse; }
  th, td { padding: 0.4rem 0.8rem; text-align: left; }
  th { font-weight: 500; color: #555; width: 180px; }
  input { padding: 0.35rem 0.6rem; border: 1px solid #ccc; border-radius: 4px; width: 220px; }
  button { margin-top: 1rem; padding: 0.4rem 1rem; background: #4a6fa5; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
  .status { color: #27ae60; font-weight: 500; }
</style>
