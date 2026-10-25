# 50-Day Study Plan Integration Instructions

Use `hammesh_aae_latest_source_reference_v1.2.0.zip` as the baseline and apply this feature on top of it.

## Required behavior
- Add a **50-Day Study Plan** entry at the top of Study Material.
- The plan covers all **165 existing topics**.
- Days 1-40 distribute all 165 topics from `master_study_material.json` without renaming or reordering the source data.
- Days 41-47 are subject-group revision days.
- Day 48 is Grand Revision 1.
- Day 49 is Grand Revision 2 with PYQs/numericals/formulas/confusing concepts.
- Day 50 is Final Syllabus Lock and final preparation.
- Show current plan day after the user starts the plan. The start date must be stored under a NEW preference key only.

## Critical progress rule
- **DO NOT modify `Your Progress`.**
- Do not call `saveStudyProgress`, `markTopicCompleted`, or any progress-reset method from the 50-Day Plan.
- The plan may READ `LocalStorageService.loadStudyProgress()` to show which assigned topics are already completed.
- The plan's counters and checkmarks are read-only projections of existing progress.
- Do not change the existing `study_progress` preference key, model, serialization, or progress screen.
- Starting/resetting the 50-Day Plan must never reset or rewrite study progress.

## UI
- Keep existing bottom navigation unchanged.
- Keep existing Study Material screens unchanged apart from the new entry point.
- Each day should expand to show its assigned topics and revision focus.
- Clearly label the progress card as read-only.
- Use English feature/system labels consistent with the existing app.

## Data safety
- Do not edit/delete/shorten `assets/study_material/master_study_material.json`.
- Do not edit subject names or topic names.
- Do not alter MCQs/PYQs.
- Do not remove Video Learning or existing Visual Learning.

## Verification
Run:
1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`

Verify manually:
- Study -> 50-Day Study Plan opens.
- All 50 days are visible.
- Total assigned topics for Days 1-40 = 165.
- Existing completed topics appear checked in the plan.
- Starting the plan does NOT change the existing Your Progress screen/counters.
- Existing Study Material, MCQs, PYQs and Video Learning continue to work.
