# Feature Specification: ZertoZVM.Core (Utility & Logic Hub)

**Feature Branch**: `002-zvm-core`  
**Created**: 2026-04-05  
**Status**: Draft  

## Clarifications

### Session 2026-04-05
- Q: How should `Write-Log` handle catastrophic failure when writing to a log file? → A: Terminate Execution (Option A)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Environment Bootstrapping (Priority: P1)

The system needs to load project configuration automatically during startup so that all other functions have access to required environmental variables (like logging paths and authentication paths).

**Why this priority**: Without parsing and validating the configuration file (`config.json`), the entire module cannot safely operate or log actions.

**Independent Test**: Can be tested independently by providing a mock JSON configuration and verifying the global state has been successfully populated and appropriately validated.

**Acceptance Scenarios**:

1. **Given** a valid configuration JSON file, **When** the initialization command is called, **Then** the global configuration state is successfully populated with the file contents.
2. **Given** a missing or invalid JSON configuration file, **When** the initialization command is called, **Then** the process safely terminates with a clear error preventing unstable execution.
3. **Given** a populated configuration object, **When** validation is run and all target directories exist (or parent directories for file paths), **Then** the validation passes and allows execution to proceed.
4. **Given** a populated configuration object with an invalid or inaccessible directory path, **When** validation is run, **Then** the process terminates with an error identifying the specific missing resource.

---

### User Story 2 - Dual-Stream Logging (Priority: P2)

The system needs a thread-safe method to emit logs simultaneously to a developer debug file and an audit syslog-style file to support robust troubleshooting and security auditing.

**Why this priority**: Required for compliance with Constitution Section 4, enabling trace-ability of system actions and errors.

**Independent Test**: Can be tested independently by generating logs at various levels and observing that they are correctly written to the respective files without file locking issues.

**Acceptance Scenarios**:

1. **Given** a logging command at the 'Debug' level, **When** the log is generated, **Then** the entry appears in the developer log file but is EXCLUDED from the security audit log file.
2. **Given** a logging command at the 'Info', 'Warn', or 'Error' level, **When** the log is generated, **Then** the entry appears in BOTH the developer log file and the security audit log file.
3. **Given** multiple concurrent logging actions, **When** the logs are written, **Then** no file locking errors occur and all messages are recorded with accurate timestamps.

### Edge Cases

- What happens when the logging target directory doesn't have sufficient write permissions? (Resolved: The process will throw a terminating error and halt execution immediately.)
- How does the system handle parallel execution scenarios where multiple runspaces invoke the logger at the exact same millisecond?
- What occurs if the provided configuration object does not match the mandatory schema defined in Constitution Section 3?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide automatic bootstrapping of the project configuration from a defined location (defaulting to `.\config.json`).
- **FR-002**: System MUST convert the JSON configuration into a globally accessible container object.
- **FR-003**: System MUST validate the environmental integrity of the configuration by verifying all directory/folder paths defined in the config are accessible. For file paths, verifying only that the parent directory exists is sufficient before processing.
- **FR-004**: System MUST implement a unified, thread-safe logging mechanism for concurrent execution contexts.
- **FR-005**: System MUST support distinct log levels (`Info`, `Warn`, `Error`, `Debug`).
- **FR-006**: System MUST maintain dual log streams: a Developer Stream containing all log levels, and an Audit Stream containing only `Info`, `Warn`, and `Error`.
- **FR-007**: System MUST prefix every log entry with a standardized timestamp in `[yyyy-MM-dd HH:mm:ss]` format along with the configured severity `[LEVEL]`.
- **FR-008**: System MUST throw a terminating error resulting in execution halt if `Write-Log` encounters an unrecoverable failure (e.g. absent write permissions) when attempting to output log data.

### Architectural Constraints

- **AR-001**: Implementation MUST adhere to Constitution Section 2 (Architectural Integrity).
- **AR-002**: Module structure MUST follow standard partitioning with public commands in `public/` and internal logic in `private/`.

### Key Entities 

- **Global Configuration Object**: Represents the parsed environmental and operational parameters that guide the lifespan of a session.
- **Log Streams**: The representation of sequenced execution records split functionally between debug trace requirements and broad audit requirements.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Quality testing verifies configuration load state achieves 100% test coverage against mock inputs.
- **SC-002**: Thread-safe logging mechanism allows rapid parallel writing from multiple concurrent runspaces without file locking IO collisions.
- **SC-003**: Log files are successfully generated displaying accurately segregated streams (debug vs standard operations).
- **SC-004**: Test environment configuration precisely raises deliberate exceptions when presented with intentionally malformed or non-existent filesystem paths.

## Assumptions

- Operating context possesses necessary file system write-permissions for logging directories.
- Pester 5 testing framework is the standard constraint framework for acceptance metrics.
- Execution occurs within single PowerShell Host Process session architecture avoiding complex cross-process mutexes.
