#!/usr/bin/env node
import { readFile, writeFile } from "node:fs/promises";

const [,, input, output = "generated-ash.js"] = process.argv;
if (!input) {
  console.error("usage: node tools/ashrefgen.mjs <ashref.txt> [generated-ash.js]");
  process.exit(2);
}

const source = await readFile(input, "utf8");
const lines = source.split(/\r?\n/).map(s => s.trim()).filter(Boolean);
const parsed = [];
for (const line of lines) {
  const m = line.match(/^(.+?)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)\s*;?$/);
  if (!m) continue;
  const [, ret, name, paramsRaw] = m;
  const params = paramsRaw.trim() ? paramsRaw.split(",").map(s => s.trim()) : [];
  parsed.push({ ret: ret.trim(), name, params });
}

const counts = new Map();
for (const p of parsed) counts.set(p.name, (counts.get(p.name) ?? 0) + 1);
const primitive = new Set(["boolean","int","float","string","buffer"]);
const enumTypes = new Set(["item","familiar","skill","effect","monster","location","slot","stat","path","class","element","phylum","thrall","servant","coinmaster"]);
const supportedType = t => {
  t = t.replace(/^strict_/, "").trim();
  if (primitive.has(t) || enumTypes.has(t)) return true;
  return false;
};
const camel = s => s.replace(/_([a-zA-Z0-9])/g, (_, c) => c.toUpperCase());
const argName = (i) => `arg${i}`;

let generated = 0, skipped = [];
let out = `// Generated from KoLmafia ashref output.\n// Do not edit by hand.\n\nexport function installGeneratedASH(AshClient) {\n`;
for (const p of parsed) {
  if (counts.get(p.name) !== 1) { skipped.push(`${p.name}: overloaded`); continue; }
  if (!supportedType(p.ret) && p.ret !== "void") { skipped.push(`${p.name}: unsupported return type ${p.ret}`); continue; }
  if (p.params.some(t => !supportedType(t.replace(/^\[|\]$/g, "")) || /^\[/.test(t))) {
    skipped.push(`${p.name}: unsupported parameter type`); continue;
  }
  const args = p.params.map((_, i) => argName(i));
  out += `  AshClient.prototype.${camel(p.name)} = function(${args.join(", ")}) { return this.call(${JSON.stringify(camel(p.name))}${args.length ? ", " + args.join(", ") : ""}); };\n`;
  generated++;
}
out += `}\n`;
await writeFile(output, out);
console.error(`generated=${generated} skipped=${skipped.length}`);
for (const s of skipped) console.error(`skip: ${s}`);
