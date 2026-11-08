# iCloud schema (CloudKit)

iCloud keeps app data in two environments.
TestFlight and App Store builds always use
**Production**, which only takes record
types and fields that were first made in
**Development** and then deployed. Without
that, sync quietly does nothing (the app
still works on the phone).

A Mac build normally makes them. With no
Mac, a one-off TestFlight build does it:
built with `CLOUDKIT_SCHEMA` and signed for
Development, it uploads a sample of every
field from a throwaway store, then deletes
it (`Support/CloudKitSchema.swift`). That
build keeps your data off iCloud; it still
opens it on the phone as usual.

Do this again whenever a schema version
adds a field (Production can only grow:
new fields, never renamed or removed).

## 1. Build it
Claude runs the TestFlight workflow with
`cloudkit: Development` (first with
`upload` off, to check it signs for
Development). Its tag ends in `-schema`.

## 2. Run it once
1. Install that build from TestFlight.
2. Open the app and keep it open, on
   Wi-Fi and signed in to iCloud, for a
   minute.

## 3. Check Development
1. In Safari open icloud.developer.apple.com
   and sign in → **CloudKit Database**.
2. Pick the container
   `iCloud.com.gastly92.onehundo` and the
   **Development** environment.
3. Under **Schema** → **Record Types**,
   check for `CD_Challenge` and
   `CD_Attempt`, with fields such as
   `CD_copyID`, `CD_loggedAt` and
   `CD_completedDate`.

## 4. Deploy to Production
1. Still in Development, tap **Deploy
   Schema Changes…**, look over the
   list, and **Deploy**.
2. Switch to **Production**: the same
   record types are there.

## 5. Back to normal builds
Install a normal TestFlight build (the
next one from `main`). Sync now works.
