# AGENT IMPLEMENTATION INSTRUCTIONS — Quick Access + Leaderboard + Chat Fix v1.2.2

## Baseline
This ZIP is a new standalone source baseline based on `hammesh_aae_latest_source_reference_v1.2.1.zip`.
Do NOT merge an older ZIP and do NOT remove existing working features.

## Changes included

### 1. Quick Access
`lib/main.dart`
- Preserve the existing Quick Access items:
  - MCQ Practice
  - Mock Test
  - Bookmarks
  - Mistakes
- Restore direct access to the existing `QuickRevisionScreen`.
- Add direct access to the existing `FiftyDayStudyPlanScreen`.
- No old removed Home shortcuts such as Format/Notes are reintroduced.
- No existing bottom navigation is changed.

### 2. Direct Chat / Two-way messaging
`lib/services/chat_service.dart`
- Firebase Auth UID is now the canonical chat user ID.
- The previous random `asp_*` chat ID conflicted with Firebase rules that require `auth.uid`.
- Existing local random IDs are replaced by the authenticated Firebase UID when authentication is available.
- Added null-auth guards so messages are queued locally instead of failing unexpectedly.
- Direct-message channel remains deterministic and symmetric:
  `p2p_<sorted-user-id-1>_<sorted-user-id-2>`
- Message IDs use microseconds to reduce collisions.
- Existing polling/offline cache/report/block behavior is preserved.

### 3. Leaderboard identity and synchronization
`lib/services/competition_service.dart`
- Firebase Auth UID is now always preferred as the canonical leaderboard member ID.
- Older locally generated member IDs are migrated when an authenticated UID becomes available.
- Local cached/pending results are rebound to the authenticated UID during migration.
- Cached members/results are merged with remote members/results instead of discarding the cache whenever a remote response is non-empty.
- This prevents friend entries and local test results from disappearing because of temporary sync/API failures.
- Existing point calculation, best-attempt protection, accuracy and ranking rules remain unchanged.

### 4. Firebase Realtime Database rules
`firebase.database.rules.json`
- Chat users are writable only by their own Firebase Auth UID.
- Global leaderboard members are writable only by their own Firebase Auth UID.
- Leaderboard results can only be created by the authenticated member whose UID is stored in `memberId`.
- Direct-message writes remain restricted to the sender or recipient.
- Global chat/report restrictions are preserved.

## IMPORTANT: Firebase deployment
After applying this source ZIP, deploy the included `firebase.database.rules.json` to the same Firebase Realtime Database used by the app.

The app uses:
`https://hammesh-aae-default-rtdb.firebaseio.com`

Also verify Firebase Anonymous Authentication is enabled, because `OnlineAuthService` uses anonymous sign-in.

## Verification checklist
1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Build the debug APK.
4. Test with two different Firebase anonymous users/devices:
   - User A appears in Chat user list for User B.
   - A -> B message appears on B.
   - B -> A reply appears on A.
   - Close/reopen chat and verify history remains.
5. Leaderboard:
   - Both users appear.
   - Each user's completed test count updates.
   - Points and accuracy update.
   - Rank changes when points change.
6. Quick Access:
   - All six current items open the correct existing screens.
   - Bookmarks/Mistakes badges still work.
   - Quick Revision loads.
   - Study Plan opens.
7. Verify existing Home, Study, AI, Daily Task, Progress, bottom navigation, tests and update workflow remain unchanged.

## Do not do
- Do not restore the old removed Quick Access Format/Notes shortcuts.
- Do not delete existing features.
- Do not replace Firebase with another backend.
- Do not invent a new chat or leaderboard architecture.
- Do not change subject names, topic names, MCQ/PYQ data, or study-material JSON in this task.
