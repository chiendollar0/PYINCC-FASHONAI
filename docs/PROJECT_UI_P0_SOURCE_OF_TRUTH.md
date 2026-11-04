# PYINCC FashionAI — product/UI source of truth

**Document purpose:** Lock the intended product behavior. This file is a product contract, not evidence that every feature has been implemented.

For the current code baseline, CI, asset identity, branch and next action, read `docs/PROJECT_PROGRESS_AND_REMAINING_P.md` first.

## Source precedence

1. Latest explicit owner instructions.
2. `docs/product-contract-v2.md` for the locked target scope.
3. This document for UI behavior and acceptance constraints.
4. Architecture documents and design references as implementation guidance.
5. Source code and CI as evidence of what actually exists; code does not silently redefine the product scope.

## Non-negotiable product direction

- FashionAI remains separate from AIPET.
- Main tabs: HOME | STUDIO | STORE | ACCOUNT.
- Home is the product entry point and routes users to Studio, Store, Wardrobe and Account.
- Studio is a single continuous 3D space. Tool panels must not cover or unexpectedly resize the avatar viewport.
- Keep the app local-first and offline-aware. No fake AI output, fake commerce, fake persistence or false success state.
- One primary avatar presentation; do not add an A/B avatar selector or unrelated demo characters.
- Keep consent, privacy and deletion controls explicit. Do not silently upload a user's face/photo.

## Avatar identity — current owner decision

The current Gracy Lee GLB is a **temporary technical build/UAT asset only**. It is not the official PYINCC avatar, must be labeled as a test model in the UI and must not be described as a completed PYINCC avatar.

The owner is building the official PYINCC GLB and will provide it later. Its absence does not block Android UI/P1 implementation or a technical APK build using the test model. The official-avatar acceptance gate remains pending until the real asset is supplied and evaluated.

The current temporary asset identity is recorded in `config/avatar-asset.json` and `docs/evidence/gracy-lee-license-grant.json`. The October 18/19 candidate with UID `4385c4af843e43379df8b702d04634f9` is superseded and must not be selected or downloaded as a fallback.

## Locked tab responsibilities — intended behavior

### HOME
- Entry point for face photo selection, consent and avatar setup.
- Show clearly whether a face/3D mapping operation is available; selecting a photo is not a completed Face Swap.
- Do not expose height/weight/form controls as functional until they are connected to a verified avatar mapping flow.
- Direct routes to Studio, Store, Wardrobe and Account.

### STUDIO
- Full-body 3D avatar viewer with stable, centered framing.
- Camera movement remains bounded; automatic rotation can be paused and reset.
- Skin Care, Wardrobe, Shop and Big Bag appear in a stable menu/panel system and do not cover the viewer.
- Effects or garment operations may be enabled only when they change the real GLB/material/garment data and pass verification.
- A disabled state is preferable to a control that only changes its own UI.

### STORE
- Only show connected product listings with verified source, merchant and price.
- Do not invent product images, prices, brands, stock or checkout status.
- Until a catalog is connected, state that the catalog is not integrated.

### ACCOUNT
- Explain privacy/local-first behavior and the actual authentication state.
- Provide applicable asset credits and license links for bundled third-party assets.
- Cloud backup remains unavailable until an actual opted-in persistence flow is implemented and tested.
- Never imply that an account, cloud or payment integration is live if it has not been verified.

## Current implementation limits to preserve

At the current checkpoint:
- Home routes and the Studio 3D-first viewer are implemented and passed the latest CI/widget checks.
- The bundled Gracy Lee viewer model remains a technical test model only.
- Face Swap, GLB Skin Care material processing, rigged 3D garment fitting, production Store/checkout and Cloud Backup are not accepted as implemented capabilities.
- The current Account widget test explicitly expects no visible “Bản quyền mô hình 3D” screen. The file-based asset attribution is bundled and checked, but a user-accessible selectable credit page is still an outstanding UI item; see the progress checkpoint and PR #2 history.
- Debug UI access is not proof of production authentication. Production auth remains gated by Firebase configuration.

## Acceptance rules

1. Preserve the currently working 3D model/render path unless a reproducible defect requires a change.
2. Do not replace a real GLB viewer with a static image or CSS mock.
3. Verify Home/Studio layouts at compact Android sizes; no overflow, clipped controls, or viewport overlap.
4. Verify the exact GLB bytes included in any APK; a source-only gate is not an APK check.
5. Require actual Android device evidence for render quality, camera behavior, offline operation and stability.
6. Keep test-asset technical acceptance separate from official PYINCC-avatar acceptance.
7. CI, successful compilation and widget tests do not imply visual, device or production PASS.

## Superseded historical decision

The October 18/19 temporary Sketchfab candidate with UID `4385c4af843e43379df8b702d04634f9` was blocked by the then-available listing/license evidence. It is not the current asset. On October 23 the project moved to the owner-supplied Gracy Lee GLB with UID `5e0c47f7f7fe453bb4d3c8c7eba356e8`, recorded CC BY 4.0 evidence and pinned byte/hash identity for temporary technical UAT. See the active manifest/evidence; do not reuse the older blocked candidate notes.
