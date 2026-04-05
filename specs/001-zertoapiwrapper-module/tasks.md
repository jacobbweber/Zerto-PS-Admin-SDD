# Implementation Tasks: ZertoZVM.APIWrapper Module

## Implementation Strategy

**MVP Scope**: User Story 1 (Connect + Read). This validates the foundational architecture: initializing the `ZertoSession` object, configuring the `Invoke-ZertoRequest` routing, HTTP mocking tests, and establishing basic `Invoke-RestMethod` delegation.

**Incremental Delivery**:
1. Implement State and Proxy Foundation (unblocks everything).
2. Deliver US1 (Connect + simple Get).
3. Deliver US2 (Silent refresh / Assert logic).
4. Deliver US3 (Write / WhatIf logic).
5. Deliver US4 (Disconnect cleanup).

---

## Phase 1: Setup

- [x] T001 Initialize Pester 5 test scaffolding and mock folder structure in `tests/Unit/` and `tests/Mocks/`
- [x] T002 Generate mock JSON payload fixtures for testing in `tests/Mocks/ZertoZVM.APIWrapper.Mocks.json`

## Phase 2: Foundational

**Goal**: Provide the core transport layer and session footprint.

- [x] T003 Initialize `$script:ZertoSession` module variable inside `src/Modules/InfraCore.ZertoZVM/InfraCore.ZertoZVM.psm1`
- [x] T004 Build `Invoke-ZertoRequest` proxy function resolving method, URI, and HTTP exceptions with `Write-Verbose` telemetry in `src/Modules/InfraCore.ZertoZVM/Private/Invoke-ZertoRequest.ps1`
- [x] T005 [P] Create unit test for `Invoke-ZertoRequest` exception throwing/Verbose logging in `tests/Unit/Invoke-ZertoRequest.Tests.ps1`

## Phase 3: [US1] Connect and Execute a Read Operation

**Goal**: Establish session and fetch read-only data (VPG list).
**Test Criteria**: Connect sets module vars. Get-ZertoVPG returns parsed JSON with typed `PSCustomObject`.

- [x] T006 [US1] Build `Connect-ZertoZVM` supporting parameters and `CachedCredential` storage in `src/Modules/InfraCore.ZertoZVM/Public/Connect-ZertoZVM.ps1`
- [x] T007 [P] [US1] Create Pester test file for session instantiation logic in `tests/Unit/Connect-ZertoZVM.Tests.ps1`
- [x] T008 [US1] Build `Get-ZertoVPG` utilizing the proxy contract securely in `src/Modules/InfraCore.ZertoZVM/Public/Get-ZertoVPG.ps1`
- [x] T009 [P] [US1] Create Pester test for fetching collections logically in `tests/Unit/Get-ZertoVPG.Tests.ps1`

## Phase 4: [US2] Session Auto-Refresh on Token Expiry

**Goal**: `Assert-ZertoSession` transparently handles 5-minute TTL recycling.
**Test Criteria**: When `TokenTimestamp` is stale, `Assert-ZertoSession` triggers backend silent re-authentication.

- [x] T010 [US2] Build `Assert-ZertoSession` resolving TTL durations and triggering silent re-connects natively in `src/Modules/InfraCore.ZertoZVM/Private/Assert-ZertoSession.ps1`
- [x] T011 [US2] Update `Get-ZertoVPG` natively to invoke `Assert-ZertoSession` as its first operational instruction 
- [x] T012 [P] [US2] Create Pester test suite isolating timestamp expiration checks logically in `tests/Unit/Assert-ZertoSession.Tests.ps1`

## Phase 5: [US3] Execute a Write / Action Operation Safely

**Goal**: Deliver a mutative endpoint mapping correctly issuing strict `ShouldProcess` protocols.
**Test Criteria**: Running with `-WhatIf` bypasses HTTP webhooks safely. Standard operations extract and return precisely the `TaskId` asynchronously.

- [x] T013 [US3] Build `Start-ZertoFailover` applying `[CmdletBinding(SupportsShouldProcess)]` structures exclusively mapping async paths internally inside `src/Modules/InfraCore.ZertoZVM/Public/Start-ZertoFailover.ps1`
- [x] T014 [P] [US3] Create Pester test rigorously ensuring `-WhatIf` compliance skips destructive POST actions in `tests/Unit/Start-ZertoFailover.Tests.ps1`

## Phase 6: [US4] Disconnect and Clean Session State

**Goal**: Secure teardown mechanics purging global credentials.
**Test Criteria**: `$script:ZertoSession` nullifies memory payload including its native `.CachedCredential` permanently.

- [x] T015 [US4] Build `Disconnect-ZertoZVM` to scrub module variables locally and cleanly DELETE tokens server-side in `src/Modules/InfraCore.ZertoZVM/Public/Disconnect-ZertoZVM.ps1`
- [x] T016 [P] [US4] Create Unit test suite rigorously confirming `CachedCredential` memory lifetime destruction in `tests/Unit/Disconnect-ZertoZVM.Tests.ps1`

## Phase 7: Polish & Integration Testing

- [x] T017 Build integration test suite confirming true API validation mapping locally within `tests/Integration/ZertoZVM.APIWrapper.Integration.Tests.ps1`
- [x] T018 Run `Invoke-ScriptAnalyzer` via configured standard settings forcing zero defects strictly within module spaces natively via PowerShell standards.

---

## Dependencies

- Phase 2 (Foundational T003, T004) completely blocks Phase 3+. 
- Phase 4 ([US2] Refresh Logic natively) relies effectively upon the credential properties secured originally natively inside Phase 3 ([US1] Connection Phase).
- Phase 6 ([US4] Cleanup Logic) relies on the generated active connections originating strictly inside Phase 3. 

**Parallel Execution Examples**:
- Pester scripts directly linked uniquely tracking corresponding core libraries natively inside parallel testing cycles unconditionally (T005, T007, T009, T012, T014, T016). Validated directly as `Invoke-RestMethod` is actively mocked explicitly omitting HTTP blocking sequences asynchronously tracking natively.
