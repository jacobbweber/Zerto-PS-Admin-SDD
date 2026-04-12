## TL;DR
The **Telemetry Contract** mandates the use of the `InfraCode.Telemetry` module to capture a standard 4-point baseline. It enforces **Linear Execution** (no blocks) and a strict **Simulation Mode** that blocks remote transmission while allowing local JSON backups for auditing.

---

# Telemetry Contract

## I. Intent
To ensure every Controller script provides quantitative data regarding its execution success, duration, and business impact. This contract abstracts the transmission logic, ensuring data is sent to the central repository (e.g., Dynatrace) consistently while protecting production data integrity during testing.

## II. Mandatory Baseline Metrics
Regardless of the specific script logic, every Controller MUST capture and submit these four dimensions:

| Metric Key | Type | Source/Logic |
| :--- | :--- | :--- |
| **script_name** | Dimension | `$MyInvocation.MyCommand.Name` |
| **business_unit** | Dimension | Resolved from `$ProjectConfig.business_unit` |
| **result** | Dimension | `Success` if `$Error.Count -eq 0`, otherwise `Failure` |
| **script_duration** | Gauge | Total seconds from start to completion |

---

## III. Implementation Requirements

### III.1 Module Dependency
Controllers MUST statically import the `InfraCode.Telemetry` module at the top of the script.

### III.2 Linear Lifecycle Hooks
As Controllers follow a **Linear Execution** model, telemetry MUST be handled in three phases:

1.  **Initialization (Top of Script)**:
    - Capture `$StartTime = Get-Date`.
    - Instantiate the session using `New-ProjectTelemetry`.
2.  **Collection (Execution Phase)**:
    - Add functional KPIs using `Add-TelemetryMetric` as work is performed.
3.  **Submission (Bottom of Script)**:
    - Calculate final duration and result status.
    - Call `Submit-ProjectTelemetry` as the final orchestration step.

---

## IV. Simulation & `-WhatIf` Guardrails
To prevent data pollution, the following logic is enforced within the telemetry transmission:

* **Transmission Blocking**: All remote API or Agent calls MUST be wrapped in a `$PSCmdlet.ShouldProcess()` check.
* **Backup Persistence**: The telemetry module MUST still write a local `.json` backup to the `-LogPath` even when `-WhatIf` is active, allowing developers to verify the data payload without sending it.

---

## V. Implementation Pattern

```powershell
# Phase 1: Setup
$StartTime = Get-Date
$TelemetrySession = New-ProjectTelemetry -Namespace "zerto.vpg"

# Phase 2: Orchestration (Optional KPI Capture)
# Add-TelemetryMetric -Session $TelemetrySession -Key "vpg_count" -Value $Vpgs.Count

# Phase 3: Finalization
$FinalResult = if ($Error.Count -eq 0) { "Success" } else { "Failure" }
$Duration = (New-TimeSpan -Start $StartTime -End (Get-Date)).TotalSeconds

# Add Mandatory Baselines
Add-TelemetryMetric -Session $TelemetrySession -Key "script_name" -Value $MyInvocation.MyCommand.Name
Add-TelemetryMetric -Session $TelemetrySession -Key "result" -Value $FinalResult
Add-TelemetryMetric -Session $TelemetrySession -Key "script_duration" -Value $Duration

# Final Submission (Respects -WhatIf internally)
Submit-ProjectTelemetry -Session $TelemetrySession -LogPath $LogPath -Backup
```

---

## VI. Compliance Checklist
* [ ] Telemetry session initialized at script start.
* [ ] All 4 mandatory baseline metrics included.
* [ ] `Submit-ProjectTelemetry` is the final step before the script exits or returns data.
* [ ] Local JSON backup is generated regardless of `-WhatIf` status.