# ZAF Standards — Directory Hierarchy, Naming Conventions & Test Topology

**Version**: 1.0.0
**Authority**: ZAF Constitution §I, §II, §XII
**Status**: Canonical

---

## 1. Repository Directory Hierarchy

```text
zerto-ps-admin-1/                       # Repository root
│
├── config.json                          # Global runtime configuration (mandatory keys per Constitution §V)
├── .gitignore
│
├── docs/
│   ├── reference/                       # Zerto/vCenter API reference files (Swagger, endpoint CSVs)
│   └── zaf/                             # Zerto Automation Factory design documents (this folder)
│       ├── constitution.md              # ← YOU ARE HERE (master governance)
│       ├── standards.md                 # ← THIS FILE
│       ├── contracts/
│       │   ├── zerto-context.md         # $ZertoContext schema
│       │   ├── credential-map.md        # credentialmappaths.psd1 schema
│       │   ├── kpi-contract.md          # KPI naming and submission rules
│       │   └── output-contract.md       # CSV, Doctor, Email, Return Object shapes
│       └── intake-spec-template.md      # Reusable intake form for new controllers
│
├── src/
│   ├── config/
│   │   └── credentialmappaths.psd1      # Account → AES credential file mapping
│   │
│   ├── Modules/
│   │   ├── ZertoZVM.APIWrapper/         # REST transport layer
│   │   │   ├── ZertoZVM.APIWrapper.psd1
│   │   │   ├── ZertoZVM.APIWrapper.psm1
│   │   │   ├── Private/                 # Internal helpers (not exported)
│   │   │   │   └── Invoke-ZertoRequest.ps1
│   │   │   ├── Public/                  # Exported cmdlets (one file per function)
│   │   │   │   ├── Connect-ZertoZVM.ps1
│   │   │   │   ├── Disconnect-ZertoZVM.ps1
│   │   │   │   ├── Get-ZertoVPG.ps1
│   │   │   │   └── ...
│   │   │   └── tests/
│   │   │       ├── Unit/                # Unit tests per public function
│   │   │       ├── Integration/         # Module-level integration tests
│   │   │       └── Mocks/              # Module-specific mock data
│   │   │
│   │   ├── ZertoZVM.Core/               # Business logic and workflows
│   │   │   ├── ZertoZVM.Core.psd1
│   │   │   ├── ZertoZVM.Core.psm1
│   │   │   ├── private/
│   │   │   ├── public/
│   │   │   └── tests/
│   │   │       └── Unit/
│   │   │
│   │   ├── ZertoZVM.Utilities/          # 🔶 PLANNED — Logging, bootstrapping, credential resolution
│   │   │   ├── ZertoZVM.Utilities.psd1
│   │   │   ├── ZertoZVM.Utilities.psm1
│   │   │   ├── Private/
│   │   │   ├── Public/
│   │   │   │   ├── Write-Log.ps1           # Consolidated logging (Splunk + file + memory)
│   │   │   │   ├── Initialize-ZertoContext.ps1
│   │   │   │   └── Resolve-ZertoCredential.ps1
│   │   │   └── tests/
│   │   │       └── Unit/
│   │   │
│   │   ├── InfraCode.Telemetry/         # Dynatrace KPI session and submission
│   │   │   ├── InfraCode.Telemetry.psd1  # Target: ZertoZVM.Telemetry (rename pending)
│   │   │   ├── InfraCode.Telemetry.psm1
│   │   │   └── Public/
│   │   │       ├── New-ProjectTelemetry.ps1
│   │   │       ├── Complete-ProjectTelemetry.ps1
│   │   │       └── Submit-ProjectTelemetry.ps1
│   │   │
│   │   ├── ZertoZVM.Snow/               # 🔶 PLANNED — ServiceNow REST integration
│   │   │   ├── ZertoZVM.Snow.psd1
│   │   │   ├── ZertoZVM.Snow.psm1
│   │   │   ├── Private/
│   │   │   ├── Public/
│   │   │   │   ├── Get-SnowTicket.ps1
│   │   │   │   ├── Set-SnowTask.ps1
│   │   │   │   └── Update-SnowCMDB.ps1
│   │   │   └── tests/
│   │   │       └── Unit/
│   │   │
│   │   └── InfraCode.Email/             # HTML email composition and SMTP delivery
│   │       ├── InfraCode.Email.psd1     # Target: ZertoZVM.Email (rename pending)
│   │       ├── InfraCode.Email.psm1
│   │       └── Public/
│   │           ├── Set-FormattedEmail.ps1
│   │           └── Send-FormattedEmail.ps1
│   │
│   └── Controllers/
│       ├── Get-VPGJournalSettings.ps1   # Existing controller (needs $ZertoContext refactor)
│       ├── {Verb}-{Noun}.ps1            # New controllers (one file per use case)
│       │
│       └── Tests/
│           ├── Integration/             # Controller integration tests (per Constitution §XII)
│           │   ├── Get-VPGJournalSettings.Integration.Tests.ps1
│           │   └── {Verb}-{Noun}.Integration.Tests.ps1
│           └── Shared/
│               └── mocks/              # Shared JSON mock data (cross-test fixtures)
│                   ├── zvm_vpg_data.json
│                   ├── zvm_vm_data.json
│                   └── snow_ticket_data.json
│
└── .agent/
    ├── rules/
    │   └── specify-rules.md             # Auto-generated spec-kit technology index
    └── skills/                          # speckit-* skill implementations
```

---

## 2. Naming Conventions

### 2.1 File Naming

| Artifact | Convention | Examples |
|---|---|---|
| Controller | `{ApprovedVerb}-{ZertoNoun}.ps1` | `Get-VPGJournalSettings.ps1`, `New-ZertoVPGFromSnow.ps1` |
| Module manifest | `{Module.Name}.psd1` | `ZertoZVM.APIWrapper.psd1` |
| Module root | `{Module.Name}.psm1` | `ZertoZVM.APIWrapper.psm1` |
| Public function | `{Verb}-{Noun}.ps1` | `Connect-ZertoZVM.ps1`, `Write-Log.ps1` |
| Private helper | `{PascalCase}.ps1` | `Invoke-ZertoRequest.ps1`, `ConvertTo-AesCredential.ps1` |
| Integration test | `{ControllerName}.Integration.Tests.ps1` | `Get-VPGJournalSettings.Integration.Tests.ps1` |
| Unit test | `{FunctionName}.Tests.ps1` | `Connect-ZertoZVM.Tests.ps1` |
| Mock data | `{resource_type}_data.json` | `zvm_vpg_data.json`, `snow_ticket_data.json` |
| Config file | `config.json` (singular, root) | Fixed name, fixed location |
| Credential map | `credentialmappaths.psd1` (fixed name) | Fixed name, at `src/config/` |

### 2.2 Function Naming

All PowerShell functions MUST use **Approved PowerShell Verbs** (`Get-Verb` output):

| Tier | Verb Examples | Usage |
|---|---|---|
| Data Retrieval | `Get`, `Read`, `Find`, `Search` | API read-only operations |
| Data Mutation | `New`, `Set`, `Remove`, `Add`, `Clear` | API write operations |
| Lifecycle | `Connect`, `Disconnect`, `Start`, `Stop`, `Initialize` | Session management |
| Verification | `Test`, `Assert`, `Confirm` | Validation and checks |
| Output | `Write`, `Export`, `Send`, `Submit`, `Publish` | Output distribution |
| Formatting | `Format`, `Convert`, `ConvertTo`, `ConvertFrom` | Data shaping |

**Noun prefix convention**:
- `Zerto{Resource}` for Zerto domain objects: `Get-ZertoVPG`, `New-ZertoVM`
- `Project{Noun}` for cross-cutting concerns: `Export-ProjectCSVReport`, `New-ProjectTelemetry`
- `Snow{Noun}` for ServiceNow objects: `Get-SnowTicket`, `Set-SnowTask`
- `Formatted{Noun}` for formatted output objects: `Set-FormattedEmail`
- `ZertoContext` for the context factory: `Initialize-ZertoContext`

### 2.3 Module Naming

| Namespace | Meaning | Modules |
|---|---|---|
| `ZertoZVM.*` | Zerto ZVM domain logic and transport | APIWrapper, Core, Utilities, Snow |
| `InfraCode.*` | Shared infrastructure tooling | Telemetry, Email |

> **Rename Backlog**: `InfraCode.Telemetry` → `ZertoZVM.Telemetry` and `InfraCode.Email` → `ZertoZVM.Email` is planned but requires dependency update across all consumers first.

### 2.4 Branch Naming (spec-kit)

When a feature branch is created for a new controller, the branch name MUST follow:

```
{NNN}-{short-kebab-description}
```

| Part | Rules | Example |
|---|---|---|
| `{NNN}` | Zero-padded 3-digit sequential number | `005`, `012` |
| `{short-kebab-description}` | 2–4 kebab-case words capturing the essence | `vpg-journal-audit`, `create-vpg-from-snow` |

Examples: `005-create-vpg-from-snow`, `006-vm-replication-report`

---

## 3. Module Internal Structure Standard

Every module MUST follow this internal directory layout:

```text
{ModuleName}/
├── {ModuleName}.psd1         # Module manifest
├── {ModuleName}.psm1         # Root module (dots-sources Public/ and Private/; exports)
├── Public/                   # Exported cmdlets (one file per function)
│   └── {Verb}-{Noun}.ps1
├── Private/                  # Internal helpers (not exported)
│   └── {PascalCase}.ps1
└── tests/
    ├── Unit/                 # One .Tests.ps1 per public function
    │   └── {Verb}-{Noun}.Tests.ps1
    └── Mocks/                # Module-specific mock data
        └── {resource}_mock.json
```

**Rules**:
- Each `Public/` file exports exactly **one** function.
- `{ModuleName}.psm1` auto-discovers and dot-sources all `.ps1` files in `Public/` and `Private/`.
- `{ModuleName}.psm1` exports via `Export-ModuleMember -Function (Get-ChildItem Public/*.ps1).BaseName`.

---

## 4. Controller Test Topology

### 4.1 Integration Test File Structure

```powershell
# {Verb}-{Noun}.Integration.Tests.ps1
# .\src\Controllers\Tests\Integration\

BeforeAll {
    # 1. Dot-source or import the controller for testing
    # 2. Import shared mocks
    $MockPath = Join-Path $PSScriptRoot '..\Shared\mocks'
    $VpgMock  = Get-Content "$MockPath\zvm_vpg_data.json" | ConvertFrom-Json

    # 3. Define all external mocks
    Mock Connect-ZertoZVM    { }
    Mock Disconnect-ZertoZVM { }
    Mock Invoke-ZertoRequest { return $VpgMock }
    Mock Write-Log           { }
    Mock Submit-ProjectTelemetry { }
}

Describe '{ControllerName} Integration Tests' {
    Context 'Happy path — live data' {
        It 'Returns expected result count' { ... }
        It 'Populates all required result properties' { ... }
    }
    Context 'Empty input — graceful degradation' {
        It 'Returns empty list without error' { ... }
    }
    Context 'Partial failure — one ZVM unreachable' {
        It 'Continues to next ZVM on connection error' { ... }
        It 'Logs warning for failed ZVM' { ... }
    }
    Context 'WhatIf mode' {
        It 'Makes no mutations with -WhatIf' { ... }
    }
    Context 'Simulation mode' {
        It 'Loads mock data and returns results without API calls' { ... }
    }
}
```

### 4.2 Shared Mock Data Conventions

Mock files in `.\src\Controllers\Tests\Shared\mocks\` MUST:
- Represent the **real API response schema** (not simplified/truncated).
- Be named for the resource type: `zvm_vpg_data.json`, `zvm_vm_data.json`.
- Contain at minimum **3 representative records** (happy path, edge case, failure case).
- Be updated whenever the API response schema changes.

---

## 5. Module Creation Checklist

When scaffolding a **new planned module** (`ZertoZVM.Utilities`, `ZertoZVM.Snow`):

```markdown
- [ ] Create directory: `src/Modules/{ModuleName}/`
- [ ] Create `{ModuleName}.psd1` from manifest template
- [ ] Create `{ModuleName}.psm1` with auto-discover pattern (see §3)
- [ ] Create `Public/`, `Private/`, `tests/Unit/`, `tests/Mocks/` subdirectories
- [ ] Implement each public function in a separate `Public/{Verb}-{Noun}.ps1` file
- [ ] Add unit test for each public function in `tests/Unit/`
- [ ] Verify `Invoke-ScriptAnalyzer` passes with zero warnings on all files
- [ ] Update `src/config/credentialmappaths.psd1` if new credential accounts added
- [ ] Update `docs/zaf/constitution.md` module status from 🔶 Planned → ✅ Active
```

---

## 6. Controller Creation Checklist

When a new controller is approved via the intake+spec-kit workflow:

```markdown
- [ ] Intake form completed and approved (`docs/zaf/intake-spec-template.md`)
- [ ] spec-kit `speckit-specify` → `speckit-plan` → `speckit-tasks` executed
- [ ] Controller file created: `src/Controllers/{Verb}-{Noun}.ps1`
- [ ] `#Requires -Version 7.5` as first line
- [ ] `Set-StrictMode -Version Latest` + `$ErrorActionPreference = 'Stop'` in Begin block
- [ ] `$ZertoContext` initialized via `Initialize-ZertoContext`
- [ ] All module imports from intake Module Mapping Matrix
- [ ] All intake orchestration steps implemented with granular Try/Catch
- [ ] All intake completion actions implemented in End block
- [ ] `[CmdletBinding(SupportsShouldProcess)]` declared
- [ ] All mutations wrapped in `$PSCmdlet.ShouldProcess()`
- [ ] `-Doctor`, `-CSV`, `-Email`, `-Telemetry`, `-Simulation` switches implemented
- [ ] Integration test created: `src/Controllers/Tests/Integration/{Name}.Integration.Tests.ps1`
- [ ] `Invoke-ScriptAnalyzer` passes with zero warnings
- [ ] All Pester integration tests pass in offline (mock) mode
- [ ] PR self-attestation checklist completed (per Constitution §XIII.3)
```

---

*Standards: standards.md — ZAF Constitution §I, §II, §XII*
