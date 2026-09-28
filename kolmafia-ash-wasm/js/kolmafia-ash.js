const encoder = new TextEncoder();
const decoder = new TextDecoder();

export class ASHEnumRef {
  constructor(objectType, identifier) {
    this.objectType = objectType;
    this.identifier = identifier;
    Object.freeze(this);
  }
}

export const Enumerated = (type, value) => new ASHEnumRef(type, value);
export const Item = value => Enumerated("Item", value);
export const Familiar = value => Enumerated("Familiar", value);
export const Skill = value => Enumerated("Skill", value);
export const Effect = value => Enumerated("Effect", value);
export const Monster = value => Enumerated("Monster", value);
export const Location = value => Enumerated("Location", value);
export const Slot = value => Enumerated("Slot", value);
export const Stat = value => Enumerated("Stat", value);
export const Path = value => Enumerated("Path", value);
export const AscensionClass = value => Enumerated("Class", value);
export const Element = value => Enumerated("Element", value);
export const Phylum = value => Enumerated("Phylum", value);
export const Thrall = value => Enumerated("Thrall", value);
export const Servant = value => Enumerated("Servant", value);
export const Coinmaster = value => Enumerated("Coinmaster", value);

async function loadBytes(source) {
  if (source instanceof ArrayBuffer || ArrayBuffer.isView(source)) {
    return source instanceof ArrayBuffer ? source : source.buffer.slice(source.byteOffset, source.byteOffset + source.byteLength);
  }
  if (source instanceof WebAssembly.Module) return source;
  if (source instanceof URL || typeof source === "string") {
    if (typeof process !== "undefined" && process.versions?.node && String(source).startsWith("file:")) {
      const { readFile } = await import("node:fs/promises");
      const bytes = await readFile(source);
      return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    }
    const response = await fetch(source);
    if (!response.ok) throw new Error(`failed to fetch wasm: HTTP ${response.status}`);
    return await response.arrayBuffer();
  }
  throw new TypeError("unsupported WebAssembly source");
}

export class AshWasmCore {
  static async instantiate(source) {
    const bytesOrModule = await loadBytes(source);
    const result = bytesOrModule instanceof WebAssembly.Module
      ? await WebAssembly.instantiate(bytesOrModule, {})
      : await WebAssembly.instantiate(bytesOrModule, {});
    const instance = result instanceof WebAssembly.Instance ? result : result.instance;
    return new AshWasmCore(instance);
  }

  constructor(instance) {
    this.instance = instance;
    this.exports = instance.exports;
    this.memory = this.exports.memory;
  }

  get version() {
    return `${this.exports.ash_version_major()}.${this.exports.ash_version_minor()}.${this.exports.ash_version_patch()}`;
  }

  #write(value) {
    const bytes = encoder.encode(String(value));
    const ptr = this.exports.ash_alloc(bytes.length || 1);
    if (!ptr) throw new Error(this.lastError || "WebAssembly arena exhausted");
    new Uint8Array(this.memory.buffer, ptr, bytes.length).set(bytes);
    return [ptr, bytes.length];
  }

  #result() {
    return decoder.decode(new Uint8Array(this.memory.buffer, this.exports.ash_out_ptr(), this.exports.ash_out_len()));
  }

  get lastError() {
    return decoder.decode(new Uint8Array(this.memory.buffer, this.exports.ash_error_ptr(), this.exports.ash_error_len()));
  }

  #run(fn) {
    this.exports.ash_reset_arena();
    const code = fn();
    if (code !== 0) throw new Error(this.lastError || `WebAssembly binding error ${code}`);
    return this.#result();
  }

  enumRef(ref) {
    if (!(ref instanceof ASHEnumRef)) throw new TypeError("expected ASHEnumRef");
    return JSON.parse(this.#run(() => {
      const [tp, tl] = this.#write(ref.objectType);
      const [ip, il] = this.#write(ref.identifier);
      if (typeof ref.identifier === "number" || typeof ref.identifier === "bigint") {
        return this.exports.ash_build_enum_number(tp, tl, ip, il);
      }
      return this.exports.ash_build_enum_string(tp, tl, ip, il);
    }));
  }

  normalize(value) {
    if (value instanceof ASHEnumRef) return this.enumRef(value);
    if (Array.isArray(value)) return value.map(v => this.normalize(v));
    if (value && typeof value === "object") {
      return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, this.normalize(v)]));
    }
    return value;
  }

  setAllowList(names) { this.#setPolicy(1, names); }
  setDenyList(names) { this.#setPolicy(2, names); }
  clearPolicy() { this.exports.ash_policy_clear(); }

  #setPolicy(mode, names) {
    this.exports.ash_reset_arena();
    const csv = [...names].join(",");
    const [p, l] = this.#write(csv);
    const code = this.exports.ash_policy_set(mode, p, l);
    if (code !== 0) throw new Error(this.lastError || "failed to set policy");
  }

  isAllowed(name) {
    this.exports.ash_reset_arena();
    const [p, l] = this.#write(name);
    return this.exports.ash_policy_allowed(p, l) === 1;
  }

  buildFunction(name, args = []) {
    const normalized = this.normalize(args);
    const argsJSON = JSON.stringify(normalized);
    return JSON.parse(this.#run(() => {
      const [np, nl] = this.#write(name);
      const [ap, al] = this.#write(argsJSON);
      return this.exports.ash_build_function(np, nl, ap, al);
    }));
  }

  buildBatch({ properties = [], functions = [] } = {}) {
    const builtFunctions = functions.map(fn => this.buildFunction(fn.name, fn.args ?? []));
    const propertiesJSON = properties.length ? JSON.stringify(properties) : "";
    const functionsJSON = builtFunctions.length ? JSON.stringify(builtFunctions) : "";
    return JSON.parse(this.#run(() => {
      const [pp, pl] = this.#write(propertiesJSON);
      const [fp, fl] = this.#write(functionsJSON);
      return this.exports.ash_build_batch(pp, pl, fp, fl);
    }));
  }
}

export class AshClient {
  static async create({
    wasm = new URL("../dist/kolmafia_ash.wasm", import.meta.url),
    ...options
  } = {}) {
    const core = await AshWasmCore.instantiate(wasm);
    return new AshClient(core, options);
  }

  constructor(core, {
    baseUrl = "",
    pwdProvider,
    fetchImpl = globalThis.fetch,
  } = {}) {
    if (!(core instanceof AshWasmCore)) throw new TypeError("core must be AshWasmCore");
    if (typeof pwdProvider !== "function") throw new TypeError("pwdProvider is required");
    if (typeof fetchImpl !== "function") throw new TypeError("fetch implementation is required");
    this.core = core;
    this.baseUrl = baseUrl.replace(/\/$/, "");
    this.pwdProvider = pwdProvider;
    this.fetchImpl = fetchImpl;
  }

  setAllowList(names) { this.core.setAllowList(names); return this; }
  setDenyList(names) { this.core.setDenyList(names); return this; }
  clearPolicy() { this.core.clearPolicy(); return this; }

  async batch(request) {
    const bodyObject = this.core.buildBatch(request);
    const pwd = await this.pwdProvider();
    if (!pwd) throw new Error("pwdProvider returned an empty value");
    const response = await this.fetchImpl(`${this.baseUrl}/KoLmafia/jsonApi`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
      },
      body: new URLSearchParams({ pwd: String(pwd), body: JSON.stringify(bodyObject) }),
    });
    if (!response.ok) throw new Error(`KoLmafia returned HTTP ${response.status}: ${await response.text()}`);
    const json = await response.json();
    if (json && typeof json === "object" && typeof json.error === "string" && json.error) {
      throw new Error(`KoLmafia error: ${json.error}`);
    }
    return json;
  }

  async call(name, ...args) {
    const response = await this.batch({ functions: [{ name, args }] });
    if (!Array.isArray(response.functions) || response.functions.length !== 1) {
      throw new Error("expected exactly one function result");
    }
    return response.functions[0];
  }

  async property(name) {
    const response = await this.batch({ properties: [name] });
    if (!Array.isArray(response.properties) || response.properties.length !== 1) {
      throw new Error("expected exactly one property result");
    }
    return response.properties[0];
  }

  myName() { return this.call("myName"); }
  myMeat() { return this.call("myMeat"); }
  myAdventures() { return this.call("myAdventures"); }
  availableAmount(item) { return this.call("availableAmount", item); }
  haveSkill(skill) { return this.call("haveSkill", skill); }
  numericModifier(...args) { return this.call("numericModifier", ...args); }
}
