# PYINCC FashionAI

Flutter Android/iOS foundation. Runtime 3D viewing uses `model_viewer_plus` 1.9.3 and a bundled GLB. Face Swap, final avatar appearance, garment replacement and physical-device UAT are not verified production capabilities.

## Current source and scope

Read `docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md` and `docs/product-contract-v2.md` first. Latest owner decision (18 October 2026): defer final GLB reconstruction and use the single selected Sketchfab candidate for temporary technical UAT, subject to verified rights. Tabs remain **Home | Studio | Store | Account**.

The selected candidate has been identified, but an authorized GLB and reviewed license grant are not available. See `config/avatar-asset.json` and `docs/evidence/sketchfab-4385c4a-metadata.json`. Public listing metadata does not establish download or distribution entitlement.

## Build gates

- `python3 -m unittest discover -s tests -v`: regression tests for rights, structural and APK integrity gates. Unit fixtures are temporary, never app assets.
- `python3 scripts/avatar_gate.py --report build/evidence/avatar-gate.json`: require a reviewed rights manifest and exactly one matching `assets/avatars/pyincc_avatar_primary.glb`. Exit 2 means BLOCKED; no fallback model is generated.
- Android source validation runs independently. APK packaging requires both source validation and the asset gate; actual APK GLB bytes and raw APK SHA-256 are checked before upload. Package, minimum SDK and signing evidence are also captured.
- iOS checks source/tests, then requires the same asset gate before unsigned simulator compilation. Simulator compilation is not physical-device UAT.

The historical root-level scan files and `scripts/prepare_avatar_assets.py` remain preserved for reference. Automatic scan regeneration and alternate-GLB packaging are disabled in CI.

## When an authorized asset is available

Engineering records the exact model ID, author, applicable license, reviewed permissions and license-grant evidence; imports the sole primary GLB; and pins byte size/SHA-256 in the manifest. Local preflight must pass before CI packages it. Do not replace pending evidence with invented approval, a sample or a generated placeholder.

After a successful build, physical Android evidence must identify the APK, device/Android/WebView and logcat, and demonstrate full-body rendering, four angles, camera interaction and offline behavior. Passing CI is never production or visual approval.

Local-first controls and explicit consent remain required. Firebase, identity mapping, merchant integration, final avatar skin/garments and payment are not certified by these gates.
