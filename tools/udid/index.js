// Shows an iPhone's device ID (UDID)
// using Apple's profile service: the
// profile asks iOS to send the device's
// details here, and the reply redirects
// Safari to a page showing them. Nothing
// is stored or logged.

const page = (body) =>
  new Response(
    `<!doctype html>
<meta name="viewport"
  content="width=device-width">
<title>One Hundo</title>
<style>
  body { font: 17px -apple-system,
    sans-serif; margin: 24px; }
  code { font-size: 15px;
    word-break: break-all; }
  a, button { font-size: 17px; }
</style>
${body}`,
    {
      headers: {
        "content-type":
          "text/html; charset=utf-8",
      },
    },
  );

const profile = (origin) =>
  `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC
  "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadType</key>
  <string>Profile Service</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
  <key>PayloadIdentifier</key>
  <string>com.gastly92.onehundo.udid</string>
  <key>PayloadUUID</key>
  <string>5B0A7E2C-3D4F-4E61-9A8B-1C2D3E4F5A6B</string>
  <key>PayloadDisplayName</key>
  <string>One Hundo: device ID</string>
  <key>PayloadDescription</key>
  <string>Sends this iPhone's device ID to show it to you. Installs nothing.</string>
  <key>PayloadContent</key>
  <dict>
    <key>URL</key>
    <string>${origin}/reply</string>
    <key>DeviceAttributes</key>
    <array>
      <string>UDID</string>
      <string>PRODUCT</string>
      <string>VERSION</string>
    </array>
  </dict>
</dict>
</plist>`;

// The reply is a signed plist; its text
// sits inside as is.
const field = (text, key) => {
  const found = text.match(
    new RegExp(
      `<key>${key}</key>\\s*` +
        "<string>([^<]*)</string>",
    ),
  );
  return found ? found[1] : "";
};

// The schema build (docs/CLOUDKIT.md),
// published by schema-build.yml.
const release =
  "https://github.com/Gastly92/one-hundo/" +
  "releases/download/schema-build/" +
  "OneHundo.ipa";

// What iOS reads to install an ad hoc
// build over the air.
const manifest = (origin) =>
  `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC
  "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>items</key>
  <array>
    <dict>
      <key>assets</key>
      <array>
        <dict>
          <key>kind</key>
          <string>software-package</string>
          <key>url</key>
          <string>${origin}/app.ipa</string>
        </dict>
      </array>
      <key>metadata</key>
      <dict>
        <key>bundle-identifier</key>
        <string>com.gastly92.onehundo</string>
        <key>bundle-version</key>
        <string>1.1.0</string>
        <key>kind</key>
        <string>software</string>
        <key>title</key>
        <string>One Hundo (schema build)</string>
      </dict>
    </dict>
  </array>
</dict>
</plist>`;

const escape = (text) =>
  text.replace(/[^A-Za-z0-9,.-]/g, "");

export default {
  async fetch(request) {
    const url = new URL(request.url);
    if (url.pathname === "/profile") {
      return new Response(
        profile(url.origin),
        {
          headers: {
            "content-type":
              "application/x-apple-aspen-config",
          },
        },
      );
    }
    if (
      url.pathname === "/reply" &&
      request.method === "POST"
    ) {
      const bytes = new Uint8Array(
        await request.arrayBuffer(),
      );
      const text = new TextDecoder(
        "latin1",
      ).decode(bytes);
      const done = new URL("/done", url);
      for (const key of [
        "UDID",
        "PRODUCT",
        "VERSION",
      ]) {
        done.searchParams.set(
          key,
          field(text, key),
        );
      }
      // iOS opens a 301's address in
      // Safari.
      return Response.redirect(done, 301);
    }
    if (url.pathname === "/install") {
      const link =
        "itms-services://?action=" +
        "download-manifest&url=" +
        encodeURIComponent(
          `${url.origin}/manifest.plist`,
        );
      return page(`<h1>Schema build</h1>
<p>The one-off build that makes iCloud's
  schema (docs/CLOUDKIT.md). It installs
  over the App Store or TestFlight app and
  keeps your data.</p>
<p><a href="${link}">Install</a></p>
<p>Then open it once, on Wi-Fi and signed
  in to iCloud, for a minute.</p>`);
    }
    if (url.pathname === "/manifest.plist") {
      return new Response(
        manifest(url.origin),
        {
          headers: {
            "content-type": "application/xml",
          },
        },
      );
    }
    if (url.pathname === "/app.ipa") {
      // GitHub redirects to its file
      // storage; serve it from here so iOS
      // gets it from one https address.
      const file = await fetch(release);
      if (!file.ok) {
        return new Response(
          "No schema build yet.",
          { status: 404 },
        );
      }
      return new Response(file.body, {
        headers: {
          "content-type":
            "application/octet-stream",
        },
      });
    }
    if (url.pathname === "/done") {
      const get = (key) =>
        escape(
          url.searchParams.get(key) ?? "",
        );
      const udid = get("UDID");
      return page(`<h1>Device ID</h1>
<p><code id="udid">${udid}</code></p>
<p><button onclick="navigator.clipboard
  .writeText('${udid}')">Copy</button></p>
<p>${get("PRODUCT")}, iOS
  ${get("VERSION")}</p>
<p>Now delete the profile if one stayed:
  Settings → General → VPN &amp; Device
  Management.</p>`);
    }
    return page(`<h1>Find this iPhone's
  device ID</h1>
<p>Installs a profile that only sends
  this iPhone's device ID, model and iOS
  version back here, to show you. Nothing
  is kept.</p>
<p><a href="/profile">Get the device
  ID</a></p>
<p>Then open Settings, tap
  <b>Profile Downloaded</b>, and
  <b>Install</b>.</p>`);
  },
};
