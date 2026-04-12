# zerto-ps-admin Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-04-12

## Active Technologies
- [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION] (002-zvm-core)
- [if applicable, e.g., PostgreSQL, CoreData, files or N/A] (002-zvm-core)
- PowerShell 7.5+ + Built-in PowerShell JSON capabilities (003-project-config)
- Local Filesystem (Root `config.json` file) (003-project-config)
- PowerShell 7.5+ + `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email` (004-vpg-journal-settings)
- `E:\source\zvmservers.txt` (input list), Local Filesystem (CSV/Logs) (004-vpg-journal-settings)
- PowerShell 7.5+ + `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email` (all existing project modules) (001-set-journal-scratch)
- JSON files on local filesystem (`E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\{datetime}.json`) (001-set-journal-scratch)

- PowerShell 7.5+ + Pester 5 (for validation/mock testing) (001-zertoapiwrapper-module)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for PowerShell 7.5+

## Code Style

PowerShell 7.5+: Follow standard conventions

## Recent Changes
- 001-set-journal-scratch: Added PowerShell 7.5+ + `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email` (all existing project modules)
- 004-vpg-journal-settings: Added PowerShell 7.5+ + `ZertoZVM.APIWrapper`, `ZertoZVM.Core`, `InfraCode.Telemetry`, `InfraCode.Email`
- 003-project-config: Added PowerShell 7.5+ + Built-in PowerShell JSON capabilities


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
