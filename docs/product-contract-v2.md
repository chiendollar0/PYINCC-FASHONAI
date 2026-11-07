# PYINCC FashionAI — LOCKED PRODUCT CONTRACT v2.0 (2026-10-13)
Status: scope locked by product owner; **not** implementation-complete. Functional changes require a reviewed version update.

## Source precedence
1. Product owner's latest requirements (Home/Studio/Store/Account, offline-first, 3D).
2. PYINCC Nguyen tac hoat dong v1.0: identity, consent, rights, truthful output status.
3. Architecture Draft01 and The New Black proposal: non-binding implementation references.
4. Existing code and reference repos: evidence of current state, not scope authority.

## Locked tabs
- **Home**: face upload + consent + automatic face-to-3D-avatar mapping only when verified; display avatar and registration profile/form controls.
- **Studio**: static full-body 3D avatar, rotate camera 360 degrees, compact menus for Skin Care, bundled wardrobe, Shop tray, Big Bag, Undo, Reset. No separate feature tabs that obscure the stage.
- **Store**: permitted product imagery and legitimate product links; selected products populate Studio Shop tray; checkout via verified provider.
- **Account**: session-only default, explicit opt-in cloud save, account/privacy/deletion; payment handoff through official providers, never store payment credentials.

## Offline-first rules
Local images, controls, history, packaged/cached GLB viewing and basic rendering must work without network where technically possible. Face processing offline is a research target, not a delivered capability. Sharing/export creates user-owned files outside automatic session cleanup.

## Face and garment 3D pipeline
Consent -> face landmarks/segmentation -> face UV/texture mapping onto compatible avatar head mesh -> identity/quality review -> static GLB viewer -> garment GLB rigged/skinned to compatible skeleton -> full-body 360-degree camera orbit. A 2D product photo is not a rigged 3D garment. No rigged garment system is accepted without matching skeleton/skin tests.

## Official avatar asset
As of 7 November 2026, the owner has uploaded a user-created official static mesh at `assets/avatars/pyincc_avatar_primary.glb`. The mesh is stated to be unrigged. Binary structure and SHA-256 are pending; see `docs/official-avatar-intake-2026-11-07.md`. Static rendering can proceed after structural validation. Rigged garment fitting remains blocked until a compatible skeleton/skin pipeline is separately implemented and verified.

## Reference repositories (candidates; asset license/compatibility unverified)
- https://github.com/KhronosGroup/glTF-Sample-Assets
- https://github.com/KhronosGroup/glTF-Validator
- https://github.com/google/model-viewer
- https://github.com/mrdoob/three.js
- https://github.com/google-ai-edge/mediapipe
- https://github.com/blender/blender

## Source cleanup / acceptance
One shared StudioSession data model; avoid duplicate image pickers/state between Studio and 2D editor. Retain working 2D editor as labeled fallback until 3D is verified. Remove dead demo screens and fake result UI, never remove consent/auth/privacy or tests. Acceptance requires real asset files, camera orbit, garment fit in A/T pose, unobstructed full-body view, offline fallback, session cleanup, CI and physical device evidence.

Open questions: exact X/M/N form semantics; face-to-avatar mapping accuracy; 2D garment-to-3D conversion; payment provider.
