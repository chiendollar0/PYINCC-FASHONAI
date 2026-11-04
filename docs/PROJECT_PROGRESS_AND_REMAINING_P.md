# PYINCC FashionAI — project checkpoint and session handoff

**Checkpoint date:** 2026-11-04  
**Repository:** `chiendollar0/PYINCC-FASHONAI`  
**Android working branch:** `fashionai/gracy-20261023`  
**iOS working branch:** `ios` (separate)  
**Last validated application-code commit:** `c3d8dde0b288c3261a456337e8cee16cff5b9596`  
**Last verified Android workflow:** [Run #140](https://github.com/chiendollar0/PYINCC-FASHONAI/actions/runs/41773896173)

This document is the single execution checkpoint for resuming FashionAI after a chat/session change. Update this file when the actual baseline or acceptance evidence changes. Do not create a second competing progress document.

## 1. Source-of-truth rules

Use this order:

1. Latest explicit owner instructions.
2. This checkpoint for current implementation state, branch, CI, blockers and next action.
3. `docs/PROJECT_UI_P0_SOURCE_OF_TRUTH.md` for product/UI intent and non-negotiable behavior.
4. `docs/product-contract-v2.md` for the locked target scope.
5. The asset manifest and hashed evidence for the exact bundled test asset.
6. Current source code, workflow runs and test results as implementation evidence.

Older plans, old chat summaries, stale branches and historical workflow runs must not override the current branch and exact latest evidence. If two documents disagree, fix the stale document and update this checkpoint; do not start another implementation branch to work around documentation drift.

## 2. Authoritative code baseline

| Item | Current value |
|---|---|
| Android source branch | `fashionai/gracy-20261023` |
| Validated application-code commit | `c3d8dde0b288c3261a456337e8cee16cff5b9596` |
| Latest run | [#140](https://github.com/chiendollar0/PYINCC-FASHONAI/actions/runs/41773896173) |
| Run result | `completed / success` |
| Android application ID configured by workflow | `com.pyincc.fashionai` |
| Minimum Android SDK configured by workflow | API 26 |
| iOS branch | `ios`, independent of Android |

At the time of this checkpoint, `main` is still the repository default branch but is not the Android implementation source. Comparison reported Android branch `27` commits ahead and `7` behind `main`. Do not merge `main` into the Android working branch as a routine sync; inspect each unique change first.

Any documentation-only commit made after the validated code commit does not change the application code tested by Run #140. When resuming, fetch the live branch ref and confirm that later commits are documentation-only before reusing the Run #140 evidence.

## 3. Latest CI result — Run #140

Run ID: `41773896173`  
Commit: `c3d8dde0b288c3261a456337e8cee16cff5b9596`  
Event: `push`  
Workflow: `.github/workflows/android-apk.yml`

| Job | Result | Evidence |
|---|---|---|
| `gate-tests` | PASS | Python asset/APK gate regression suite completed |
| `asset-gate` | PASS | Reviewed temporary asset manifest, evidence, attribution and exact GLB identity accepted by the gate |
| `validate` | PASS | Flutter dependency resolution, static analysis, unit/widget tests and Android Gradle Kotlin compile check completed |
| `build` | SKIPPED | Expected for a push event; APK job requires manual dispatch with `build_apk=true` |

Run #140 produced the `fashionai-asset-gate` evidence artifact only. It did **not** produce a new APK. Do not report this run as APK build success or device acceptance.

Historical APK results from earlier runs/PR merge refs are not APK evidence for this current code commit.

## 4. Current 3D asset identity and rights boundary

The active manifest is `config/avatar-asset.json`.

| Field | Recorded value |
|---|---|
| Model | Gracy Lee |
| Source UID | `5e0c47f7f7fe453bb4d3c8c7eba356e8` |
| Author | `hong227` |
| License recorded | CC BY 4.0 |
| Intended use | Temporary technical UAT only |
| GLB path | `assets/avatars/pyincc_avatar_primary.glb` |
| GLB size | 3,291,488 bytes |
| GLB SHA-256 | `cba9ea4f3db8961609fdb4ef6fda33b9a7af818cea3e65f534a37047d0f5f2dc` |
| Attribution file | `assets/avatars/GRACY_LEE_ATTRIBUTION.txt` |
| Rights evidence | `docs/evidence/gracy-lee-license-grant.json` |
| Public source snapshot | `docs/evidence/gracy-lee-sketchfab-api.json` |

The manifest's `approval_status=verified` and Run #140 asset-gate PASS apply only to recorded rights/identity and technical packaging prerequisites for this temporary asset. The evidence records that the supplied GLB was **not independently downloaded again** from Sketchfab; origin linkage is based on embedded provenance matching the saved public metadata snapshot. It makes no claim about third-party publicity/privacy rights, visual quality, runtime behavior or production acceptance.

The official PYINCC GLB is being built by the owner and has not yet been supplied. It is a separate acceptance gate. Its absence does not block the current Android UI/P1 work or building a technical APK using the temporary Gracy Lee asset. Do not use any old candidate with UID `4385c4af843e43379df8b702d04634f9`; that October 18/19 candidate was superseded.

## 5. Application implementation state at the validated code commit

### Implemented in the current Android code

- Home is the entry point and exposes routes to Studio, Store, Wardrobe and Account.
- Main navigation remains Home / Studio / Store / Account.
- Studio is 3D-first and uses the bundled temporary Gracy Lee model; the UI labels it as a technical test model and states that the official PYINCC avatar will be added later.
- Studio has slow automatic rotation, pause/resume, reset-view controls and bounded camera settings. The viewer disables pan/zoom to reduce accidental displacement.
- Studio tool definitions are centralized with stable keys, labels, semantics and actions.
- Compact Home/Studio widget tests and the latest interaction tests pass in Run #140.
- Unavailable features are presented as disabled or not integrated, rather than claiming a completed result.

### Not implemented or not accepted as production capabilities

- Face Swap / face-to-3D mapping engine.
- Real Skin Care effects applied to GLB materials/textures.
- Rigged 3D garment try-on, wardrobe persistence and complete Big Bag pipeline.
- Connected product catalog, verified merchant links and checkout.
- Cloud Backup persistence and production cloud data flow.
- Live production Firebase authentication on a configured real project/device.
- Final PYINCC avatar quality and physical-device visual acceptance.

### Attribution UI discrepancy that must not be lost

The current `test/widget_test.dart` explicitly asserts that the Account page does **not** show “Bản quyền mô hình 3D”. The license/attribution text file is bundled and checked by the asset gate, but a user-accessible attribution screen is not present in the active code snapshot. PR #2 contains an earlier attempt at this feature and has a review finding that the source/license links must remain selectable. Do not mark Account attribution UI as complete. Review and implement the small required change directly on the existing Android branch; do not merge the stale PR branch wholesale.

## 6. Acceptance matrix

| Gate | Current status | What is still required |
|---|---|---|
| Python asset/APK regression gate | PASS in #140 | No re-run unless code/gate changes |
| Flutter static analysis | PASS in #140 | No re-run unless code changes |
| Flutter unit/widget tests | PASS in #140 | No re-run unless code/tests change |
| Android Gradle Kotlin compile | PASS in #140 | No re-run unless Android source/config changes |
| Temporary GLB structural/rights gate | PASS in #140 | Temporary technical-UAT scope only |
| New APK from current source | NOT BUILT | Manual `workflow_dispatch`, `build_apk=true` |
| APK SHA/package/signature/embedded GLB on current source | NOT AVAILABLE | Verify actual APK artifact after build |
| Galaxy A11 physical UAT | NOT RUN | Install exact APK and record device/render/log evidence |
| Official PYINCC GLB | PENDING OWNER ASSET | Inspect real asset and re-run separate official-avatar gate |
| Production release | NOT ACCEPTED | Requires all applicable runtime, privacy, asset and device gates |

## 7. Next work order — one canonical sequence

1. **Resolve the Account attribution UI discrepancy** on `fashionai/gracy-20261023`: add the bundled credit page with selectable source/license links and a widget regression; preserve the current GLB viewer and all existing passing tests.
2. Batch the related code/test changes into one coherent commit. Run one complete Android workflow and repair any failure from its actual log before reporting.
3. After validation is green, dispatch `.github/workflows/android-apk.yml` manually with `build_apk=true`. Push-triggered runs do not build APKs.
4. Inspect the resulting APK artifact: package ID, minSdk, debug signature, raw APK SHA-256, exact embedded GLB size/SHA-256 and attribution bytes.
5. Install that exact APK on Galaxy A11 and record real render, camera interaction, offline behavior, logcat and stability. Keep physical UAT separate from CI.
6. When the official PYINCC GLB is supplied, evaluate it independently and replace the temporary asset only after identity, rights, mesh, UV, textures, hash and Android render checks pass.

Do not restart already passing Home/Studio work without a new regression. Do not create a new Android branch for these tasks.

## 8. Branches, PRs and issue tracking

Current branch inventory was checked on 2026-11-04:

| Branch / PR | Current relationship or status | Handling |
|---|---|---|
| `fashionai/gracy-20261023` | Active Android source; validated code commit above | Continue here |
| `ios` / PR #5 | Separate iOS workstream; PR targets `main` | Keep separate; do not combine with Android |
| `main` | Default branch; diverged from active Android branch | Not the Android work base |
| `android` | 6 commits ahead / 27 behind the active branch | Do not switch to it; inspect unique commits before cleanup |
| `aipet-render-audit-20261017` | 0 ahead / 29 behind active branch | Owner previously authorized removal; branch still exists. Current connector has no branch-delete action, so removal was not performed |
| `fix/studio-fixed-viewport-auto-rotate` | 5 ahead / 26 behind active branch; related PR #4 is already merged | Historical branch; do not merge again; cleanup requires a delete-ref capability |
| `fix/gracy-attribution-widget-test` / PR #2 | 6 ahead / 26 behind active branch; still open | Review only the needed attribution behavior; do not merge the stale branch wholesale |
| `fix/fashionai-gracy-asset-gate-20261020` / PR #1 | Still open against `main`; contains an older alternate asset-fetch/workflow path | Do not merge automatically; active branch already uses the pinned owner-supplied GLB and current gate |

Issue #3 remains the main Android P0/P1 tracker. Do not create duplicate issues for the same work. PR #5 is the separate iOS workflow change. No branch deletion, PR merge or history rewrite was performed during this checkpoint update.

## 9. Workflow and session-resumption rules

### Android workflow behavior

- Push to `fashionai/gracy-20261023`: run Python gate tests, asset gate, Flutter analysis/tests and Android Gradle compile check.
- Manual dispatch with `build_apk=true`: run the same prerequisites, then build the debug APK and verify the actual packaged asset, package identity, minSdk and signature.
- The current connector can inspect workflow runs/jobs and source files, but does not expose a workflow-dispatch action. Do not claim the APK job has been started unless GitHub reports a real run.

### Required steps at the start of every new session

1. Read this file before editing anything.
2. Fetch the live ref for `fashionai/gracy-20261023`; record its exact HEAD SHA.
3. Compare that HEAD with the last checkpoint. Inspect only new commits/diffs since the checkpoint.
4. Check the latest workflow for the current HEAD. Reuse PASS evidence when the source has not changed; do not re-run fixed items without a regression.
5. Continue on the existing Android branch. Keep `ios` separate. Never create a new branch merely because a chat session changed.
6. Batch related repairs into one commit and one validation cycle. Fix CI errors from the actual failing step/log; update this checkpoint after the result is verified.
7. Give the owner one consolidated report after the work batch: progress, final commit, CI, APK/device status and remaining blockers.

**Do not treat a new chat session as a new project baseline.** The Git branch, exact commit, this checkpoint and the latest verified workflow are the persistent handoff.
