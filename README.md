# PYINCC FashionAI

Flutter Android/iOS application foundation. Android is the active delivery priority; iOS remains a separate workstream.

## Start here when resuming work

**Read `docs/PROJECT_PROGRESS_AND_REMAINING_P.md` first.** It is the single current project checkpoint: authoritative Android branch, last verified commit/workflow, asset identity, open blockers and the next action. Do not reconstruct progress from old chat messages, old plans or unrelated branches.

Then read:
1. `docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md` — product/UI intent and current implementation limits.
2. `docs/product-contract-v2.md` — locked target product contract, not proof of delivered functionality.
3. `docs/3d-avatar-integration.md` and `docs/3d-asset-integrity-2026-10-15.md` — current test-asset identity and acceptance gates.

## Current source branches

- Android working branch: `fashionai/gracy-20261023`.
- iOS working branch: `ios`, kept separate.
- The repository default branch `main` is not the current Android working branch. Do not switch Android work to `main`, merge it into the Android branch, or create another branch without a specific need and owner approval.

## Current 3D asset status

The bundled Gracy Lee GLB is a **temporary technical build/UAT asset only**. Its current identity, recorded CC BY 4.0 evidence, attribution file and exact SHA-256 are pinned in `config/avatar-asset.json` and `docs/evidence/`. The asset gate verifies structural/packaging prerequisites; this is not a legal warranty, a visual-quality approval, or acceptance of the official PYINCC avatar.

The official PYINCC GLB is being created by the project owner and will be supplied later. Its absence does not block Android UI work or a temporary-asset technical APK build. Never relabel the Gracy Lee test model as the official PYINCC avatar.

## Build and acceptance boundaries

- Android push workflow runs source/gate validation; it intentionally skips APK packaging.
- APK packaging requires manually dispatching `.github/workflows/android-apk.yml` with `build_apk=true`.
- CI PASS is not APK PASS. APK PASS is not physical-device UAT. Physical-device UAT is not production acceptance.
- Current code limitations and the exact next step are recorded in `docs/PROJECT_PROGRESS_AND_REMAINING_P.md`.

FashionAI is separate from AIPET. Do not import AIPET code, assets, workflows, branches, build artifacts or test evidence into this repository.
