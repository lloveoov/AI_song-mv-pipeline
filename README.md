# AI_song-mv-pipeline

Song MV asset pipeline: URL -> audio + subtitles + research + visual plan for Jianying workflows.  
歌曲 MV 素材流水线：链接 -> 音频 + 字幕 + 背景资料 + 视觉方案，便于剪映工作流。

## Output Structure

默认输出到 Windows 目录：`D:\AI_output`（在 WSL 中为 `/mnt/d/AI_output`）。

```text
D:\AI_output\
  <song-title-safe>__<song-id>\
    audio\
    subtitles\
    research\song_background.md
    visuals\plan.md
    manifest.json
```

## One-command Pipeline

```bash
cd projects/AI_song-mv-pipeline
scripts/run_pipeline.sh -u "<youtube_or_bilibili_url>"
# 可选自定义输出目录：
# scripts/run_pipeline.sh -u "<url>" -o "/mnt/d/AI_output"
```

What it does:
1. Download audio
2. Generate Chinese SRT subtitles (Jianying-friendly)
3. Create research draft file
4. Create visual storyboard draft
5. Export `manifest.json`

## Dependency

- `yt-dlp`
- `ffmpeg`
- `whisper`
- local skill script:
  `/home/palmsens/.openclaw/workspace/skills/media-subtitles/scripts/media_subtitles.sh`

## Current Milestone

- ✅ Minimal reproducible end-to-end pipeline ready
- ⏭ Next: automate research enrichment + visual generation model integration
