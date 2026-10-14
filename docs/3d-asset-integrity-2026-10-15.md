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
