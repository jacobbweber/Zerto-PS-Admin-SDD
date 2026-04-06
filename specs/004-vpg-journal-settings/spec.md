# Feature Specification: Get VPG Journal Settings

**Feature Branch**: `004-vpg-journal-settings`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "Spec: Get VPG Journal Settings-script Script Name: Get-VPGJournalSettings.ps1 Inputs: Optional, ZVM, VPG, EmailTo (defaults from constitution) Business logic: User will execute the script and either supply a ZVM, VPG, or both. If No ZVM is supplied, being block will load a zvm server list from E:\source\zvmservers.txt. If no ZVM but a VPG is supplied, it will connect to the ZVMs to find the VPG and then use that ZVM to continue. Get all VPGs and then return the following: [string]VPGName: [string]VpgIdentifier: [string]ProtectedSiteName: Telemetry KPIs: script_name: vpg_count: outputs: Email, CSV, Telemetry, Doctor"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Multi-ZVM Journal Audit (Priority: P1)

As a Backup Administrator, I want to run a journal audit across all my ZVMs without manually specifying each one, so that I can ensure all VPGs across the environment are consistently configured.

**Why this priority**: Core value proposition for environmental oversight.

**Independent Test**: Can be tested by running the script without arguments and verifying it reads from `E:\source\zvmservers.txt`, connects to each, and aggregates data.

**Acceptance Scenarios**:

1. **Given** no ZVM or VPG is specified, **When** the script is executed, **Then** it loads ZVMs from `E:\source\zvmservers.txt` and processes all VPGs.
2. **Given** a list of 5 ZVMs in the text file, **When** the script runs, **Then** it produces a report containing VPGs from all 5 ZVMs.

---

### User Story 2 - Targeted VPG Journal Audit (Priority: P2)

As a Support Engineer, I want to provide a VPG name without knowing which ZVM it belongs to, so that the script can find it and report its journal settings for troubleshooting.

**Why this priority**: Essential for rapid troubleshooting when ZVM mapping is unknown.

**Independent Test**: Can be tested by providing only a VPG name and verifying the script iterates through ZVMs until it finds the match.

**Acceptance Scenarios**:

1. **Given** only a VPG name is provided, **When** the script is executed, **Then** it searches all ZVMs until the VPG is found.
2. **Given** the VPG is found on the 3rd ZVM, **When** the script finds it, **Then** it stops searching and generates the report for that specific VPG.

---

### User Story 3 - Flexible Output Reporting (Priority: P3)

As an IT Manager, I want to receive the journal settings report via Email or CSV, and for the system to record telemetry, so that I can archive reports and track automation usage.

**Why this priority**: Stakeholder reporting and operational tracking.

**Independent Test**: Can be tested by selecting specific output flags (CSV, Email, Telemetry) and verifying each target receive the data.

**Acceptance Scenarios**:

1. **Given** the CSV output is selected, **When** the script completes, **Then** a CSV file containing VPGName, VpgIdentifier, and ProtectedSiteName is saved.
2. **Given** the Telemetry output is selected, **When** the script completes, **Then** KPIs `script_name` and `vpg_count` are recorded.

---

### Edge Cases

- What happens when a ZVM in `E:\source\zvmservers.txt` is unreachable? (System should log a warning and continue to next ZVM)
- How does the system handle duplicate VPG names across different ZVMs? (System should report all matches if no ZVM was specified)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support optional `-ZVMHost`, `-VpgName`, and `-EmailTo` parameters.
- **FR-002**: System MUST default ZVM server list to `E:\source\zvmservers.txt` if `-ZVMHost` is null.
- **FR-003**: System MUST connect to each ZVM in the provided or loaded list to retrieve VPG data.
- **FR-004**: System MUST return an object/report containing `VPGName`, `VpgIdentifier`, and `ProtectedSiteName` for each VPG.
- **FR-005**: System MUST support `-CSV`, `-Email`, `-Telemetry`, and `-Doctor` output modes.
- **FR-006**: System MUST record `script_name` (Get-VPGJournalSettings) and `vpg_count` (total VPGs processed) as telemetry KPIs.
- **FR-007**: System MUST use default `$EmailTo` values from the project Constitution if not provided.

### Key Entities *(include if feature involves data)*

- **VPG Journal Record**: Represents the reporting data for a single VPG. Includes VPG name, ID, and the site it is protected on.
- **ZVM Server List**: A text file containing hostnames or IP addresses of ZVM servers to be audited.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users receive a consolidated report of all VPGs across the environment within 5 minutes for up to 10 ZVMs.
- **SC-002**: 100% of reachable ZVMs from the list are successfully processed.
- **SC-003**: Telemetry data is recorded for every successful script execution.
- **SC-004**: CSV output can be opened in standard spreadsheet software without formatting errors.

## Assumptions

- `E:\source\zvmservers.txt` is the authoritative source for the environment's ZVM list.
- The project Constitution provides the standard email configuration and telemetry endpoint details.
- The script will run in an environment where Zerto API connectivity is established as per `ZertoZVM.APIWrapper` standards.
- "Doctor" output refers to a diagnostic/validation check (Assumption: used for health checks).
