#!/usr/bin/env bash
# Sends a sample request to the local Laya server.
# Reads LAYA_API_KEY from the environment, or from .env next to this script.
set -eu

ENV_FILE="$(dirname "$0")/.env"
if [ -z "${LAYA_API_KEY:-}" ] && [ -f "$ENV_FILE" ]; then . "$ENV_FILE"; fi

# Works on macOS's old bash 3.2 (no empty-array expansion under `set -u`)
AUTH_HEADER="Authorization: Bearer ${LAYA_API_KEY:?set LAYA_API_KEY or create .env}"

curl -sS -H "$AUTH_HEADER" http://localhost:8000/health; echo
curl -sS -X POST http://localhost:8000/v1/systemone \
  -H 'Content-Type: application/json' -H "$AUTH_HEADER" \
  -d '{
    "state": {"body": "We were billed twice. Please refund the duplicate."},
    "questions": {
      "intent": {
        "type": "choice",
        "instructions": "What does the customer want?",
        "criteria": {
          "refund": "money returned or a duplicate charge reversed",
          "technical_help": "a bug, outage or integration problem",
          "other": "none of the other options fits"
        }
      },
      "wants_refund": {"type": "noul", "instructions": "Does the user request a refund?"}
    }
  }'
echo
