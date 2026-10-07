# TestFlight setup

One-time setup, all doable on an iPhone in
Safari. Do these after your Apple Developer
Program membership is active.

## 1. Find your Team ID
1. Open developer.apple.com/account in Safari
   and sign in.
2. Scroll to **Membership details**.
3. Copy the **Team ID** (10 characters, like
   `AB12CD34EF`). Save it in Notes.

## 2. Register the bundle ID
1. Go to
   developer.apple.com/account/resources/identifiers.
2. Tap **+** → **App IDs** → Continue →
   **App** → Continue.
3. Description: `One Hundo`.
4. Bundle ID: **Explicit**,
   `com.gastly92.onehundo`.
5. Tap Continue → **Register**.

## 3. Create the app in App Store Connect
1. Open appstoreconnect.apple.com → **Apps**
   → **+** → **New App**.
2. Platform: **iOS**. Name: `One Hundo`. If
   the name is taken, add a word; you can
   change it later.
3. Primary language: your choice. Bundle ID:
   pick `com.gastly92.onehundo`.
4. SKU: `onehundo`. User access: **Full
   Access**.
5. Tap **Create**.

## 4. Create an API key
1. In App Store Connect go to **Users and
   Access** → **Integrations** → **App Store
   Connect API**.
2. The first time, tap **Request Access** and
   accept the terms.
3. Under **Team Keys** tap **+**. Name:
   `GitHub`. Access: **Admin**. Tap
   **Generate**.
4. Copy the **Issuer ID** (shown above the
   key list) into Notes.
5. Copy the key's **Key ID** into Notes.
6. Tap **Download** next to the key. You can
   only download it once.

## 5. Copy the key's text
1. Open the **Files** app → Downloads →
   `AuthKey_XXXXXXXXXX.p8`.
2. Long-press → **Rename** → change `.p8` to
   `.txt`.
3. Open it, select all the text (including
   the `-----BEGIN` and `-----END` lines),
   and copy it.

## 6. Add GitHub secrets
1. In Safari, open
   github.com/Gastly92/one-hundo →
   **Settings** → **Secrets and variables** →
   **Actions**.
2. Tap **New repository secret** and add each
   of these:

| Name | Value |
|---|---|
| `APPLE_TEAM_ID` | Team ID from step 1 |
| `ASC_ISSUER_ID` | Issuer ID from step 4 |
| `ASC_KEY_ID` | Key ID from step 4 |
| `ASC_KEY_P8` | The key text from step 5 |

Then delete the downloaded key file from
Files.

## 7. Add yourself as a tester
1. In App Store Connect open **One Hundo** →
   **TestFlight** tab.
2. Under **Internal Testing** tap **+**, name
   the group `Me`, and add yourself.

## 8. Build and install
1. In the GitHub app: repo → **Actions** →
   **TestFlight** → **Run workflow**.
2. Wait for the run to go green (about 5
   minutes), then 5–15 minutes more for Apple
   to process the build.
3. Install **TestFlight** from the App Store,
   sign in with the same Apple ID, and tap
   **Install** on One Hundo.

Each later build: just repeat step 8.1. Build
numbers go up automatically.
