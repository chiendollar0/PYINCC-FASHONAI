# FashionAI 3D asset integration — official owner-created mesh

## Current official candidate

The owner uploaded `pyincc_avatar_primary.glb` to the repository. It was found at `assets/pyincc_avatar_primary.glb` and moved to the canonical path `assets/avatars/pyincc_avatar_primary.glb` in commit `1cd4d8152b8806131f3a03808ffb8662c0b7b249`.

Repository metadata confirms:
- Size: 2,608,120 bytes.
- Git blob SHA: `c190984eb7ff92cba6dd27ddc6a5d1603b522308`.
- Same blob identity before and after move, so the file was not re-encoded.
- Owner states this is the official PYINCC mesh and is not rigged.

The binary has not yet been inspected. Mesh/primitive/vertex/index counts, UVs, materials, embedded textures, GLB header, buffer references and SHA-256 are not yet known. The manifest and APK asset gate remain BLOCKED.

## Static mesh versus rigged avatar

An unrigged mesh can be rendered and rotated by the existing static 3D viewer if its GLB structure, materials and textures are valid. A skeleton/skin is not required for static display. However, rigged garment fitting, skeletal deformation and character animation require a compatible rig and are not delivered by this asset as currently described.

## Integration checklist

1. Inspect the binary GLB, do not infer mesh quality from the filename or file size.
2. Record GLB version/length, scene/node inventory, mesh/primitive counts, vertex/index counts, UV sets, normals, material/texture references, embedded image formats, external dependencies, skeleton/skin counts and exact SHA-256.
3. Check the current viewer compatibility and Android memory/rendering implications.
4. Update `config/avatar-asset.json` with observed values only.
5. Update `scripts/avatar_gate.py` to support owner-created assets without the historical Sketchfab UID assumption; add tests and keep the gate fail-closed.
6. Run the complete Python gate suite, Flutter analyze/tests, Android Gradle compile, then APK build only after asset gate passes.
7. Verify APK contains exactly one primary GLB with byte-for-byte identical size and SHA-256.
8. Perform physical Android UAT for full-body framing, front/back/left/right views, camera orbit, texture/material and offline behavior.

## Preserved history

The historical root-level scan GLBs and conversion script remain preserved for audit. The deleted ZIP is not required after intake. Do not delete historical source files or create an alternate avatar selector.
