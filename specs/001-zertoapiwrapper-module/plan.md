# Implementation Plan: ZertoZVM.APIWrapper Module

**Branch**: `001-zertoapiwrapper-module` | **Date**: 2026-04-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-zertoapiwrapper-module/spec.md`

## Summary

Build a stateless, pure functional REST API wrapper for the Zerto ZVM platform. The module manages session state internally with auto-refresh capabilities using cached credentials, enforcing strict URI construction, query parameter encoding, and error handling through a single private proxy function. Mutating operations are shielded by `-WhatIf` guards, and all telemetry emitted by the wrapper is restricted to native `Write-Verbose` streams.

## Technical Context

**Language/Version**: PowerShell 7.5+  
**Primary Dependencies**: Pester 5 (for validation/mock testing)  
**Storage**: In-memory module scope (`$script:ZertoSession`)  
**Testing**: Pester 5 (Unit with mocked HTTP; Integration against live/simulated v1 API)  
**Target Platform**: PowerShell Core (Cross-platform)  
**Project Type**: PowerShell Library Module (API Wrapper)  
**Performance Goals**: < 3s local network HTTP response for all reads and short-lived writes  
**Constraints**: Single-session design, thread last-writer-wins for refresh; credential stored in process memory until explicit disconnect.  
**Scale/Scope**: Refactoring the foundational transport layer for ~219 downstream cmdlets.  

## Constitution Check

*GATE: Passed*

- **I. Modern, Strict PowerShell**: Adheres strictly to `Set-StrictMode`, explicit typing, PascalCasing, splatting, and documentation requirements. PSScriptAnalyzer testing mandates are defined in spec.
- **II. The Module Rule**: Specifically complies by acting as a pure REST layer. All logic remains in upper-level controllers or `ZertoZVM.Core`.
- **III. The Global Configuration Contract**: N/A for wrapper internals. Parameters are injected by orchestrator layers via `$Config`.
- **IV. Thread-Safe Dual-Stream Logging**: Exempted safely. Uses strictly `Write-Verbose` per specification to remain independent of Core logging libraries.
- **V. The "Doctor" Diagnostic Pattern**: N/A for pure modules.
- **VI. Predictable Execution**: Explicit `-WhatIf`/`ShouldProcess` compliance added for all `Start/Stop/Invoke` action cmdlets.

## Project Structure

### Documentation (this feature)

```text
specs/001-zertoapiwrapper-module/
├── plan.md              
├── research.md          
├── data-model.md        
├── quickstart.md        
├── contracts/
│   └── APIWrapper.md           
└── tasks.md             
```

### Source Code (repository root)

```text
src/Modules/InfraCore.ZertoZVM/
├── InfraCore.ZertoZVM.psd1
├── InfraCore.ZertoZVM.psm1
├── Private/
│   ├── Assert-ZertoSession.ps1
│   └── Invoke-ZertoRequest.ps1
└── Public/
    ├── Connect-ZertoZVM.ps1
    ├── Disconnect-ZertoZVM.ps1
    └── [Refactored Cmdlet Scripts]

tests/
├── Integration/
│   └── ZertoZVM.APIWrapper.Integration.Tests.ps1
├── Mocks/
│   └── ZertoZVM.APIWrapper.Mocks.json
└── Unit/
    └── ZertoZVM.APIWrapper.Tests.ps1
```

**Structure Decision**: Continuing to house the code in `src/Modules/InfraCore.ZertoZVM` as the module currently resides there, applying strict private/public boundaries and migrating all cmdlets to use the consolidated proxy functions.

## Complexity Tracking

*(No Constitution violations detected. No complexity justification required.)*
