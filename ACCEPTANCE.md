# Acceptance Checklist (Milestone 1)

## Goal
From one song URL, produce a complete editable package for Jianying prep.

## Command
```bash
scripts/run_pipeline.sh -u "<url>"
```

## Pass Criteria
- [ ] `outputs/<song-id>/audio/` contains audio file
- [ ] `outputs/<song-id>/subtitles/` contains `.srt`
- [ ] `outputs/<song-id>/research/song_background.md` exists
- [ ] `outputs/<song-id>/visuals/plan.md` exists
- [ ] `outputs/<song-id>/manifest.json` exists and paths are valid

## Notes
- Current milestone provides stable scaffold and draft documents.
- Next milestone will replace drafts with fully automated research + generated visuals.
