#!/usr/bin/env bash
set -euo pipefail

# AI_song-mv-pipeline: URL -> audio + subtitle + research + visuals + manifest
# Usage:
#   scripts/run_pipeline.sh -u "<youtube_or_bilibili_url>" [-o /mnt/d/AI_output]

usage() {
  cat <<'EOF'
Usage:
  run_pipeline.sh -u <url> [-o output_root]

Options:
  -u  Song URL (YouTube/Bilibili)
  -o  Output root directory (default: /mnt/d/AI_output)
EOF
}

sanitize_for_windows_dir() {
  local s="$1"
  # Remove control chars and Windows-invalid path chars: < > : " / \ | ? *
  s="$(printf '%s' "$s" | tr -d '\000-\031' | sed -E 's/[<>:"\/\\|?*]/ /g')"
  # Collapse spaces and trim
  s="$(printf '%s' "$s" | sed -E 's/[[:space:]]+/ /g; s/^ +| +$//g')"
  # Avoid trailing dot/space issues on Windows
  s="$(printf '%s' "$s" | sed -E 's/[. ]+$//')"
  [[ -n "$s" ]] || s="untitled"
  printf '%s' "$s"
}

URL=""
OUT_ROOT="/mnt/d/AI_output"

while getopts ":u:o:h" opt; do
  case "$opt" in
    u) URL="$OPTARG" ;;
    o) OUT_ROOT="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) echo "Missing value for -$OPTARG"; usage; exit 2 ;;
    \?) echo "Invalid option: -$OPTARG"; usage; exit 2 ;;
  esac
done

[[ -n "$URL" ]] || { echo "Error: -u is required"; usage; exit 2; }
command -v yt-dlp >/dev/null 2>&1 || { echo "Error: yt-dlp not found"; exit 3; }

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_ROOT="$(realpath -m "$OUT_ROOT")"
mkdir -p "$OUT_ROOT"

SONG_ID="$(yt-dlp --get-id "$URL" 2>/dev/null | head -n1 || true)"
SONG_TITLE_RAW="$(yt-dlp --get-title "$URL" 2>/dev/null | head -n1 || true)"
[[ -n "$SONG_ID" ]] || SONG_ID="song-$(date +%Y%m%d-%H%M%S)"
[[ -n "$SONG_TITLE_RAW" ]] || SONG_TITLE_RAW="song"
SONG_TITLE_SAFE="$(sanitize_for_windows_dir "$SONG_TITLE_RAW")"

# Human-readable + stable folder naming
SONG_DIR_NAME="${SONG_TITLE_SAFE}__${SONG_ID}"
SONG_DIR="$OUT_ROOT/$SONG_DIR_NAME"
AUDIO_DIR="$SONG_DIR/audio"
SUB_DIR="$SONG_DIR/subtitles"
RES_DIR="$SONG_DIR/research"
VIS_DIR="$SONG_DIR/visuals"
mkdir -p "$AUDIO_DIR" "$SUB_DIR" "$RES_DIR" "$VIS_DIR"

MEDIA_SCRIPT="/home/palmsens/.openclaw/workspace/skills/media-subtitles/scripts/media_subtitles.sh"
[[ -x "$MEDIA_SCRIPT" ]] || { echo "Error: missing script $MEDIA_SCRIPT"; exit 3; }

TMP_LOG="$(mktemp)"
"$MEDIA_SCRIPT" -i "$URL" -d "$AUDIO_DIR" -t audio -s srt -l zh -j on -c on -m small | tee "$TMP_LOG"

MEDIA_FILE="$(grep '^MEDIA:' "$TMP_LOG" | sed 's/^MEDIA: //')"
SUB_FILE="$(grep '^SUBTITLE:' "$TMP_LOG" | sed 's/^SUBTITLE: //')"

[[ -f "$MEDIA_FILE" ]] || { echo "Error: media file not found"; exit 4; }
[[ -f "$SUB_FILE" ]] || { echo "Error: subtitle file not found"; exit 4; }

mv -f "$SUB_FILE" "$SUB_DIR/"
SUB_FILE="$SUB_DIR/$(basename "$SUB_FILE")"

cat > "$RES_DIR/song_background.md" <<EOF
# Song Background / 歌曲背景

- Source URL: $URL
- Song Title: $SONG_TITLE_RAW
- Song ID: $SONG_ID
- Captured At: $(date '+%Y-%m-%d %H:%M:%S %Z')

## Draft Notes (to enrich)
- Theme / 主题：
- Story / 故事线：
- Mood / 情绪：
- Suggested MV direction / 建议MV方向：
EOF

cat > "$VIS_DIR/plan.md" <<EOF
# Visual Plan / 视觉计划

## Option A: 10-second mood clip
- Shot 1 (0-3s):
- Shot 2 (3-7s):
- Shot 3 (7-10s):

## Option B: Image + motion storyboard (6-12 frames)
1.
2.
3.
4.
5.
6.

Style tags: cinematic, soft light, emotional, modern C-pop
EOF

cat > "$SONG_DIR/manifest.json" <<EOF
{
  "project": "AI_song-mv-pipeline",
  "input_url": "$URL",
  "song_id": "$SONG_ID",
  "song_title": "$SONG_TITLE_RAW",
  "song_dir_name": "$SONG_DIR_NAME",
  "created_at": "$(date -Iseconds)",
  "assets": {
    "audio": "$MEDIA_FILE",
    "subtitle_srt": "$SUB_FILE",
    "research": "$RES_DIR/song_background.md",
    "visual_plan": "$VIS_DIR/plan.md"
  }
}
EOF

rm -f "$TMP_LOG"

echo "DONE"
echo "SONG_DIR: $SONG_DIR"
echo "AUDIO: $MEDIA_FILE"
echo "SUBTITLE: $SUB_FILE"
echo "MANIFEST: $SONG_DIR/manifest.json"
