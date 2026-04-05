# Feature Specification: Global Environment Configuration

**Feature Branch**: `003-project-config`  
**Created**: 2026-04-05  
**Status**: Draft  

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configure Runtime Environment (Priority: P1)

As a Zerto automation administrator, I need a centralized `config.json` file at the root of the project to bootstrap the execution environment with all absolute paths and environment configuration, so that my orchestration scripts behave consistently across differing environments (Dev/Prod).

**Why this priority**: Essential requirement mapped directly to Constitution Section 3, forming the foundational state for the module to connect to platforms and log execution.

**Independent Test**: Can be independently tested by defining a configuration file, calling `Initialize-ProjectConfig`, and validating `$Config` mirrors the file payload.

**Acceptance Scenarios**:

1. **Given** a valid `config.json` at project root, **When** `Initialize-ProjectConfig` is called, **Then** a global `$Config` object is correctly populated.
2. **Given** an invalid `config.json` schema, **When** `Initialize-ProjectConfig` is run, **Then** it throws a terminating error.

---

### User Story 2 - Pre-Flight Configuration Validation (Priority: P1)

As a PowerShell function running in the pipeline, I need to ensure all paths dynamically referenced from `$Config.base.logging.paths` really exist before proceeding to the `Process` block, so that the script doesn't fail midway due to a missing log directory.

**Why this priority**: Ensures clean failure modes during script execution. Core constitutional compliance requirement.

**Independent Test**: Can be fully tested by creating mock directories, supplying their paths in the config JSON, and observing if `Test-ProjectConfig` succeeds or fails depending on whether the directory exists.

**Acceptance Scenarios**:

1. **Given** all logging and data paths exist on the local file system, **When** `Test-ProjectConfig` is called, **Then** it returns true or proceeds without error.
2. **Given** one or more missing paths, **When** `Test-ProjectConfig` is called, **Then** it halts execution, warning which paths are invalid.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support a JSON-based (`config.json`) bootstrap file encoded in UTF-8 without BOM.
- **FR-002**: System MUST load configuration by default from project root, or via `-ConfigPath` parameter.
- **FR-003**: System MUST require `base.logging.paths` containing lowercase keys for `logdir`, `archive`, and `state`.
- **FR-004**: System MUST require `base.telemetry` describing hostname, username, and business_unit.
- **FR-005**: System MUST require `base.auth` paths to encrypted AES files (`vmware_user`, `vmware_password`). Plain-text unencrypted passwords MUST NOT be stored within `config.json`.
- **FR-006**: System MUST export an `Initialize-ProjectConfig` function to parse the `config.json` file securely into memory.
- **FR-007**: System MUST export a `Test-ProjectConfig` function to validate all external dependencies (log directories/files) exist before pipeline execution starts.

### Key Entities 

- **Config Object (`$Config`)**: A PowerShell object representation of the `config.json` tree, representing `base.logging`, `base.telemetry`, `base.auth`, `base.email`, and `base.env`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All defined local directory paths are validated for existence by `Test-ProjectConfig` before script execution.
- **SC-002**: Configuration schema is 100% compliant with Constitution Section 3.
- **SC-003**: `Initialize-ProjectConfig` consistently parses `config.json` into `$Config`.
- **SC-004**: Passwords or secrets are fully decrypted dynamically, never stored plain-text in JSON keys.

## Assumptions

- Target servers have permissions to read `config.json`.
- Administrative vault files referenced in `base.auth` have already been generated and encrypted properly by the administrator.
