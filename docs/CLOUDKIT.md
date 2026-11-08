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
3. Set the build watch paths (Settings →
   Build) to `tools/udid/*`, so other
   pushes don't redeploy it. Pull
   requests get a preview of the page
   (a comment with its address); a new
   branch's first push builds one
   anyway.
4. Deploy, and note its `workers.dev`
   address. Worker name
   `onehundo-udid` (must match
   `wrangler.toml`).

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

Once, also register the schema app's ID:
1. Open
   developer.apple.com/account/resources/identifiers,
   tap **+** → **App IDs** → **App**.
2. Description `One Hundo Schema`, Bundle
   ID **Explicit**:
   `com.gastly92.onehundo.schema`.
3. Tick **iCloud** with **Include
   CloudKit support**, and under
   **Edit**/**Configure** tick the
   container `iCloud.com.gastly92.onehundo`.
4. Tick **Push Notifications**.
5. **Continue** → **Register**.

## 4. Build and install it
1. Claude runs the **Schema build**
   workflow (`schema-build.yml`). It
   builds ad hoc for Development with the
   schema upload compiled in, checks the
   signed app uses Development, and
   publishes it as the `schema-build`
   release. A device registered after the
   last run needs a new run.
2. In Safari open the device ID page's
   `/install` (e.g.
   `onehundo-udid.<name>.workers.dev/install`)
   and tap **Install**. It's a separate
   app, **One Hundo Schema**
   (`com.gastly92.onehundo.schema`, same
   iCloud container), since iOS won't put
   an ad hoc build over the TestFlight
   app without deleting it and its data.
   It only uploads the schema samples.

## 5. Run it once
1. iOS opens ad hoc apps only with
   **Developer Mode** on: Settings →
   Privacy & Security → Developer Mode
   (it shows once such an app is
   installed), then restart and confirm.
2. Open **One Hundo Schema** on Wi-Fi,
   signed in to iCloud, and keep it open
   for a minute. It looks empty: it has
   none of your data.

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

## 7. Clean up
Delete **One Hundo Schema** from the
phone, and turn Developer Mode off again
if you like (another restart). One Hundo
itself was never touched, and syncs from
now on.
