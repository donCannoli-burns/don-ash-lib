# ASH Agent Standard Library v0.1.0

A source-grounded ASH library corpus generated from **41 supplied source entries**.

- Sources: 41
- New functions per source: 10
- Total generated functions: **410**
- Target reviewed against current KoLmafia release context: **r29307** (2026-09-27)
- Design bias: PURE / READ_ONLY observation, normalization, serialization, diffing, validation, planning, and LLM context
- Import policy: library modules contain no top-level game mutations
- Live `verify`: **NOT RUN in the build container**; see `docs/VERIFY_REPORT.md`

## Layout

```text
ash_agent_stdlib_master.ash   # single-file master artifact (410 functions)
ash_agent_stdlib.ash          # modular import master
lib/
  ash_agent_types.ash
  41 source modules
tests/
  ash_agent_smoke.ash
  expected_manifest.json
docs/
  SOURCE_ANALYSIS.md
  FUNCTION_INDEX.md
  AGENT_RUNTIME_INDEX.md
  VERIFY_REPORT.md
  PROVENANCE.md
```

## Install

For a single-file install, copy `ash_agent_stdlib_master.ash` into KoLmafia's `scripts/` tree.

For the modular install, copy `ash_agent_stdlib.ash` and `lib/` into the `scripts/` tree.
KoLmafia's import resolver searches script subdirectories by filename.

Then run:

```text
verify ash_agent_stdlib_master.ash
verify ash_agent_stdlib.ash
verify ash_agent_smoke.ash
call ash_agent_smoke.ash
```

The smoke test is intentionally read-only.

## Design boundary

This release emphasizes:

`READ -> NORMALIZE -> DESCRIBE -> COMPARE -> VALIDATE -> PLAN`

It deliberately does **not** add hundreds of direct executors. Planning helpers return records/text that a caller can inspect before choosing an existing typed/native execution surface.

## Malformed source resolution

The supplied URL ending in `scripts/OCD%20Inventory%` is not a complete GitHub file URL. GitHub code search resolved the intended source to:

`IronTetsubo/KoLmafia-ash/scripts/OCD Inventory Control.ash`

Both the supplied URL and this resolution are recorded in provenance.

## Repeated source

`Prusias-kol/pUpdates` appeared twice in the supplied URL list. It is honored as two independent source entries:

- SOURCE 10: operational seen-version/update-state helpers
- SOURCE 37: pure changelog parsing/search/serialization helpers

No function names are duplicated.

## Why It Exists

It consolidates many recurring agent-facing read/normalize/describe patterns into a single inspectable ASH standard-library experiment.

## Files

- `ARTIFACT_SHA256SUMS.txt` — packaged source/support material.
- `ash_agent_stdlib.ash` — packaged source/support material.
- `ash_agent_stdlib_master.ash` — packaged source/support material.
- `docs/` — packaged source/support material.
- `lib/` — packaged source/support material.
- `tests/` — packaged source/support material.

## Status

Experimental.

## Compatibility

Designed for current KoLmafia ASH; 410 generated exports require local KoLmafia verify before runtime use.

## Provenance

Extracted and packaged as a standalone repository from `ash_agent_stdlib_v0.1.0.zip` in the KoLmafia ASH language-lab session. Existing upstream/source credits in this repository are preserved. See `PROVENANCE.md`.

## License

MIT License. See `LICENSE`. Third-party material, where present, remains subject to its original notices and terms.

## Packaging Verification

**PASS**

- 41 modules / 410 unique exports static audit
- packaged source integrity

Live KoLmafia verify has not been run; runtime verification remains separate from publication readiness.
