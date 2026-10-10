# Implementation plan

How to build what `docs/PRODUCT.md`
describes, as a series of small PRs. Each PR
leaves the app working and passes CI, so any
merged state can go to TestFlight. Check off
a PR here (and update `PRODUCT.md` if the
design changed) as each one lands.

## Approach

- **SwiftUI + SwiftData**, iOS 17. No
  third-party packages in the app itself, so
  it stays small and has no outside code to
  keep updated. Test and CI tooling is fine
  (it never ships to the phone).
- **Checks on every PR**: unit tests, UI
  tests, snapshots of every screen,
  SwiftLint (strict, 100-character lines),
  warnings as errors with strict concurrency,
  100% line coverage of non-view code
  (`Models/`, `Support/`), a lint rule
  against skipping Swift's data race
  checks, and Periphery for unused code.
- **Stored data**: versioned with
  migrations (schema V1 since 0.9.10, the
  shape 1.0 ships with), so App Store users
  never lose data.
- **Testable by design**: views stay thin;
  decisions live in `Models/` or `Support/`,
  and outside pieces (data store, clock,
  notifications) are passed in so tests can
  fake them.
- **Logic is plain Swift, separate from
  views**, so it can be unit tested: today's
  target, progress, "days to goal", reminder
  text.
- **Two test targets**: `OneHundoTests` (unit
  tests, fast, for the logic) and the
  existing `OneHundoUITests` (launch the app
  and tap through each screen).
- **Test launch mode**: UI tests launch the
  app with `-uiTesting`, which uses an
  in-memory store (a clean slate every run),
  skips the notification prompt, and turns
  off UIKit animations.
- **Accessibility identifiers** on key
  buttons and labels so UI tests can find
  them.
- **Swift Charts** for the history chart;
  **local notifications**
  (`UserNotifications`) for reminders.
  Neither needs an entitlement or signing
  changes.

## Data model

- `Challenge`: id, kind (built-in id or
  custom), name, unit (reps / seconds /
  minutes), color, shape, starting count,
  goal, daily increase, reminder on/off and
  time,
  created date, completed date (optional),
  attempts.
- `Attempt`: date (one per challenge per
  day), count.
- `BuiltIn` (static data in code, not
  stored): id, name, description, form tips,
  image names.

Today's target = the latest attempt *before
today* (or the starting count if there is
none) + daily increase, capped at the goal.
Missed days don't change it, and logging
today doesn't move today's target. The
starting test is the start day's attempt, so
the card says "Done: 5" that day and "Try 6
today" the next (changed in 0.4.5). Logging
again that day replaces the test. Reminder
time is stored as minutes after midnight;
color as a palette name; unit and shape
(`Marker`) as raw strings.

## PRs

Each PR bumps the version to `0.<step>.0`
(fixes between steps bump the patch, e.g.
0.4.1); see CLAUDE.md.

### 1. Data model, logic, and unit tests ✅
- SwiftData models above, built-in catalog
  (Push-ups, Sit-ups, Pull-ups), and the
  target/progress logic.
- Add the `OneHundoTests` unit test target in
  `project.yml`, add it to the scheme, and
  add `OneHundoTests/**` to the CI `changes`
  filter.
- Unit tests: target after a normal day,
  after a short day, after missed days,
  capped at goal, days-to-goal estimate.
- Models follow CloudKit's rules from the
  start (every property has a default,
  relationships optional, no unique
  constraints) so iCloud sync can be added
  later without a migration. "One attempt per
  day" is enforced in code instead.
- No visible change yet.

### 2. App shell and challenge list ✅
- Tab bar: Challenges and Calendar (Calendar
  is a placeholder for now).
- Challenge grid (2 columns) with cards, the
  empty state, and the + button (opens a
  placeholder sheet for now).
- `-uiTesting` launch mode, plus
  `-seedSampleData` to fill the list for
  tests.
- Replace the "Hello One Hundo" test with:
  empty state shows on first launch; seeded
  challenges show as cards.

### 3. Add challenge and enroll flow ✅
- Add challenge sheet listing the built-ins
  (greyed out while one is active, i.e.
  started and not completed).
- Enroll flow: intro (tips as text for now),
  test yourself, goal and pace, reminder
  (toggle and time saved, not scheduled yet),
  Start.
- Shared number entry component (− / + and
  number pad), reused later.
- Custom challenge row shows as "Coming soon"
  until PR 5.
- UI test: start Push-ups with 5, goal 100;
  the card shows "Done: 5" (0.4.5; was "Try 6
  today").

**Milestone:** you can start real challenges.
Worth a TestFlight build.

### 4. Challenge screen and logging ✅
- Challenge screen: header with progress
  ring, Today section, attempt list.
- Log attempt sheet with the replace-same-day
  rule, plus edit and delete attempts.
- Small celebration / encouragement after
  logging, with a "New personal best!" badge
  when the count beats every earlier attempt
  (not on the first attempt).
- Header stats: personal best and days
  logged.
- Unit tests for the personal-best and
  days-logged logic.
- UI test: log 6, card shows "Done: 6"; log
  again the same day replaces it.
- As built: a new best means beating the
  starting test and every attempt on other
  days (re-logging a day doesn't compete with
  itself). Days logged counts the starting
  test's day. Editing an attempt changes its
  count only; to move it to another day,
  delete it and log that day. The result says
  "Next time, try for 7" (latest count +
  increase), which also reads right when
  logging a past day.

**Milestone:** the core daily loop works.
Ship to TestFlight and use it daily.

#### 4.1 UX polish from first use (0.4.1) ✅
- First screen explains the idea in three
  steps instead of a bare empty state.
- "Set your plan" step: quick goal buttons, a
  "1 more each day" stepper instead of the
  +1/+2/… picker, and a Today → Tomorrow →
  Goal preview.
- Long-press a card: Log attempt / Edit
  today, and Delete challenge (pulled forward
  from PR 5). History rows are tap-to-edit
  with a hint.
- 0.4.2: both tabs share one title header, so
  the title doesn't jump when switching tabs.
- 0.4.3: both tabs use the standard iOS large
  title instead of a custom header, which
  still bounced a little when switching tabs.
  The + becomes an "Add challenge" tile at
  the end of the grid, so the title bar stays
  plain.
- 0.4.4: no challenge icons. Apple has no
  push-up, sit-up, or pull-up symbol, so
  challenges are told apart by name and
  color. `Challenge.icon` is removed from the
  stored data, and the pre-1.0 schema
  versioning from 4.2 goes too (see Stored
  data).
- 0.4.5: the starting test counts as the
  start day's attempt: the card says "Done:
  5" until the next day, instead of "Try 6
  today" right after starting.

#### 4.2 Safety tooling ✅
- Stored data versioning (dropped in 0.4.4
  until 1.0, see Stored data above).
- App Store privacy manifest (no tracking, no
  data collected), checked by a test.
- Thread Sanitizer on every test run, and
  Periphery for unused code, both in CI.
- No version bump (nothing user-visible).

#### 4.3 CI diagnostics and tidy-up ✅
- A failed UI test prints its step-by-step
  log (taps, waits, what it found), and the
  CI summary shows build and test times.
- The Release device build runs in its own
  job alongside the tests; the unused
  simulator app build and downloadable app
  files are dropped. Every check still gates
  PRs.
- Not a speed-up: runs still take about 13
  minutes, almost all building and running
  the tests on one simulator. Two simulators
  in parallel overloaded the 3-core runner
  (the second timed out, the first slowed
  down 4x).

#### 4.4 Localization prep ✅
- All text is translatable, still English
  only: a String Catalog
  (`Localizable.xcstrings`) with plural forms
  ("1 day" / "95 days", seconds, minutes),
  `String(localized:)` for text built in
  code, and `LocalizedStringKey` for view
  helpers.
- Built-in challenges show their name in the
  user's language even if started in another,
  and the "Test yourself" question is a whole
  sentence per challenge.
- `LocalizationTests` runs the main screens
  in a pseudo-language that brackets every
  translatable string, and fails on any
  visible text without brackets.
- No version bump (nothing visible changes in
  English).

#### 4.5 Screen list ✅
- Every screen and screen state is a
  `ScreenID` case, shown on its own by
  `ScreenHost` (`-showScreen <id>`, with
  sample data where needed). The
  accessibility audit and the localization
  check loop over all of them, so new screens
  are covered automatically.
- Screens live in `Views/Screens/`; CI fails
  if one isn't in the list.
- A SwiftLint rule flags untranslated
  sentences in `Models/` and `Support/`.
- Step 4.11's snapshot tests can loop over
  the same list.
- No version bump (nothing visible changes).

#### 4.6 80-character lines ✅
- SwiftLint's line limit drops from 100 to
  80, so diffs wrap less on the phone (a
  portrait diff fits only about 45
  characters, so long lines still wrap
  there). All Swift code and comments are
  rewrapped; no text changes.
- No version bump (nothing visible changes).

#### 4.7 60-character lines ✅
- SwiftLint's line limit drops to 60. Code
  fits by shorter names (e.g.
  `attempt(on:in:)` instead of `calendar:`,
  `Progression` takes `step:`), small helpers
  where nesting was deep (screen sections,
  `DoneMark`, `wrapsText()`), and `"""`
  literals for long text. Tests use short
  helpers (`pushUps.log(5, day: 1)`,
  `element.appears()`).
- No version bump (nothing visible changes).

#### 4.8 46-character lines ✅
- SwiftLint's line limit drops to 46, so each
  diff line fits a phone in portrait. Code is
  indented with 2 spaces.
- Shorter names: `BuiltIn` (was
  `BuiltInChallenge`), `CountUnit` (was
  `ChallengeUnit`); helpers `LeadingStack`,
  `.testID`, `.fullWidth`; UI tests use
  `App.start` and
  `app.text(_:)`/`button(_:)`. A few test IDs
  got shorter (`addTile`, `enrollNext`,
  `testCount.plus`).
- No version bump (nothing visible changes).

#### 4.9 46-character docs and config ✅
- Docs, YAML and scripts fit in 46 too, and a
  `Line length` CI job (part of the CI Gate)
  checks them. Workflow steps sit at the same
  indent as `steps:`; the test step moved
  into `.github/scripts/run-tests.sh`.
- No version bump (nothing visible changes).

#### 4.10 Workflow, script and lint checks ✅
- A `Workflows & scripts` CI job (part of the
  CI Gate) runs actionlint on the workflows
  and ShellCheck on the scripts, pinned to
  versions that also run in this container.
- More SwiftLint rules, including
  `indentation_width` (2 spaces; wrapped
  lines go in one level, not aligned by
  hand).
- No version bump (nothing visible changes).

#### 4.11 Screen snapshot tests ✅
Most screens exist by now, and steps 5–9
change a lot of UI (step 5 reworks shared
pieces like the number entry), so snapshots
go in first.
- Add Point-Free's `swift-snapshot-testing`
  to the test targets only (SPM via
  `project.yml`).
- One snapshot per `ScreenID` (opened with
  `-showScreen`, as the accessibility and
  localization tests do). Light and dark
  mode, and one large text size.
- Stable rendering: one fixed simulator model
  and OS, a fixed "now" for seeded dates
  (e.g. a `-fixedDate` launch argument),
  animations off.
- Reference images are committed in the repo,
  so PR diffs show before/after images.
  There's no Mac to record them, so CI
  records them: a manual workflow (or a PR
  label) re-records and commits the images to
  the PR branch. On a mismatch, CI uploads
  the diff images as an artifact and fails.
- No version bump (nothing user-visible).
- Then add a coverage gate for views, set
  from what the snapshots reach (4.13 gates
  every line at 100%).

#### 4.12 Dark mode and large text audit ✅
- Run the accessibility audit on every screen
  in dark mode (contrast only) and at the
  largest text size (all checks but Dynamic
  Type, which can't grow further). Dark mode
  comes from a `-darkMode` launch flag, not
  the simulator setting (switching that made
  launches time out).
- Fix: at accessibility text sizes, a
  challenge card's checkmark sits above
  "Done: 20" instead of squeezing it into
  breaking mid-word (seen in the snapshots).
- Fix: at accessibility text sizes the quick
  goal buttons (50/100/150/200) go in two
  rows, so "100" fits inside its button.
- Version 0.4.6 (the card fix shows).

#### 4.13 Swift 6 and 100% coverage ✅
- Every target builds in Swift 6 language
  mode, so data races are compile errors
  (tests included), before step 5 adds
  settings and step 6 notifications.
- Every line of the app must run in tests,
  views included (they were at 97%). To get
  there:
  - UI tests now cover the card's long-press
    Log attempt, editing and deleting history
    attempts, and Back in the enroll flow.
  - Logic moved out of views and is unit
    tested: number field input
    (`NumberText`), raising the goal past
    today's test (`Progression.goal`), and
    reminder times as minutes
    (`ReminderTime`).
  - The welcome screen is the real empty
    list, and the store-error screen opens
    through the real failure path.
  - Sample data gains a Plank in seconds,
    with a `logTimed` screen state.
  - Dead code went.
- No version bump (nothing visible changes).

#### 4.14 45-character lines ✅
- A 46-character line still wraps by one
  character in the GitHub app on the phone.
  Lower the limit to 45 everywhere:
  SwiftLint's `line_length`,
  `.github/scripts/check-lines.py`, and
  every mention of 46 in CLAUDE.md and
  comments; rewrap the ~240 lines at
  exactly 46.
- No version bump (nothing visible changes).

#### 4.15 Challenge card layout ✅
- Found in the snapshots at large text:
  cards in a row have different heights and
  aren't top-aligned, and narrow cards break
  words ("sec-onds", "Push-ups").
- Cards in a row match heights, top-aligned.
- At accessibility text sizes the list shows
  one card per row.
- Re-record the challenge list snapshots.
- Version 0.4.7 (visible fix).

#### 4.16 Audit without exemptions ✅
- No labels are exempt from the
  accessibility audit any more, and no
  audit is retried: a failure is real.
- The audit's Dynamic Type check is off: it
  enlarges text and fails on whatever that
  pushes off screen. A `fixed_font_size`
  lint rule catches the real cause instead;
  it found a fixed 72pt icon on the log
  result screen, now scaled.
- Scrolling each screen to audit text
  below the fold was tried and dropped:
  simulated drags made the tests flaky.
- With one card per row, the done
  checkmark fits beside "Done: 20" again at
  accessibility sizes.
- Version 0.4.8 (visible fix).

#### 4.17 Parallel CI ✅
- CI builds the tests once, then runs them
  in four shards on separate runners at
  the same time: accessibility in light,
  in dark (with localization), and at the
  largest text, and everything else. A
  last job merges the results for the
  coverage gate. About half the wait.

#### 4.18 No Thread Sanitizer ✅
- Snapshots set the standard text size, so
  light and dark match a real phone.
- Thread Sanitizer is off: Swift 6 mode
  already makes data races compile errors,
  it never found one, and without it the
  tests run 25–30% faster. A lint rule
  bans the ways to skip Swift's check
  (`@unchecked Sendable`,
  `nonisolated(unsafe)`, `@preconcurrency`).
- No version bump (nothing user-visible).

#### 4.19 No accessibility audit ✅
- Xcode's accessibility audit is gone: on
  CI's simulators one screen's audit
  stalled at random (about 1 job in 4),
  with or without Thread Sanitizer. Its
  `-darkMode` launch flag and exceptions
  went with it. Lint, large text snapshots
  and UI tests (which find controls by
  their labels) still cover most of it; a
  manual check on the phone is in step 9.
- CI runs two test shards (main,
  localization), straight from the build's
  `.xctestrun`, without XcodeGen.
- No version bump (nothing user-visible).

### 5. Custom challenges and settings ✅
- Custom challenge form: name, unit, color
  swatches, counts, reminder (no icon).
- Settings screen for any challenge (goal,
  increase, reminder; name, unit, and color
  for custom), and Delete challenge with
  confirmation.
- Goal can be raised or lowered any time.
  Lowering it to at or below the current
  count is treated as reaching it (the
  celebration itself lands in PR 9).
- UI test: create a "Plank" challenge in
  seconds and see its card.
- As built (0.5.0): both forms edit a
  `ChallengeDraft` (Models), which checks
  them, starts a custom challenge, and
  saves settings, so the logic is unit
  tested. They share `CustomSections`
  (name, unit), `LookSections` (shape,
  color) and `PlanSections` (goal, daily
  step, reminder). Settings is a sheet
  with Cancel / Save; a built-in keeps its
  name, unit, shape and color.
- Shapes, so color is never the only way
  to tell challenges apart: each challenge
  has a `Marker` (circle, square, triangle,
  diamond, star, hexagon), shown before its
  name on the card. New stored field
  `markerName`; SwiftData adds it with no
  reinstall. Deleting
  there closes settings and the challenge
  screen first, then deletes. A goal at or
  below the current count says "this goal
  counts as reached".

#### 5.1 UI tests without animations ✅
- A long-press in a UI test sometimes
  opened the Edit sheet instead of its
  menu: the screen recording showed it
  landed while the screen was still sliding
  in, so iOS read it as a tap. `-uiTesting`
  now turns off UIKit animations. No
  retries or longer waits.
- No version bump (nothing user-visible).

### 6. Daily reminders ✅
- Ask notification permission when a reminder
  is first turned on.
- Schedule one repeating local notification
  per challenge at its reminder time, with
  today's target in the text ("Push-ups: try
  for 6 today").
- Reschedule after every log, edit, or
  settings change, so the text stays current.
  Skip today's reminder once logged.
- Unit test the notification text and
  schedule; check on the phone by hand, since
  UI tests can't easily verify notifications.
- As built (0.6.0): not one repeating
  notification but one per day for the next
  14 days (`ReminderPlan`), since a repeating
  one can't skip a logged day or change its
  text. Title is the name, text "Try for 6
  today." iOS keeps 64 at most, so the
  soonest 64 are kept.
- `RootView` schedules them again whenever
  they'd change (a log, edit, delete, new
  challenge or settings) and each time the
  app comes back, so the 14 days move on.
  It asks for permission first if any
  challenge has a reminder on; iOS shows the
  prompt only once.
- Outside pieces go through `Notifier`:
  `PhoneNotifier` on the phone,
  `SilentNotifier` in UI tests (no prompt),
  a fake in unit tests. One UI test
  (`-notifications`) taps Allow on the real
  prompt.
- If notifications are turned off in iOS
  Settings, reminders silently don't come;
  a hint for that could come in step 9.

#### 6.1 Long-press after a CI stall
- CI's free macOS runners (3 cores, no
  GPU) stall for seconds now and then. A
  long-press held during a stall reaches
  the app as a tap, so the card or history
  menu never opens (seen in a screen
  recording; the same failure hit before
  step 6). Slow spells hit a random test
  each run; long-presses are the only step
  they break.
- `menuItem` presses again (up to twice,
  as of step 7, after one run stalled
  twice in a row) only on that sign: no
  menu, and what a tap opens (the
  challenge screen, or the Edit sheet) is
  showing. It closes that first and logs
  "Long-press read as a tap" in the CI log.
  Any other miss still fails.
- `testLongPressLogsToday` makes its first
  press a tap, so the retry path runs on
  every CI run.
- No version bump (tests only).

### 7. Calendar ✅
- Month calendar with swipe between months
  and a shape marker per challenge per day
  (in its color, but never color alone).
- Day view listing that day's attempts and
  whether the target was hit; tap through to
  the challenge screen.
- UI test: seeded data shows dots; tapping a
  day lists its challenges.
- As built (0.7.0): `CalendarMonth`
  (Models) lays out a month (weeks start on
  the phone's first weekday) and handles
  the arrows and swipes; it stops at the
  current month. `DayEntry` says how each
  day went: "Hit the target of 6.", "The
  target was 7.", or "Started this
  challenge" on its first day (was
  "Starting test", unclear on the phone).
  Only days with
  attempts open a day view. Up to 3
  markers a day; VoiceOver reads a day as
  its number and the challenges' names.
- Completed challenges still show their
  days (step 9 adds completing).

#### 7.1 Restart a stuck UI test runner
- On CI's simulators the UI test runner
  sometimes fails to start ("Timed out
  while loading Accessibility") before any
  UI test runs. `run-tests.sh` runs the
  shard once more on exactly that sign,
  with a warning; any other failure stands.
- Not retried: a job GitHub never starts
  (no free macOS runner). It's re-run by
  hand; a watcher workflow can come if it
  gets common.
- Booting the simulator has a 5-minute
  limit (it takes seconds): a hung runner
  sat there for the job's whole 25
  minutes (#68). It fails, not retries;
  re-run by hand.
- No version bump (CI only).

### 8. Form tips, images, and history chart ✅
- Write tips for each built-in; add form
  images to the asset catalog (illustrations
  or SF Symbols to start, real images later).
- Collapsible tips section on the challenge
  screen and in the enroll intro.
- Swift Charts line chart of counts over time
  on the challenge screen.
- As built (0.8.0): tips are a shared
  `FormTips` ("Good form", opens and
  closes): open in the enroll intro,
  closed on the challenge screen.
  `HistoryChart` draws each attempt's
  count by day (line and points) in the
  challenge's color. Both sit below the
  history on the challenge screen, so its
  rows stay on screen first.
- Calendar fixes from first use: every
  day's number lines up (a day without
  markers keeps an empty marker row), and
  today is a filled accent circle instead
  of bold, which had shrunk it.
- No images yet: Apple has no push-up,
  sit-up or pull-up symbol (see 0.4.4), so
  real form images need artwork; they can
  come later.

### 9. Goal reached and polish
Split into four PRs: 9a goal reached, 9b
polish, 9c release safety (schema V1,
performance, telemetry), 9d App Store
listing and 1.0.0.

#### 9a. Goal reached ✅
- Goal-reached celebration (full screen,
  confetti, success haptic), Set a new goal
  (defaults higher, e.g. 150 after 100) /
  Done, and the Completed section.
- Completed challenges keep their screen and
  history, with a Set a new goal button that
  makes them active again. A
  completed built-in can also be started
  fresh from Add challenge.
- UI test: log the goal count, see the
  celebration, tap Done, card is under
  Completed; Set a new goal moves it back.
- As built (0.9.0): logging the goal (or
  lowering it to the current count in
  settings) completes the challenge right
  away, so swiping the sheet away counts
  as Done. The result screen adds
  confetti and Set a new goal, which opens
  `NewGoalView` (suggests half as much
  again, to the nearest 10:
  `Progression.nextGoal`); Keep going
  sets the goal and makes it active
  again. Completed cards say "Reached
  100" under a Completed heading; the
  challenge screen swaps Log for Continue
  (the same new goal screen). Reminders
  stop while completed. `GoalTests` runs
  both paths; screens `goalReached` and
  `newGoal`.
- Day view fix: each count is centered in
  its row, in line with the chevron.
- 0.9.1: Done is the main button after
  reaching a goal; Set a new goal is the
  secondary one above it.
- 0.9.2: on a completed challenge,
  Continue is now "Set a new goal" (it
  read as moving on), and its sheet has
  Cancel. Screens `completedList` and
  `completedDetail` (sample Push-ups
  reached a goal of 10) give completed
  challenges snapshots too.
- 0.9.3: snapshots for the other screen
  states: a missed target (`logMissed`),
  logging a day already logged
  (`logReplace`), a challenge with no
  attempts (`noHistory`), and a new goal
  that's too low (`newGoalLow`), built-ins
  in progress (`addInProgress`), a missed
  target in the day view (`dayMissed`), a
  challenge logged today (`detailToday`),
  and the reminder off
  (`settingsNoReminder`), the app with its
  tab bar (`tabs`), and the custom form in
  seconds (`customTimed`). A CI gate keeps
  the list complete: view code the
  localization shard (every ScreenID) never
  draws must be listed in
  `.github/unpictured.txt`. Cancel
  moved into `NewGoalView`, so `newGoal`
  shows it. Fix: the suggested new goal
  builds on the count when it went past
  the goal (log 200 of 100: 300, not 150,
  which was below the count).

#### 9b. Polish
- App icon and accent color ✅ (0.9.4): a
  neon ring (light blue into purple) with
  "100" inside, in light, dark and tinted
  versions, drawn by
  `.github/scripts/app-icon.sh`
  (ImageMagick, Inter Display Bold). The
  accent is a neon violet, tuned so white
  text on it and it on black both pass
  4.5:1 contrast. Challenges default to a
  new Violet swatch (the accent); built-ins
  always show their built-in color, so an
  existing Push-ups turns violet too.
- Haptics and empty states (0.9.5): a
  light tap when picking a goal, shape or
  color and on − / +, on top of the
  success tap after logging. The progress
  chart says "Log a couple of days to see
  your progress here." until there are two
  attempts (it was a blank box). CI: only
  the run that adding `record-snapshots`
  starts records everything, so a later
  run while the label is still on (the
  bot's commit) doesn't record again.
- Large-text snapshots are three phones
  tall: at that size most screens ran past
  the bottom, and what was below (the
  Completed section, the progress chart)
  was never pictured.
- Empty calendar (0.9.6): a month with
  nothing logged says so under the grid,
  and that each day you log shows your
  challenges' shapes. Away from this
  month, a Today button jumps back
  (screen `calendarEmpty`: no challenges,
  last month).
- Light icon inverted (0.9.7): a glowing
  white ring and "100" on the blue-to-
  purple gradient, instead of a colored
  ring on near-white, which looked plain
  next to other icons. The calendar
  always draws six week rows, so the
  empty-month note and the page don't
  jump between months.
- Completed cards (0.9.8): the date the
  goal was reached replaces "100 / 100",
  and there's no "logged today" checkmark,
  so two runs of a restarted built-in read
  as two runs. The custom form's name
  example is "e.g. Squats" (it was "e.g.
  Plank", while the unit starts on reps).
- Add challenge tile (0.9.9): always a
  card's height. Alone in its row it fell
  back to a fixed minimum and looked
  shorter; it now sits on a hidden empty
  card (same fonts and spacing), so it
  matches at any text size.

#### 9c–9d. Release

- Manual accessibility check on the phone:
  VoiceOver on every screen (each control
  named, sensible order) and the largest
  text size (nothing cut off, buttons easy
  to tap). Replaces the automated audit.
- Stored data versioning ✅ (0.9.10): the
  models are frozen as `SchemaV1` (a
  `VersionedSchema`, the app uses them
  through `Challenge`/`Attempt` aliases),
  opened with the `Migrations` plan.
  `StoreTests` writes a store with V1 and
  reopens it through the plan. Every later
  model change adds a version, a migration
  stage, and keeps that test.
- Time zone tests ✅: `TimeZoneTests`
  logs either side of midnight and across
  both daylight saving changes (US
  Pacific), checking days and targets
  follow the phone's calendar.
- Crash and usage telemetry ✅: Apple's
  own, no code. Crash and hang reports come
  through Xcode Organizer / App Store
  Connect, and App Analytics shows installs,
  sessions and retention, both from users
  who opt in to share analytics on their
  device. The app collects nothing itself,
  so the privacy manifest stays as it is
  and the App Store privacy label is "Data
  Not Collected" (step 9d). A third-party
  SDK only if these fall short.
- Performance tests ✅: `PerformanceTests`
  times the work behind the list, a
  challenge's screen, a calendar month and
  logging, on three challenges with a year
  of daily attempts each, against fixed
  ceilings about ten times CI's times.
  (Xcode's saved baselines are tied to one
  machine, and CI's free runners differ
  run to run.) App launch isn't timed: it
  opens one small store, and a launch
  metric adds about a minute to CI.
- Support and privacy pages ✅: `site/`,
  published by GitHub Pages at
  https://gastly92.github.io/one-hundo/
  (support) and `privacy.html`, for the
  listing's required URLs.
- App Store listing: screenshots made by a
  UI test from the sample data (light mode,
  the required iPhone sizes), plus the
  description, keywords and support URL.
- Bump `MARKETING_VERSION` to 1.0.0 when
  you're happy with it: the first App Store
  release.

## Later

Not scheduled; each would be its own PR
series after 1.0.

- **Apple Health**: needs the HealthKit
  entitlement, a usage string, and signing
  changes in the TestFlight workflow.
- **iCloud sync** (CloudKit): needs the
  iCloud entitlement, a CloudKit container,
  and the same signing changes. The models
  are already CloudKit-ready (PR 1).
- **iPhone Duo (foldable) support**: apps
  fill its inner screen only when built
  with Xcode 27.1 or later (older builds
  show with black borders), and from
  April 2027 App Store submissions need
  Duo screenshots. When GitHub's free
  `macos-26` runners have Xcode 27.1 (a
  reminder checks from 2026-10-26),
  switch CI and the TestFlight workflow to
  it, re-record snapshots, check the
  portrait lock and wide layouts on the
  inner screen, and add Duo-sized
  snapshots and App Store screenshots.
- **"Lower is better" challenges**, e.g.
  a faster mile time (shown as mm:ss) or
  less screen time. Targets step down,
  hitting one means at or below it, and
  new goals, progress, the chart and the
  celebration all read the other way.
- **Ads or monetization**.
