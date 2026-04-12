# Tasks: Set-JournalAndScratch

**Branch**: `001-set-journal-scratch`  
**Input**: Design documents from `/specs/001-set-journal-scratch/`  
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are included in all descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm directory structure, verify module registration, and create the controller scaffold.

- [x] T001 Verify all required modules are importable: `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email` in `src/Modules/`
- [x] T002 Create the controller file scaffold (param block + `#Requires` + module imports only, no logic) in `src/Controllers/Set-JournalAndScratch.ps1`
- [x] T003 Create the integration test file scaffold in `src/Controllers/Tests/Set-JournalAndScratch.Tests.ps1`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: All new `ZertoZVM.Core` public functions that every user story depends on. Must be complete before any user story work begins.

**⚠️ CRITICAL**: No user story controller work can begin until this phase is complete.

- [x] T004 [P] Implement `Get-VpgJournalScratchState` in `src/Modules/ZertoZVM.Core/Public/Get-VpgJournalScratchState.ps1`  
  Opens a read-only VPG settings edit session via `New-ZertoVpgsetting`, calls `Get-ZertoVpgsettingjournal` and `Get-ZertoVpgsettingscratch`, converts HardLimitInMB → GB, discards the session (no commit), and returns a `[PSCustomObject]` with fields: `ZVMHost`, `VpgName`, `VpgIdentifier`, `JournalSizeGB`, `ScratchSizeGB`, `CapturedAt`.

- [x] T005 [P] Implement `Test-JournalScratchBackupExists` in `src/Modules/ZertoZVM.Core/Public/Test-JournalScratchBackupExists.ps1`  
  Accepts `-ZVMHost [string]` and `-BackupRoot [string]`. Checks `{BackupRoot}\{ZVMHost}\*.json` excluding `*_processed.json`. Returns `[bool]` — `$true` if any unprocessed backup exists, `$false` otherwise.

- [x] T006 [P] Implement `New-JournalScratchBackup` in `src/Modules/ZertoZVM.Core/Public/New-JournalScratchBackup.ps1`  
  Accepts `-ZVMHost [string]`, `-BackupRoot [string]`, `-StateRecords [PSCustomObject[]]`. Ensures the directory `{BackupRoot}\{ZVMHost}\` exists (creates it). Serializes the array to JSON and writes to `{BackupRoot}\{ZVMHost}\{yyyyMMdd-HHmmss}.json`. Returns the full path written.

- [x] T007 [P] Implement `Invoke-JournalScratchUpdate` in `src/Modules/ZertoZVM.Core/Public/Invoke-JournalScratchUpdate.ps1`  
  Accepts `-ZVMHost [string]`, `-VpgIdentifier [string]`, `-VpgName [string]`, `-JournalSizeGB [int]`, `-ScratchSizeGB [int]`.  
  Converts GB → MB (`× 1024`). Opens a VPG settings edit session via `New-ZertoVpgsetting`, calls `Set-ZertoVpgsettingjournal` and `Set-ZertoVpgsettingscratch` with the MB-converted body, commits with `Start-ZertoVpgsettingcommit`. On any error, calls `Remove-ZertoVpgsetting` to clean up the uncommitted session before re-throwing.  
  Returns a `[PSCustomObject]` `VpgUpdateResult` (see data-model.md) with `Action = 'Updated'` on success or `Action = 'Failed'` on error.

- [x] T008 [P] Implement `Invoke-JournalScratchRestore` in `src/Modules/ZertoZVM.Core/Public/Invoke-JournalScratchRestore.ps1`  
  Accepts `-ZVMHost [string]`, `-BackupRecord [PSCustomObject]` (one element from backup JSON).  
  Uses `$BackupRecord.JournalSizeGB` and `$BackupRecord.ScratchSizeGB` (GB → MB conversion). Opens settings session, sets journal + scratch, commits. Cleans up session on failure.  
  Returns a `VpgUpdateResult` with `Action = 'Restored'` on success or `Action = 'Failed'` on error.

- [x] T009 [P] Implement `Complete-JournalScratchBackup` in `src/Modules/ZertoZVM.Core/Public/Complete-JournalScratchBackup.ps1`  
  Accepts `-BackupFilePath [string]`. Renames the file to insert `_processed` before the `.json` extension: `{basename}_processed.json`. Throws if the file does not exist. Returns the new path.

- [x] T010 Update `ZertoZVM.Core.psd1` to export all 6 new public functions in `src/Modules/ZertoZVM.Core/ZertoZVM.Core.psd1`  
  *(psm1 uses `Export-ModuleMember -Function $file.BaseName` — auto-exports all public functions by filename. No manifest change needed.)*

- [x] T011 [P] Write Pester unit tests for `Get-VpgJournalScratchState` in `src/Modules/ZertoZVM.Core/tests/Get-VpgJournalScratchState.Tests.ps1`  
  Mock `New-ZertoVpgsetting`, `Get-ZertoVpgsettingjournal`, `Get-ZertoVpgsettingscratch`. Assert MB→GB conversion, returned object shape, and that no commit is called.

- [x] T012 [P] Write Pester unit tests for `Test-JournalScratchBackupExists` in `src/Modules/ZertoZVM.Core/tests/Test-JournalScratchBackupExists.Tests.ps1`  
  Use `TestDrive:` filesystem. Assert `$true` when unprocessed file present, `$false` when only `_processed.json` present, `$false` when no files present.

- [x] T013 [P] Write Pester unit tests for `New-JournalScratchBackup` in `src/Modules/ZertoZVM.Core/tests/New-JournalScratchBackup.Tests.ps1`  
  Use `TestDrive:`. Assert file creation, correct JSON content, returned path matches written file.

- [x] T014 [P] Write Pester unit tests for `Invoke-JournalScratchUpdate` in `src/Modules/ZertoZVM.Core/tests/Invoke-JournalScratchUpdate.Tests.ps1`  
  Mock all API wrappers. Assert GB→MB conversion in body, `Action = 'Updated'` on success, `Action = 'Failed'` and `Remove-ZertoVpgsetting` called on error.

- [x] T015 [P] Write Pester unit tests for `Invoke-JournalScratchRestore` in `src/Modules/ZertoZVM.Core/tests/Invoke-JournalScratchRestore.Tests.ps1`  
  Mock all API wrappers. Assert sizes come from backup record, `Action = 'Restored'` on success, cleanup called on error.

- [x] T016 [P] Write Pester unit tests for `Complete-JournalScratchBackup` in `src/Modules/ZertoZVM.Core/tests/Complete-JournalScratchBackup.Tests.ps1`  
  Use `TestDrive:`. Assert rename produces `_processed.json` suffix, throws when file not found.

**Checkpoint**: All 6 module functions implemented, exported, and unit-tested. Controller work can now begin.

---

## Phase 3: User Story 1 — Apply New Journal and Scratch Sizes (Priority: P1) 🎯 MVP

**Goal**: Implement the core apply flow — validate no existing backup, capture current state, write backup, compare sizes, update differing VPGs, report results.

**Independent Test**: Run against a test ZVM with 2+ VPGs whose current sizes differ from `-JournalSizeGB`/`-ScratchSizeGB`. Verify backup file written, VPGs updated, CSV + email + telemetry + Doctor outputs produced.

### Implementation for User Story 1

- [x] T017 [US1] Implement the parameter block and setup section (Phase 1 of controller-contract) in `src/Controllers/Set-JournalAndScratch.ps1`  
  Add `#Requires -Version 7.5`. Declare all parameters: `ZVMHost [string]`, `VpgName [string[]]`, `JournalSizeGB [int]` (mandatory), `ScratchSizeGB [int]` (mandatory), `EmailTo [string]`, `ZertoCred [PSCredential]`, `Doctor [bool] = $true`. Use `ParameterSetName` to enforce `JournalSizeGB`/`ScratchSizeGB` required when `-Restore` absent. Import all modules from `$PSScriptRoot\..\Modules\*`. Call `Initialize-ProjectConfig`, resolve ZVM server list from `-ZVMHost` or `zvmservers.txt`, initialize `$Results` list, capture `$StartTime`, call `New-ProjectTelemetry`.

- [x] T018 [US1] Implement backup guard and state capture loop in `src/Controllers/Set-JournalAndScratch.ps1`  
  For each ZVM: call `Connect-ZertoZVM`; call `Test-JournalScratchBackupExists` — if `$true`, log with `Write-Log -Level 'Error'` (key=value: `zvm=$Server`), emit non-terminating error via `Write-Error`, `Disconnect-ZertoZVM`, `continue` to next ZVM. Otherwise, retrieve VPG list via `Get-ZertoVPG`, apply `-VpgName` filter if provided, call `Get-VpgJournalScratchState` for each VPG, accumulate state records.

- [x] T019 [US1] Implement backup write and size update logic in `src/Controllers/Set-JournalAndScratch.ps1`  
  After state is captured for a ZVM: call `New-JournalScratchBackup -ZVMHost $Server -BackupRoot $BackupPath -StateRecords $StateRecords`. Then iterate VPGs: if `JournalSizeGB` or `ScratchSizeGB` differs from desired, call `Invoke-JournalScratchUpdate`; otherwise produce a `VpgUpdateResult` with `Action = 'Skipped'`. Increment `$vpgs_processed`, `$vpgs_updated`, `$vpgs_failed` counters. Implement consecutive failure circuit-breaker: local `$ConsecutiveFails` counter resets to 0 on success; if it reaches 3, log circuit-breaker trigger and `break` inner VPG loop. Add all results to `$Results`. Call `Disconnect-ZertoZVM`.

- [x] T020 [US1] Implement output distribution (Phase 3 of controller-contract) in `src/Controllers/Set-JournalAndScratch.ps1`  
  Call `Add-TelemetryMetric` for all 5 feature KPIs (`vpgs_processed`, `vpgs_updated`, `vpgs_failed`, `desired_journal_size_gb`, `desired_scratch_size_gb`) plus 4 mandatory baselines. Call `Export-ProjectCSVReport`. Compose and send email via `Set-FormattedEmail` / `Send-FormattedEmail` with subject `"Set-JournalAndScratch"` and CSV attachment. Call `Submit-ProjectTelemetry`. Implement Doctor output: pipe `$Results` through `Select-Object ZVMHost,VpgName,JournalSizeGB,ScratchSizeGB,vpgs_processed,vpgs_updated,vpgs_failed | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1` with quote-stripping. Wrap in `if ($Doctor)` block.

- [x] T021 [US1] Write integration test for the apply flow in `src/Controllers/Tests/Integration/Set-JournalAndScratch.Tests.ps1`  
  Use mock data from `src/Controllers/Tests/Shared/mocks/`. Mock `Connect-ZertoZVM`, `Get-ZertoVPG`, all new Core module functions, `Submit-ProjectTelemetry`, `Send-FormattedEmail`. Assert backup written before updates, results count correct, KPIs populated, Doctor output format.

**Checkpoint**: User Story 1 fully functional — apply runs, backup created, VPGs updated, all 4 outputs produced.

---

## Phase 4: User Story 2 — Restore Journal and Scratch Sizes from Backup (Priority: P2)

**Goal**: Implement the `-Restore` switch path — locate backup, restore each VPG to backed-up sizes, mark backup as processed.

**Independent Test**: After a successful apply run (creating a backup), run `Set-JournalAndScratch -Restore`. Verify VPG sizes returned to original values, backup file renamed to `_processed.json`, and all 4 outputs produced.

### Implementation for User Story 2

- [x] T022 [US2] Add `-Restore` switch parameter and parameter set validation in `src/Controllers/Set-JournalAndScratch.ps1`  
  Add `[switch]$Restore` to the param block. Use `ParameterSetName` or an early guard: if `-Restore` is present and either `-JournalSizeGB` or `-ScratchSizeGB` is provided, throw `[System.ArgumentException]`. In the restore path, `JournalSizeGB` and `ScratchSizeGB` are not mandatory.

- [x] T023 [US2] Implement the restore orchestration loop in `src/Controllers/Set-JournalAndScratch.ps1`  
  When `$Restore` is `$true`: for each ZVM, call `Connect-ZertoZVM`. Locate unprocessed backup using `Get-ChildItem` on `{BackupRoot}\{ZVMHost}\*.json` excluding `*_processed.json`; if none found, `Write-Error` and `continue`. If multiple found, select most recent by `LastWriteTime` and log a warning. Load backup JSON with `Get-Content | ConvertFrom-Json`. Apply `-VpgName` filter if provided. For each backup record, call `Invoke-JournalScratchRestore`; increment counters; apply circuit-breaker (same 3-consecutive-fail logic as apply). Add results to `$Results`. After all VPGs processed for a ZVM, call `Complete-JournalScratchBackup`. Call `Disconnect-ZertoZVM`.

- [x] T024 [US2] Write integration test for the restore flow in `src/Controllers/Tests/Integration/Set-JournalAndScratch.Tests.ps1`  
  Mock the backup file presence via `TestDrive:`. Assert `Invoke-JournalScratchRestore` called once per backup record, `Complete-JournalScratchBackup` called after all VPGs, correct renaming, Doctor output produced.

**Checkpoint**: User Stories 1 and 2 both independently functional. Apply creates backup; restore consumes and marks it.

---

## Phase 5: User Story 3 — Multi-ZVM Execution with Partial Failure Tolerance (Priority: P3)

**Goal**: Validate that multi-ZVM iteration, ZVM-level failure isolation, per-VPG failure isolation, and the consecutive-failure circuit-breaker all work correctly when reading from `zvmservers.txt`.

**Independent Test**: Run without `-ZVMHost`, with `zvmservers.txt` containing 3 ZVM entries (1 unreachable). Verify: unreachable ZVM logged + skipped, reachable ZVMs processed, final report covers all ZVMs.

### Implementation for User Story 3

- [x] T025 [US3] Verify and harden ZVM iteration error isolation in `src/Controllers/Set-JournalAndScratch.ps1`  
  Wrap each ZVM's entire processing block (connect through disconnect) in a `try/catch`. On ZVM-level exception, call `Write-Log -Level 'Error'` with `key=value` format (`zvm=$Server error=$($_.Exception.Message)`), call `Write-Error`, and `continue` to next ZVM. Confirm this is already present from T018–T019; add any missing guard for `Connect-ZertoZVM` failure specifically.

- [x] T026 [US3] Validate `zvmservers.txt` loading logic and missing-file handling in `src/Controllers/Set-JournalAndScratch.ps1`  
  Confirm that when `zvmservers.txt` is absent and `-ZVMHost` is not provided, `Write-Log -Level 'Warn'` is emitted and the script terminates gracefully (or falls back, per the existing reference controller). Ensure blank lines in the file are filtered out.

- [x] T027 [US3] Write integration tests for multi-ZVM failure tolerance in `src/Controllers/Tests/Integration/Set-JournalAndScratch.Tests.ps1`  
  Mock `Connect-ZertoZVM` to throw on the second ZVM. Assert first and third ZVMs are processed, second ZVM's error is logged, `$Results` only contains entries from reachable ZVMs, final reporting still runs.

- [x] T028 [US3] Write integration test for the circuit-breaker in `src/Controllers/Tests/Integration/Set-JournalAndScratch.Tests.ps1`  
  Mock `Invoke-JournalScratchUpdate` to throw for 3 consecutive VPGs. Assert that processing of the current ZVM stops after the 3rd failure, the circuit-breaker is logged, and the next ZVM (if any) is still attempted.

**Checkpoint**: All 3 user stories fully functional. Fleet-scale multi-ZVM execution with partial failure tolerance confirmed.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, linter compliance, and documentation.

- [x] T029 [P] Run PSScriptAnalyzer against `src/Controllers/Set-JournalAndScratch.ps1` and fix all errors/warnings
- [x] T030 [P] Run PSScriptAnalyzer against all 6 new files in `src/Modules/ZertoZVM.Core/Public/` and fix all errors/warnings
- [ ] T031 Run all Pester unit tests under `src/Modules/ZertoZVM.Core/tests/` and confirm 100% pass rate
- [ ] T032 Run all integration tests under `src/Controllers/Tests/` and confirm 100% pass rate
- [x] T033 [P] Add `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, and `.EXAMPLE` comment-based help to the controller in `src/Controllers/Set-JournalAndScratch.ps1`
- [x] T034 [P] Add comment-based help to all 6 new public module functions in `src/Modules/ZertoZVM.Core/Public/`
- [x] T035 Verify Doctor output format matches contract: headerless, no quotes, comma-delimited, correct column order (`ZVMHost, VpgName, JournalSizeGB, ScratchSizeGB, vpgs_processed, vpgs_updated, vpgs_failed`) in `src/Controllers/Set-JournalAndScratch.ps1`
- [x] T036 Verify telemetry payload: assert all 9 KPIs (4 mandatory baselines + 5 feature KPIs) are present in a test run via `Submit-ProjectTelemetry` mock in `src/Controllers/Tests/Integration/Set-JournalAndScratch.Tests.ps1`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — **BLOCKS all user stories**
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion
- **User Story 2 (Phase 4)**: Depends on Phase 2 completion; integrates naturally with US1 (restore requires an apply backup)
- **User Story 3 (Phase 5)**: Depends on Phase 2 completion; validates US1 and US2 at scale
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational (Phase 2). No dependency on US2/US3.
- **US2 (P2)**: Can start after Foundational (Phase 2). Logically depends on US1 having been run first (needs a backup to restore), but the code path is independent.
- **US3 (P3)**: Can start after Foundational (Phase 2). Validates US1/US2 behavior in multi-ZVM context.

### Within Each User Story

- Module functions (Phase 2) before controller sections
- Backup guard before state capture (T018 before T019)
- State capture before backup write (T018 before T019)
- Backup write before VPG updates (T019 ordering)
- Apply loop before output distribution (T019 before T020)
- Restore loop before backup completion (T023 ordering)

### Parallel Opportunities

| Group | Parallel Tasks |
|-------|---------------|
| Module functions | T004, T005, T006, T007, T008, T009 (all different files) |
| Unit tests | T011, T012, T013, T014, T015, T016 (all different files) |
| Integration test scenarios | T027, T028 (different `Describe` blocks in same file — sequential writes) |
| Polish | T029, T030, T033, T034 (different files) |

---

## Parallel Example: Phase 2 (Foundational)

```text
# All 6 module function implementations can run in parallel (different files):
T004: Get-VpgJournalScratchState.ps1
T005: Test-JournalScratchBackupExists.ps1
T006: New-JournalScratchBackup.ps1
T007: Invoke-JournalScratchUpdate.ps1
T008: Invoke-JournalScratchRestore.ps1
T009: Complete-JournalScratchBackup.ps1

# All 6 unit test files can run in parallel after their respective implementations:
T011, T012, T013, T014, T015, T016
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (⚠️ blocks all stories)
3. Complete Phase 3: User Story 1 — Apply flow
4. **STOP and VALIDATE**: Run against test ZVM, confirm backup created and VPGs updated
5. Deliver MVP — the script is useful and safe from here

### Incremental Delivery

1. Setup + Foundational → 6 module functions ready ✅
2. User Story 1 → Apply flow working → MVP delivered ✅
3. User Story 2 → Restore flow working → full apply/restore lifecycle ✅
4. User Story 3 → Multi-ZVM hardening confirmed ✅
5. Polish → PSScriptAnalyzer clean, 100% test pass ✅

### Single-Developer Sequence

```
T001 → T002 → T003
→ T004–T009 (can parallelize) → T010
→ T011–T016 (can parallelize)
→ T017 → T018 → T019 → T020 → T021
→ T022 → T023 → T024
→ T025 → T026 → T027 → T028
→ T029–T036 (can parallelize where marked)
```

---

## Notes

- **[P]** tasks operate on different files and have no incomplete dependencies — safe to parallelize
- **[US#]** label maps each task to its spec user story for traceability
- No test-first (TDD) approach was specified; tests are included for correctness validation, not as pre-implementation gates
- The consecutive-failure circuit-breaker counter lives in the controller loop (within 10% logic density allowance per research.md decision §3)
- GB→MB conversion (`× 1024`) always happens inside `Invoke-JournalScratchUpdate` and `Invoke-JournalScratchRestore` — never in the controller
- Backup file naming: `{yyyyMMdd-HHmmss}.json`; processed state: `{yyyyMMdd-HHmmss}_processed.json`
- Commit after each task or logical group; stop at any checkpoint to validate independently
