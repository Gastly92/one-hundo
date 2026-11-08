// Runs the Worker with sample requests:
// `node --test` (CI: worker-preview.yml).
import assert from "node:assert/strict";
import { test } from "node:test";
import worker from "./index.js";

const get = (path, init) =>
  worker.fetch(
    new Request(`https://w.dev${path}`, init),
  );

test("the start page links the profile", async () => {
  const page = await (await get("/")).text();
  assert.match(page, /href="\/profile"/);
});

test("the profile sends replies here", async () => {
  const res = await get("/profile");
  assert.equal(
    res.headers.get("content-type"),
    "application/x-apple-aspen-config",
  );
  const text = await res.text();
  assert.match(text, /^<\?xml version="1.0"/);
  assert.match(text, /https:\/\/w\.dev\/reply/);
  assert.match(text, /<string>UDID<\/string>/);
});

test("a reply opens the ID page", async () => {
  // iOS signs the plist; its text is
  // inside as is.
  const body =
    "0\u0082junk<plist><dict>" +
    "<key>PRODUCT</key>\n" +
    "<string>iPhone17,1</string>" +
    "<key>UDID</key>\n\t" +
    "<string>00008130-ABC</string>" +
    "<key>VERSION</key>" +
    "<string>23F77</string>" +
    "</dict></plist>junk";
  const res = await get("/reply", {
    method: "POST",
    body,
  });
  assert.equal(res.status, 301);
  const to = new URL(
    res.headers.get("location"),
  );
  const page = await (
    await get(to.pathname + to.search)
  ).text();
  assert.match(
    page,
    /<code id="udid">00008130-ABC</,
  );
  assert.match(page, /iPhone17,1, iOS/);
});

test("the ID page shows no markup", async () => {
  const page = await (
    await get("/done?UDID=<script>x")
  ).text();
  assert.doesNotMatch(page, /<script>x/);
});

test("install links the manifest", async () => {
  const page = await (
    await get("/install")
  ).text();
  assert.match(
    page,
    /itms-services:\/\/\?action=download-manifest&url=https%3A%2F%2Fw\.dev%2Fmanifest\.plist/,
  );
});

test("the manifest names the schema app", async () => {
  const text = await (
    await get("/manifest.plist")
  ).text();
  assert.match(
    text,
    /<string>com\.gastly92\.onehundo\.schema<\/string>/,
  );
  assert.match(text, /https:\/\/w\.dev\/app\.ipa/);
});

test("the app is passed through", async (t) => {
  t.mock.method(globalThis, "fetch", async () =>
    new Response("IPA"),
  );
  const res = await get("/app.ipa");
  assert.equal(await res.text(), "IPA");
});

test("no build yet is a 404", async (t) => {
  t.mock.method(globalThis, "fetch", async () =>
    new Response("", { status: 404 }),
  );
  const res = await get("/app.ipa");
  assert.equal(res.status, 404);
});
