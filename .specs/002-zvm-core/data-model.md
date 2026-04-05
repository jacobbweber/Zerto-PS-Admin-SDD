# Data Model: ZertoZVM.Core

## Entities

### `ProjectConfig`
Global configuration object (`$Global:Config`) parsed from JSON.

**Required Paths (per schema):**
- `base.logging.paths.logdir` (String - Directory)
- `base.logging.paths.archive` (String - Directory)
- `base.logging.paths.state` (String - Directory)
- `base.logging.paths.telemetry` (String - Directory)
- `base.logging.paths.syslog` (String - File name)
- `base.logging.paths.devlog` (String - File name)

**Other Contexts Expected (un-validated deeply within Core, except simple existence):**
- `base.auth.vmware_user`
- `base.telemetry`

### `LogStreamEvent`
Conceptual object representing a single log pipeline entry.

- `Timestamp`: `[datetime]` - Formatted out to `yyyy-MM-dd HH:mm:ss`.
- `Level`: `[string]` - `Info`, `Warn`, `Error`, or `Debug`.
- `Message`: `[string]` - Primary event information.
