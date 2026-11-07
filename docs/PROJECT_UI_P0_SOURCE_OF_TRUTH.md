# PYINCC FashionAI — SOURCE OF TRUTH / UI & P0

Document precedence:
1. Latest explicit owner instructions.
2. PYINCC_FashionAI_Spec_KhoaCung_v2_2026-10-13.docx (scope locked).
3. PYINCC_FashionAI_Nguyen_tac_hoat_dong_co_anh_mau.docx.
4. PYINCC FashionAI UX.mp4 and architecture documents; code is implementation evidence only.

## Non-negotiable contract
- Exactly ONE approved avatar in the user-facing app. No A/B selector, invented models, or demo replacements.
- Bottom tabs: HOME | STUDIO | STORE | ACCOUNT.
- HOME: face photo, consent, truthful Face Swap status, avatar, registration profile and form controls. Do not imply face mapping works before it does.
- STUDIO: full-body 3D avatar, 360-degree camera, compact menus for Skin Care / Tủ đồ mẫu / Shop / Big Bag, Undo/Reset; tools must not obscure avatar.
- STORE: legitimate product links/sources, no invented prices/brands.
- ACCOUNT: authentication, temporary session, cloud opt-in, delete controls.
- UI: fashion-grade neutral palette, consistent hierarchy and spacing; remove debug copy from user-facing pages.
- Offline-first; no fake AI output, no forced production PASS.

## Current official avatar state — 7 November 2026
The owner states that `assets/pyincc_avatar_primary.glb` is the official PYINCC mesh and is not rigged. It was moved, without changing its Git blob, to `assets/avatars/pyincc_avatar_primary.glb` in commit `1cd4d8152b8806131f3a03808ffb8662c0b7b249`.

Binary inspection and SHA-256 capture are pending. The avatar manifest remains BLOCKED until the GLB structure, mesh/UV/material/texture inventory and hash are verified and the gate is updated for owner-created assets. Static viewing does not require a skeleton; rigged garment fitting does.

## Build and acceptance sequence
1. Read this contract and the named source docs.
2. Inspect and hash the official GLB; preserve historical files.
3. Update manifest/gate/tests for the owner-created asset.
4. Run Python regression tests, Flutter analyze/tests, Android Gradle compile and asset gate.
5. Build APK only when source validation and asset gate pass.
6. Verify exact GLB bytes inside APK and record raw APK SHA-256, package, min SDK and signature evidence.
7. Perform physical Android UAT for rendering, four angles, camera interaction and offline behavior.
8. Keep P0 FAIL/BLOCKED until the evidence exists. CI green does not prove visual correctness.

## Product limitations
Face processing offline remains a research target, not a delivered capability. A 2D product photo is not a rigged 3D garment. A static unrigged avatar does not enable skeletal deformation, rigged clothing, Face Swap or animation. Firebase identity, cloud backup, merchant integration and payment require separate verification.

## Preserved history
Do not delete historical scan GLBs, conversion scripts, evidence or docs merely because the official mesh has arrived. Keep AIPET out of this repository and its evidence.
