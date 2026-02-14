#!/usr/bin/env bash
set -euo pipefail

ROLE="${1:-}"; shift || true
MSG="${1:-}"
EMAIL="1560715+lloveoov@users.noreply.github.com"

if [[ -z "$ROLE" || -z "$MSG" ]]; then
  echo "Usage: scripts/commit_as.sh <manager|builder|qa|doc> \"<prefix: message>\""
  exit 2
fi

case "$ROLE" in
  manager) NAME="Orion Manager"; PREF="manager:" ;;
  builder|code) NAME="Orion Code"; PREF="builder:" ;;
  qa) NAME="Orion QA"; PREF="qa:" ;;
  doc|docs) NAME="Orion Doc"; PREF="doc:" ;;
  *) echo "Unknown role: $ROLE"; exit 2 ;;
esac

if [[ "$MSG" != $PREF* ]]; then
  echo "Message must start with '$PREF'"
  exit 2
fi

git commit --author="$NAME <$EMAIL>" -m "$MSG"
