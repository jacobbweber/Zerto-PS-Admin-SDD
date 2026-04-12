

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