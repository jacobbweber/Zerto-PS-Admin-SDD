# Implementation Tasks: ZertoZVM.Core

**Feature**: `002-zvm-core`
**Context**: Extracted from Implementation Plan and Feature Spec to satisfy Constitution 1.1.0 parameters.

## Phase 1: Setup
- [x] T001 Initialize module scaffold in `src/Modules/ZertoZVM.Core` (psm1, psd1, tree structure).

## Phase 2: Foundational
Blocking prerequisites for the main utilities.
- [x] T002 Implement `src/Modules/ZertoZVM.Core/private/Invoke-ThreadSafeFileWrite.ps1`.
- [x] T003 Implement basic framework for `src/Modules/ZertoZVM.Core/tests/Unit/ZertoZVM.Core.Tests.ps1`.

## Phase 3: User Story 1 - Environment Bootstrapping
- [x] T004 [US1] Implement `src/Modules/ZertoZVM.Core/public/Initialize-ProjectConfig.ps1`.
- [x] T005 [US1] Implement `src/Modules/ZertoZVM.Core/public/Test-ProjectConfig.ps1`.
- [x] T006 [US1] Add configuration unit tests to `ZertoZVM.Core.Tests.ps1`.

## Phase 4: User Story 2 - Dual-Stream Logging
- [ ] T007 [US2] Implement `src/Modules/ZertoZVM.Core/public/Write-Log.ps1` calling the parallel-safe private IO handler.
- [ ] T008 [US2] Add dual-stream logging tests to `ZertoZVM.Core.Tests.ps1` and finalize module loading scripts.

## Dependencies Context
- Foundational file writing (T002) blocks `Write-Log` (T007).
- Configuration loading (T004) functions independently but must be parsed strictly by (T005).
