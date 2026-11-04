# FashionAI asset identity — current gate and historical record

**Current authority:** `config/avatar-asset.json` and the evidence files it hashes.  
**Current code baseline:** `c3d8dde0b288c3261a456337e8cee16cff5b9596`.  
**Latest gate:** Android workflow #140 — PASS for the temporary technical-UAT asset.

## Current manifest state

The current manifest records:
- `approval_status: verified`
- `intended_use: temporary_technical_uat_only`
- Model UID: `5e0c47f7f7fe453bb4d3c8c7eba356e8`
- Author: `hong227`
- License: CC BY 4.0
- Asset: `assets/avatars/pyincc_avatar_primary.glb`
- Exact size: 3,291,488 bytes
- Exact SHA-256: `cba9ea4f3db8961609fdb4ef6fda33b9a7af818cea3e65f534a37047d0f5f2dc`
- Attribution file: `assets/avatars/GRACY_LEE_ATTRIBUTION.txt`

Evidence files:
- `docs/evidence/gracy-lee-license-grant.json`
- `docs/evidence/gracy-lee-sketchfab-api.json`

The asset gate verifies the manifest, evidence hash, attribution hash, exact one-GLB inventory, GLB binary structure, embedded texture data and source-to-APK equality when an actual APK is supplied. Run #140 passed the source asset gate. It did not build an APK.

## Limits

This is a recorded source/rights review and structural packaging gate for temporary technical UAT only. The evidence records that the supplied GLB was not independently downloaded again; embedded provenance was matched against the saved public source snapshot. The gate does not certify legal entitlement beyond the recorded evidence, third-party publicity/privacy rights, visual quality, physical Android runtime or production acceptance.

The official PYINCC GLB is not yet in the repository. It remains a separate owner-supplied asset and acceptance gate. Do not use the temporary Gracy Lee hash as the official PYINCC asset hash.

## Historical record — superseded

On 2026-10-15, a previously supplied archive was recorded with these old prepared neutralized static-mesh files:

| Historical path | Bytes | SHA-256 |
|---|---:|---|
| `assets/avatars/pyincc_avatar_primary.glb` | 5,152,656 | `919421af91f4d155da84ba9e47670d5aac7739cac9fac959ab5add7d5381b983` |
| `assets/avatars/pyincc_avatar_alternate.glb` | 4,674,404 | `b8c964e38a097e5ca1f88773235af74f2a55db5c6e5c9ac388dd04e4d2388e6a` |

These values are historical and must not be used as current thresholds. They are not proof of a rigged avatar, Face Swap, garment replacement or current asset integration.
