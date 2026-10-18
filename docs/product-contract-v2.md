# PYINCC FashionAI — LOCKED PRODUCT CONTRACT v2.0 (2026-10-13)
Status: scope locked by product owner; **not** implementation-complete. Functional changes require a reviewed version update.

## Source precedence
1. Product owner's latest requirements (Home/Studio/Store/Account, offline-first, 3D).
2. PYINCC Nguyen tac hoat dong v1.0: identity, consent, rights, truthful output status.
3. Architecture Draft01 and The New Black proposal: non-binding implementation references.
4. Existing code and reference repos: evidence of current state, not scope authority.

## Locked tabs
- **Home**: Fake button: upload face + consent + automatic face-to-3D-avatar mapping when verified; display avatar with user's mapped face, registration profile, height/weight/form X-M-N sliders.
- **Studio**: static full-body 3D avatar, rotate camera 360 degrees, floating menus overlaying stage: Skin Care (smoothing/brightness, blush, lipstick styles, lenses, lashes), bundled wardrobe, Shop tray (Store selections), Big Bag (user garment images), Undo, Reset, unobstructed full-body result. Avoid navigating into separate feature tabs.
- **Store**: Shopee/Lazada/TikTok Shop and user-added URLs; retrieve permitted product imagery only; selected products populate Studio Shop tray; checkout via verified provider.
- **Account**: session-only default (no automatic photo/history persistence), explicit opt-in cloud save, account/privacy/deletion; wallet/payment handoff through official providers, never store payment credentials.

## Offline-first rules
Local images, controls, history, packaged/cached GLB viewing and basic rendering must work without network where technically possible. Face processing offline is a research target, **not a delivered capability**. On Android force-close cannot guarantee a cleanup callback: use ephemeral storage and cleanup on next launch. Sharing/export creates user-owned files outside automatic session cleanup.

## Face and garment 3D pipeline
Consent -> face landmarks/segmentation -> face UV/texture mapping onto compatible avatar head mesh -> identity/quality review -> static GLB viewer -> garment GLB rigged/skinned to compatible skeleton -> full-body 360-degree camera orbit. A 2D product photo is NOT a rigged 3D garment. Never claim a 2D overlay or CesiumMan sample implements this. A-pose/T-pose accepted; no animation required.

## Reference repositories (candidates; asset license/compatibility unverified)
- https://github.com/KhronosGroup/glTF-Sample-Assets (GLB test fixtures; CesiumMan is a sample, not a wardrobe-ready avatar)
- https://github.com/KhronosGroup/glTF-Validator (GLB conformance)
- https://github.com/google/model-viewer (camera orbit viewer; not garment rigging or face swap)
- https://github.com/mrdoob/three.js (skinned meshes, materials, rendering; benchmark Android WebView)
- https://github.com/google-ai-edge/mediapipe (face landmark research, check device and license)
- https://github.com/blender/blender (offline garment modeling/UV/rig/export)

**No verified free redistributable avatar + garment GLB pair with matching rig has yet been selected.** The 18 October owner override selects one temporary Sketchfab candidate for technical UAT only; it does not approve final avatar quality, license entitlement, Face Swap or garment replacement. See `PROJECT_UI_P0_SOURCE_OF_TRUTH.md` and `config/avatar-asset.json`. Verify license, skeleton, UV, pose, mesh separation, polygon count, and Android 10 6GB performance before importing.

## Source cleanup / acceptance
One shared StudioSession data model; avoid duplicate image pickers/state between Studio and 2D editor. Retain the working 2D editor as explicitly labeled fallback until 3D is verified. Remove dead demo screens and fake result UI, never remove consent/auth/privacy or tests. Acceptance requires real asset files, camera orbit, garment fit in A/T pose, complete unobstructed full-body view, offline fallback, session cleanup, CI and physical device evidence.

Open questions: exact X/M/N form semantics; compatible redistributable GLB assets; face-to-avatar mapping accuracy; 2D garment-to-3D conversion; payment provider.

