# Implementation Plan: Get VPG Journal Settings

**Branch**: `004-vpg-journal-settings` | **Date**: 2026-04-06 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/004-vpg-journal-settings/spec.md`

## Summary

Implement a Controller script `Get-VPGJournalSettings.ps1` that performs a journal audit across one or more Zerto ZVMs. The script will support automated ZVM discovery via a local text file, targeted VPG searching, and multiple output formats (CSV, Email, Telemetry, Doctor). It strictly follows the Infracode Zerto Management Constitution v1.3.0, utilizing the Plan/Apply pattern and mandatory Simulation/Doctor modes.

## Technical Context

**Language/Version**: PowerShell 7.5+  
**Primary Dependencies**: `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email`  
**Storage**: `E:\source\zvmservers.txt` (input list), Local Filesystem (CSV/Logs)  
**Testing**: Pester 5.0.0+ (Integration tests in `src/Controllers/Tests/Integration/`)  
**Target Platform**: Windows Server / Zerto ZVM Environment  
**Project Type**: CLI Controller Script  
**Performance Goals**: Process 10 ZVMs in < 5 minutes  
**Constraints**: Mandatory `-Simulation`, `-Doctor`, and `-WhatIf` (via CmdletBinding)  
**Scale/Scope**: Enterprise-wide ZVM audit tool  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Logic |
|------|--------|-------|
| **Plan/Apply** | ✅ | Mandatory for this reporting script to separate ZVM data retrieval from result aggregation/output. |
| **Strictness** | ✅ | Scripts will use `Set-StrictMode` and `$ErrorActionPreference = 'Stop'`. |
| **Strong Typing** | ✅ | All parameters and internal variables will be explicitly typed. |
| **Simulation Mode** | ✅ | `-Simulation` switch required to facilitate offline testing via mocks. |
| **Doctor Pattern** | ✅ | `$Doctor` switch required for headerless CSV console output. |
| **Encapsulation** | ✅ | Logic resides in modules; Controller handles orchestration only. |

## Project Structure

### Documentation (this feature)

```text
specs/004-vpg-journal-settings/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
src/
├── Controllers/
│   ├── Get-VPGJournalSettings.ps1
│   └── Tests/
│       ├── Integration/
│       │   └── Get-VPGJournalSettings.Tests.ps1
│       └── Shared/
│           ├── mocks.ps1
│           └── mocks/
│               └── zvm_vpg_data.json
└── Modules/
    ├── ZertoZVM.APIWrapper/  # Existing
    ├── ZertoZVM.Core/       # Existing
    └── InfraCode.Telemetry/ # Existing
```

**Structure Decision**: Standard PowerShell Architecture as per Constitution. The script is a Controller in `src/Controllers/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations identified.*
