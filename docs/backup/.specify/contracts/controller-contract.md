## TL;DR
The **Controller Contract** has been updated to remove the mandatory `Begin/Process/End` block requirement. Controllers now follow a **Linear Orchestration** model, while maintaining strict logic density limits (10%) and delegating all substantive work to modules.

---

# Controller Contract (Revised)

## I. Intent
To provide a standardized, linear execution framework for all scripts in `.\src\Controllers\`. This contract ensures controllers remain thin "glue" scripts that sequence module functions, handle high-level errors, and manage project configuration without the overhead of formal block structures.

## II. Structural Requirements

### II.1 Logic Density Rule
Controllers MUST NOT exceed **10% unique logic**.
- **Substantive Logic**: API data parsing, conditional business math, and complex branching MUST reside in a Module.
- **Orchestration**: Sequencing module functions, variable assignment, and parameter passing is the sole responsibility of the Controller.

---

## III. Implementation Blueprint

### III.1 Phase 1: Environment & Setup
The top of the script handles all prerequisites.
```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 1. Module Imports (Static) - Must import all modules under .\src\modules\*
Import-Module ZertoZVM.APIWrapper -Force
Import-Module ZertoZVM.Core       -Force
Import-Module InfraCode.Utilities  -Force
Import-Module InfraCode.Telemetry -Force

# 2. Initialization
$ProjectConfig = Initialize-ProjectConfig -ScriptName $MyInvocation.MyCommand.Name
Initialize-ProjectLogs -Config $ProjectConfig

# 3. Auth Resolution (per Auth-Contract)
if (-not $ZertoCred) { $ZertoCred = Resolve-ProjectCredential -Provider 'Zerto' }

# 4. Telemetry Initialization
$TelemetrySession = New-ProjectTelemetry -Context $ProjectConfig
```

### III.2 Phase 2: Functional Orchestration
The "middle" of the script sequences the work. Use granular try/catch blocks for distinct failure points.
```powershell
Write-Log -Level 'Info' -Message "Starting orchestration" -Context $ProjectConfig

try {
    # Step 1: Call Module Function
    $RawData = Get-ZertoVPG -Credential $ZertoCred
    
    # Step 2: Call Core Logic Module
    $Results = Convert-ToZertoReport -Data $RawData
}
catch {
    Write-Log -Level 'Error' -Message "Orchestration failed: $($_.Exception.Message)"
    throw
}
```

### III.3 Phase 3: Finalization & Output
The bottom of the script handles telemetry submission and return values.
```powershell
# 1. Finalize Telemetry
Complete-ProjectTelemetry -Session $TelemetrySession

# 2. Conditional Outputs (Doctor Pattern)
if ($Doctor) {
    return Show-DoctorOutput -Results $Results
} else {
    # 3. Standard Object Return
    Write-Log -Level 'Info' -Message "Script Complete"
    return $Results
}
```

---

## IV. Constraint Checklist
* **No In-Script Functions**: All helper logic must be moved to a `.\src\Modules\` directory.
* **New Modules/Functions**: If a new module or function is created, it MUST be added to the `.\src\Modules\` directory.
* **New Modules/Functions**: Must utilize existing modules/functions when available.
* **Explicit Inputs**: Pass variables explicitly to module functions; do not rely on script-scope "bleeding."
* **PSScriptAnalyzer**: Scripts must achieve a zero-warning state despite the linear structure.

---
