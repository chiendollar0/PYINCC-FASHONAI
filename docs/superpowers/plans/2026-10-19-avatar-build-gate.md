# FashionAI avatar build gate implementation plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task. Continue the authorized repair in this session.

**Goal:** Stop APKs from silently packaging old scans after the temporary-avatar decision; require reviewed rights and exact source-to-APK asset identity.

**Architecture:** A Python standard-library gate validates one approved embedded-texture GLB against a reviewed manifest. Android builds depend on this gate and verify the actual APK before upload. Historical scans and their conversion script remain preserved outside the active build path.

**Tech Stack:** Python 3 unittest/zipfile/hashlib; existing Flutter/model_viewer_plus; GitHub Actions.

**Spec:** docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md, docs/product-contract-v2.md, owner chat decision 2026-10-18T05:16:31Z.

## Global constraints
- FashionAI only; never use or modify AIPET evidence, code, branches or workflows.
- Sole temporary candidate: https://skfb.ly/6YvQ7, UID 4385c4af843e43379df8b702d04634f9.
- Exactly one approved user-facing/avatar package asset; preserve historical work.
- Missing rights/assets blocks packaging; CI success never certifies visual quality or physical Android UAT.
- No purchases, substitute avatars, or unlicensed downloads.

## Review focus
- Missing or string-valued permission flags must not unlock a build.
- Wrong/mutated GLB or evidence must fail SHA-256 checks.
- Alternate or duplicate GLBs inside the actual APK must fail.
- External image/buffer references must not pass the offline asset gate.
- Source conversion must never overwrite the approved temporary avatar in CI.

## Task 1: Asset and APK gate
- [x] Write unittest cases for approved asset, pending license, altered files, invalid GLB and wrong APK inventory; run RED.
- [x] Implement scripts/avatar_gate.py: validate_assets(root: Path) -> dict; verify_apk(root: Path, apk: Path) -> dict; CLI --root/--apk/--report.
- [x] Run python -m unittest discover -s tests -v; expect GREEN.

## Task 2: Build integration and documentation
- [x] Replace automatic scan regeneration in Android CI with an explicit asset-gate prerequisite; run Python regression suite independently.
- [x] Require actual APK asset hashing before upload; retain evidence with commit/run identity and raw APK SHA-256.
- [x] Apply the asset gate before iOS simulator packaging as well.
- [x] Add blocked manifest and public source metadata; correct stale integration/asset docs without inventing approval.
- [ ] Review YAML and all changes, commit atomically with an expected-HEAD lease, observe CI, and update the existing FashionAI audit.

## Progress
- Context: latest owner chat confirms temporary Sketchfab candidate; main adfc76c. No newer FashionAI implementation found.
- Evidence: short URL resolved; live Sketchfab metadata reports isDownloadable=false, Standard license. Fab listing requires license selection/acquisition; no entitlement supplied.
- Ruling: implement and verify fail-closed packaging now; do not substitute or acquire a paid model. Cost: technical APK remains blocked until an authorized asset is available.

- Task 1: complete — 24 regression tests RED before implementation, GREEN after implementation; source-only fixture GLBs remain in temporary directories.
- Task 2: implementation complete locally; YAML graph/bash syntax checks PASS; real pending manifest exits2/BLOCKED with production_verified=false. Independent review pending before remote update.

- Independent review: two Important findings, no Critical. Fixed accessor bounds/type/stride/count checking and valid solid-color secondary materials. Six new regression cases observed RED, then full31/31 GREEN. Additional unused-texture guard passes.
- Local verification: full Python suite31/31; both workflow YAML graphs and all bash run blocks valid; real manifest remains BLOCKED with exit2. No Flutter/Dart runtime behavior was changed. SDK signature/identity execution and physical Android UAT remain unverified until an authorized asset is supplied.
