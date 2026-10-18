# PYINCC FashionAI — SOURCE OF TRUTH / UI & P0

Document precedence (do not reinterpret from CI or screenshots):
1. Latest explicit owner instructions.
2. PYINCC_FashionAI_Spec_KhoaCung_v2_2026-10-13.docx (scope locked).
3. PYINCC_FashionAI_Nguyen_tac_hoat_dong_co_anh_mau.docx.
4. PYINCC FashionAI UX.mp4, architecture documents; code is implementation evidence only.

## Non-negotiable contract
- Exactly ONE approved avatar in the user-facing app. No A/B selector, invented models, or demo replacements.
- Bottom tabs: HOME | STUDIO | STORE | ACCOUNT. Responsibilities are locked by the V2 document.
- HOME: real face photo, consent, Face Swap status, avatar, height/weight/form X/M/N. Do not imply face mapping works before it does.
- STUDIO: full-body 3D avatar, 360-degree camera, floating compact menus for Skin Care / Tủ đồ mẫu / Shop / Big Bag, Undo/Reset; tools must not obscure avatar. No duplicate pages or giant placeholders.
- STORE: legitimate product links/sources, no invented prices/brands.
- ACCOUNT: authentication, temporary session, cloud opt-in, delete controls.
- UI: fashion-grade, cream/beige/white/neutral; consistent component size, hierarchy, spacing; remove debug/explanatory copy from user-facing pages. Error messages must remain truthful and accessible.
- Offline-first; no fake AI output, no forced production PASS.

## Each build — do not ask owner to restate prior requirements
1. Read this contract and the named source docs. Compare changes against every locked rule.
2. Static analyze, widget tests, GLB validation, APK compile, inspect packaged assets, record commit/run/artifact/digest.
3. Review mobile layouts and Studio full-body front/side/back camera; CI green does not prove visual correctness.
4. Owner tests only actual Android device behavior, render, interaction, and performance. Keep P0 FAIL/BLOCKED until verified.
5. Record regressions and fixes; do not invent extra scope or ask the owner to repeat established constraints.

Current limitations: bundled scanned GLB is a renderer source, not evidence of successful Face Swap or separate 3D garment rigging. Existing debug builds are not production approvals.

## Temporary avatar override — 2026-10-18
- Owner authorized deferring final GLB mesh recreation and requested using https://skfb.ly/6YvQ7 as the sole temporary model for P0 technical UAT.
- Preserve existing GLB work and reference images; do not delete or claim avatar quality PASS.
- Short URL could not be resolved or license verified in this session. Do not download, redistribute, bundle or publish the Sketchfab asset until the exact model, download permission and commercial/redistribution license are verified.
- After obtaining an authorized GLB, bundle exactly one `assets/avatars/pyincc_avatar_primary.glb`; disable old scan regeneration and alternate-asset packaging. Validate geometry, texture, APK contents and physical Android render. Technical UAT is not final avatar acceptance.


## Verified follow-up — 2026-10-19
- The selected short URL now resolves to Sketchfab model UID `4385c4af843e43379df8b702d04634f9`, by `deep3dstudio`. Evidence: `docs/evidence/sketchfab-4385c4a-metadata.json`.
- Live metadata reports `isDownloadable=false` and Standard license metadata. No acquired asset/license grant has been verified. Do not classify this candidate as a verified free redistributable download.
- The sole-asset/rights contract is enforced by `scripts/avatar_gate.py` and `config/avatar-asset.json`. CI must not regenerate the old scan pair, package an alternate GLB or create a replacement avatar. Missing rights or exact approved asset blocks packaging.
- Tests and source analysis may run while the asset is blocked. A successful test job does not unlock APK upload or physical Android acceptance.
- Final skin/garment reconstruction remains deferred, not PASS. Temporary technical UAT, four-angle render and physical Android UAT remain separate unverified gates.
