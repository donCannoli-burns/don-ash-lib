import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { AshWasmCore, AshClient, Item } from "../js/kolmafia-ash.js";

const wasm = await readFile(new URL("../dist/kolmafia_ash.wasm", import.meta.url));
const core = await AshWasmCore.instantiate(wasm);
let seen;
const fakeFetch = async (url, options) => {
  seen = { url, options };
  const form = new URLSearchParams(options.body);
  const body = JSON.parse(form.get("body"));
  assert.equal(form.get("pwd"), "abc+123&xyz");
  assert.equal(url, "http://127.0.0.1:60080/KoLmafia/jsonApi");
  assert.equal(options.method, "POST");
  assert.equal(options.headers["Content-Type"], "application/x-www-form-urlencoded");
  assert.deepEqual(body, {
    properties: ["kingLiberated"],
    functions: [{ name: "availableAmount", args: [{ objectType: "Item", identifierString: "filthy lucre" }] }]
  });
  return new Response(JSON.stringify({ properties: [true], functions: [7] }), {
    status: 200, headers: { "Content-Type": "application/json" }
  });
};

const client = new AshClient(core, {
  baseUrl: "http://127.0.0.1:60080/",
  pwdProvider: async () => "abc+123&xyz",
  fetchImpl: fakeFetch,
});
const batch = await client.batch({
  properties: ["kingLiberated"],
  functions: [{ name: "availableAmount", args: [Item("filthy lucre")] }]
});
assert.deepEqual(batch, { properties: [true], functions: [7] });
assert.ok(seen);

let networkCalls = 0;
client.setDenyList(["visitUrl"]);
client.fetchImpl = async () => { networkCalls++; throw new Error("must not run"); };
await assert.rejects(() => client.call("visitUrl", "main.php"), /rejected by policy/);
assert.equal(networkCalls, 0);
console.log("WASM_CLIENT_SMOKE=PASS");
