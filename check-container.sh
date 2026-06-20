#!/bin/bash
# Usage: ./check-container.sh <container_name>

CONTAINER="$1"

if [ -z "$CONTAINER" ]; then
  echo "Usage: ./check-container.sh <container_name>"
  echo "(run 'docker ps -a' if you're not sure of the name)"
  exit 1
fi

echo "Fetching logs for '$CONTAINER'..."
LOGS=$(docker logs --tail 100 "$CONTAINER" 2>&1)

if [ -z "$LOGS" ]; then
  LOGS="(no log output captured)"
fi

echo ""
echo "===== LOGS for $CONTAINER ====="
echo "$LOGS"
echo "================================"

PROMPT=$(printf "Here are the most recent logs from a Docker container named %s:\n\n%s\n\nIn plain language: what is this container doing, and is anything wrong?" "$CONTAINER" "$LOGS")

echo ""
echo "Asking Ollama (deepseek-r1:1.5b)..."

RESPONSE=$(curl -s http://localhost:11434/api/generate -d "$(jq -n --arg model "deepseek-r1:1.5b" --arg prompt "$PROMPT" '{model: $model, stream: false, prompt: $prompt}')")

ANSWER=$(echo "$RESPONSE" | jq -r '.response // "Could not get an answer - check that Ollama is running (ollama serve / brew services start ollama)."')

echo ""
echo "===== OLLAMA'S DIAGNOSIS ====="
echo "$ANSWER"
echo "================================"
