## I. Philosophy & Strict PowerShell Standards

### I.1 Runtime Environment

- **Minimum version**: PowerShell 7.5+. All scripts MUST begin with `#Requires -Version 7.5`.
- **No Windows PowerShell**: PowerShell 5.x is explicitly unsupported.

Architecture & Encapsulation

The project architecture strictly separates internal logic from top-level orchestration.

- **Module Encapsulation Rule**: All local PowerShell modules residing in `.\src\Modules\[ModuleName]\` MUST be self-contained.
  - **Internal Structure**: Each module directory MUST strictly house its own `Public`, `Private`, `Tests` (Unit), and `Docs` folders.
  - **Constraint**: Do NOT place module-specific logic or unit tests outside of the specific module's root directory.
- **Controller Integration Standards**: Controller scripts (located in `.\src\Controllers\`) are responsible for cross-module orchestration and require dedicated Integration Tests to validate business logic "offline."
  - **Integration Test Path**: `.\src\Controllers\Tests\Integration\`
  - **Naming Convention**: Tests MUST follow the format `[ControllerName].Tests.ps1`.
  - **Mocking Strategy**: All shared mocks used to simulate "offline" behavior for ZertoZVM modules MUST be stored in `.\src\Controllers\Tests\Shared\mocks.ps1`.
- **Dependency Logic**: Modules perform **Units of Work** (Unit Tested internally). Controllers perform **Business Logic** (Integration Tested externally via Mocks).

- **`ZertoZVM.APIWrapper`**: Pure REST API calls (Method / URI / Body) for the Zerto API only.
  No business logic permitted.
- **`ZertoZVM.Core`**: Zerto-specific business logic, utility functions, and output formatters.
- **`InfraCode.Telemetry`**: Dynatrace session management and KPI submission.
- **`InfraCode.Snow`**: Pure REST API calls (Method / URI / Body) for ServiceNow (SNOW) only.
- **`InfraCode.Email`**: Functions for email composition and HTML formatting.
- **`InfraCode.HeadQuarters`**: Pure REST API calls (Method / URI / Body) for the
  Headquarters API only.
- **No In-Script Functions**: Controller scripts MUST NOT define internal helper functions.
- **10% Logic Limit**: Controller scripts MUST NOT exceed 10% unique logic density; all
  substantive logic belongs in a module.
- **Source of Truth**: The `.specify/` directory is the sole authority for standards and rules.
  The `.\docs\*` folder MUST be ignored by AI tooling unless explicitly directed to a specific
  file for a single, named task.
---

### II.1 Module Boundary Rules

**ZertoZVM.APIWrapper**:
- MUST only call `Invoke-ZertoRequest` (its own private proxy).
- MUST NOT contain conditional branching on business outcomes.
- MUST NOT call any other ZertoZVM module.
- Each function = one REST endpoint. Function name mirrors HTTP action + resource noun.

**ZertoZVM.Core**:
- MUST NOT make direct HTTP calls. All REST via `ZertoZVM.APIWrapper`.
- MUST own multi-step orchestration logic that requires combining multiple API calls.
- MUST own all formatter functions (e.g., CSV shaping, data normalization).

**ZertoZVM.Utilities**:
- MUST NOT contain business logic or Zerto domain knowledge.
- MUST own all file I/O for logging and bootstrapping.
- MUST own `Write-Log` (the consolidated logging function).
- MUST own `Resolve-ProjectCredentials` (AES + explicit credential resolution).
- MUST own `Initialize-ProjectLogDirectory`

**ZertoZVM.Telemetry**:
- MUST NOT read `$ProjectContext` directly; telemetry data is passed explicitly.
- MUST own `New-ProjectTelemetry`, `Complete-ProjectTelemetry`, `Submit-ProjectTelemetry`.
- MUST own KPI registration and submission to Dynatrace.

**ZertoZVM.Snow**:
- MUST only call ServiceNow REST APIs. No Zerto API calls.
- MUST be stateless — no session caching.

**ZertoZVM.Email**:
- MUST NOT query data sources. Receives pre-formed data, produces HTML, sends via SMTP.

---

# Contracts
Must adhere to **`contracts/controller-architecture.md`** for the full controller architecture.
Must adhere to **`contracts/auth-contract.md`** for the full authentication contract.
Must adhere to **`contracts/telemetry-contract.md`** for the full telemetry contract.
Must adhere to **`contracts/logging-contract.md`** for the logging contract.
Must adhere to **`contracts/doctor-contract.md`** for the doctor contract.

# Standards
All code must adhere to the standards defined in **`standards/global-standard.md`**.

---

## XIII. Governance

### XIII.1 Versioning Policy

| Change Type | Version Bump | Example |
|---|---|---|
| Non-negotiable rule added or removed | `MAJOR` | Removing `Write-Log` consolidation mandate |
| New module added to registry; new section | `MINOR` | Adding `ZertoZVM.Snow` to Module Registry |
| Clarification, wording fix, example added | `PATCH` | Fixing a code sample |

### XIII.2 Amendment Procedure

1. Propose change in a pull request targeting `main`.
2. Update `constitution.md` with new version and `Last Amended` date.
3. Propagate changes to affected Contracts and Standards documents.
4. All open spec/plan/task files MUST be reviewed for constitutional compliance.
5. Amendment is ratified upon PR merge with at least one approving review.

### XIII.3 Compliance Review

Every new controller PR MUST include a self-attestation checklist item confirming alignment with:
- [ ] Module boundary rules (Section II)
- [ ] `$ZertoContext` usage (Section IV)
- [ ] Granular error handling (Section IX)
- [ ] Doctor pattern implementation (Section XI)
- [ ] PSScriptAnalyzer zero-warning (Section I.6)
- [ ] Integration test present (Section XII)

---

*End of ZAF Constitution v1.0.0 — Ratified 2026-04-11*
