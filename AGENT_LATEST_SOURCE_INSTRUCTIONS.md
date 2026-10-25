# hammesh_aae Latest Source Reference

This ZIP is the reference source for the current merged project.

## Preservation rule
- The BASE study-material JSON is authoritative.
- Existing subjects, topics, MCQs/PYQs and study-material fields are preserved.
- Video metadata is additive only.
- Do not replace the study-material JSON with an older copy.

## Video Learning
- Multi-video support is available under `visualLearning.videos`.
- Online Media opens the configured HTTPS YouTube resource externally.
- A fallback launch mode is used if the external launch fails.
- Offline visual/animation content remains available.

## Study-material display
Definitions stored as names are displayed with the topic's existing concept/overview as an explanation instead of showing a bare name only. No source study-material field is deleted.

## Validation
After installing dependencies, run:
- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Agent implementation rule
Use this ZIP as the new baseline/reference for future edits. Do not reintroduce files from earlier ZIPs unless they are explicitly compared and merged. For future changes, preserve all existing study-material fields and treat new features as additive changes.
