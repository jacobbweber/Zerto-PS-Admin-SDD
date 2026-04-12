# Script Contract: Set-JournalAndScratch

**Feature**: `001-set-journal-scratch`  
**Date**: 2026-04-12  
**Type**: CLI Controller Script Interface Contract

---

## Overview

This contract defines the public interface for the `Set-JournalAndScratch.ps1` controller script. It specifies the accepted parameters, output modes, error behaviors, and file-system side effects that consumers and automation callers can depend upon.

---

## Parameter Interface

| Parameter | Type | Mandatory | Default | Description |
|-----------|------|-----------|---------|-------------|
| `ZVMHost` | `[string]` | No | *(reads `zvmservers.txt`)* | Target a single ZVM. When omitted, all ZVMs in `zvmservers.txt` are processed. |
| `VpgName` | `[string[]]` | No | *(all VPGs)* | Limit processing to one or more named VPGs. Accepts array. |
| `JournalSizeGB` | `[int]` | **Yes** (apply mode) | — | Desired journal disk hard limit in GB. Required when `-Restore` is not specified. |
| `ScratchSizeGB` | `[int]` | **Yes** (apply mode) | — | Desired scratch disk hard limit in GB. Required when `-Restore` is not specified. |
| `Restore` | `[switch]` | No | `$false` | Activates restore mode. Reads backup file and reverts VPG sizes. Cannot be combined with `-JournalSizeGB` or `-ScratchSizeGB`. |
| `EmailTo` | `[string]` | No | *(config default)* | Override email recipient. |
| `ZertoCred` | `[PSCredential]` | No | *(AES credential store)* | Explicit Zerto credential. Falls back to `Resolve-ProjectCredential`. |
| `Doctor` | `[bool]` | No | `$true` | Emit headerless CSV output for machine consumption. |

---

## Mutual Exclusivity Rules

- `-Restore` is mutually exclusive with `-JournalSizeGB` and `-ScratchSizeGB`. Providing `-Restore` along with either size parameter throws a `[System.ArgumentException]` before any ZVM is contacted.
- `-JournalSizeGB` and `-ScratchSizeGB` are both required when `-Restore` is not specified (enforced via `ParameterSetName`).

---

## Output Modes

### Standard Mode (interactive / pipeline)
Returns `[VpgUpdateResult[]]` — an array of per-VPG result objects (see data-model.md).

### Doctor Mode (`$Doctor = $true`, default)
Emits headerless, quote-stripped, comma-delimited CSV to stdout.  
**Column order**: `ZVMHost, VpgName, JournalSizeGB, ScratchSizeGB, vpgs_processed, vpgs_updated, vpgs_failed`

### CSV Report
Written to the report path resolved by `Initialize-ProjectConfig`. Contains all columns listed in the spec:
`ZVM, VPG, JournalSize, ScratchSize, VpgsProcessed, VpgsUpdated, VpgsFailed, DesiredJournalSize, DesiredScratchSize`

### Email
Sent via `InfraCode.Email`. Subject: `"Set-JournalAndScratch"`. CSV report attached.

### Telemetry
Submitted via `InfraCode.Telemetry`. Namespace: `"zerto.vpg"`.

| KPI Key | Type | Description |
|---------|------|-------------|
| `script_name` | Dimension | `Set-JournalAndScratch` |
| `business_unit` | Dimension | From config |
| `result` | Dimension | `Success` or `Failure` |
| `script_duration` | Gauge | Total seconds |
| `vpgs_processed` | Gauge | Total VPGs evaluated |
| `vpgs_updated` | Gauge | VPGs successfully changed |
| `vpgs_failed` | Gauge | VPGs that errored |
| `desired_journal_size_gb` | Gauge | Requested journal GB |
| `desired_scratch_size_gb` | Gauge | Requested scratch GB |

---

## Filesystem Side Effects

### Apply Mode
- **Creates**: `E:\scripts\log\Set-JournalAndScratch\backup\{ZVMHost}\{yyyyMMdd-HHmmss}.json`
- **Blocks if**: any `*.json` (not `*_processed.json`) exists in the ZVM's backup directory

### Restore Mode
- **Reads**: most recent unprocessed `*.json` in `E:\scripts\log\Set-JournalAndScratch\backup\{ZVMHost}\`
- **Renames to**: `{original-basename}_processed.json`

---

## Error Behaviors

| Condition | Behavior |
|-----------|----------|
| Unprocessed backup exists for a ZVM (apply mode) | Throw non-terminating error for that ZVM; continue to next ZVM |
| No unprocessed backup for a ZVM (restore mode) | Throw non-terminating error for that ZVM; continue to next ZVM |
| Backup already marked `_processed` (restore mode) | Throw informative error; skip that ZVM |
| Single VPG update fails | Log error; increment `vpgs_failed`; continue to next VPG |
| 3+ consecutive VPG failures within one ZVM | Log circuit-breaker trigger; stop processing that ZVM; `continue` to next ZVM |
| ZVM connection fails entirely | Log warning; skip entire ZVM; continue |
| `-Restore` + size params supplied together | Throw `[System.ArgumentException]` immediately; no ZVMs processed |
| Credential resolution fails | Throw `[System.Exception]` after logging `Critical`; script terminates |

---

## Compliance Attestation

This script interface satisfies:
- ✅ `Contracts/auth-contract.md` — `$ZertoCred` parameter + `Resolve-ProjectCredential` fallback
- ✅ `Contracts/telemetry-contract.md` — Linear lifecycle with 4 mandatory baselines + 5 feature KPIs
- ✅ `Contracts/logging-contract.md` — `Write-Log` with key=value format throughout
- ✅ `Contracts/controller-contract.md` — Linear orchestration, ≤10% logic density, no in-script functions
- ✅ `Contracts/doctor-contract.md` — `$Doctor` bool, headerless CSV, comma-delimited, no quotes
