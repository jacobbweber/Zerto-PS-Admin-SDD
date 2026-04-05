# Feature Specification: ZertoZVM.APIWrapper Module

**Feature Branch**: `001-zertoapiwrapper-module`
**Created**: 2026-04-05
**Status**: Draft
**Input**: User description: "ZertoZVM.APIWrapper PowerShell module — session-based REST API wrapper for the Zerto ZVM API"

## Overview

**Purpose**: Provide a 1:1 functional mapping of the Zerto ZVM REST API to PowerShell cmdlets.

**Constitutional Role**: This is a **Pure API Wrapper**. It MUST contain zero business logic,
zero data transformation (beyond JSON-to-PSCustomObject deserialization), and no orchestration.
All exported cmdlets delegate 100% of their work to the internal `Invoke-ZertoRequest` proxy.

---

## Clarifications

### Session 2026-04-05

- Q: What observability contract (logging/verbose) applies at the wrapper layer? → A: `Write-Verbose` only for HTTP call tracing; `ShouldProcess`/`-WhatIf` for all mutation gates; all terminating errors MUST throw the exception with full method, URI, and status detail — no swallowing, no `Write-Log` dependency in the wrapper.
- Q: Which action cmdlets are required to return a `TaskId`? → A: Only long-running async operations (e.g. `Start-ZertoFailover`, `Start-ZertoMove`) return a `TaskId`. Synchronous/administrative operations (e.g. `Invoke-ZertoDismissEvent`) return the raw API response object, or nothing if the API returns 204/empty.
- Q: What happens if two threads call an API cmdlet simultaneously during token refresh? → A: No concurrency lock is applied — last-writer-wins. Both threads may independently refresh; whichever writes last produces a valid token. This is a documented v1 limitation; callers requiring strict serialization must manage it externally.
- Q: What is the lifetime of `CachedCredential` in module-scoped memory? → A: `CachedCredential` persists for the PowerShell process lifetime. It is ONLY cleared by an explicit `Disconnect-ZertoZVM` call. Cleanup is the caller's responsibility; no automatic TTL or idle-timeout is applied.
- Q: Is there a measurable HTTP call latency target for write/action operations? → A: Yes — same as reads. All HTTP calls (read or write) MUST complete within 3 seconds on a local network. Async job duration after the `TaskId` is returned is environment-dependent and explicitly out of scope.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Connect and Execute a Read Operation (Priority: P1)

An infrastructure automation engineer needs to authenticate against a Zerto ZVM appliance and
immediately retrieve the current list of Virtual Protection Groups (VPGs) from the API in a
single-session workflow.

**Why this priority**: Connection + read is the minimum viable interaction pattern. Every other
story builds on an authenticated session. This story validates the core auth-and-call pipeline.

**Independent Test**: Engineer calls `Connect-ZertoZVM` then `Get-ZertoVPG`. The call succeeds
without error and returns a typed PSCustomObject collection. No live network is required if
`Invoke-RestMethod` is mocked to return valid JSON.

**Acceptance Scenarios**:

1. **Given** a valid ZVM hostname and credential, **When** `Connect-ZertoZVM` is called,
   **Then** `$script:ZertoSession.Connected` is `$true`, `BaseUri` is populated, `Headers`
   contains `x-zerto-session`, and `TokenTimestamp` is set to the current UTC time.

2. **Given** a connected session, **When** `Get-ZertoVPG` is called without parameters,
   **Then** all VPGs are returned as an array of `PSCustomObject`.

3. **Given** a connected session, **When** `Get-ZertoVPG -VpgIdentifier 'abc-123'` is called,
   **Then** the single matching VPG object is returned.

4. **Given** a connected session, **When** `Get-ZertoVPG -Name 'ProdVPG' -Status 'MeetingSLA'`
   is called, **Then** the request URL contains `name=ProdVPG&status=MeetingSLA` as query
   parameters.

5. **Given** no prior `Connect-ZertoZVM` call, **When** any `Get-Zerto*` cmdlet is invoked,
   **Then** an `InvalidOperationException` is thrown with a message directing the user to call
   `Connect-ZertoZVM` first.

---

### User Story 2 — Session Auto-Refresh on Token Expiry (Priority: P2)

An automation script runs a long-duration workflow. After the session token age exceeds 5 minutes,
the next API call must silently re-authenticate using the cached credential without requiring
user intervention or script restarts.

**Why this priority**: Production automation scripts run unattended. Silent re-auth prevents
runtime failures mid-script due to expired tokens. This directly impacts script reliability.

**Independent Test**: Connect, then artificially set `$script:ZertoSession.TokenTimestamp` to
6 minutes in the past. Call any `Get-Zerto*` cmdlet. Verify that `Connect-ZertoZVM` is called
once internally and the cmdlet completes successfully without the caller seeing any error.

**Acceptance Scenarios**:

1. **Given** a connected session where `TokenTimestamp` is > 5 minutes old,
   **When** `Assert-ZertoSession` is called (directly or via any public cmdlet),
   **Then** `Connect-ZertoZVM` is invoked with `CachedCredential` and the session is refreshed
   transparently.

2. **Given** a connected session where `TokenTimestamp` is < 5 minutes old,
   **When** any public cmdlet is called,
   **Then** no re-authentication occurs and the existing token is used.

3. **Given** a session with a stale token and an invalid cached credential,
   **When** auto-refresh is attempted,
   **Then** the failure is surfaced as a clear, actionable error (not swallowed silently).

---

### User Story 3 — Execute a Write / Action Operation Safely (Priority: P3)

An engineer triggers a live Zerto failover for a specific VPG from an automation script. The
operation must be gated by PowerShell's `-WhatIf` / `-Confirm` safety mechanisms and must
return a trackable Task ID for polling.

**Why this priority**: Write operations carry production risk. Correct `ShouldProcess` behavior
is a non-negotiable constitution requirement and directly impacts operational safety.

**Independent Test**: Call `Start-ZertoFailover -VpgIdentifier 'abc-123' -WhatIf`. Verify that
no HTTP POST is made and a "WhatIf" message is emitted. Call without `-WhatIf` and verify the
returned object contains a `TaskId` property.

**Acceptance Scenarios**:

1. **Given** a connected session, **When** `Start-ZertoFailover -VpgIdentifier 'abc'` is called,
   **Then** a POST request is sent to the failover endpoint and the returned object includes a
   `TaskId` for async polling.

2. **Given** a connected session, **When** `Start-ZertoFailover -WhatIf` is called,
   **Then** no HTTP call is made and the console displays what would have been done.

3. **Given** the failover API returns a non-success HTTP status,
   **When** the request is made,
   **Then** an exception is thrown containing the HTTP method, full URI, and status code.

---

### User Story 4 — Disconnect and Clean Session State (Priority: P4)

An automation script terminates cleanly by explicitly invalidating the ZVM session token
server-side and clearing all local state, ensuring no credential or token persists in memory
after the script completes.

**Why this priority**: Security hygiene. Credentials cached in module scope must be explicitly
cleared on disconnect to avoid credential leakage between script runs.

**Acceptance Scenarios**:

1. **Given** an active session, **When** `Disconnect-ZertoZVM` is called,
   **Then** a DELETE request is sent to invalidate the server token, and all `$script:ZertoSession`
   properties are reset to their null/default state (including `CachedCredential`).

2. **Given** no active session, **When** `Disconnect-ZertoZVM` is called,
   **Then** a warning is emitted and the function exits gracefully without error.

3. **Given** the DELETE token endpoint returns an error,
   **When** `Disconnect-ZertoZVM` is called,
   **Then** local session state is still cleared (via `finally` block) and the error is written
   as a warning, not a terminating exception.

---

### Edge Cases

- What happens when `Connect-ZertoZVM` is called with an invalid host / unreachable ZVM?
  → Terminating exception thrown; `$script:ZertoSession.Connected` remains `$false`.
- What happens when a query parameter value is `$null`?
  → Null values are excluded from the query string (not serialized as empty strings).
- What happens when a body serializes to `null` or `{}`?
  → Empty body is not attached to the request; only populated bodies are included.
- What happens when `SkipCertificateCheck` is required but not passed on re-auth?
  → `CachedCredential` re-auth must preserve the `SkipCertificateCheck` flag from the original
  session state.
- What happens when more than one session is needed simultaneously?
  → Out of scope for v1. Module is single-session by design.
- What happens if two threads call an API cmdlet simultaneously during token refresh?
  → No concurrency lock is used. Both threads may attempt refresh independently (last-writer-wins).
  Both refreshes produce a valid token. This is a known v1 limitation; callers requiring strict
  call serialization must manage it at the controller layer.
- What happens if a script ends without calling `Disconnect-ZertoZVM`?
  → `CachedCredential` and the session token remain in module-scoped memory for the remainder
  of the PowerShell process lifetime. No automatic cleanup occurs. This is the caller's
  responsibility per the constitution's End Block pattern.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The module MUST expose `Connect-ZertoZVM` to establish an authenticated session
  against a ZVM given a hostname, optional port (default 9669), API version (default v1),
  credential, and TLS options.
- **FR-002**: The module MUST maintain a script-scoped session object with `BaseUri`, `Headers`,
  `TokenTimestamp`, `Connected`, and `CachedCredential` properties.
- **FR-003**: Every exported cmdlet MUST call `Assert-ZertoSession` as its first instruction
  before performing any other work.
- **FR-004**: `Assert-ZertoSession` MUST check token age and auto-refresh using `CachedCredential`
  when the token is ≥ 5 minutes old.
- **FR-005**: The module MUST expose `Disconnect-ZertoZVM` to server-side invalidate the token
  and clear all local session state, including `CachedCredential`.
- **FR-006**: All HTTP communication MUST be routed exclusively through `Invoke-ZertoRequest`.
  No public cmdlet may call `Invoke-RestMethod` directly.
- **FR-007**: `Invoke-ZertoRequest` MUST construct URIs using `[System.UriBuilder]` and encode
  query parameters using `[System.Web.HttpUtility]::ParseQueryString`.
- **FR-008**: `Invoke-ZertoRequest` MUST catch HTTP errors and MUST always re-throw a terminating
  exception containing the HTTP method, full URI, and HTTP status code. Errors MUST NOT be
  swallowed, downgraded to warnings, or redirected to `Write-Log`. The wrapper has no logging
  dependency.
- **FR-009**: All `Get-Zerto*` cmdlets MUST return `[PSCustomObject]` (or `[PSCustomObject[]]`).
- **FR-010**: Action cmdlets that trigger long-running async ZVM operations (`Start-ZertoFailover`,
  `Start-ZertoMove`, and equivalents) MUST return a `PSCustomObject` containing a `TaskId`
  property for async polling. Synchronous/administrative action cmdlets MUST return the raw API
  response object as-is, or `$null` if the API returns HTTP 204 (No Content).
- **FR-011**: All write-operation cmdlets MUST implement `[CmdletBinding(SupportsShouldProcess)]`
  and gate mutating HTTP calls inside `$PSCmdlet.ShouldProcess()`.
- **FR-012**: The module MUST contain unit tests in `tests\Unit\` using Pester 5, mocking
  `Invoke-RestMethod` against fixtures stored in `tests\Mocks\`. No test may contact a live network.
- **FR-013**: The module MUST contain integration tests in `tests\Integration\` that validate
  session lifecycle: connect populates state, token refresh triggers on stale timestamp, and
  disconnect clears all state.
- **FR-014**: All functions MUST include Comment-Based Help and `[CmdletBinding()]`.
- **FR-015**: The module `.psm1` MUST include `Set-StrictMode -Version Latest` and
  `$ErrorActionPreference = 'Stop'`.
- **FR-016**: All functions MUST use explicit strong typing on all parameters and return types.
- **FR-017**: Function naming MUST follow `Verb-ZertoNoun` (Approved Verbs only, PascalCase,
  singular noun).
- **FR-018**: No function definition MUST use backticks for line continuation.
- **FR-019**: Any call with ≥ 4 parameters MUST use splatting.
- **FR-020**: The wrapper layer MUST use ONLY `Write-Verbose` for observability output (format:
  `"[METHOD] [FullURI]"`). It MUST NOT call `Write-Log`, `Write-Warning`, or `Write-Information`.
  The only non-verbose output permitted is a terminating `throw` on error.
- **FR-021**: `CachedCredential` MUST persist for the PowerShell process lifetime once set by
  `Connect-ZertoZVM`. It MUST NOT be auto-cleared by any TTL or idle timer. The ONLY mechanism
  that clears `CachedCredential` is an explicit `Disconnect-ZertoZVM` call.

### Key Entities

- **ZertoSession**: Module-scoped state object. Properties: `BaseUri [string]`,
  `ApiVersion [string]`, `Headers [hashtable]`, `TokenTimestamp [DateTime]`,
  `Connected [bool]`, `SkipCertificateCheck [bool]`, `CachedCredential [PSCredential]`.
- **VPG (Virtual Protection Group)**: Primary replication unit. Identified by `VpgIdentifier`.
  Core API resource for read, write, and action operations.
- **Task**: Returned exclusively by long-running async ZVM operations. Identified by `TaskId`.
  Used by callers to poll job completion status via `Get-ZertoTask`. Synchronous operations
  do NOT produce a Task entity — they return the raw API response or nothing.
- **Alert**: Zerto system notification. Filterable by level (`Warning`, `Error`).
- **VRA (Virtual Replication Appliance)**: Hypervisor-level replication agent. Lifecycle managed
  via install, upgrade, and uninstall operations.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All HTTP calls — both read operations and write/action operations (including those
  that return a `TaskId`) — MUST complete within 3 seconds on a local network connection.
  The downstream async job duration after a `TaskId` is returned is environment-dependent and
  explicitly out of scope for this module.
- **SC-002**: 100% of public cmdlets succeed in their first call after a fresh `Connect-ZertoZVM`
  with valid credentials — zero "not connected" errors in a properly sequenced script.
- **SC-003**: Token auto-refresh is invisible to callers: scripts running longer than 5 minutes
  complete without any manual re-authentication or human intervention.
- **SC-004**: All write operations called with `-WhatIf` produce zero HTTP requests — 100%
  "WhatIf clean" across the entire module's action cmdlets.
- **SC-005**: 100% of cmdlets pass `Invoke-ScriptAnalyzer` using the project's settings file
  with zero warnings or errors.
- **SC-006**: Unit test suite achieves ≥ 90% code coverage across `Private/` and `Public/`
  functions, with all tests passing against mocked fixtures (no live network).
- **SC-007**: After `Disconnect-ZertoZVM`, all session state properties are verifiably reset —
  any subsequent cmdlet call throws `InvalidOperationException` without exception.

---

## Assumptions

- The primary consumers of this module are infrastructure automation engineers and
  controller scripts — not interactive end users. CLI ergonomics are secondary to
  correctness and testability.
- The Zerto ZVM API version is `v1`. The API version is configurable but `v1` is the default
  and the only version validated by integration tests in this feature.
- Token TTL for auto-refresh is fixed at 5 minutes. This value is not configurable in v1.
- The module is single-session by design. Multi-ZVM concurrent sessions are out of scope.
- TLS certificate validation may be skipped for lab and simulator environments via
  `-SkipCertificateCheck`. Production environments MUST use valid certificates.
- Mock JSON fixtures for unit tests are sourced from the existing Zerto API reference
  documentation — no live ZVM is required for unit test execution.
- The 219 existing `Public/` cmdlets in `InfraCore.ZertoZVM` represent the full target surface;
  the spec formalizes the contract they must all comply with, not just the exemplars reviewed.
- Concurrent token refresh by parallel runspaces is a known v1 limitation. The module applies no
  locking mechanism; last-writer-wins is the accepted behavior. True multi-runspace safety is
  deferred to a future version.
