# Implementation Plan: Global Environment Configuration

**Branch**: `003-project-config` | **Date**: 2026-04-05 | **Spec**: [specs/003-project-config/spec.md](spec.md)
**Input**: Feature specification from `/specs/003-project-config/spec.md`

## Summary

Provide a centralized, machine-readable JSON configuration file (`config.json`) and accompanying structural loaders (`Initialize-ProjectConfig`, `Test-ProjectConfig`) that bootstrap the execution environment. This effectively normalizes the logging, telemetry, authentication, and reporting endpoints across different Zerto environments.

## Technical Context

**Language/Version**: PowerShell 7.5+  
**Primary Dependencies**: Built-in PowerShell JSON capabilities  
**Storage**: Local Filesystem (Root `config.json` file)  
**Testing**: Pester 5  
**Target Platform**: Any system executing Infracode Zerto Management  
**Project Type**: Core Configuration Schema & Module Logic (`ZertoZVM.Core`)  
**Performance Goals**: `Initialize-ProjectConfig` consistently parses `config.json` into `$Config` in under 200ms.  
**Constraints**: Fully compliant with the mandatory exact property paths of Constitution Section III.  
**Scale/Scope**: Impacts all Zerto Automation controller scripts globally.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Section I (Modern PS)**: Adheres to strict mode, strong typing, zero unapproved verbs.
- **Section II (The Module Rule)**: Functions `Initialize-ProjectConfig` and `Test-ProjectConfig` will live in `ZertoZVM.Core` PS module.
- **Section III (The Global Configuration Contract)**: Direct alignment with required keys (`base.logging.paths`, `base.telemetry`, `base.auth`, etc.)
- **Section VI (Predictable Execution)**: Test-ProjectConfig serves precisely as a predictable gate to avoid crashes on missing paths.

## Project Structure

### Documentation (this feature)

```text
specs/003-project-config/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── contracts/           # Phase 1 output (schema definitions)
```

### Source Code (repository root)

```text
config.json                         # Template configuration file at root

src/Modules/
└── ZertoZVM.Core/
    ├── Public/
    │   ├── Initialize-ProjectConfig.ps1
    │   └── Test-ProjectConfig.ps1
    └── tests/
        └── Unit/
            ├── Initialize-ProjectConfig.Tests.ps1
            └── Test-ProjectConfig.Tests.ps1
```

**Structure Decision**: Functions are localized within the existing `ZertoZVM.Core` module to provide generalized access across all scripts. The baseline `config.json` template lives at the repo root.
