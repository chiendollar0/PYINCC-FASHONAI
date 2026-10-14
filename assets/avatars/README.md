# PYINCC scanned avatar assets

Upload the two GLB files from the project asset bundle into this directory, keeping these exact names:

- `pyincc_avatar_primary.glb` (5,152,656 bytes)
- `pyincc_avatar_alternate.glb` (4,672,404 bytes)

GitHub supports files of these sizes in a normal repository; Git LFS is not necessary. For browser upload, open this folder on GitHub, select **Add file → Upload files**, select each extracted .glb, then commit. Do not upload the ZIP without extracting it: Flutter expects the individual .glb files.

After upload, verify the file sizes in GitHub and trigger Android CI. The viewer loads assets locally. Face Swap and modular clothing are not implemented.
