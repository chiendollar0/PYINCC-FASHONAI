# FashionAI asset identity — current gate and historical record

## Current packaging authority (19 October 2026)

`config/avatar-asset.json` is the current sole-asset identity/rights manifest. Status is BLOCKED: selected model has been identified, but there is no authorized GLB, license grant, asset byte count or SHA-256 to approve. The historical values below must not be used as current acceptance thresholds.

Current acceptance requires exactly one approved primary, reviewed license-grant evidence, source hash/size validation, and an identical embedded GLB in the actual APK. Raw APK SHA-256 is recorded separately from GitHub artifact ZIP digest. Structural/packaging checks never imply visual or production PASS.

## Historical record — superseded for current packaging

# PYINCC FashionAI — 3D asset integrity manifest

Verified from provided `PYINCC_FashionAI_3D_assets_ready.zip` on 2026-10-15.

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `assets/avatars/pyincc_avatar_primary.glb` | 5152656 | `919421af91f4d155da84ba9e47670d5aac7739cac9fac959ab5add7d5381b983` |
| `assets/avatars/pyincc_avatar_alternate.glb` | 4672404 | `b8c964e38a097e5ca1f88773235af74f2a55db5c6e5c9ac388dd04e4d2388e6a` |

Both files have a valid glTF binary header (`glTF`), version 2, and declared binary length matching actual length. These are prepared neutralized static mesh assets, not a rigged avatar, Face Swap, or true outfit-change implementation.

## P0 gate

**BLOCKED:** The two binary GLBs have not yet been committed to this repository. A manifest or passing Flutter build must never be presented as asset integration PASS.

**P0 PASS requires:** GitHub tree contains both GLBs at exact paths, matching byte sizes and SHA-256; downstream CI must verify them before packaging.

## Ownership

Engineering integration owns transferring the assets and CI validation. Do not ask the product owner to rename, upload, install SDKs, or debug build tools.

