<!--
================================================================================
SYNC IMPACT REPORT
================================================================================
Version Change  : 0.0.0 (blank template) → 1.0.0
Bump Rationale  : MAJOR — first ratification; all placeholders replaced with
                  concrete governance content. No prior version to compare.

Modified Principles (old → new)
  [PRINCIPLE_1_NAME] → Modern, Strict PowerShell
  [PRINCIPLE_2_NAME] → The Module Rule
  [PRINCIPLE_3_NAME] → The Global Configuration Contract
  [PRINCIPLE_4_NAME] → Thread-Safe Dual-Stream Logging
  [PRINCIPLE_5_NAME] → The "Doctor" Diagnostic Pattern
  [PRINCIPLE_6_NAME] → Predictable Execution (added; template had 5 slots)

Added Sections
  - Lifecycle Execution (The Data Pipeline) — replaces generic SECTION_2/3

Removed Sections
  - Generic [SECTION_2_NAME] / [SECTION_3_NAME] template slots (superseded)

Templates Requiring Updates
  ✅ .specify/memory/constitution.md            (this file — now complete)
  ✅ .specify/templates/plan-template.md        (Constitution Check gate is
       dynamic per-feature; no structural change needed)
  ✅ .specify/templates/spec-template.md        (FR-XXX + user-story structure
       aligns; no change required)
  ✅ .specify/templates/tasks-template.md       (Pester/testing guidance aligns;
       Phase labels align with PS module structure; no change required)

Deferred TODOs
  - RATIFICATION_DATE: Set to today (2026-04-05) as first formal adoption date.
  - No remaining unexplained bracket tokens.
================================================================================
-->

# Infracode Zerto Management Constitution

## Core Principles

### I. Modern, Strict PowerShell

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
  - Unit Tests: Every Library function requires a Pester 5 test file in `tests\Unit\`.
  - Integration Tests: Controller scripts MUST have a Pester 5 test file in
    `tests\Integration\`. Tests MUST validate business outcomes via mocking to ensure
    zero impact on live systems.

### II. The Module Rule

Logic MUST be encapsulated in modules; controller scripts MUST only orchestrate.

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
  The `docs/` folder MUST be ignored by AI tooling unless explicitly directed to a specific
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

### IV. Thread-Safe Dual-Stream Logging

All logging MUST be centralized via the `Write-Log` function from the `ZertoZVM.Core` module.

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

### V. The "Doctor" Diagnostic Pattern

Every controller MUST support a runtime diagnostic mode via a `$Doctor` switch parameter.

- **Signature**: `[Parameter()][bool]$Doctor`
- **Behavior**: When `$Doctor -eq $true`, the script MUST extract a defined subset of
  `$Results` and output it as **headerless CSV** to the console (stdout).
- The subset of fields included in Doctor output MUST be explicitly documented per controller.

### VI. Predictable Execution

All scripts MUST implement safe-operation guards to prevent unintended state changes.

- **ShouldProcess**: All scripts MUST declare `[CmdletBinding(SupportsShouldProcess)]`.
- **WhatIf Gate**: Every "Write" operation (any action that mutates state) MUST be wrapped in
  a `$PSCmdlet.ShouldProcess()` guard block.

## Lifecycle Execution (The Data Pipeline)

Every controller script MUST follow the Begin / Process / End pipeline structure to ensure
baseline telemetry, logging, and safe execution.

### A. Begin Block — The Bootstrap

1. Import all modules from the `modules` directory.
2. Parse `config.json` into the global `$Config` object.
3. Initialize the results collection: `$Results = [System.Collections.Generic.List[PSObject]]::new()`.
4. If `$Doctor` is active: initialize `$DoctorReport = [ordered]@{}`.
5. Call `New-ProjectTelemetry` using `$Config.base.telemetry` values to open the telemetry session.

### B. Process Block — The Orchestration

1. All logic MUST be wrapped in a `Try / Catch` block.
2. Collect data and append to `$Results`; perform state changes only via `ShouldProcess` guards.
3. **Formatting is prohibited** in this block — no conversion to CSV, Table, or JSON.

### C. End Block — The Distribution

1. Finalize KPIs and add them to the telemetry collection.
2. Pass `$Results` to `Export-ProjectCSVReport` and `Set-FormattedEmail`.
3. Call `Send-FormattedEmail` with the HTML body generated by `Set-FormattedEmail`.
4. If `$Doctor` is active: output the headerless CSV subset to the console.
5. Call `Complete-ProjectTelemetry` (triggers JSON conversion) followed by
   `Submit-ProjectTelemetry` to close the telemetry session.
6. Log script completion via `Write-Log`.

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

**Version**: 1.0.0 | **Ratified**: 2026-04-05 | **Last Amended**: 2026-04-05
