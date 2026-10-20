# FashionAI repository isolation policy

Owner directive (2026-10-21): AIPET and PYINCC FashionAI are separate projects.

- This repository is dedicated to PYINCC FashionAI only.
- Do not add AIPET source, assets, build jobs, branches, artifacts, test results, or audit evidence.
- Do not use this repository as an AIPET test environment.
- Cross-project source sharing, CI sharing, or repository sharing requires a separate, explicit owner approval.
- The obsolete branch `aipet-render-audit-20261017` has no commits ahead of main and is approved for deletion; do not merge it.
- Build evidence must correspond to the exact FashionAI source revision and the exact approved FashionAI GLB.
- Gracy Lee is a temporary FashionAI P0 technical-UAT candidate, not an approved production avatar.
- Never mark an APK or visual Android test PASS without actual build/device evidence.
