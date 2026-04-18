<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";

  let name = $state(""); // reactive state
  let greetMsg = $state(""); // another reactive state

  async function greet(event: Event) {
    event.preventDefault();
    greetMsg = await invoke("greet", { name });
  }

  async function somethingElse() {
    const result = await invoke("do_something_else");
    greetMsg = result as string;
  }
</script>

<main class="container">
  <h1>ClipNexus</h1>

  <form onsubmit={greet}>
    <input type="text" placeholder="Enter a name..." bind:value={name} />
    <button type="submit">Greet</button>
  </form>
  <button onclick={somethingElse}>Do something else</button>
  <p>{greetMsg}</p>
</main>

<style>
  :root {
    font-family: sans-serif;
    background: #f0f0f0;
  }
  .container {
    margin: 0 auto;
    padding: 10vh 2em;
    text-align: center;
  }
  input,
  button {
    padding: 0.6em 1.2em;
    margin: 0.25em;
  }
</style>
