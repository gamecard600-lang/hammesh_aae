# Hammesh AAE v1.2.0 - Agent Execution Instructions

This ZIP contains source changes already applied. Execute and verify them, then complete the items marked CONTENT/BACKEND below. Do not overwrite working changes blindly.

## Already changed in source
1. Recent tests preserve/open the real saved result; old history without answer payload is not fabricated.
2. Daily Task now uses only completed study topics and prioritizes PYQ, hard/MSQ and mistake/confusion questions. Completed Daily Task cannot be reopened; a new task is generated on the next day.
3. Definitions UI now shows term + best available definition sentence from the topic content instead of only a bare name.
4. Visual learning auto-activates for cycle/process/engineering topics even when older JSON flags are missing.
5. Bottom navigation label changed from Leaderboard to compact Ranks to prevent wrapping.
6. Daily Task is not resumable. Resume/state persistence must remain only for Mock Test and Practice modes.
7. Your Progress card redesigned.
8. Quick Access expanded/reorganized and includes PYQ Test, Quick Revision and Concept Reels.
9. Dark-mode contrast improved in test options, explanation cards and chat.
10. AI model list/API payload updated to current Gemini models and proper system_instruction usage.
11. Quick Revision falls back to master study material when the dedicated file is empty.
12. Home order is Countdown -> Your Progress -> AI Assistant -> Daily Task -> Quick Access -> remaining cards.
13. Concept Reels screen added using swipeable visual study cards.
14. Chat supports long-press unsend/delete for messages owned by the current user.
15. Redundant master_study_material.json.before_detail_backup removed to reduce package size.
16. Maestro + Flutter integration-test + golden-test scaffolding + GitHub Actions quality workflow added.
17. PYQ-only test entry screen added.

## Must complete / verify
A. CONTENT: Populate definitions for every definition-only entry in master_study_material.json. Preferred schema: [{"term":"...","definition":"..."}] but keep backward compatibility with current string list until migration is complete. Never invent engineering definitions.
B. CONTENT: Enrich visualLearning for topics where a real diagram/cycle/drawing materially improves understanding. Use existing AnimatedTopicVisualWidget where possible; add only meaningful visuals.
C. CONTENT: Build a complete quick_revision.json from master material, with high-value last-minute points.
D. STUDY COACH: Implement Weakness Engine, Smart Revision, Today's Mission and AI Wrong-Answer Coach as one recommendation pipeline. Goal: automatically decide what the aspirant should study today, not merely add more screens.
E. DAILY TASK: verify selection strictly respects completed topics and ranking: PYQ > confusion/mistake > hard/MSQ > important. Prevent immediate repeats.
F. LEADERBOARD: extend leaderboard payload/backend so every aspirant row can show rank, points, tests, accuracy and a study-progress percentage. Keep privacy-safe display names only.
G. CHAT BACKEND: verify Firebase/Realtime Database rules permit DELETE only for the message owner. Do not allow arbitrary user deletion.
H. AI: test a real Gemini key from Settings. Do not use an OpenAI key. Verify 200 response, invalid-key handling, 429 handling and offline fallback.
I. RESUME: keep resume persistence ONLY for Mock Test and Practice. Daily Task, PYQ Test and normal topic tests must start fresh.
J. DARK THEME: audit every screen for hardcoded light backgrounds + light text combinations. Use Theme.of(context).colorScheme for surfaces and text.
K. TESTS: run flutter analyze, flutter test, golden test, integration test, Maestro smoke test and debug APK build. Do not accept failures as 'known'.
L. SIZE: remove only genuinely unused generated/backup assets after verifying no pubspec/reference dependency. Do not delete source/content used by the app.

## Required validation commands
flutter clean
flutter pub get
flutter analyze
flutter test
flutter test test/golden/home_golden_test.dart
flutter test integration_test/app_smoke_test.dart
flutter build apk --debug

Then run the Maestro flow on an emulator/device.

## Acceptance priorities
P0: compile/analyze, Daily Task bug, Recent Result fidelity, AI working, dark-mode readability.
P1: Definitions, Quick Revision, PYQ Test, Quick Access, Progress card, Leaderboard layout.
P2: Reels polish, Weakness Engine, Smart Revision, Today's Mission, AI Coach, backend leaderboard progress.
