import { readFile } from "node:fs/promises";
import { AshWasmCore, AshClient, Item } from "../js/kolmafia-ash.js";

const core = await AshWasmCore.instantiate(await readFile(new URL("../dist/kolmafia_ash.wasm", import.meta.url)));
const client = new AshClient(core, {
  baseUrl: process.env.KOLMAFIA_URL ?? "http://127.0.0.1:60080",
  pwdProvider: async () => {
    if (!process.env.KOLMAFIA_PWD) throw new Error("set KOLMAFIA_PWD at runtime");
    return process.env.KOLMAFIA_PWD;
  },
});
client.setAllowList(["myName", "myMeat", "availableAmount"]);
console.log(await client.myName());
console.log(await client.myMeat());
console.log(await client.availableAmount(Item("filthy lucre")));
