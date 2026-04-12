# Feature Specification: Set-JournalAndScratch

**Feature Branch**: `001-set-journal-scratch`  
**Created**: 2026-04-12  
**Status**: Draft  
**Input**: User description: "Update journal and scratch disk sizes for all VPGs on a ZVM to a value passed in as a parameter, with restore capability and backup/state management."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Apply New Journal and Scratch Sizes (Priority: P1)

An operations engineer runs the script targeting one or more ZVMs and provides desired journal and scratch sizes in GB. The script discovers all VPGs (or a filtered subset), inspects their current sizes, creates a backup of the current state, and updates any VPG whose sizes differ from the desired values. A CSV report, email notification, telemetry, and Doctor output are produced on completion.

**Why this priority**: This is the primary use case — the reason the script exists. All other stories depend on the data structures this flow produces.

**Independent Test**: Can be fully tested by running the script with `-JournalSizeGB` and `-ScratchSizeGB` against a ZVM that has at least one VPG and verifying that a backup file is created, sizes are updated, and a CSV/email/telemetry output is produced.

**Acceptance Scenarios**:

1. **Given** a ZVM with multiple VPGs whose journal/scratch sizes differ from the desired values, **When** the script is run with valid `-JournalSizeGB` and `-ScratchSizeGB` parameters, **Then** all VPGs are updated to the new sizes, a dated backup JSON is written to `E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\{datetime}.json`, and results are reported via CSV, email, telemetry, and Doctor.
2. **Given** a ZVM whose VPGs already match the desired sizes, **When** the script is run, **Then** no updates are applied but a backup is still created and reporting is produced.
3. **Given** a ZVM with an existing (unprocessed) backup file, **When** the script is run in apply mode, **Then** the script throws an error and does not process that ZVM.
4. **Given** the `-VpgName` filter is supplied with one or more names, **When** the script runs, **Then** only the specified VPGs are evaluated and updated; all others are skipped.

---

### User Story 2 - Restore Journal and Scratch Sizes from Backup (Priority: P2)

An operations engineer runs the script with the `-Restore` switch after a previous apply run. The script reads the backup JSON file for the targeted ZVM, restores each VPG's journal and scratch sizes to the values recorded at backup time, and marks the backup file as processed by appending a `_processed` tag to its filename.

**Why this priority**: The restore path is the safety net for the apply path. Without it, operators cannot roll back changes, making the apply path risky in production.

**Independent Test**: Can be fully tested by first running a successful apply run (creating a backup), then running with `-Restore` and verifying that VPG sizes return to original values, the backup file is renamed with a `_processed` suffix, and reporting is produced.

**Acceptance Scenarios**:

1. **Given** a ZVM with an existing unprocessed backup JSON file, **When** the script is run with `-Restore`, **Then** each VPG's journal and scratch sizes are set back to the values in the backup, and the backup file is renamed to append `_processed` to its base name.
2. **Given** a ZVM with no backup file, **When** the script is run with `-Restore`, **Then** the script throws an informative error and takes no action on that ZVM.
3. **Given** a ZVM with a backup file already marked `_processed`, **When** the script is run with `-Restore`, **Then** the script throws an error indicating the backup has already been used and does not re-apply.

---

### User Story 3 - Multi-ZVM Execution with Partial Failure Tolerance (Priority: P3)

An operations engineer runs the script without specifying a ZVM host, causing it to read the ZVM list from `zvmservers.txt` and iterate over every ZVM. If one ZVM fails entirely, execution continues to the next ZVM. If three or more VPGs fail consecutively within a ZVM, that ZVM is aborted and the next ZVM is processed.

**Why this priority**: Multi-ZVM resilience is needed for fleet-scale operations but is a composable extension of the single-ZVM flow.

**Independent Test**: Can be fully tested by simulating multiple ZVMs (including one that fails to connect) and verifying that the script processes the reachable ones, logs the failures, and still produces a complete report.

**Acceptance Scenarios**:

1. **Given** multiple ZVMs in `zvmservers.txt` where one is unreachable, **When** the script runs without `-ZVMHost`, **Then** the unreachable ZVM is logged as failed and all reachable ZVMs are processed.
2. **Given** a ZVM where 3 or more VPGs fail consecutively during update, **When** the script processes that ZVM, **Then** processing for that ZVM stops, the failure is logged, and the script continues to the next ZVM.
3. **Given** a specific ZVM passed via `-ZVMHost`, **When** the script runs, **Then** only that single ZVM is processed regardless of `zvmservers.txt`.

---

### Edge Cases

- What happens when `zvmservers.txt` is missing or empty and `-ZVMHost` is not provided?
- What happens when the backup directory path (`E:\scripts\log\...`) does not exist — is it created automatically?
- What happens when a VPG exists in the backup file but no longer exists on the ZVM at restore time?
- What happens when both `-JournalSizeGB`/`-ScratchSizeGB` and `-Restore` are supplied simultaneously?
- What happens when a VPG update is submitted but the ZVM reports a failure response?
- What happens when the `-VpgName` filter includes a name that does not exist on the ZVM?

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST accept `-ZVMHost` as an optional parameter; when omitted, it MUST read ZVM targets from `zvmservers.txt`.
- **FR-002**: The system MUST accept `-VpgName` as an optional array parameter to limit processing to one or more named VPGs; when omitted, all VPGs on the ZVM are processed.
- **FR-003**: The system MUST accept `-JournalSizeGB` (integer, required) representing the desired journal disk size in gigabytes.
- **FR-004**: The system MUST accept `-ScratchSizeGB` (integer, required) representing the desired scratch disk size in gigabytes.
- **FR-005**: The system MUST accept a `-Restore` switch that, when present, activates restore mode instead of apply mode.
- **FR-006**: In apply mode, the system MUST check whether an unprocessed backup file already exists for a ZVM; if one exists, it MUST throw an error and skip that ZVM without making any changes.
- **FR-007**: In apply mode, the system MUST write a backup JSON file recording the current journal and scratch sizes for all targeted VPGs before applying any changes. The file MUST be written to `E:\scripts\log\Set-JournalAndScratch\backup\{zvmname}\{datetime}.json`.
- **FR-008**: In apply mode, the system MUST compare current VPG sizes with desired sizes and update only VPGs where at least one size differs.
- **FR-009**: In restore mode, the system MUST locate the most recent unprocessed backup file for the targeted ZVM, restore each VPG's journal and scratch sizes to the backed-up values, and rename the backup file to append a `_processed` tag.
- **FR-010**: In restore mode, if no valid unprocessed backup file exists for a ZVM, the system MUST throw an informative error and take no restorative action.
- **FR-011**: The system MUST process each ZVM independently; a failure on one ZVM MUST NOT prevent processing of remaining ZVMs.
- **FR-012**: The system MUST process each VPG independently within a ZVM; a failure on one VPG MUST NOT prevent processing of remaining VPGs.
- **FR-013**: If 3 or more VPGs fail consecutively during processing within a single ZVM, the system MUST stop processing that ZVM, log the consecutive failure condition, and continue to the next ZVM.
- **FR-014**: The system MUST emit telemetry KPIs: `vpgs_processed`, `vpgs_updated`, `vpgs_failed`, `desired_journal_size_gb`, and `desired_scratch_size_gb`.
- **FR-015**: The system MUST produce a CSV report with columns: ZVM, VPG, journal size, scratch size, vpgs_processed, vpgs_updated, vpgs_failed, desired journal size, desired scratch size.
- **FR-016**: The system MUST send an email notification with the subject "Set-JournalAndScratch" and attach the CSV report.
- **FR-017**: The system MUST submit a Doctor output containing: ZVM, VPG, journal size, scratch size, vpgs_processed, vpgs_updated, and vpgs_failed.
- **FR-018**: All failures (VPG-level and ZVM-level) MUST be logged for auditability.

### Key Entities

- **ZVM (Zerto Virtual Manager)**: A management host that controls one or more VPGs. Identified by hostname. Sourced from `-ZVMHost` parameter or `zvmservers.txt`.
- **VPG (Virtual Protection Group)**: A named group of VMs protected by Zerto on a ZVM. Has configurable journal and scratch disk sizes (in GB).
- **Backup File**: A JSON document recording the pre-change journal and scratch sizes for all targeted VPGs on a ZVM, stored at a deterministic path with a datetime stamp. Has two states: unprocessed and processed (indicated by `_processed` filename suffix).
- **Run Report**: An aggregated result including per-VPG outcomes and summary KPI counts (processed, updated, failed), distributed via CSV, email, telemetry, and Doctor.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All targeted VPGs on all reachable ZVMs have their journal and scratch sizes updated to the desired values within a single script execution, with zero manual follow-up required for successful VPGs.
- **SC-002**: A backup file is always present on disk before any VPG modification is attempted, ensuring every apply run is reversible.
- **SC-003**: A restore run completes with 100% of VPGs in the backup returned to their original sizes, and the backup file is marked as processed so it cannot be accidentally re-applied.
- **SC-004**: When 3 or more consecutive VPG failures occur within a ZVM, no further VPGs on that ZVM are attempted, preventing a cascade of failures from consuming execution time.
- **SC-005**: A complete CSV report, email notification, telemetry submission, and Doctor output are produced at the end of every execution, regardless of partial failures.
- **SC-006**: An operator attempting to apply changes to a ZVM that already has an unprocessed backup receives a clear error and no changes are made to that ZVM.

---

## Assumptions

- The script runs in an environment where `zvmservers.txt` is accessible at the project-standard location when `-ZVMHost` is not provided.
- The backup directory `E:\scripts\log\Set-JournalAndScratch\backup\` is either pre-existing or will be created by the script at runtime.
- Journal and scratch size values in the backup file are stored as integers in GB, matching the same unit expected by the ZVM API.
- A backup file is considered "unprocessed" if its filename does NOT contain the `_processed` tag; it is considered "processed" once renamed.
- In restore mode, if multiple unprocessed backup files exist for the same ZVM (e.g., due to manual intervention), the most recently created file is used.
- The `-JournalSizeGB` and `-ScratchSizeGB` parameters are mutually exclusive with `-Restore` at the functional level; supplying both simultaneously results in an error.
- The script follows the existing project controller pattern (Plan/Apply, telemetry contract, CSV/email/Doctor distribution) consistent with the project Constitution.
- ZVM connectivity and authentication are handled by the existing shared modules; this script does not implement its own auth logic.
