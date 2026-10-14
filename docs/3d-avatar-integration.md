# PYINCC 3D model integration — asset delivery

## Models
- `assets/avatars/pyincc_avatar_primary.glb`: 138,088 vertices, 199,132 triangles; neutral material.
- `assets/avatars/pyincc_avatar_alternate.glb`: 121,336 vertices, 187,031 triangles; neutral material.
- Extract `PYINCC_FashionAI_3D_assets_ready.zip` from the project conversation at the repository root.
- **Binary GLB files are not yet committed to GitHub.** The viewer shows an explicit missing-asset message until these are installed.
- `pubspec.yaml` already includes `assets/avatars/`. Studio embeds the primary model; Home provides an A/B full-screen viewer.

## Validation
Run `flutter pub get`, `flutter analyze`, `flutter test` and `flutter run` after extracting assets. Test offline camera orbit and full-body framing on Android 10 / 6GB RAM. Scan mesh and UV remain; texture was removed. These scans have no face material separation, rig or modular garment meshes. Face Swap and 3D outfit replacement remain unimplemented. The 2D overlay editor is not part of user-facing navigation.
