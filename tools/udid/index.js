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
<title>Device ID</title>
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
