#!/usr/bin/env bash
set -euo pipefail

gateway="http://browser-cdp.intra.quantum-box.com:9222"
session_id=""
temporary=0
cleanup=0
agent_session=""

usage() {
  cat <<'USAGE'
Usage:
  remote-browser.sh [--session-id ID | --temporary] [--cleanup | --keep] [--gateway URL] [--agent-session NAME] -- <agent-browser args...>
  remote-browser.sh --delete SESSION_ID
  remote-browser.sh --list

Examples:
  remote-browser.sh --session-id sakura-job-001 -- open https://example.com
  remote-browser.sh --temporary --cleanup -- open https://example.com
  remote-browser.sh --temporary --keep -- open https://example.com
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "remote-browser.sh: missing required command: $1" >&2
    exit 127
  fi
}

urlencode() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import quote
print(quote(sys.argv[1], safe=""))
PY
}

delete_session() {
  local id="$1"
  require_cmd curl
  require_cmd jq
  local encoded
  encoded="$(urlencode "$id")"
  curl -sS -X DELETE "${gateway}/sessions/${encoded}" | jq .
}

list_sessions() {
  require_cmd curl
  require_cmd jq
  curl -sS "${gateway}/sessions" | jq .
}

while (($# > 0)); do
  case "$1" in
    --gateway)
      gateway="${2:?missing value for --gateway}"
      shift 2
      ;;
    --session-id)
      session_id="${2:?missing value for --session-id}"
      shift 2
      ;;
    --temporary)
      temporary=1
      shift
      ;;
    --cleanup)
      cleanup=1
      shift
      ;;
    --keep)
      cleanup=0
      shift
      ;;
    --agent-session)
      agent_session="${2:?missing value for --agent-session}"
      shift 2
      ;;
    --delete)
      delete_session "${2:?missing session id for --delete}"
      exit 0
      ;;
    --list)
      list_sessions
      exit 0
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

require_cmd curl
require_cmd jq
require_cmd agent-browser

if [[ -n "$session_id" && "$temporary" == "1" ]]; then
  echo "remote-browser.sh: choose either --session-id or --temporary, not both" >&2
  exit 2
fi

if [[ -z "$session_id" ]]; then
  temporary=1
fi

cdp_ws=""

if [[ "$temporary" == "1" ]]; then
  session_json="$(curl -sS -X POST "${gateway}/sessions")"
  session_id="$(printf '%s' "$session_json" | jq -r .session_id)"
  cdp_ws="$(printf '%s' "$session_json" | jq -r .cdp_ws_url)"
  if [[ -z "$session_id" || "$session_id" == "null" || -z "$cdp_ws" || "$cdp_ws" == "null" ]]; then
    echo "remote-browser.sh: failed to create temporary session" >&2
    printf '%s\n' "$session_json" >&2
    exit 1
  fi
else
  encoded_session_id="$(urlencode "$session_id")"
  cdp_ws="${gateway/http:/ws:}/sessions/${encoded_session_id}"
fi

if [[ -z "$agent_session" ]]; then
  agent_session="$session_id"
fi

echo "remote-browser.sh: session_id=${session_id}" >&2
echo "remote-browser.sh: cdp_ws=${cdp_ws}" >&2

if (($# == 0)); then
  printf '%s\n' "$cdp_ws"
  exit 0
fi

if [[ "$cleanup" == "1" ]]; then
  trap 'delete_session "$session_id" >/dev/null 2>&1 || true' EXIT
fi

agent-browser --cdp "$cdp_ws" --session "$agent_session" "$@"
