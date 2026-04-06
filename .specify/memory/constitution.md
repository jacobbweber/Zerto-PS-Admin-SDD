<!--
================================================================================
SYNC IMPACT REPORT
================================================================================
Version Change  : 1.2.0 → 1.3.0
Bump Rationale  : MINOR — Formalized Plan/Apply pattern, Simulation/WhatIf execution modes, and Quality Assurance standards.

Modified Principles (old → new)
  I. Modern, Strict PowerShell → I. Philosophy & Strict PowerShell
  IV. Thread-Safe Dual-Stream Logging → V. Thread-Safe Dual-Stream Logging
  V. The "Doctor" Diagnostic Pattern → VI. The "Doctor" Diagnostic Pattern
  VI. Predictable Execution → (Merged into IV. Execution & Simulation Modes)
  Lifecycle Execution → (Updated B. Process Block and C. End Block to Planner/Executor pattern)

Added Sections
  IV. Execution & Simulation Modes
  VII. Quality Assurance

Removed Sections
  VI. Predictable Execution (Merged)

Templates Requiring Updates
  ✅ .specify/memory/constitution.md            (this file)
  ✅ .specify/templates/plan-template.md        (no change required)
  ✅ .specify/templates/spec-template.md        (no change required)
  ✅ .specify/templates/tasks-template.md       (no change required)

Deferred TODOs
  - None
================================================================================
-->

# Infracode Zerto Management Constitution

## Core Principles

### I. Philosophy & Strict PowerShell

**State-Action Separation (Plan/Apply)**:
- **Mandatory for Action Scripts**: Any script that performs state-changing operations (e.g., `Set-`, `New-`, `Remove-`, `Sync-`) MUST utilize the Plan/Apply pattern. The `Process` block MUST strictly generate an **Action Manifest** (The Plan); the `End` block (or a final Apply loop) executes changes.
- **Optional for Reporting Scripts**: Scripts that are purely read-only (`Get-`, `Export-`) are encouraged, but not required, to separate data acquisition from analysis.

All code MUST adhere to the highest standards of the PowerShell 7.5+ ecosystem.

- **Environment**: Targets PowerShell 7.5+ exclusively. No downlevel compatibility shims.
- **Strictness**: Every script MUST open with `Set-StrictMode -Version Latest` and
  `$ErrorActionPreference = 'Stop'`.
- **Strong Typing**: All variables, parameters, and function return types MUST be explicitly
  typed (e.g., `[int]$Count`, `[psobject]$Data`). Implicit typing is prohibited.
- **Naming**:
  - Functions: `Verb-Noun` format using PowerShell Approved Verbs only; singular nouns.
  - Casing: `PascalCase` for all variables, parameters, and function names.
- **Formatting**:
  - Style: OTBS (One True Brace Style) — opening brace on the same line.
  - Splatting: Mandatory for any call with 4 or more parameters.
  - No Backticks: Line-continuation backticks are **strictly prohibited**; use splatting or
    pipeline-based alternatives.
- **Documentation**: Every function MUST include Comment-Based Help and `[CmdletBinding()]`.
- **Static Analysis**: All code MUST pass `Invoke-ScriptAnalyzer` using the project's
  `PSScriptAnalyzerSettings.psd1` with **zero warnings or errors**.
- **Testing**:
  - Unit Tests: Every module function MUST have a Pester 5 test file housed strictly within its module directory (`.\src\Modules\[ModuleName]\Tests\`).
  - Integration Tests: Controller scripts MUST have a Pester 5 test file in `.\src\Controllers\Tests\Integration\`. Tests MUST validate business outcomes via shared mocks (`.\src\Controllers\Tests\Shared\mocks.ps1`) to ensure zero impact on live systems.

### II. Architecture & Encapsulation

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

### III. The Global Configuration Contract

Scripts MUST rely on a standardized `config.json` loaded into a global `$Config` object.

The following schema keys are **mandatory** — any script that omits them is non-compliant:

- **Logging paths** (`$Config.base.logging.paths`):
  - Directories: `logdir`, `archive`, `state`, `telemetry`
  - Filenames: `syslog`, `devlog`, `telemetry`, `csv`
- **Telemetry** (`$Config.base.telemetry`): `hostname`, `username`, `business_unit`
- **Authentication** (`$Config.base.auth`): `vmware_user`, `vmware_password`
- **Reporting** (`$Config.base.email`): `smpt_server`

### IV. Execution & Simulation Modes

All scripts MUST implement safe-operation guards to prevent unintended state changes and facilitate logic testing.

- **Simulation Mode (`-Simulation`)**: Mandatory for all Controllers.
  - **Intent**: To test Business Logic and Report Generation "Offline."
  - **Behavior**: MUST bypass `Begin` block connections and load mock data from `.\src\Controllers\Tests\Shared\mocks\`.
  - **Artifacts**: MUST generate all standard artifacts (Logs, Excel, Telemetry) on the local filesystem to allow for visual and automated verification.
- **WhatIf Mode (`-WhatIf`)**:
  - **ShouldProcess**: All scripts MUST declare `[CmdletBinding(SupportsShouldProcess)]`.
  - **Intent**: Standard PowerShell Impact Analysis.
  - **Behavior**: Uses **Live Data** but suppresses changes via `ShouldProcess`. Every "Write" operation (any action that mutates state) MUST be wrapped in a `$PSCmdlet.ShouldProcess()` guard block.
  - **Constraint**: MUST follow "Pure PowerShell" intent—primarily providing console-based feedback of intended changes.

### V. Thread-Safe Dual-Stream Logging

`Write-Log` is ONLY to be utilized within Controller Scripts, and the `ZertoZVM.Core` PS Module. Other modules (e.g., wrappers) MUST utilize native streams (`Write-Verbose`, `Write-Warning`) to prevent cross-module dependencies. All compliant logging MUST be centralized via the `Write-Log` function from `ZertoZVM.Core`.

**Signature**:
```
Write-Log -Level <String> -Message <String> -LogPath <String>
          -SyslogFileName <String> -DevLogFileName <String>
```

**Behavior** (non-negotiable):
- `[scriptname]_developer.log`: MUST receive **Info, Warn, Error, Debug** levels.
- `[scriptname]_syslog.log`: MUST receive **Info, Warn, Error** levels only.
- **Splunk / Structured Events**: `Write-InfracodeLog` MUST be used for structured JSON events
  destined for Splunk ingestion.

### VI. The "Doctor" Diagnostic Pattern

Every controller MUST support a runtime diagnostic mode via a `$Doctor` switch parameter.

- **Signature**: `[Parameter()][bool]$Doctor`
- **Behavior**: When `$Doctor -eq $true`, the script MUST extract a defined subset of
  `$Results` and output it as **headerless CSV** to the console (stdout).
- The subset of fields included in Doctor output MUST be explicitly documented per controller.

### VII. Quality Assurance

- **Integration Tests**: Controller Integration Tests MUST call the controller using the `-Simulation` switch. Pester MUST assert that the **Action Manifest** generated by the simulation matches the expected business outcome, ensuring complete "offline" validation without network dependencies.

## Lifecycle Execution (The Data Pipeline)

Every controller script MUST follow the Begin / Process / End pipeline structure to ensure
baseline telemetry, logging, and safe execution.

### A. Begin Block — The Bootstrap

1. Import all modules from the `modules` directory.
2. Parse `config.json` into the global `$Config` object.
3. Initialize the results collection: `$Results = [System.Collections.Generic.List[PSObject]]::new()`.
4. If `$Doctor` is active: initialize `$DoctorReport = [ordered]@{}`.
5. Call `New-ProjectTelemetry` using `$Config.base.telemetry` values to open the telemetry session.

### B. Process Block — The Planner

1. All logic MUST be wrapped in a `Try / Catch` block.
2. This block performs data analysis and populates the **Action Manifest** (`$Results`). It MUST be "Pure Logic"—it should not care if the data came from a ZVM or a Mock JSON.
3. **Formatting is prohibited** in this block — no conversion to CSV, Table, or JSON.

### C. End Block — The Executor

1. In **Simulation Mode**: Skip state-changing calls; focus on outputting files/logs for verification.
2. In **Live Mode**: Iterate through the Action Manifest (`$Results`) and execute changes using `ShouldProcess` guards.
3. Finalize KPIs and add them to the telemetry collection.
4. Pass `$Results` to `Export-ProjectCSVReport` and `Set-FormattedEmail`.
5. Call `Send-FormattedEmail` with the HTML body generated by `Set-FormattedEmail`.
6. If `$Doctor` is active: output the headerless CSV subset to the console.
7. Call `Complete-ProjectTelemetry` (triggers JSON conversion) followed by
   `Submit-ProjectTelemetry` to close the telemetry session.
8. Log script completion via `Write-Log`.

## Governance

This Constitution supersedes all other practices, conventions, and informal agreements within
the Infracode Zerto Management project. It is the binding, machine-verifiable standard for all
contributors and AI tooling.

- **Amendment Procedure**: Amendments MUST be proposed via a documented change request,
  reviewed against all dependent templates, and version-bumped following semantic versioning
  (MAJOR / MINOR / PATCH) before being written to `.specify/memory/constitution.md`.
- **Versioning Policy**:
  - MAJOR: Backward-incompatible removals or redefinitions of principles.
  - MINOR: New principle or section added, or materially expanded guidance.
  - PATCH: Clarifications, wording refinements, or typo fixes.
- **Compliance Review**: All PRs MUST verify compliance against every principle prior to merge.
  Any deviation MUST be justified in the Complexity Tracking section of the relevant plan.
- **AI Tooling Rule**: AI agents MUST read this file at the start of every task and treat it
  as the authoritative source. The `docs/` directory MUST be ignored unless explicitly
  referenced for a single, named task.
- **Runtime Guidance**: Use `.specify/` documents for all runtime development guidance.

**Version**: 1.3.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-06
