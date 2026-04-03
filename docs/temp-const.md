You are absolutely right to call that out. In the process of narrowing down the architectural split, some of the specific "boots-on-the-ground" coding rules like Splatting and the Backtick ban were inadvertently trimmed.

For a **GitHub Spec-Kit** to be effective, it needs those granular constraints to prevent the AI from generating "lazy" code. Here is the **Complete, Unabridged Constitution**, restoring all technical requirements while maintaining your new 3-tier architectural split.

---

# The Zerto ZVM Automation Constitution (v4.0 - Master)

## 1. Core Development Philosophy
* **Spec-Driven Development (SDD):** The `.spec.md` is the absolute source of truth. No code logic changes occur without a prior update to the corresponding specification.
* **Declarative Intent & Idempotency:** Scripts must focus on the "Target State." Operations must verify current state first (e.g., `Get-ZvmVpg`) to ensure running a script $N$ times yields the same result as a single run without unintended side effects.
* **Fail-Fast Validation:** Validate all inputs (JSON, Environment, Permissions) in the `Begin` block. Use **Guard Clauses** to `throw` early and prevent partial execution.

## 2. Multi-Module Architecture & Governance
The project strictly separates logic into three distinct tiers:

### A. The Shared Services Layer (`InfraCode.Utils`)
* **Purpose:** Cross-cutting infrastructure logic and logistics.
* **Bootstrap Function:** The mandatory entry point for controllers. It reads `config.json`, handles the decryption of AES-encrypted credentials, and initializes the **Context Object**.
* **Logistics:** Contains `Write-Log`, Telemetry baseline generation, and shared I/O logic. It remains "Zerto-agnostic."

### B. The Domain Layer (`InfraCode.ZertoZVM`)
* **Purpose:** A "Pure" API Wrapper for the Zerto ZVM appliance via a proper Module Manifest (`.psd1`).
* **Encapsulation:** Contains all ZVM-specific classes, type definitions, and functions (e.g., `New-ZvmVpg`).
* **Purity:** This module does not handle its own logging or secret management; it consumes those from `Utils` or accepts them via parameters.

### C. The Orchestration Layer (Controller Scripts)
* **Role:** The "Glue." Scripts that import the local `InfraCode` modules to execute specific business workflows.
* **Logic Constraint:** Controllers are prohibited from defining local functions or type definitions. They are purely orchestrational.

## 3. Global Configuration (`config.json`)
Every controller must consume a root-level `config.json`:
* **Secrets:** Contains file paths to **AES-encrypted** blobs (Usernames/Passwords).
* **Telemetry:** Defines baseline metadata (e.g., `App_ID`, `Business_Unit`).
* **Environment:** Global paths for logging, reports, and API endpoints.

## 4. Architectural Lifecycle Mandate
All scripts must adhere to the `Begin -> Process -> End` lifecycle. No logic is permitted outside these blocks.
* **Begin Block:** Initialization only. Import modules, run the `Utils` Bootstrap function, and validate environment readiness. **Function/Type definitions are strictly prohibited here.**
* **Process Block:** Data ingestion and transformation. All objects should be collected into a strongly typed buffer: `[System.Collections.Generic.List[psobject]]$ResultBuffer`.
* **End Block:** Final calculations, Reporting (CSV/Excel), Telemetry extension (merging baseline with script-specific metrics), and final Pipeline Output.

## 5. Coding & Language Standards
* **Language:** PowerShell 7.5+.
* **Strictness:** Mandatory `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at the script root.
* **Strong Typing:** Mandatory explicit typing for all variables, parameters, and function return types (e.g., `[int]$Count`, `[string]$Name`).
* **Naming:** * Functions: `Verb-Noun` using [Approved Verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands). Singular nouns only.
    * Casing: `PascalCase` for all variables, parameters, and functions.
* **Formatting:**
    * **Splatting:** If a cmdlet or function takes 4 or more parameters, you **must** use splatting.
    * **No Backticks:** Use of the backtick (`` ` ``) for line continuation is **strictly prohibited**. Use arrays or splatting for multi-line commands.
* **Documentation:** All advanced functions must include **Comment-Based Help** (Synopsis, Description, Examples) and `[CmdletBinding()]`.

## 6. Execution Modes ($WhatIf & $Doctor)
### The `$WhatIf` Switch (Simulation)
Live mode is the default (`$WhatIf = $false`). There must be no shared code paths for state-changing operations.
* **Live Mode:** Call real API functions and write state/reports to disk.
* **Mock Mode ($WhatIf = $true):** Call only mock data functions. Do not write to disk. Emit a `[WhatIf]`-prefixed log for every action that would have occurred.

### The `$Doctor` Parameter (Diagnostics)
* **Type:** Explicitly defined as **`[bool]$Doctor`** (Mandatory, not a switch).
* **Logic:** * `$true`: The script returns **only** a CSV-formatted string via `ConvertTo-Csv`.
    * `$false`: The script returns the standard rich object collection.

## 7. Performance & Concurrency
* **Throttling:** Parallel operations must have an enforced ceiling (e.g., `-ThrottleLimit 5`).
* **Thread Safety:** Use thread-safe .NET classes (e.g., `[System.Collections.Concurrent.ConcurrentBag[psobject]]`) when aggregating data across parallel threads.
* **Atomic I/O:** Use `[System.IO.File]::AppendAllText()` for logging to prevent file-lock collisions. 
* **Mutexes:** Use `[System.Threading.Mutex]` inside `try/finally` blocks for any shared state updates (e.g., updating a local JSON tracker).
* **Pipeline Etiquette:** For high-performance requirements, prefer `.Where({})` and `.ForEach({})` methods over the standard `|` pipeline.

## 8. Error Handling & Logging
* **Structure:** Wrap all external calls in `try/catch` blocks. Use **Guard Clauses** (early return/throw) to avoid deeply nested `if` statements.
* **Standardized Logging:** `Write-Log` (from `Utils`) must support levels (`Info`, `Warning`, `Error`, `Debug`) and format outputs for Splunk (Key=Value).
* **Telemetry Schema:** Every script must return a telemetry object containing: `Script_Name`, `Duration_ms`, `Execution_Date`, `User_Identity`, `Success_Boolean`, and `Affected_Count`.

## 9. Quality Assurance & Release
* **Static Analysis:** All code must pass `Invoke-ScriptAnalyzer` using the project's `PSScriptAnalyzerSettings.psd1` with zero warnings or errors.
* **Testing:** * **Unit Tests:** Every Library function requires a Pester 5 test file in `tests\Unit\`.
    * **Integration Tests:** Controllers must have a Pester 5 test file in `tests\Integration\`.
* **Secrets:** Hardcoding credentials or API keys is strictly prohibited. 
* **Version Control:** Adhere to **Semantic Versioning** (`Major.Minor.Patch`) and **Conventional Commits** (e.g., `feat:`, `fix:`, `docs:`). Maintain a `docs\change.log`.