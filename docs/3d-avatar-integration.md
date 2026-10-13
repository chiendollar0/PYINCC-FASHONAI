# PYINCC 3D model integration — asset delivery

## Verified local scan assets
- `pyincc_avatar_primary.glb`: 138088 vertices, 199132 triangles.
- `pyincc_avatar_alternate.glb`: 121336 vertices, 187031 triangles.
- Mesh and UV preserved, source textures removed; neutral material. No skeleton/rig, independent face material, garment separation or Face Swap.
- Both files were packaged separately in `PYINCC_3D_avatar_assets_for_project.zip` for delivery. **Binary assets are not yet committed to GitHub.** Do not claim the app renders these scans until assets are installed and tested.

## Install into Flutter app
Copy both `.glb` files into `assets/avatars/`. Register both in `pubspec.yaml` under `flutter: assets:`, then update the viewer's `src` to the bundled asset path. Run `flutter pub get`, `flutter analyze`, `flutter test` and Android physical-device validation.

## Next engineering gates
1. Bundle real GLBs in repository or approved asset distribution, replacing remote CesiumMan.
2. Verify camera 360, framing, UV, face geometry and performance on Android 10/6GB.
3. Split head/face UV region for consent-based texture replacement; do not claim true face swap before validation.
4. Prepare independently replaceable, fully clothed garment meshes and matching rig, without distorting scan.
5. Studio is 3D-first; the 2D editor must not be linked from user-facing navigation.

Reference image is a **pose/composition target**, not geometry or verified garment fit. Do not present a generated reference infographic as an actual GLB render.
