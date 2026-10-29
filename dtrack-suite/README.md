# dTrack GPL-3.0 source shelf — staged, not active

> **Original upstream credit:** [Prusias-kol/pTrack](https://github.com/Prusias-kol/pTrack), built on The Dictator's ProfitTracking / DicsLibrary and Thoth19's TimeTracking. This copy was staged from [donCannoli-burns/dTrack](https://github.com/donCannoli-burns/dTrack).
>
> **EXPERIMENTAL — USE AT YOUR OWN RISK.** This project retains the upstream GPL-3.0 license in [LICENSE](LICENSE). Do not treat this folder as part of the repository's independently MIT-licensed DON Master ASH Lib.
>
> **Status: SOURCE-SHELF STAGING ONLY.** The root `don-ash-lib/manifest.json` points at `don-master-ash-lib/`. The contents of this `dtrack-suite/` directory **are not installed** by a standard `git checkout don-ash-lib`. Do not remove the installed dTrack project merely because this source snapshot exists.

## Staged files

- `kolmafia/scripts/ptrackSuite/ProfitTracking.ash` — tracking & valuation, now importing `don_track_compat.ash`
- `kolmafia/scripts/ptrackSuite/TimeTracking.ash` — time/cumulative comparisons
- `kolmafia/scripts/ptrackSuite/coinvalue.js` — coinmaster valuation (read-only)
- `kolmafia/scripts/ptrackSuite/networth_graph.js` — net-worth HTML graph
- `kolmafia/scripts/ptrackSuite/ptrack.ash` — legacy `ptrack` command
- `kolmafia/scripts/ptrackSuite/ptrack_relay.js` — read-only checkpoint relay view
- `kolmafia/relay/relay_ptrack.js` — relay wrapper
- `kolmafia/dependencies.txt`, `manifest.json` and upstream `LICENSE`

## Audit repairs already applied in source dTrack

1. Removed implicit `pull all` from `ProfitTracking.ash` checkpoint capture. Counting items already includes storage.
2. Added bounded, non-recursive breakpoint naming; constrained new names to `[A-Za-z0-9_-]` with 64-character limit.
3. Disabled silent preference initialization on `ptrack help`.
4. Required explicit confirmation before redeeming/autoselling Screege drops; limited override price range.
5. Reworked `coinvalue.js` to avoid zero-denominator token prices, implicit globals and unescaped HTML, and to remove eager mall-price refresh for every coinmaster item.
6. Validated checkpoint path components in `ptrack_relay.js`; sanitized graph output filenames in `networth_graph.js`.

## Remaining blockers before runtime replacement

- Test `verify ptrack`, `verify ProfitTracking.ash` and `verify TimeTracking.ash` inside a current KoLmafia client.
- Check `call ptrack.ash help`, `ptrack list`, `ptrack recap` on a copy of existing tracking data.
- Test relay menu, graphs, and optional KolItemPrices/Irrat data in read-only mode.
- Compare old/new historical net worth, price overrides, and familiar/closet/store counts.
- Validate GPL-3.0 compliance of any combined distribution before importing these GPL files into an otherwise MIT-directed runtime subtree.
- Only then choose an activation path, retire the standalone dTrack checkout, and remove its dLooper dependency.

No live gameplay, compilation, or relay runtime was executed during this staging operation. Historical source blobs and original dTrack Git history remain available.
