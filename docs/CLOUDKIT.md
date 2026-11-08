# iCloud schema (CloudKit)

iCloud keeps app data in two environments.
TestFlight and App Store builds always use
**Production**, which only takes record
types and fields that were first made in
**Development** and then deployed. Without
that, sync quietly does nothing (the app
still works on the phone).

A Mac build normally makes them. TestFlight
can't: its signing always sets Production,
even when the app asks for Development
(tried in PR #101; Apple confirms it on
its forums). An ad hoc build ("Release
Testing") can use Development, so a
one-off ad hoc build installed on the
owner's iPhone makes them, using Apple's
own `initializeCloudKitSchema` (it sends a
sample of every field, so fields that are
always empty so far are made too).

Do this again whenever a schema version
adds a field (Production can only grow:
new fields, never renamed or removed).
Everything works from the phone.

## 1. Put the device ID page online
Once. Ad hoc builds install only on
registered devices, and iPhones don't show
their device ID (UDID). `tools/udid` is a
tiny Cloudflare Worker that shows it,
deployed from Cloudflare's dashboard:
1. In the Cloudflare dashboard: **Workers &
   Pages** → **Create** → import the
   `one-hundo` repository.
2. Root directory: `tools/udid`. Keep the
   default deploy command.
3. If offered, set the build watch paths
   to `tools/udid/*`, so other pushes
   don't redeploy it.
4. Deploy, and note its `workers.dev`
   address.

## 2. Get the device ID
1. Open that address in Safari and tap
   **Get the device ID**.
2. Open Settings, tap **Profile
   Downloaded**, then **Install** (it
   says "Not Verified": it isn't signed,
   which is fine here). It only sends the
   ID, model and iOS version to the page.
3. Safari shows the ID: tap **Copy**.
4. If a profile stayed, delete it in
   Settings → General → VPN & Device
   Management.

## 3. Register the iPhone
1. Open
   developer.apple.com/account/resources/devices.
2. Tap **+**, platform **iOS**, a name
   (e.g. "My iPhone"), and paste the ID.
3. **Continue** → **Register**.

## 4. Build and install it
Coming next (PR 5): an ad hoc build for
Development and a page to install it from
in Safari.

## 5. Run it once
Open the app on Wi-Fi, signed in to
iCloud, and keep it open for a minute.

## 6. Check and deploy
1. In Safari open icloud.developer.apple.com
   → **CloudKit Database** (the desktop
   site, via **aA**, if it's cramped).
2. Pick `iCloud.com.gastly92.onehundo` and
   **Development**. Under **Schema** →
   **Record Types**, check for
   `CD_Challenge` and `CD_Attempt`, with
   fields such as `CD_copyID`,
   `CD_loggedAt` and `CD_completedDate`.
3. Tap **Deploy Schema Changes…**, look
   over the list, and **Deploy**.
4. Switch to **Production**: the same
   record types are there.

## 7. Back to normal builds
Install a normal TestFlight build (the
next one from `main`) over the ad hoc
one. Sync now works.
