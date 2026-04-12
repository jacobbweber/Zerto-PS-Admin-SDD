# Implementation Plan: Set-JournalAndScratch

**Branch**: `001-set-journal-scratch` | **Date**: 2026-04-12 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-set-journal-scratch/spec.md`

---

## Summary

`Set-JournalAndScratch` is a Controller script that updates journal and scratch disk sizes for all targeted VPGs across one or more Zerto ZVMs. It implements a Plan/Apply/Restore lifecycle: on first run it creates a dated JSON backup of current sizes, then applies the desired values. When run with `-Restore`, it reads the backup and reverts each VPG, then marks the backup as processed. The script tolerates partial failures (per-VPG and per-ZVM), enforcing a consecutive-failure circuit-breaker (threshold: 3) before aborting a ZVM. All four output channels are mandatory: Telemetry, CSV, Email, and Doctor.

---

## Technical Context

**Language/Version**: PowerShell 7.5+  
**Primary Dependencies**: `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email` (all existing project modules)  
**Storage**: JSON files on local filesystem (`E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\{datetime}.json`)  
**Testing**: Pester (Unit tests per module function; Integration tests under `src/Controllers/Tests/`)  
**Target Platform**: Windows Server (PowerShell 7.5+ runtime)  
**Project Type**: CLI Controller script (Orchestrator pattern)  
**Performance Goals**: No strict throughput target; sequential per-ZVM processing acceptable for fleet operations  
**Constraints**: Logic density ≤10% per controller-contract; zero in-script functions; all business logic in modules  
**Scale/Scope**: N ZVMs × M VPGs per ZVM; designed for fleet-scale (dozens of ZVMs, hundreds of VPGs total)

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| `#Requires -Version 7.5` directive | ✅ PASS | Will be first line of controller |
| Controller is a thin Orchestrator (≤10% logic density) | ✅ PASS | All business logic (backup, compare, restore, circuit-breaker) delegated to `ZertoZVM.Core` module functions |
| No `function` keywords inside controller body | ✅ PASS | Enforced by design; all helpers are module functions |
| Auth Contract: `Resolve-ProjectCredential` | ✅ PASS | Uses existing `ZertoCred` pattern |
| Telemetry Contract: `New-ProjectTelemetry` / `Add-TelemetryMetric` / `Submit-ProjectTelemetry` | ✅ PASS | Linear lifecycle; 5 KPIs defined |
| Logging Contract: `Write-Log` with key=value format | ✅ PASS | No native Write-Host/Write-Output for status |
| Controller Contract: Linear Orchestration model | ✅ PASS | Controller replaced `Begin/Process/End` with linear flow per updated contract |
| Doctor Contract: `$Doctor` bool, headerless CSV output | ✅ PASS | Doctor output at script end |
| All modules in `./src/Modules/` | ✅ PASS | New `ZertoZVM.Core` functions added to existing module structure |
| Unit Tests (Pester) for every new public function | ✅ PASS | Tests co-located in module `Tests/` directory |
| Integration Tests for Controller | ✅ PASS | Placed under `src/Controllers/Tests/` |
| PSScriptAnalyzer: Zero errors/warnings | ✅ PASS | Enforced at implementation time |

**POST-DESIGN RE-EVALUATION**: All gates pass. No complexity violations required.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-set-journal-scratch/
├── plan.md              ← This file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
├── contracts/           ← Phase 1 output
│   └── script-contract.md
├── checklists/
│   └── requirements.md
└── tasks.md             ← Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
src/
├── Controllers/
│   ├── Set-JournalAndScratch.ps1          [NEW] Controller script
│   └── Tests/
│       ├── Shared/
│       │   └── mocks/                     [existing]
│       └── Set-JournalAndScratch.Tests.ps1 [NEW] Integration tests
│
└── Modules/
    └── ZertoZVM.Core/
        ├── Public/
        │   ├── Get-VpgJournalScratchState.ps1     [NEW] Read current journal+scratch per VPG
        │   ├── Test-JournalScratchBackupExists.ps1 [NEW] Check for unprocessed backup
        │   ├── New-JournalScratchBackup.ps1        [NEW] Write backup JSON
        │   ├── Invoke-JournalScratchUpdate.ps1     [NEW] Apply desired sizes to a single VPG
        │   ├── Invoke-JournalScratchRestore.ps1    [NEW] Restore one VPG from backup record
        │   └── Complete-JournalScratchBackup.ps1   [NEW] Rename backup file as processed
        └── Tests/
            ├── Get-VpgJournalScratchState.Tests.ps1
            ├── Test-JournalScratchBackupExists.Tests.ps1
            ├── New-JournalScratchBackup.Tests.ps1
            ├── Invoke-JournalScratchUpdate.Tests.ps1
            ├── Invoke-JournalScratchRestore.Tests.ps1
            └── Complete-JournalScratchBackup.Tests.ps1
```

**Structure Decision**: Single-project, Controller + Module extension pattern. All new logic is added as public functions to the existing `ZertoZVM.Core` module, consistent with all other controllers in the repository. The Controller itself is thin: it sequences module calls, passes data, and manages the outer ZVM/VPG loop structure.

---

## Complexity Tracking

> No Constitution violations. Section left intentionally blank.
