# 60-Day Study Plan Agent Instructions

Add the 60-Day Study Plan already included in this source. Keep `master_study_material.json` as the only topic source and keep the existing 165 topics/14 subjects unchanged. The plan must use existing `StudyProgress` as the single source of truth: completed topics are excluded, remaining topics are dynamically distributed across the remaining days, and progress is shown inside the existing Your Progress experience. Store only the plan start date in SharedPreferences. Resetting the plan must not delete study progress. Reuse existing Study Material screens/services.

Run `flutter pub get`, `flutter analyze`, and `flutter test`. Verify 165 unique topics, completion sync, Day 1-60 calculation, dark mode, and that existing features remain intact.
