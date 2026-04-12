# Meta-Prompt: Zerto Automation Factory (ZAF)

## The Mission
Establish a **PowerShell Controller Script Factory** using GitHub Spec-Kit. The system must transform a simple, non-technical Markdown intake form into robust, enterprise-standard Zerto ZVM controller scripts. This will enable repeatable, consistent, and reliable automation for the Zerto team.

## Phase 1: Architectural Discovery (Instructions for AI)
> **Action Required:** Before scaffolding, analyze the requirements and the sample intake form below.
> 1. **Infer & Define:** Determine what logic must exist in the **Constitution**, what data shapes belong in **Shared Contracts**, and what directory structures belong in **Standards**. You are tasked with determining where the provided information should live to achieve the project mission.
> 2. **Clarification Loop:** Ask me a series of 5-10 targeted questions to resolve any ambiguities, identify missing information, seek direction on technical trade-offs, or resolve conflicts in the requirements.
> 3. **Drafting:** Once I answer the clarification questions, produce the initial versions of the Constitution, Contracts, and Standards.

---

## The Initial Raw Requirements (The Source)
* **Monorepo Structure:** All modules (`.psm1`) and Controllers (`.ps1`) reside in a single repository.
* **Inherited Features:** Every script MUST include real-time logging (Splunk + Local + Memory), Dynatrace telemetry, and `ShouldProcess` support.
* **Error Handling Strategy:** Scripts MUST utilize granular Try/Catch/Finally blocks at each specific point of failure rather than a single aggregate block. These blocks handle decision-making and map to relevant modules for remediation or notification.
* **State Management:** A `$ZertoContext` object initialized at start carries all state and data between functions.
* **Security:** Use an optional `$Credential` parameter; fallback to AES-encrypted credentials at `E:\script\aescreds\` using `.\src\config\credentialmappaths.psd1`.
* **Module Mapping Intent:** The system (Intake, Constitution, Contracts, and Specs) must dynamically map terminology and requirements from the intake form to the appropriate local modules. The following modules are available for mapping:
    * `ZertoZVM.APIWrapper`: Pure REST calls only.
    * `ZertoZVM.Core`: Multi-step business logic and workflows.
    * `ZertoZVM.Utilities`: Logging, bootstrapping, and plumbing.
    * `ZertoZVM.Telemetry`: Dynatrace/KPI submission.
    * `ZertoZVM.Snow`: ServiceNow API integration.
    * `ZertoZVM.Email`: HTML formatting and SMTP delivery.
* **Testing Standards:**
    * Every controller requires an integration test in `.\src\modules\controller\tests\integration\`.
    * Tests must use a shared mocks file at `.\src\modules\controller\tests\shared-mocks\mocksfile`.
    * Module functions must have individual unit tests.

---

## The North Star (Sample Intake Form)
*Use this sample to infer how the Constitution and Contracts should map terminology to backend modules.*

```markdown
# Spec: Create-ZertoVPG-From-SNOW
**Goal:** Automate VPG creation based on a ServiceNow Request.

## Integrations
- [X] ServiceNow (Action: Close Task, Update CMDB)
- [X] Credentials: Zerto_Service_Account
- [ ] Email Notification

## Telemetry & KPIs
- KPI: VM_Count
- KPI: Provisioning_Time_Seconds
- Destination: Dynatrace

## Orchestration (The Steps)
1. GET VPG details from the ServiceNow Ticket provided in $Args.
2. CHECK if the Target ZVM is reachable.
3. VALIDATE vCenter resource availability via ZertoZVM.Core.
4. CREATE the VPG via ZertoZVM.APIWrapper.
5. IF successful, update SNOW CMDB and log success to Splunk.

## Script Completion
- Submit Telemetry
- Submit CSV Report
- Submit Email
- Submit Doctor

## Completion Details
- Submit Telemetry
    - KPI: VM_Count
    - KPI: Provisioning_Time_Seconds
    - Destination: Dynatrace
- Submit CSV Report
    - Columns: VM_Count, Provisioning_Time_Seconds
    - Destination: C:\Logs\Zerto\zvm_report.csv
- Submit Email
    - Attach the CSV Report
- Submit Doctor
    - Return Object Output: VM_Count, Provisioning_Time_Seconds
    - Destination: C:\Logs\Zerto\zvm_debug.log
```

---

## Infracode Zerto Management Constitution

### I. Philosophy & Strict PowerShell
* **Environment**: Targets PowerShell 7.5+ exclusively.
* **Strictness**: Every script MUST use `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`.
* **Strong Typing**: All variables, parameters, and return types MUST be explicitly typed.
* **Granular Error Handling**: Use Try/Catch/Finally blocks per point of failure. Avoid monolithic catch-all blocks.
* **Naming**: `Verb-Noun` for functions; `PascalCase` for variables/parameters.
* **Formatting**: OTBS (One True Brace Style). No backticks; use splatting.
* **Static Analysis**: MUST pass `Invoke-ScriptAnalyzer` with zero warnings.

### II. Architecture & Encapsulation
* **Module Encapsulation**: Modules in `.\src\Modules\[ModuleName]\` must be self-contained with `Public`, `Private`, `Tests`, and `Docs`.
* **Dynamic Mapping**: The Constitution and Specs must resolve intake terminology to local module functions. 
* **Controller Logic**: Controllers in `.\src\Controllers\` handle orchestration. Logic density must not exceed 10% unique code; substantive logic belongs in modules.
* **Module Responsibilities**:
    * `ZertoZVM.APIWrapper`: Pure REST, no business logic.
    * `ZertoZVM.Core`: Business logic, utilities, and formatters.
    * `InfraCode.Telemetry`: Session management and KPI submission.
    * `InfraCode.Snow`: Pure REST for ServiceNow.
    * `InfraCode.Email`: Composition and HTML formatting.

### III. The Global Configuration Contract
Scripts MUST load a standardized `.psd1` into a `$Config` object with these mandatory keys:
* **Logging paths**: `logdir`, `archive`, `state`, `telemetry`, `syslog`, `devlog`.
* **Telemetry**: `hostname`, `username`, `business_unit`.
* **Authentication**: `vmware_user`, `vmware_password`.
* **Reporting**: `smpt_server`.

### IV. Execution & Simulation Modes
* **WhatIf Support**: Mandatory `SupportsShouldProcess`.
* **Guard Blocks**: Every state mutation must be wrapped in `$PSCmdlet.ShouldProcess()`. Emit mocked objects for simulation testing.

### V. Thread-Safe Dual-Stream Logging
* **Utilities Centralization**: Use `Write-Log` from `ZertoZVM.Utilities`.
* **Behavior**: 
    * `[scriptname]_developer.log`: Info, Warn, Error, Debug.
    * `[scriptname]_syslog.log`: Info, Warn, Error.
    * **Splunk**: Use `Write-InfracodeLog` for structured JSON events.

### VI. The Doctor Diagnostic Pattern
* **Signature**: `[Parameter()][bool]$Doctor`.
* **Behavior**: If `$true`, extract `$Results` subset and output as headerless CSV to stdout.

### VII. Quality Assurance
* **Tests**: Pester MUST validate business outcomes via shared mocks for offline validation.

---

## Lifecycle Execution (The Data Pipeline)
Every controller MUST follow this structure:

### A. Begin Block (The Bootstrap)
1. Import all modules based on mapping requirements.
2. Initialize `$Context` object.
3. Initialize logging directories.
4. Build constants.

### B. Process Block (The Planner)
1. Execute orchestration logic with granular Try/Catch blocks at every potential failure point.

### C. End Block (The Executor)
1. Complete and Submit Telemetry.
2. Generate and Submit CSV/Excel Report.
3. Return Doctor Console Output.
4. Submit Email.
5. Return Object Output.

---

## Expected Output
1. **The Constitution**: Finalized directives for the `specify` command to map intake terms to module actions.
2. **Shared Contracts**: Technical definitions for the `$ZertoContext` and data shapes.
3. **Standards**: Documented folder hierarchy and naming conventions.
4. **The Base Template**: A reusable `intake-spec.md` template based on the North Star.