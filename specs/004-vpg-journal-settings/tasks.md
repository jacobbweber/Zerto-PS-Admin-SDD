# Tasks: Get VPG Journal Settings

**Input**: Design documents from `specs/004-vpg-journal-settings/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Note**: Tasks are grouped by user story to enable independent implementation and testing of each story. Integration tests are included to validate the Controller orchestration.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Controller script initialization and basic structure.

- [x] T001 Create controller script skeleton in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T002 Implement `Begin` block with module imports and config loading in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T003 [P] Initialize telemetry session in `Begin` block using `New-ProjectTelemetry` in `src/Controllers/Get-VPGJournalSettings.ps1`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core ZVM discovery logic that blocks all user stories.

- [x] T004 Implement `E:\source\zvmservers.txt` loader with `Test-Path` safety in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T005 [P] Create integration test scaffold in `src/Controllers/Tests/Integration/Get-VPGJournalSettings.Tests.ps1`
- [x] T006 [P] Define shared mocks for `Get-ZertoVPG` and `Connect-ZertoZVM` in `src/Controllers/Tests/Shared/mocks.ps1`

**Checkpoint**: Foundation ready - ZVM list loading and mocking infrastructure complete.

---

## Phase 3: User Story 1 - Multi-ZVM Journal Audit (Priority: P1) 🎯 MVP

**Goal**: Automatically audit all ZVMs from the server list and aggregate VPG data.

**Independent Test**: Running script with no arguments; verify it iterates through multiple ZVMs and populates `$Results`.

### Implementation for User Story 1

- [ ] T007 [US1] Implement ZVM iteration loop in `Process` block in `src/Controllers/Get-VPGJournalSettings.ps1`
- [ ] T008 [US1] Implement `Get-ZertoVPG` calls and object mapping to `$Results` (VPGName, VpgIdentifier, ProtectedSiteName, ZVMHost, Status) in `src/Controllers/Get-VPGJournalSettings.ps1`
- [ ] T009 [US1] Add basic error handling for unreachable ZVMs in `src/Controllers/Get-VPGJournalSettings.ps1`
- [ ] T010 [P] [US1] Create integration test for multi-ZVM iteration in `src/Controllers/Tests/Integration/Get-VPGJournalSettings.Tests.ps1`

**Checkpoint**: User Story 1 is functional. The script can audit the entire environment.

---

## Phase 4: User Story 2 - Targeted VPG Search (Priority: P2)

**Goal**: Find a specific VPG across all ZVMs and stop once found.

**Independent Test**: Providing `-VpgName`; verify script stops searching after finding the match.

### Implementation for User Story 2

- [x] T011 [US1] Implement `-VpgName` parameter and filtering logic in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T012 [US2] Implement "found" exit logic to terminate ZVM iteration early if VPG is matched in `src/Controllers/Get-VPGJournalSettings.ps1`
- [/] T013 [P] [US2] Create integration test for targeted VPG search in `src/Controllers/Tests/Integration/Get-VPGJournalSettings.Tests.ps1`

**Checkpoint**: User Story 2 is functional. Targeted searching is optimized.

---

## Phase 5: User Story 3 - Flexible Output Reporting (Priority: P3)

**Goal**: Support Email, CSV, Telemetry, and Doctor output formats.

**Independent Test**: Using `-CSV`, `-Email`, `-Telemetry`, or `-Doctor` flags and verifying the respective artifacts/stdout.

### Implementation for User Story 3

- [x] T014 [US3] Implement CSV export logic in `End` block in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T015 [US3] Implement HTML Email generation via `Set-FormattedEmail` and `Send-FormattedEmail` in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T016 [US3] Implement Telemetry KPI submission (`vpg_count`) via `Submit-ProjectTelemetry` in `src/Controllers/Get-VPGJournalSettings.ps1`
- [x] T017 [US3] Implement "Doctor" mode (headerless CSV to console) in `src/Controllers/Get-VPGJournalSettings.ps1`
- [/] T018 [P] [US3] Create integration tests for all output modes in `src/Controllers/Tests/Integration/Get-VPGJournalSettings.Tests.ps1`

**Checkpoint**: All output modes are functional and verified.

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T019 [P] Perform final linting check using `Invoke-ScriptAnalyzer`
- [ ] T020 Run `quickstart.md` validation to ensure all examples work as documented
- [ ] T021 [P] Cleanup temporary test artifacts in `src/Controllers/Tests/Shared/mocks/`

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Setup (Phase 1)**: Prerequisites for any code.
2. **Foundational (Phase 2)**: Blocks all US implementation.
3. **User Stories (Phase 3-5)**: Targeted implementation of specific features.

### Parallel Opportunities

- T003, T005, T006 can be worked on in parallel during Setup/Foundation.
- Integration tests (T010, T013, T018) can be developed in parallel with their respective features.

---

## Implementation Strategy: MVP First

1. Complete **Setup** and **Foundational** (T001-T006).
2. Implement **User Story 1** (T007-T010) to deliver the Environmental Audit capability.
3. **Validate**: Verify report generation for multiple ZVMs.
4. Scale to US2 and US3.
