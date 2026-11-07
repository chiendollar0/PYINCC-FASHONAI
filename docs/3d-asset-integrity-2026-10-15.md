# FashionAI asset identity — historical record and current official asset

## Current official asset intake (7 November 2026)

The owner-uploaded official mesh is present at `assets/avatars/pyincc_avatar_primary.glb`.

- File size reported by the GitHub repository tree: 2,608,120 bytes.
- Git blob SHA: `c190984eb7ff92cba6dd27ddc6a5d1603b522308`. This is a Git object identifier, **not** the file's SHA-256.
- The file was moved from `assets/pyincc_avatar_primary.glb` to the canonical `assets/avatars/pyincc_avatar_primary.glb` path without re-encoding. The same Git blob SHA was retained.
- Owner states this is the official PYINCC mesh and that it has not been rigged.
- Binary structural inspection, mesh/UV/material/texture inventory, GLB header/length validation and SHA-256 are pending. Do not infer these values from file size or Git blob SHA.
- The packaging manifest remains BLOCKED. The existing gate still assumes a historical Sketchfab UID and needs a tested owner-created-asset path.

A static unrigged mesh can be used for static viewing if it passes structural checks. It does not establish garment skinning, animation, Face Swap, final visual approval or physical-device acceptance.

## Current acceptance requirements

1. Verify GLB v2 header and declared byte length against actual bytes.
2. Inventory scenes, nodes, meshes, primitives, vertex/index counts, normals and UV attributes.
3. Verify material references, embedded texture formats and all buffer/image references; reject external dependencies for offline packaging.
4. Record skeleton/skin presence accurately. Absence is expected for this user-supplied unrigged static mesh and is not by itself a failure for static viewing.
5. Compute exact SHA-256 and pin size/hash in the manifest.
6. Update the gate to support owner-created assets without fabricating third-party model IDs or license grants; add regression tests.
7. Verify exactly one primary GLB in the app asset directory and identical bytes in the actual APK.
8. Keep visual review and physical Android UAT as separate acceptance gates.

## Historical record — superseded, preserved for audit

Verified from provided `PYINCC_FashionAI_3D_assets_ready.zip` on 2026-10-15:

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `assets/avatars/pyincc_avatar_primary.glb` | 5152656 | `919421af91f4d155da84ba9e47670d5aac7739cac9fac959ab5add7d5381b983` |
| `assets/avatars/pyincc_avatar_alternate.glb` | 4672404 | `b8c964e38a097e5ca1f88773235af74f2a55db5c6e5c9ac388dd04e4d2388e6a` |

These historical prepared assets were static meshes, not rigged avatars, Face Swap or true outfit-change implementations. They are not the current official asset and must not be restored or packaged as substitutes.

## Preserved historical root files

The two historical root-level scan GLBs and `scripts/prepare_avatar_assets.py` remain preserved. They are not part of the official asset path. Do not delete them during this integration.
