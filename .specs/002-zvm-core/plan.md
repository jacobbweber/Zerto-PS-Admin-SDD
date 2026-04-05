# Implementation Plan: ZertoZVM.Core

**Branch**: `002-zvm-core` | **Date**: 2026-04-05 | **Spec**: [spec.md](./spec.md)

## Summary

The `ZertoZVM.Core` module provides foundational capabilities across all future Zerto automation scripts. The core features are initializing structured configurations (`config.json`), validating them against structural requisites, and deploying a thread-safe unified dual-stream logging command (`Write-Log`) to guarantee that operations are securely tracked for auditing and comprehensively logged for debugging.

## Technical Context

**Language/Version**: PowerShell 7.5+  
**Primary Dependencies**: None (Native .NET IO / native PSCustomObject logic)  
**Storage**: config.json mapping to variables. File system for Logs.  
**Testing**: Pester 5 (Mock-based isolated testing)  
**Target Platform**: Cross-Platform  
**Project Type**: PowerShell Module  
**Constraints**: Zero-collision logging concurrency without locking process execution. Must fully conform to all rules defined in Constitution 1.1.0.

## Constitution Check

*GATE: Passed*

- **I. Modern, Strict PowerShell**: Strong typing and `Verb-Noun` constraints inherently baked into design goals. Backticks prohibited per design checks.
- **II. The Module Rule**: Architecture strictly segregates public functions from private code inside the module structural paths.
- **III. Global Configuration Contract**: Explicit validation check programmed for schema compliance (`Test-ProjectConfig`).
- **IV. Thread-Safe Dual Logging**: Central design pivot; exactly maps to `Write-Log` specifications (Debug vs Audit streams).

## Project Structure

### Documentation

```text
specs/002-zvm-core/
├── plan.md              
├── research.md          
├── data-model.md        
├── quickstart.md        
├── contracts/config-schema.md
└── tasks.md             (Phase 2)
```

### Source Code

```text
src/Modules/ZertoZVM.Core/
├── ZertoZVM.Core.psd1
├── ZertoZVM.Core.psm1
├── public/
│   ├── Write-Log.ps1
│   ├── Initialize-ProjectConfig.ps1
│   └── Test-ProjectConfig.ps1
├── private/
│   ├── Convert-LogObject.ps1
│   └── Invoke-ThreadSafeFileWrite.ps1
└── tests/
    └── Unit/
        └── ZertoZVM.Core.Tests.ps1
```

**Structure Decision**: A single Module footprint encapsulating Public interfaces, Internal abstractions (Private) for file writing to keep main functions clean, and Pester tests co-located under the module structure per Constitution II.
