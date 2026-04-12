# Contract: KPI — Registration, Naming, and Submission

**Version**: 1.0.0
**Authority**: ZAF Constitution §III.4, §VI.3
**Status**: Canonical

---

## Overview

KPIs (Key Performance Indicators) are numeric measurements emitted by a controller at the end of each run. They are registered in the **Begin block** against `$ZertoContext.Session.KPIs`, populated during **Process** or **End**, and submitted to Dynatrace via `ZertoZVM.Telemetry` in the **End block**.

This contract defines the naming rules, metadata requirements, data types, timing, and submission behavior.

---

## KPI Data Shape

```powershell
# $ZertoContext.Session.KPIs is a [hashtable] where:
#   Key   = KPI name (string, see Naming Rules below)
#   Value = Numeric measurement (int | double | long) or $null if not yet populated

$ZertoContext.Session.KPIs = @{
    'VM_Count'                  = $null   # Registered in Begin; populated in End
    'Provisioning_Time_Seconds' = $null   # Registered in Begin; populated in Process or End
    'VPG_Count'                 = $null
    'Error_Count'               = $null
}
```

---

## Naming Rules

| Rule | Detail | Example |
|---|---|---|
| Format | `PascalCase_UnderscoreSeparated` | `VM_Count`, `Provisioning_Time_Seconds` |
| Suffix for counts | `_Count` | `VM_Count`, `Error_Count` |
| Suffix for durations | `_Seconds`, `_Milliseconds` | `Provisioning_Time_Seconds` |
| Suffix for sizes | `_Bytes`, `_GB` | `Journal_Size_GB` |
| Suffix for rates | `_Per_Second`, `_Per_Hour` | `VMs_Provisioned_Per_Hour` |
| Max length | 64 characters | — |
| Allowed characters | Alphanumeric and underscore only | No spaces, hyphens, or special chars |

KPI names in the intake form MUST match this convention. If an intake form specifies `KPI: VM_Count`, the registration key is exactly `VM_Count`.

---

## Lifecycle

```text
Begin Block
└── Registration: $ZertoContext.Session.KPIs['KPI_Name'] = $null

Process Block
└── Optional population mid-run:
    $ZertoContext.Session.KPIs['Error_Count'] += 1

End Block
└── Final population:
    $ZertoContext.Session.KPIs['VM_Count']                  = $ZertoContext.Results.Count
    $ZertoContext.Session.KPIs['Provisioning_Time_Seconds'] = ([datetime]::UtcNow - $ZertoContext.Session.StartTime).TotalSeconds

└── Telemetry completion:
    Complete-ProjectTelemetry -Context $ZertoContext

└── Telemetry submission (if -Telemetry switch):
    Submit-ProjectTelemetry -Context $ZertoContext
```

---

## Standard KPI Catalog

These are the pre-approved, reusable KPIs. Use these names when the intake form's intent matches. Do not create synonyms (e.g., don't create `VmCount` when `VM_Count` exists).

| KPI Name | Type | Description | When Populated |
|---|---|---|---|
| `VM_Count` | `int` | Number of VMs processed | End block |
| `VPG_Count` | `int` | Number of VPGs processed | End block |
| `ZVM_Count` | `int` | Number of ZVMs iterated | Begin or End |
| `Provisioning_Time_Seconds` | `double` | Total wall-clock time for provisioning | End block |
| `Total_Run_Time_Seconds` | `double` | Total script wall-clock time | End block (always) |
| `Error_Count` | `int` | Number of non-critical errors encountered | Incremented in each catch |
| `Success_Count` | `int` | Number of successful items | Incremented in Process |
| `Journal_Size_GB` | `double` | Total journal storage (GB) | Process block |
| `Recovery_Point_Objective_Hours` | `double` | Average RPO in hours | Process block |
| `Snow_Tasks_Updated` | `int` | Number of ServiceNow tasks updated | Process or End |

---

## Submission Contract

`Submit-ProjectTelemetry` in `ZertoZVM.Telemetry` MUST read KPIs from `$ZertoContext.Session.KPIs` and emit them to the configured Dynatrace endpoint.

```powershell
# Internal submission logic (ZertoZVM.Telemetry module)
# Each non-null KPI is emitted as a Dynatrace metric data point:
#
# metric_key     = "zaf.{BusinessUnit}.{ScriptName}.{KPI_Name}"   (lowercase, dots)
# value          = $ZertoContext.Session.KPIs[$KpiName]
# timestamp      = $ZertoContext.Session.StartTime (Unix ms)
# dimensions     = @{ hostname = $ZertoContext.Config.Telemetry.Hostname; }
#
# Null-valued KPIs are SKIPPED (not submitted as zero).
```

**Non-blocking rule**: A failure in `Submit-ProjectTelemetry` MUST be caught and logged as `Warning` level. It MUST NOT terminate the controller.

```powershell
try {
    Submit-ProjectTelemetry -Context $ZertoContext
}
catch {
    Write-Log -Level 'Warning' -Message "Telemetry submission failed (non-critical): $($_.Exception.Message)" -Context $ZertoContext
    # Do NOT rethrow. Telemetry failure never blocks primary script completion.
}
```

---

## KPI Population Timing Rules

| KPI Category | Population Rule |
|---|---|
| **Count of results** | Always populate in End block after `$ZertoContext.Results` is finalized |
| **Elapsed time** | Compute in End block: `([datetime]::UtcNow - $ZertoContext.Session.StartTime).TotalSeconds` |
| **Incremental counts** (errors, successes) | Increment inline in Process block within try/catch |
| **Per-resource values** (RPO, journal size) | Aggregate in Process block; finalize average/sum in End |

---

## Intake Form → KPI Registration Mapping

Given an intake form:

```markdown
## Telemetry & KPIs
- KPI: VM_Count
- KPI: Provisioning_Time_Seconds
- Destination: Dynatrace
```

The generated controller Begin block MUST include:

```powershell
# KPIs — registered from intake form
$ZertoContext.Session.KPIs['VM_Count']                  = $null
$ZertoContext.Session.KPIs['Provisioning_Time_Seconds'] = $null
```

And the End block MUST include population and conditional submission:

```powershell
$ZertoContext.Session.KPIs['VM_Count']                  = $ZertoContext.Results.Count
$ZertoContext.Session.KPIs['Provisioning_Time_Seconds'] = ([datetime]::UtcNow - $ZertoContext.Session.StartTime).TotalSeconds

if ($Telemetry) {
    try     { Submit-ProjectTelemetry -Context $ZertoContext }
    catch   { Write-Log -Level 'Warning' -Message "Telemetry failed: $($_.Exception.Message)" -Context $ZertoContext }
}
```

---

*Contract: kpi-contract.md — ZAF Constitution §III.4*
