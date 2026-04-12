# Data Model: Set-JournalAndScratch

**Feature**: `001-set-journal-scratch`  
**Date**: 2026-04-12  
**Phase**: 1 — Design & Contracts

---

## Entities

### 1. VpgJournalScratchState

Represents the captured journal and scratch disk state for a single VPG at a point in time. Used both as the in-memory working record and as the serialized element within a backup file.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `ZVMHost` | `string` | Hostname of the ZVM this VPG belongs to | Non-empty |
| `VpgName` | `string` | Human-readable VPG name | Non-empty |
| `VpgIdentifier` | `string` | Zerto internal GUID for the VPG | Non-empty |
| `JournalSizeGB` | `int` | Current journal disk hard limit in GB | ≥ 0 |
| `ScratchSizeGB` | `int` | Current scratch disk hard limit in GB | ≥ 0 |
| `CapturedAt` | `string` | ISO-8601 UTC timestamp of when state was captured | Non-empty |

---

### 2. VpgUpdateResult

Represents the outcome of an apply or restore operation for a single VPG. Collected across all VPGs/ZVMs and used for reporting (CSV, Email, Doctor, Telemetry).

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `ZVMHost` | `string` | Hostname of the source ZVM | Non-empty |
| `VpgName` | `string` | Human-readable VPG name | Non-empty |
| `VpgIdentifier` | `string` | Zerto internal GUID | Non-empty |
| `JournalSizeGB` | `int` | Resulting journal size in GB (after apply/restore) | ≥ 0 |
| `ScratchSizeGB` | `int` | Resulting scratch size in GB (after apply/restore) | ≥ 0 |
| `DesiredJournalGB` | `int` | Target journal size requested by operator | ≥ 0; 0 in restore mode |
| `DesiredScratchGB` | `int` | Target scratch size requested by operator | ≥ 0; 0 in restore mode |
| `Action` | `string` | What was done: `Updated`, `Skipped`, `Failed`, `Restored` | Enum-valued |
| `Status` | `string` | `Success` or `Failure` | Enum-valued |
| `ErrorMessage` | `string` | Exception message if `Status = Failure`; `$null` on success | Nullable |

---

### 3. JournalScratchBackup (File)

Persisted as a JSON array of `VpgJournalScratchState` objects on the local filesystem.

**File Path Pattern**:
```
E:\scripts\log\Set-JournalAndScratch\backup\{ZVMHost}\{yyyyMMdd-HHmmss}.json
```

**Processed State**:
```
E:\scripts\log\Set-JournalAndScratch\backup\{ZVMHost}\{yyyyMMdd-HHmmss}_processed.json
```

**State Transitions**:
```
[Written]  →  {datetime}.json          (unprocessed — blocks new apply runs)
    |
    └── -Restore  →  {datetime}_processed.json  (consumed — allows new apply runs)
```

**Validation Rules**:
- A ZVM is blocked from apply if any file matching `{ZVMHost}\*.json` exists (excluding `*_processed.json`).
- A ZVM restore requires exactly one unprocessed file (most recent selected if multiple exist).

---

### 4. RunSummary (KPI Aggregate)

An in-memory scalar aggregate accumulated across the entire script execution. Feeds Telemetry and Doctor output.

| Field | Type | Description |
|-------|------|-------------|
| `vpgs_processed` | `int` | Total VPGs evaluated (attempted) |
| `vpgs_updated` | `int` | VPGs successfully changed (apply or restore) |
| `vpgs_failed` | `int` | VPGs that encountered errors |
| `desired_journal_size_gb` | `int` | The `-JournalSizeGB` parameter value (0 in restore mode) |
| `desired_scratch_size_gb` | `int` | The `-ScratchSizeGB` parameter value (0 in restore mode) |

---

## State Machine: Backup Lifecycle

```
                    ┌─────────────────────────────────┐
                    │       Apply Run Requested        │
                    └─────────────┬───────────────────┘
                                  │
                   ┌──────────────▼──────────────┐
                   │  Test-JournalScratchBackup   │
                   │  BackupExists($ZVMHost)       │
                   └──────────────┬──────────────┘
                                  │
              ┌───────────────────┴───────────────────┐
              │ Unprocessed backup found               │ No backup found
              ▼                                        ▼
    ┌─────────────────────┐               ┌────────────────────────┐
    │ THROW — skip ZVM    │               │ New-JournalScratch      │
    │ (existing backup    │               │ Backup($ZVMHost, $State)│
    │  blocks new apply)  │               └────────────┬───────────┘
    └─────────────────────┘                            │
                                           ┌───────────▼──────────┐
                                           │  Invoke-Journal       │
                                           │  ScratchUpdate (×N)   │
                                           └───────────┬──────────┘
                                                       │
                                           ┌───────────▼──────────┐
                                           │  [Backup remains as   │
                                           │   unprocessed.json]   │
                                           └──────────────────────┘

                    ┌─────────────────────────────────┐
                    │      Restore Run Requested       │
                    └─────────────┬───────────────────┘
                                  │
                   ┌──────────────▼──────────────┐
                   │  Find unprocessed backup     │
                   │  for $ZVMHost               │
                   └──────────────┬──────────────┘
                                  │
              ┌───────────────────┴───────────────────┐
              │ None found                             │ Found
              ▼                                        ▼
    ┌─────────────────────┐               ┌────────────────────────┐
    │ THROW — no backup   │               │ Invoke-Journal         │
    │ to restore from     │               │ ScratchRestore (×N)    │
    └─────────────────────┘               └────────────┬───────────┘
                                                       │
                                           ┌───────────▼──────────┐
                                           │ Complete-Journal      │
                                           │ ScratchBackup         │
                                           │ (rename → _processed) │
                                           └──────────────────────┘
```

---

## Relationships

```
Get-ZertoVPG  ──produces──▶  VPG list
VPG list  ──feeds──▶  Get-VpgJournalScratchState  ──produces──▶  VpgJournalScratchState[]
VpgJournalScratchState[]  ──persisted as──▶  JournalScratchBackup (JSON)
VpgJournalScratchState[]  ──feeds──▶  Invoke-JournalScratchUpdate  ──produces──▶  VpgUpdateResult
VpgUpdateResult[]  ──aggregated into──▶  RunSummary (KPIs)
VpgUpdateResult[]  ──distributed via──▶  CSV, Email, Telemetry, Doctor
```
