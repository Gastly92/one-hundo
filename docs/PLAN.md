# Implementation plan

How to build what `docs/PRODUCT.md` describes, as a series of small PRs. Each PR
leaves the app working and passes CI, so any merged state can go to TestFlight.
Check off a PR here (and update `PRODUCT.md` if the design changed) as each one lands.

## Approach

- **SwiftUI + SwiftData**, iOS 17. No third-party packages.
- **Logic is plain Swift, separate from views**, so it can be unit tested:
  today's target, progress, "days to goal", reminder text.
- **Two test targets**: `OneHundoTests` (unit tests, fast, for the logic) and
  the existing `OneHundoUITests` (launch the app and tap through each screen).
- **Test launch mode**: UI tests launch the app with `-uiTesting`, which uses an
  in-memory store (a clean slate every run) and skips the notification prompt.
- **Accessibility identifiers** on key buttons and labels so UI tests can find them.
- **Swift Charts** for the history chart; **local notifications**
  (`UserNotifications`) for reminders. Neither needs an entitlement or signing changes.

## Data model

- `Challenge`: id, kind (built-in id or custom), name, unit (reps / seconds /
  minutes), icon, color, starting count, goal, daily increase, reminder on/off
  and time, created date, completed date (optional), attempts.
- `Attempt`: date (one per challenge per day), count.
- `BuiltInChallenge` (static data in code, not stored): id, name, description,
  icon, form tips, image names.

Today's target = the latest attempt *before today* (or the starting count if there
is none) + daily increase, capped at the goal. Missed days don't change it, and
logging today doesn't move today's target. On the start day, the starting test
alone doesn't count as "done", so the card says "Try 6 today" after testing at 5.
Logging again that day replaces the test. Reminder time is stored as minutes after
midnight; color as a palette name; unit as a raw string.

## PRs

Each PR bumps the version to `0.<step>.0` (fixes between steps bump the patch,
e.g. 0.4.1); see CLAUDE.md.

### 1. Data model, logic, and unit tests ✅
- SwiftData models above, built-in catalog (Push-ups, Sit-ups, Pull-ups), and the
  target/progress logic.
- Add the `OneHundoTests` unit test target in `project.yml`, add it to the scheme,
  and add `OneHundoTests/**` to the CI `changes` filter.
- Unit tests: target after a normal day, after a short day, after missed days,
  capped at goal, days-to-goal estimate.
- Models follow CloudKit's rules from the start (every property has a default,
  relationships optional, no unique constraints) so iCloud sync can be added later
  without a migration. "One attempt per day" is enforced in code instead.
- No visible change yet.

### 2. App shell and challenge list ✅
- Tab bar: Challenges and Calendar (Calendar is a placeholder for now).
- Challenge grid (2 columns) with cards, the empty state, and the + button
  (opens a placeholder sheet for now).
- `-uiTesting` launch mode, plus `-seedSampleData` to fill the list for tests.
- Replace the "Hello One Hundo" test with: empty state shows on first launch;
  seeded challenges show as cards.

### 3. Add challenge and enroll flow ✅
- Add challenge sheet listing the built-ins (greyed out while one is active,
  i.e. started and not completed).
- Enroll flow: intro (tips as text for now), test yourself, goal and pace,
  reminder (toggle and time saved, not scheduled yet), Start.
- Shared number entry component (− / + and number pad), reused later.
- Custom challenge row shows as "Coming soon" until PR 5.
- UI test: start Push-ups with 5, goal 100; the card shows "Try 6 today".

**Milestone:** you can start real challenges. Worth a TestFlight build.

### 4. Challenge screen and logging ✅
- Challenge screen: header with progress ring, Today section, attempt list.
- Log attempt sheet with the replace-same-day rule, plus edit and delete attempts.
- Small celebration / encouragement after logging, with a "New personal best!"
  badge when the count beats every earlier attempt (not on the first attempt).
- Header stats: personal best and days logged.
- Unit tests for the personal-best and days-logged logic.
- UI test: log 6, card shows "Done: 6"; log again the same day replaces it.
- As built: a new best means beating the starting test and every attempt on other
  days (re-logging a day doesn't compete with itself). Days logged counts the
  starting test's day. Editing an attempt changes its count only; to move it to
  another day, delete it and log that day. The result says "Next time, try for 7"
  (latest count + increase), which also reads right when logging a past day.

**Milestone:** the core daily loop works. Ship to TestFlight and use it daily.

### 5. Custom challenges and challenge settings
- Custom challenge form: name, unit, icon grid, color swatches, counts, reminder.
- Settings screen for any challenge (goal, increase, reminder; name, unit, icon,
  color for custom), and Delete challenge with confirmation.
- Goal can be raised or lowered any time. Lowering it to at or below the current
  count is treated as reaching it (the celebration itself lands in PR 9).
- UI test: create a "Plank" challenge in seconds and see its card.

### 6. Daily reminders
- Ask notification permission when a reminder is first turned on.
- Schedule one repeating local notification per challenge at its reminder time,
  with today's target in the text ("Push-ups: try for 6 today").
- Reschedule after every log, edit, or settings change, so the text stays
  current. Skip today's reminder once logged.
- Unit test the notification text and schedule; check on the phone by hand,
  since UI tests can't easily verify notifications.

### 7. Calendar
- Month calendar with swipe between months and colored dots per day.
- Day view listing that day's attempts and whether the target was hit; tap
  through to the challenge screen.
- UI test: seeded data shows dots; tapping a day lists its challenges.

### 8. Form tips, images, and history chart
- Write tips for each built-in; add form images to the asset catalog
  (illustrations or SF Symbols to start, real images later).
- Collapsible tips section on the challenge screen and in the enroll intro.
- Swift Charts line chart of counts over time on the challenge screen.

### 9. Goal reached and polish
- Goal-reached celebration (full screen, confetti, success haptic), Set a new
  goal (defaults higher, e.g. 150 after 100) / Done, and the Completed section.
- Completed challenges keep their screen and history, with a Continue button
  that sets a new goal and makes them active again. A completed built-in can
  also be started fresh from Add challenge.
- UI test: log the goal count, see the celebration, tap Done, card is under
  Completed; Continue moves it back.
- App icon, accent color, haptics, and a pass on empty and error states.
- Bump `MARKETING_VERSION` to 1.0.0 when you're happy with it: the first App Store release.

## Later

Not scheduled; each would be its own PR series after 1.0.

- **Apple Health**: needs the HealthKit entitlement, a usage string, and signing
  changes in the TestFlight workflow.
- **iCloud sync** (CloudKit): needs the iCloud entitlement, a CloudKit container,
  and the same signing changes. The models are already CloudKit-ready (PR 1).
- **Ads or monetization**.
