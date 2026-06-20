# Container log checker (local AI, free)

Checks a single Docker container's logs and asks a free, local AI model
(DeepSeek via Ollama) to explain what's happening — no API key, no cloud
cost, runs entirely on your own machine.

Two ways to use it: a plain shell script, or an n8n workflow if you'd
rather click a button than run a command.

## What you need

- Docker Desktop
- [Ollama](https://ollama.com), with a small model pulled:
  ```bash
  brew install ollama
  brew services start ollama
  ollama pull deepseek-r1:1.5b
  ```

## Option A: the shell script

```bash
chmod +x check-container.sh
./check-container.sh <container_name>
```

Prints the container's recent logs, then Ollama's plain-language take on
what's going on. Requires `jq` (`brew install jq`).

## Option B: the n8n workflow

1. Start the stack:
   ```bash
   docker compose -f docker-compose.local.yml up -d
   ```
2. Open `http://localhost:5678`, set up an account on first launch.
3. Import `workflow-simple-ollama.json`.
4. In the "Get container logs" node, edit the URL to point at the
   container name you want to check.
5. Click **Execute Workflow**, then check the "Show answer" node.

## How it works

A small Docker socket proxy gives read-only access to container info and
logs — it can look, but can't start/stop/delete anything. The workflow
(or script) pulls a container's recent logs, cleans up some binary noise
Docker's log stream includes, and hands them to a local LLM for a
diagnosis. Nothing leaves your machine.
