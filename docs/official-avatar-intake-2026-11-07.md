# Official PYINCC avatar intake — 7 November 2026

## Repository evidence

- Repository: `chiendollar0/PYINCC-FASHONAI`
- Branch: `main`
- Original path: `assets/pyincc_avatar_primary.glb`
- Canonical path: `assets/avatars/pyincc_avatar_primary.glb`
- Move commit: `1cd4d8152b8806131f3a03808ffb8662c0b7b249`
- File size reported by GitHub tree: 2,608,120 bytes
- Git blob SHA before and after move: `c190984eb7ff92cba6dd27ddc6a5d1603b522308`
- Owner says this is the official user-created PYINCC mesh and it has not been rigged.
- The obsolete ZIP is no longer in the repository inventory; no ZIP is needed for normal app packaging.

## Integrity limitation

The GitHub repository connector exposed the file path, size and Git blob SHA but did not provide the binary bytes for local GLB parsing. Therefore this report does **not** claim that the GLB header, declared length, mesh topology, UVs, materials, embedded textures, buffer references or rendering have passed inspection. Git blob SHA is not SHA-256.

## Current decision

- File placement: PASS.
- Binary GLB validation: NOT RUN.
- Mesh/UV/material/texture inventory: NOT RUN.
- Skeleton/skin: owner-declared unrigged; binary confirmation pending.
- SHA-256: NOT CAPTURED.
- Asset gate: BLOCKED.
- APK packaging: NOT AUTHORIZED until validation and gate updates pass.

## Next engineering actions

1. Obtain the binary in a local inspection runtime.
2. Parse with a real glTF 2.0 validator/parser and independently inventory geometry, UVs, materials, textures, external dependencies, nodes and skin/skeleton.
3. Compute SHA-256 from the exact binary.
4. Update `config/avatar-asset.json` with observed data only.
5. Refactor `scripts/avatar_gate.py` to support a user-created asset identity rather than a hard-coded Sketchfab UID and license-grant evidence model.
6. Add tests for owner-created provenance and the official GLB's actual structure.
7. Run the complete test suite and CI. Build only after the asset gate passes.
8. Verify the exact GLB is embedded in the APK and conduct physical Android UAT.

## Preservation rule

No historical GLB, conversion script, source document, or evidence file was deleted. The previous ZIP deletion was performed by the repository owner before this review; this workflow does not recreate it.
