

# Logging Contract

## I. Intent
To ensure every Controller script provides consistent and searchable audit trails across all local logs. By mandating a specific string interpolation format (`key=value`), we ensure that even flat text logs remain easily searchable for specific identifiers and variables.

## II. The `Write-Log` Specification

Controllers MUST NOT use native PowerShell output cmdlets for status updates. All events MUST be passed to `Write-Log` using the following parameters:

* **`-Level`**: Must be one of `Info`, `Warn`, `Error`, or `Debug`.
* **`-Message`**: The string payload. 
* **`-LogPath`**: The explicit directory or file path where the log will be written.

---

## III. Strict Formatting Rule: Key=Value
To maintain searchability, any message that references a variable, property, or specific item identifier MUST follow the **key=value** format inside the message string.

* **Rule**: Identify the attribute name, followed by an equals sign, followed by the value.
* **Correct**: `"The VPG to delete was vpgname=$vpgNameValue"`
* **Incorrect**: `"The VPG to delete was $vpgNameValue"` or `"VPG: $vpgNameValue"`

> **Mandate**: Use the `=` sign as the primary delimiter for all data points embedded in messages.

---

## IV. Dual-Stream Strategy
The logging module MUST concurrently maintain two files within the specified `-LogPath`:

1.  **Developer (`*_full.log`)**: Captures all levels including `Debug`. Contains verbose technical details for troubleshooting.
2.  **System (`*_minimal.log`)**: Captures `Info`, `Warn`, and `Error`. Provides a high-level audit trail of script actions.

---

## V. Operational Logic

### V.1 Simulation Mode (`-WhatIf`)
When a script is executed with the `-WhatIf` switch, `Write-Log` MUST prepend the message with `[SIMULATION]`. 
* **Example**: `[SIMULATION] Info: VPG deleted successfully where vpgname=Zerto_App_01`

### V.2 Line Integrity
Multi-line messages are forbidden to ensure log parsers do not break. If a complex object must be logged, it should be flattened or serialized into a single-line string using the key=value format for its primary properties.

---

## VI. Implementation Example

```powershell
# Standard Information Log with key=value pair
Write-Log -Level 'Info' -LogPath $LogPath -Message "Started processing for customer=$CustomerName"

# Error Log following the equality format
try {
    # Functional logic...
} catch {
    Write-Log -Level 'Error' -LogPath $LogPath -Message "Critical failure during step=VpgDeletion with error=$($_.Exception.Message)"
    throw
}
```

## I. PSD1 Schema Structure

This mapping file provides the "blueprint" for the project's filesystem. It uses placeholders that the initialization function resolves at runtime.

The `.\src\config\project-directories.psd1` schema defines a centralized path authority. The `Initialize-ProjectDirectories` function uses this map to enforce the directory structure, ensure folder existence, and execute the archival/rotation logic by moving existing data into a timestamped archive.

- **Log Retention & Rotation**: Logs must be rotated into an `\archive\[date]\` directory. Retention policy dictates logs are pruned if they exceed 30 days in age or 1GB in total size.


```powershell
@{
    # Root paths for logical separation
    'Paths' = @{
        'State'     = 'E:\Scripts\log\changestate\{scriptname}\state'
        'Backup'    = 'E:\Scripts\log\changestate\{scriptname}\backup'
        'Logs'      = 'E:\Scripts\log\{scriptname}\logs'
        'Telemetry' = 'E:\Scripts\log\{scriptname}\telemetry'
        'Archive'   = 'E:\temp\{scriptname}\archive'
        'Report'    = 'E:\temp\{scriptname}\report'
    }

    # Definition of what gets rotated/archived
    'RotationPolicy' = @(
        'Logs',
        'Telemetry',
        'Report',
        'State',
        'Backup'
    )
}
```

---

## II. Initialization Logic Workflow

The `Initialize-ProjectDirectories` function (housed in `InfraCode.Utilities`) MUST perform the following steps in order:

### 1. Resolution
Replace the `{scriptname}` token in all paths with the actual calling script name.

### 2. Rotation & Archival
Before creating new directories for the current session:
* Check if files exist in the **Logs**, **Telemetry**, or **Report** paths.
* If files exist, create a timestamped archive folder: `E:\temp\{scriptname}\archive\{yyyyMMdd-HHmmss}\`.
* **Move** (EXCEPT for State and Backup, only COPY those) the contents of the target directories into a mirrored structure under the archive path.
    * *Example*: `E:\Scripts\log\{scriptname}\logs\*` moves to `E:\temp\{scriptname}\archive\{datetime}\logs\*`.

### 3. Creation
Ensure all directories in the `Paths` table exist using `New-Item -ItemType Directory -Force`.

---

## III. Key Path Definitions

| Path Key | Logic / Purpose |
| :--- | :--- |
| **State** | Stores persistent metadata/JSON tracking files for current operations. |
| **Backup** | Stores original VPG/ZVM configurations before modification. |
| **Logs** | Destination for `Write-Log` (Full and Minimal). |
| **Telemetry** | Destination for the local JSON telemetry backup. |
| **Archive** | The long-term repository for previous execution data. |
| **Report** | Destination for CSV or HTML reports generated in the script. |

---

## IV. Implementation Mandate
* **Zero-Fail**: If the function cannot create a directory (e.g., Permissions), it MUST `throw` immediately.
* **Cleanup**: Validatino MUST be performed to ensure the current path references the script name as a sanity gate to ensure retention is only happening under the archive directory.
* **Token Consistency**: Only `{scriptname}` and `{datetime}` are valid tokens for this resolution logic.