# FashionAI 3D asset integration — current state

**Current implementation source:** `fashionai/gracy-20261023`.  
**Current code baseline:** `c3d8dde0b288c3261a456337e8cee16cff5b9596`.  
**Latest asset-gate result:** Run #140 — PASS (temporary technical-UAT scope only).

## Active temporary test asset

- Title: Gracy Lee
- Sketchfab UID: `5e0c47f7f7fe453bb4d3c8c7eba356e8`
- Author: `hong227`
- License recorded: CC BY 4.0
- Intended use: temporary technical build/UAT only
- GLB: `assets/avatars/pyincc_avatar_primary.glb`
- Size: 3,291,488 bytes
- SHA-256: `cba9ea4f3db8961609fdb4ef6fda33b9a7af818cea3e65f534a37047d0f5f2dc`
- Attribution: `assets/avatars/GRACY_LEE_ATTRIBUTION.txt`
- Rights evidence: `docs/evidence/gracy-lee-license-grant.json`
- Public metadata snapshot: `docs/evidence/gracy-lee-sketchfab-api.json`

The current manifest records `approval_status=verified` for this temporary technical use. The gate checks the source identity, evidence hash, attribution hash, single-GLB inventory, GLB structure and embedded textures. Evidence limitations are explicit: the supplied GLB was not independently downloaded again; embedded provenance matches the saved public source metadata. This record is not a legal warranty or a statement about third-party publicity/privacy rights.

## Official PYINCC avatar — separate pending gate

The official PYINCC GLB is being made by the owner and has not yet been supplied. It must not be approximated by relabeling Gracy Lee or by using an old scan/sample. Its absence does not block Android UI/P1 or technical APK build using the temporary GLB.

When received, inspect the actual supplied bytes, model identity and rights, geometry/meshes, UVs, textures/materials, file size/hash and Android runtime rendering. Only then replace the temporary test model and run the official-avatar acceptance gate.

## Active pipeline and CI boundaries

1. Review `config/avatar-asset.json` and the referenced evidence files.
2. Run `python3 scripts/avatar_gate.py --report build/evidence/avatar-gate.json`.
3. CI runs the gate and source validation. On push it does not package an APK.
4. A manual workflow dispatch with `build_apk=true` builds the debug APK after prerequisites pass.
5. The APK gate verifies exact embedded GLB and attribution bytes and records APK identity/signature evidence.
6. Physical Android UAT separately verifies full-body framing, front/back/left/right viewing, camera controls, textures/materials, offline behavior and stability.

## Historical candidate — do not resume

The October 18/19 candidate UID `4385c4af843e43379df8b702d04634f9` by `deep3dstudio` was blocked by the evidence then available. It was superseded on October 23 by the owner-supplied Gracy Lee asset above. Older notes saying the current candidate is that blocked model are obsolete.

## Preserved historical work

The two root-level scan GLBs and `scripts/prepare_avatar_assets.py` are historical assets/workflow support only. They are not alternate avatars and must not be silently included in the current APK. The active gate requires exactly one GLB under `assets/avatars`.
