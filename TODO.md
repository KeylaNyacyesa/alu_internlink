# TODO — ALU InternLink

## Done (this pass)
- [x] Real email/password auth + register with password confirmation.
- [x] "Logout" wired to `signOut()`.
- [x] Discover no longer renders empty — local starter catalog merged with live Firestore posts.
- [x] **Core apply→review loop fixed:** opportunities carry `ownerId`; applications carry
      `applicantId` + `startupOwnerId`; streams are queried by role.
- [x] Startups can review applications for opportunities they own and update status
      (Pending → Shortlisted → Interview → Accepted → Closed).
- [x] Firestore rules updated: verified-startup posting + ownership-based application access.
- [x] Streams rebind on auth change (`ref.listen`); display name resolved from profile.
- [x] Removed dead pre-split screens; `flutter analyze` clean (0 errors/warnings).
- [x] Technical report + demo script drafted in `docs/`.

## Deferred (documented as future work in the report)
- [ ] Draft vs. submit applications (a `drafts` subcollection) — not rubric-required.
- [ ] In-app messaging / interview scheduling.
- [ ] FCM push notification on status change (`firebase_messaging` already a dependency).
- [ ] Admin console for verification (currently a manual `verifiedStartup` flip).
- [ ] Pagination on Discover; Cloud Function to maintain `applicantCount`.

## Before submitting
- [ ] Publish `firestore.rules` to the Firebase project (`firebase deploy --only firestore:rules`).
- [ ] Record the 7–10 min demo on the Android emulator/physical device (not browser).
- [ ] Export `docs/TECHNICAL_REPORT.md` to PDF, add real screenshots + your name.
- [ ] Rename repo/report per `StudentName_FinalFlutterProject`.
