# PYINCC FashionAI — LOCKED PRODUCT CONTRACT v2.0

**Scope status:** Product direction locked by the owner on 2026-10-13. This document defines target behavior; it does not mean the features are implementation-complete or accepted.

**Current implementation snapshot:** `docs/PROJECT_PROGRESS_AND_REMAINING_P.md`. Read that file before continuing development. The checkpoint is authoritative for current branch, asset, CI and unfinished work.

## Source precedence

1. Latest owner requirements and explicit updates.
2. This locked contract for target product behavior.
3. `docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md` for detailed UI constraints and acceptance rules.
4. Architecture drafts and external repositories as non-binding references.
5. Existing code and reference repositories as implementation evidence, not scope authority.

## Locked tabs

- **Home:** Face photo selection with explicit consent; avatar setup; truthful mapping/Face Swap status. Height/weight/form controls are only functional when connected to a verified avatar mapping flow.
- **Studio:** Full-body 3D avatar, bounded 360-degree viewing, stable floating/anchored tool panels: Skin Care, Wardrobe, Shop and Big Bag; undo/reset only when backed by a real operation/history. No fake result UI.
- **Store:** Product links from approved sources such as Shopee, Lazada, TikTok Shop and owner-added URLs. Display only verified product imagery, merchant and price; provider checkout stays with the provider.
- **Account:** Session/privacy state, authentication, optional cloud save with explicit opt-in, account/data deletion and privacy controls. Do not store payment credentials.

## Offline-first rules

Local images, controls, cached/bundled GLB viewing and basic rendering should work offline where technically possible. Face processing offline remains a research target until a real implementation is integrated and verified. On Android force-close cannot guarantee a cleanup callback; use ephemeral storage and cleanup on next launch. Sharing/export creates user-owned files outside automatic session cleanup.

## Face and garment 3D pipeline

Consent → face landmarks/segmentation → face UV/texture mapping onto a compatible avatar head mesh → identity/quality review → GLB viewer → garment GLB rigged/skinned to a compatible skeleton → full-body 360-degree camera orbit.

A 2D product photo is not a rigged 3D garment. A 2D overlay or sample character does not implement face swap or garment fitting. A-pose/T-pose is acceptable; animation is not required.

## Current avatar decision and revision history

- The October 18/19 candidate with UID `4385c4af843e43379df8b702d04634f9` was an earlier blocked temporary candidate. It is superseded and must not be used as a fallback.
- The current bundled Gracy Lee asset has UID `5e0c47f7f7fe453bb4d3c8c7eba356e8`, author `hong227`, and recorded CC BY 4.0 evidence. It is used only for temporary technical build/UAT and is not the official PYINCC avatar.
- The official PYINCC GLB is being created by the project owner and will be supplied later. Its absence does not block current Android UI/P1 work or a technical APK build using the temporary asset.
- Exact source, rights, attribution and asset hashes are in `config/avatar-asset.json` and `docs/evidence/`. Structural/packaging gate PASS is not visual quality, legal warranty, device UAT or production acceptance.

## Reference repositories

These are implementation references; license and runtime compatibility must be checked before adopting assets or code:
- https://github.com/KhronosGroup/glTF-Sample-Assets
- https://github.com/KhronosGroup/glTF-Validator
- https://github.com/google/model-viewer
- https://github.com/mrdoob/three.js
- https://github.com/google-ai-edge/mediapipe
- https://github.com/blender/blender

## Acceptance rules

- One primary avatar presentation; no A/B selector or invented demo replacement.
- A real asset file with reviewed rights/attribution and pinned hash is required.
- Face Swap requires a real validated face-to-avatar process.
- Wardrobe/Big Bag try-on requires compatible rigged/skinned garment assets.
- Store requires connected, verifiable merchant/product data.
- Consent, privacy, offline fallback and session cleanup must be tested.
- UI/CI evidence and physical-device evidence must be reported separately.

## Open product/engineering questions

- Exact X/M/N form semantics and their dependency on avatar mapping.
- Validated face-to-avatar mapping quality on the target device.
- Compatible rigged garment assets and fitting workflow.
- Production auth configuration and server-side identity verification.
- Approved payment/commerce providers and catalog integration.
