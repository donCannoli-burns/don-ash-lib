#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "..");
const examples = path.join(root, "data", "wasm-ash", "examples");

function decodeHexFile(name) {
  const source = fs.readFileSync(path.join(examples, `${name}.hex`), "utf8");
  const cleaned = source
    .split(/\r?\n/)
    .map((line) => line.replace(/#.*/, "").replace(/\/\/.*/, ""))
    .join("")
    .replace(/[\s,:]/g, "");
  return Buffer.from(cleaned, "hex");
}

function assertEqual(label, actual, expected) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
  console.log(`PASS ${label} = ${actual}`);
}

for (const name of ["add", "answer"]) {
  const bytes = decodeHexFile(name);
  if (!WebAssembly.validate(bytes)) {
    throw new Error(`${name}.hex is not a valid WebAssembly module`);
  }
  const raw = fs.readFileSync(path.join(root, "fixtures", `${name}.wasm`));
  if (!bytes.equals(raw)) {
    throw new Error(`${name}.hex does not byte-match fixtures/${name}.wasm`);
  }
  if (!WebAssembly.validate(raw)) {
    throw new Error(`fixtures/${name}.wasm is not valid WebAssembly`);
  }
  console.log(`PASS WebAssembly.validate ${name}.hex (${bytes.length} bytes), raw fixture byte-match`);
}

const add = await WebAssembly.instantiate(decodeHexFile("add"), {});
assertEqual("add(7,35)", add.instance.exports.add(7, 35), 42);
assertEqual("add(-5,2)", add.instance.exports.add(-5, 2), -3);
assertEqual("double(21)", add.instance.exports.double(21), 42);

const answer = await WebAssembly.instantiate(decodeHexFile("answer"), {});
assertEqual("answer()", answer.instance.exports.answer(), 42);

console.log("check_fixtures PASS");
