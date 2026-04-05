---
description: "Task list template for feature implementation"
---

# Tasks: Global Environment Configuration

**Input**: Design documents from `/specs/003-project-config/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are MANDATORY per the project Constitution (Library functions require Pester 5 test files).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Exact file paths are included in the descriptions.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure.

- [x] T001 Initialize baseline configuration template in `config.json` at root directory according to `contracts/config.json`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.

- None. The feature logic relies purely on native PowerShell JSON serialization.  

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Configure Runtime Environment (Priority: P1) 🎯 MVP

**Goal**: Load the centralized `config.json` file to bootstrap the execution environment and supply absolute paths, caching into a global `$Config` object.

**Independent Test**: Provide a mock JSON payload, execute `Initialize-ProjectConfig`, and validate the `$Config` object matches the expected schema exactly.

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T002 [P] [US1] Unit test for loading configuration in `src/Modules/ZertoZVM.Core/tests/Unit/Initialize-ProjectConfig.Tests.ps1`

### Implementation for User Story 1

- [ ] T003 [US1] Implement `Initialize-ProjectConfig` function in `src/Modules/ZertoZVM.Core/Public/Initialize-ProjectConfig.ps1` (depends on T002)

**Checkpoint**: At this point, User Story 1 (the foundational configuration parser) should be fully functional and passing all unit tests independently.

---

## Phase 4: User Story 2 - Pre-Flight Configuration Validation (Priority: P1)

**Goal**: Dynamically validate that runtime directories explicitly specified in `$Config.base.logging.paths` physically exist.

**Independent Test**: Generate a mocked `$Config` object in-memory with valid and invalid paths. Call `Test-ProjectConfig` and assert that it correctly handles success or exception throwing based on parameter input.

### Tests for User Story 2 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T004 [P] [US2] Unit test for pre-flight checklist validation in `src/Modules/ZertoZVM.Core/tests/Unit/Test-ProjectConfig.Tests.ps1`

### Implementation for User Story 2

- [ ] T005 [US2] Implement `Test-ProjectConfig` function in `src/Modules/ZertoZVM.Core/Public/Test-ProjectConfig.ps1` (depends on T004)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work interchangeably passing unit tests.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories.

- [ ] T006 [P] Update module manifest `src/Modules/ZertoZVM.Core/ZertoZVM.Core.psd1` (if necessary depending on export mechanisms) to export `Initialize-ProjectConfig` and `Test-ProjectConfig`.
- [ ] T007 Run quickstart.md validation locally to ensure smooth bootstrap of functions.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately.
- **User Stories (Phase 3+)**: US1 provides the schema mechanism, US2 consumes it.
- **Polish (Final Phase)**: Depends on all user stories completion.

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories but blocks US2 functionality in reality.
- **User Story 2 (P1)**: Architecturally depends on `$Config` object loaded from US1. 

### Within Each User Story

- Pester tests MUST be written and FAIL before implementation
- Tests → Implementation 

### Parallel Opportunities

- Tests (T002, T004) can be scaffolded in parallel.
- `config.json` instantiation can happen at any time.

---

## Parallel Example: Scaffolding Phase

```bash
# Developer A focuses on configuring the foundational JSON:
Task: "Initialize baseline configuration template in config.json"

# Developer B scaffolds the unit tests across both libraries:
Task: "Unit test for loading configuration in Initialize-ProjectConfig.Tests.ps1"
Task: "Unit test for pre-flight checklist in Test-ProjectConfig.Tests.ps1"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 3: User Story 1
3. **STOP and VALIDATE**: Verify Zerto modules can securely open `config.json`.

### Incremental Delivery

1. Integrate User Story 1 (Bootstrapping loader functions).
2. Integrate User Story 2 (Validating filesystem dependency existence).

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
