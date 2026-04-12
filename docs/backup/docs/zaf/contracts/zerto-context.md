# Contract: `$ZertoContext` — Unified State Object

**Version**: 1.0.0
**Authority**: ZAF Constitution §IV
**Status**: Canonical — all new controllers MUST use this schema.

---

## Overview

`$ZertoContext` is the single hashtable that carries **all runtime state** for a controller's execution lifetime. It replaces the previous pattern of separate `$global:Config` and `$global:TelemetrySession` global variables.

It is initialized in the **Begin block** via `Initialize-ZertoContext` (from `ZertoZVM.Utilities`) and passed by reference to all module functions that consume it.

---

## Full Schema

```powershell
[hashtable]$ZertoContext = @{

    # =========================================================================
    # Config — Absorbed from config.json (previously $global:Config)
    # =========================================================================
    Config = @{
        Logging  = @{
            LogDir    = [string]''   # base.logging.paths.logdir
            Archive   = [string]''   # base.logging.paths.archive
            State     = [string]''   # base.logging.paths.state
            Telemetry = [string]''   # base.logging.paths.telemetry
            SysLog    = [string]''   # base.logging.paths.syslog
            DevLog    = [string]''   # base.logging.paths.devlog
        }
        Telemetry = @{
            Hostname     = [string]''  # base.telemetry.hostname
            Username     = [string]''  # base.telemetry.username
            BusinessUnit = [string]''  # base.telemetry.business_unit
        }
        Email    = @{
            SmtpServer = [string]''  # base.email.smpt_server
            DefaultTo  = [string]''  # base.email.default_to
        }
        Auth     = @{
            VmwareUser     = [string]''  # base.auth.vmware_user
            VmwarePassword = [string]''  # resolved from AES or explicit; stored securely
        }
    }

    # =========================================================================
    # Session — Absorbed from the telemetry session (previously $global:TelemetrySession)
    # =========================================================================
    Session = @{
        KPIs          = [hashtable]@{}   # KPI_Name → value (null until populated in Process/End)
        StartTime     = [datetime][datetime]::UtcNow
        ScriptName    = [string]''       # Populated from $MyInvocation.MyCommand.Name
        CorrelationId = [string][System.Guid]::NewGuid().ToString()
        IsActive      = [bool]$true
        LogBuffer     = [System.Collections.Generic.List[PSObject]]::new()  # In-memory log replay
    }

    # =========================================================================
    # State — Runtime mutable state (ZVM connection, mode, credentials)
    # =========================================================================
    State = @{
        CurrentZVM   = [string]''          # Hostname of currently connected ZVM
        IsConnected  = [bool]$false        # True when ZVM session is active
        Credential   = [PSCredential]$null # Resolved credential (from $Credential param or AES)
        CredSource   = [string]''          # "Explicit" | "AES" | "None"
        Mode         = [string]'Live'      # "Live" | "Simulation" | "WhatIf"
    }

    # =========================================================================
    # Results — The primary output buffer
    # =========================================================================
    Results = [System.Collections.Generic.List[PSObject]]::new()

    # =========================================================================
    # Meta — Immutable execution metadata
    # =========================================================================
    Meta = @{
        ScriptPath   = [string]$PSCommandPath
        StartedBy    = [string]$env:USERNAME
        HostName     = [string]$env:COMPUTERNAME
        PSVersion    = [string]$PSVersionTable.PSVersion.ToString()
        ConfigPath   = [string]''    # Resolved config.json path
    }
}
```

---

## Canonical Initialization Template

The `Initialize-ZertoContext` function in `ZertoZVM.Utilities` MUST be called once in the Begin block. It returns a fully-hydrated `$ZertoContext`:

```powershell
[hashtable]$ZertoContext = Initialize-ZertoContext @{
    ConfigPath  = Join-Path -Path $PSScriptRoot -ChildPath '..\..\config.json'
    ScriptName  = $MyInvocation.MyCommand.Name
    Mode        = if ($Simulation) { 'Simulation' } elseif ($WhatIfPreference) { 'WhatIf' } else { 'Live' }
    Credential  = $Credential  # null if not provided; AES fallback handled internally
}
```

`Initialize-ZertoContext` is responsible for:
1. Loading and validating `config.json` (all mandatory keys per Constitution §V).
2. Creating log directories if they don't exist.
3. Populating `$ZertoContext.Config` from the JSON.
4. Populating `$ZertoContext.Meta` from the runtime environment.
5. Setting `$ZertoContext.State.CredSource` based on credential resolution outcome.
6. Calling `Resolve-ZertoCredential` and storing the result in `$ZertoContext.State.Credential`.

---

## KPI Registration Pattern

KPIs are registered in the **Begin block** with `$null` values and populated during **Process** or **End**:

```powershell
# Begin block — register KPIs from intake form
$ZertoContext.Session.KPIs['VM_Count']                = $null
$ZertoContext.Session.KPIs['Provisioning_Time_Seconds'] = $null

# Process block or End block — populate with actual values
$ZertoContext.Session.KPIs['VM_Count']                = $ZertoContext.Results.Count
$ZertoContext.Session.KPIs['Provisioning_Time_Seconds'] = ([datetime]::UtcNow - $ZertoContext.Session.StartTime).TotalSeconds
```

---

## Accessor Patterns

Module functions that receive `$ZertoContext` as a parameter MUST use the defined key paths:

```powershell
# Correct — fully qualified path
[string]$SmtpServer = $ZertoContext.Config.Email.SmtpServer

# Correct — pass as explicit parameter to function
Send-FormattedEmail -SmtpServer $ZertoContext.Config.Email.SmtpServer -To $Recipient

# INCORRECT — do not pass the entire $ZertoContext to modules not designed for it
Some-ModuleFunction -Context $ZertoContext  # Only ZertoZVM.Utilities functions accept -Context
```

---

## State: Mode Transitions

| Mode | Trigger | Effect |
|---|---|---|
| `Live` | Default (no switches) | All API calls execute against real ZVM |
| `Simulation` | `-Simulation` switch | Load mock data from `Tests\Shared\mocks\`; skip all live calls |
| `WhatIf` | `-WhatIf` switch (from `SupportsShouldProcess`) | Show what would change; no mutations executed |

`$ZertoContext.State.Mode` is set once in Begin and is **read-only** thereafter.

---

## Migration Guide (Legacy → New Pattern)

| Legacy Pattern | New Pattern |
|---|---|
| `$global:Config.base.logging.paths.logdir` | `$ZertoContext.Config.Logging.LogDir` |
| `$global:Config.base.telemetry.hostname` | `$ZertoContext.Config.Telemetry.Hostname` |
| `$global:Config.base.email.smpt_server` | `$ZertoContext.Config.Email.SmtpServer` |
| `$global:TelemetrySession.KPIs['vpg_count']` | `$ZertoContext.Session.KPIs['vpg_count']` |
| `New-ProjectTelemetry -Hostname $global:Config...` | `New-ProjectTelemetry -Context $ZertoContext` |
| `Complete-ProjectTelemetry` (no args) | `Complete-ProjectTelemetry -Context $ZertoContext` |

---

*Contract: zerto-context.md — ZAF Constitution §IV*
