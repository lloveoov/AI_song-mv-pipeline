# Song MV Pipeline

## Goal
Given a song URL, produce per-song assets for Jianying-based MV editing:
1. Audio file
2. Chinese subtitle file (SRT, Jianying-friendly)
3. Song background notes (theme/story/mood)
4. Visual assets plan (10s video or image+motion storyboard)

## Folder structure

```text
projects/song-mv-pipeline/
  outputs/
    <song-slug>/
      audio/
      subtitles/
      research/
      visuals/
      manifest.json
```

## Step 1 (already available)
Use skill command:

```bash
scripts/media_subtitles.sh -i "<youtube_or_bilibili_url>" -d "<song_output_dir>" -t audio -s srt -l zh -j on -c on -m small
```

Outputs:
- audio media file
- SRT subtitle file (simplified Chinese)

## Next steps (to implement)
- Research module: gather song background/context and summarize to `research/song_background.md`
- Visual module: generate either
  - one 10-second mood clip, or
  - 6~12 key images + simple motion plan for full-song assembly
- Export `manifest.json` for Jianying workflow.
