# PYINCC FashionAI

Flutter Android/iOS foundation. Runtime 3D viewing uses `model_viewer_plus` 1.9.3 and a bundled GLB. Face Swap, final avatar appearance, garment replacement and physical-device UAT are not verified production capabilities.

## Current source and scope

Read `docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md` and `docs/product-contract-v2.md` first. Latest avatar intake is recorded in `docs/official-avatar-intake-2026-11-07.md`.

The owner-uploaded official candidate is now stored at `assets/avatars/pyincc_avatar_primary.glb`. It is a user-created static mesh and has not been rigged. The uploaded file was moved without re-encoding; Git blob identity was preserved. Its binary GLB structure, mesh topology, UVs, materials, embedded textures, node hierarchy and render quality have not yet been independently inspected in this environment. It is not approved for APK packaging until those checks and exact SHA-256 capture pass.

The old root-level scan files remain preserved for historical reference and are not authorized app assets. The removed ZIP is not required by the build.

## Build gates

- `python3 -m unittest discover -s tests -v`: regression tests for rights, structural and APK integrity gates. Unit fixtures are temporary, never app assets.
- `python3 scripts/avatar_gate.py --report build/evidence/avatar-gate.json`: fail-closed packaging gate. Current manifest remains BLOCKED while the new user-created GLB is inspected and the gate is updated to recognize owner-created assets.
- Android source validation runs independently. APK packaging requires source validation and the asset gate; actual APK GLB bytes and raw APK SHA-256 are checked before upload.
- iOS checks source/tests, then requires the same asset gate before unsigned simulator compilation. Simulator compilation is not physical-device UAT.

The historical root-level scan files and `scripts/prepare_avatar_assets.py` remain preserved. Do not delete them as part of avatar replacement. They are not the active source for the official avatar.

## Official avatar intake

Engineering must record the GLB header/version/declared length, mesh/primitive and vertex/index counts, UV sets, material and texture references, embedded image formats, node hierarchy, skeleton/skin presence, external dependencies, file byte size and SHA-256. A static mesh without a skeleton is valid for the current static Studio viewer; it does not support rigged garment fitting or animation.

After structural validation, update the manifest and gate for a user-created asset without inventing a Sketchfab UID or license grant. Preserve owner provenance and record the exact reviewed declaration. CI must verify the sole primary asset and identical bytes inside the APK.

After a successful build, physical Android evidence must identify the APK, device/Android/WebView and logcat, and demonstrate full-body rendering, four angles, camera interaction and offline behavior. Passing CI is never production or visual approval.

Local-first controls and explicit consent remain required. Firebase, identity mapping, merchant integration, final avatar skin/garments and payment are not certified by these gates.
