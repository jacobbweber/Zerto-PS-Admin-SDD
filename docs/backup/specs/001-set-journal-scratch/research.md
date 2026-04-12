# Research: Set-JournalAndScratch

**Feature**: `001-set-journal-scratch`  
**Date**: 2026-04-12  
**Phase**: 0 — Outline & Research

---

## 1. Zerto VPG Settings Change Workflow

### Decision
Use the Zerto 3-step VPG settings mutation pattern: `New-ZertoVpgsetting` (open edit session) → `Set-ZertoVpgsettingjournal` + `Set-ZertoVpgsettingscratch` (mutate) → `Start-ZertoVpgsettingcommit` (commit and apply).

### Rationale
The Zerto API for VPG settings is a transactional edit session. A settings edit is opened with `POST /v1/vpgSettings` targeting a specific VPG (`VpgIdentifier` in body), mutations are applied individually, and then committed with `POST /v1/vpgSettings/{id}/commit`. This is the same pattern used throughout `ZertoZVM.APIWrapper`.

### Confirmed API Wrappers Available

| Operation | Wrapper Function | Notes |
|-----------|-----------------|-------|
| Open edit session | `New-ZertoVpgsetting` | Body: `{ VpgIdentifier: "..." }` |
| Get current journal | `Get-ZertoVpgsettingjournal` | Param: `$VpgsettingsIdentifier` |
| Set journal size | `Set-ZertoVpgsettingjournal` | Body: `{ DatastoreIdentifier, HardLimitInMB, WarningThresholdInMB }` |
| Get current scratch | `Get-ZertoVpgsettingscratch` | Param: `$VpgsettingsIdentifier` |
| Set scratch size | `Set-ZertoVpgsettingscratch` | Body: `{ DatastoreIdentifier, HardLimitInMB, WarningThresholdInMB }` |
| Commit changes | `Start-ZertoVpgsettingcommit` | Param: `$VpgsettingsIdentifier` |
| Remove uncommitted session | `Remove-ZertoVpgsetting` | Cleanup on failure |
| List VPGs | `Get-ZertoVPG` | Returns all VPGs on connected ZVM |

### Alternatives Considered
- Direct PATCH to VPG object: Not supported by Zerto API; settings mutations require the open/edit/commit session pattern.
- Bulk update endpoint: Does not exist in Zerto v1 API.

---

## 2. Backup File Design

### Decision
Backup file is a JSON array of per-VPG state objects, written to `E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\{yyyyMMdd-HHmmss}.json`. A backup is considered "processed" when its filename ends with `_processed.json` (rename, not copy).

### Rationale
- The spec requires a datetime-stamped file per ZVM, making the path deterministic enough for restore lookup.
- Naming the "processed" state via filename suffix (rather than a field inside the JSON) allows a simple `Test-Path` glob check to detect unprocessed backups without parsing content.
- Using rename (not delete) preserves the audit trail.

### Backup JSON Schema

```json
[
  {
    "ZVMHost": "zvm01.corp.local",
    "VpgName": "VPG-AppTier-01",
    "VpgIdentifier": "abc123",
    "JournalSizeGB": 50,
    "ScratchSizeGB": 30,
    "CapturedAt": "2026-04-12T20:45:00Z"
  }
]
```

### Alternatives Considered
- Single file for all ZVMs: Rejected. Per-ZVM isolation means a restore for one ZVM does not risk touching another ZVM's data.
- Flag field inside JSON (`"processed": true`): Rejected. Requires parsing JSON to check state; filename suffix is simpler and visible in Explorer without opening the file.

---

## 3. Consecutive Failure Circuit-Breaker

### Decision
Track consecutive failures per ZVM with a counter that resets to 0 on each successful VPG operation. If the counter reaches 3, throw a non-terminating error, log the condition, and `continue` to the next ZVM. The counter is owned by the `Invoke-JournalScratchUpdate` / `Invoke-JournalScratchRestore` module functions which return a structured result object; the reset/increment logic lives in the Controller's ZVM loop.

### Rationale
The circuit-breaker is orchestration logic (a sequencing decision), not business logic, and is therefore appropriate to implement in the Controller's loop (staying within the 10% logic density allowance for a counting variable and a threshold check). The actual VPG update work is still in the module.

### Result Object Contract

```powershell
[PSCustomObject]@{
    ZVMHost           = [string]
    VpgName           = [string]
    VpgIdentifier     = [string]
    JournalSizeGB     = [int]
    ScratchSizeGB     = [int]
    DesiredJournalGB  = [int]
    DesiredScratchGB  = [int]
    Action            = [string]   # 'Updated', 'Skipped', 'Failed', 'Restored'
    Status            = [string]   # 'Success', 'Failure'
    ErrorMessage      = [string]   # null on success
}
```

### Alternatives Considered
- Put circuit-breaker logic entirely in a module function: Would require the module function to know the ZVM loop context and maintain cross-VPG state, which is an orchestration concern, not a unit-of-work concern.

---

## 4. Size Unit Handling (GB → MB)

### Decision
The Zerto API stores `HardLimitInMB`. The script accepts GB parameters and converts: `$GB * 1024 = $MB`. Conversion is performed inside the `Invoke-JournalScratchUpdate` module function — never in the controller.

### Rationale
This is pure business logic (unit conversion + API body construction) and must live in a module per the Controller Contract.

### Alternatives Considered
- Accept MB directly in parameters: Rejected. The spec explicitly requires GB input for usability. Internal conversion is cleaner than burdening callers with MB values.

---

## 5. Restore — Multi-Backup Selection Logic

### Decision
When restoring, locate all files matching `E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\*.json` that do NOT end in `_processed.json`. If zero match → throw error. If one matches → use it. If more than one matches → select the most recently created file (by `LastWriteTime`), log a warning that multiple unprocessed backups exist.

### Rationale
The spec states "if no backup exists, throw." Selecting the most recent unprocessed backup is the safest default for the edge case. Using `LastWriteTime` is simpler than parsing datetime from the filename, though both approaches are equivalent given the filename format.

### Alternatives Considered
- Error if more than one unprocessed backup: Overly strict; a safeguard warning is more operator-friendly than a hard stop.

---

## 6. Email / CSV Distribution

### Decision
Reuse `Export-ProjectCSVReport` (from `ZertoZVM.Core`) for CSV generation. Use `InfraCode.Email` module functions (`Set-FormattedEmail` / `Send-FormattedEmail`) for email, following the pattern established in `Get-VPGJournalSettings.ps1`. CSV is attached to the email.

### Rationale
Both modules are already present and used by the reference controller. No new infrastructure is needed. The email subject line is `"Set-JournalAndScratch"` per spec.

---

## 7. Module New Functions Summary

All new public functions belong in `ZertoZVM.Core`:

| Function | Responsibility |
|----------|---------------|
| `Get-VpgJournalScratchState` | Open a VPG settings edit session, read journal and scratch current values (GB), close/commit the read (no mutation). Returns a state object. |
| `Test-JournalScratchBackupExists` | Check the backup directory for an unprocessed `.json` file for a given ZVM. Returns `$true` / `$false`. |
| `New-JournalScratchBackup` | Serialize state array to JSON and write the backup file. Returns the file path written. |
| `Invoke-JournalScratchUpdate` | Open settings edit session, set journal + scratch sizes (GB→MB conversion), commit. Returns result object. |
| `Invoke-JournalScratchRestore` | Open settings edit session for a VPG, set journal + scratch sizes from backup record, commit. Returns result object. |
| `Complete-JournalScratchBackup` | Rename the backup file to append `_processed` before the `.json` extension. |

---

## 8. All NEEDS CLARIFICATION Items: Resolved

No `[NEEDS CLARIFICATION]` markers were present in the spec. All technical decisions above represent informed defaults based on existing codebase patterns and Zerto API wrapper inspection.
