# Project Constitution: Infracode Zerto Management

## 1. Coding & Language Standards
### Principle: Modern, Strict PowerShell
**Statement:** All code must adhere to the highest standards of the PowerShell 7.5+ ecosystem.
**Constraints:**
* **Environment:** Targets **PowerShell 7.5+** only.
* **Strictness:** Mandatory `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`.
* **Strong Typing:** All variables, parameters, and function return types MUST be explicitly typed (e.g., `[int]$Count`, `[psobject]$Data`).
* **Naming:** * **Functions:** `Verb-Noun` (Approved Verbs only). Singular nouns.
    * **Casing:** `PascalCase` for all variables, parameters, and functions.
* **Formatting:**
    * **Style:** OTBS (One True Brace Style).
    * **Splatting:** Mandatory for any call with 4 or more parameters.
    * **No Backticks:** Backticks for line continuation are **strictly prohibited**.
* **Documentation:** All functions must include **Comment-Based Help** and `[CmdletBinding()]`.
* **Static Analysis:** All code must pass `Invoke-ScriptAnalyzer` using the project's `PSScriptAnalyzerSettings.psd1` with zero warnings or errors.
* **Testing:** * **Unit Tests:** Every Library function requires a Pester 5 test file in `tests\Unit\`.
    * **Integration Tests:** Controllers must have a Pester 5 test file in `tests\Integration\`. These must validate business outcomes via mocking to ensure zero impact on live systems.

## 2. Architectural Integrity
### Principle: The Module Rule
**Statement:** Logic must be encapsulated in modules; controllers only orchestrate.
**Constraints:**
* **`ZertoZVM.APIWrapper`:** Pure REST API calls (Method/URI/Body) for Zerto API only.
* **`ZertoZVM.Core`:** Zerto-specific business logic, utility functions, and output formatters.
* **`InfraCode.Telemetry`:** Dynatrace session management and KPI submission.
* **`InfraCode.Snow`:** Pure REST API calls (Method/URI/Body) for ServiceNow (SNOW) API only.
* **`InfraCode.Email`:** Functions for Email and HTML formatting.
* **`InfraCode.HeadQuarters`:** Pure REST API calls (Method/URI/Body) for Headquarters API only.
* **No "In-Script" Functions:** Controller scripts must not define internal functions.
* **10% Logic Limit:** Controller scripts must not exceed 10% unique logic density.
* **Source of Truth:** The `.specify/` directory is the sole authority for standards and rules.
* **Ignore docs/:** AI must ignore the `docs/` folder unless explicitly directed to a specific file for a single task.

## 3. Bootstrap & Configuration Schema
### Principle: The Global Configuration Contract
**Statement:** Scripts rely on a standardized `config.json` loaded into a global `$Config` object.
**Constraints:**
* **Mandatory Schema:** The AI must explicitly utilize the `config.json` for:
    * **Logging:** `$Config.base.logging.paths.[logdir, archive, state, telemetry]` and `$Config.base.logging.paths.filename.[syslog, devlog, telemetry, csv]`.
    * **Telemetry:** `$Config.base.telemetry.[hostname, username, business_unit]`.
    * **Authentication:** `$Config.base.auth.[vmware_user, vmware_password]`.
    * **Reporting:** `$Config.base.email.smpt_server`.

## 4. Logging & Observability
### Principle: Thread-Safe Dual-Stream Logging
**Statement:** Centralized logging via `Write-Log` (Core module).
**Constraints:**
* **Function Call:** `Write-Log -Level <String> -Message <String> -LogPath <String> -SyslogFileName <String> -DevLogFileName <String>`.
* **Behavior:** * `[scriptname]_developer.log`: Receives **Info, Warn, Error, Debug**.
    * `[scriptname]_syslog.log`: Receives **Info, Warn, Error**.
* **Splunk:** Use `Write-InfracodeLog` for structured JSON events.

### Principle: The "Doctor" Diagnostic Pattern
* **Input:** Every controller must include a `[Parameter()][bool]$Doctor` switch.
* **Output:** If `$Doctor` is `$true`, extract a defined subset of `$Results` and output as **headerless CSV** to the console.

## 5. Operational Safety
### Principle: Predictable Execution
**Constraints:**
* **ShouldProcess:** All scripts MUST implement `[CmdletBinding(SupportsShouldProcess)]`.
* **WhatIf:** All "Write" operations must be wrapped in a `$PSCmdlet.ShouldProcess()` block.

## 6. Lifecycle Execution (The Data Pipeline)
**Statement:** Scripts MUST follow this structure to ensure baseline telemetry and logging.

### A. Begin Block (The Bootstrap)
1. **Import Modules:** Import all modules from the `modules` directory.
2. **Load Config:** Parse `config.json` into `$Config`.
3. **Init Results:** `$Results = [System.Collections.Generic.List[PSObject]]::new()`.
4. **Init Doctor:** If `$Doctor`, `$DoctorReport = [ordered]@{}`.
5. **Telemetry:** Call `New-ProjectTelemetry` using `$Config.base.telemetry` values.

### B. Process Block (The Orchestration)
1. **Try/Catch:** All logic wrapped in a `Try` block.
2. **Logic:** Collect data and add to `$Results`. Perform state changes via `ShouldProcess`.
3. **No Formatting:** Conversion to CSV/Table/JSON is prohibited in this block.

### C. End Block (The Distribution)
1. **KPIs:** Finalize KPIs and add to telemetry collection.
2. **Formatters:** Pass `$Results` to `Export-ProjectCSVReport` and `Set-FormattedEmail`.
3. **Email Delivery:** Call `Send-FormattedEmail` with the HTML body generated.
4. **Doctor:** If `$Doctor`, output the headerless CSV subset to the console.
5. **Telemetry Closure:** Call `Complete-ProjectTelemetry` (to JSON conversion) followed by `Submit-ProjectTelemetry`.
6. **Cleanup:** Log script completion.
