# FashionAI 3D asset integration — current state

## Selected temporary candidate

Owner decision: 2026-10-18T05:16:31Z. Final mesh reconstruction is deferred; technical UAT must use the sole selected candidate https://skfb.ly/6YvQ7.

Resolved model UID: `4385c4af843e43379df8b702d04634f9`; author: `deep3dstudio`. Live public metadata reports `isDownloadable=false` and `Standard` license metadata. The listing links to Fab. No model download, purchase or entitlement verification has been performed.

**BLOCKED:** an acquired model file and reviewed license grant are missing. A public viewer or license label does not grant permission to package a GLB in an APK.

## Active pipeline

1. Engineering reviews the actual acquisition/license evidence for the intended technical UAT and distribution use; records it in `config/avatar-asset.json`.
2. Import exactly one approved `assets/avatars/pyincc_avatar_primary.glb`; record exact size and SHA-256. The GLB must carry its mesh/UV/material and embedded PNG/JPEG textures for the current structural gate.
3. Run `python3 scripts/avatar_gate.py`. There is no automatic conversion or fallback download.
4. CI runs source checks, builds only if the asset gate passes, and hashes the GLB extracted directly from the actual APK. It records raw APK SHA-256, package, minimum SDK, and signing evidence.
5. Perform physical Android UAT with full-body framing, front/back/left/right views, 360-degree camera, texture/material and offline checks. Technical UAT does not accept final avatar quality, Face Swap or garment fit.

## Preserved historical work

Both `model_1791878457744.glb` and `model_1791877892370.glb` remain at repository root. Their old preparation script is preserved but no longer invoked by CI. Primary and alternate scan outputs from older APKs are historical evidence only; there is no A/B selector or alternate asset in the new packaging contract.
