import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { AshWasmCore, Item, Skill } from "../js/kolmafia-ash.js";

const wasm = await readFile(new URL("../dist/kolmafia_ash.wasm", import.meta.url));
const core = await AshWasmCore.instantiate(wasm);
assert.equal(core.version, "0.1.0");
assert.deepEqual(core.enumRef(Item("filthy \"lucre\"")), {
  objectType: "Item", identifierString: "filthy \"lucre\""
});
assert.deepEqual(core.enumRef(Item(1)), { objectType: "Item", identifierNumber: 1 });
assert.deepEqual(core.buildFunction("availableAmount", [Item("seal-clubbing club")]), {
  name: "availableAmount",
  args: [{ objectType: "Item", identifierString: "seal-clubbing club" }]
});
core.setDenyList(["cliExecute", "visitUrl"]);
assert.equal(core.isAllowed("myName"), true);
assert.equal(core.isAllowed("visitUrl"), false);
assert.throws(() => core.buildFunction("visitUrl", ["main.php"]), /rejected by policy/);
core.setAllowList(["myName", "haveSkill"]);
assert.equal(core.isAllowed("myName"), true);
assert.equal(core.isAllowed("myMeat"), false);
assert.deepEqual(core.buildBatch({
  properties: ["kingLiberated"],
  functions: [{ name: "myName", args: [] }, { name: "haveSkill", args: [Skill("Torso Awaregness")] }]
}), {
  properties: ["kingLiberated"],
  functions: [
    { name: "myName", args: [] },
    { name: "haveSkill", args: [{ objectType: "Skill", identifierString: "Torso Awaregness" }] }
  ]
});
console.log("WASM_CORE_SMOKE=PASS");
