## TL;DR
The **Doctor Contract** standardizes machine-readable output for integration with external automation. It requires a headerless, quote-stripped, comma-delimited CSV format triggered by a `-Doctor` bool, ensuring consistency across the entire project suite.

---

# Doctor Contract

## I. Intent
The "Doctor" pattern provides a lightweight, standardized output stream for high-speed parsing by third-party systems or intake forms. While standard execution returns rich PowerShell objects, the Doctor bool flattens specific results into a "clean" CSV string.

## II. Implementation Requirements

### II.1 Parameter Declaration
Every Controller MUST include a non-mandatory bool parameter named `Doctor`.
```powershell
[Parameter(Mandatory = $false)]
[bool]$Doctor = $true
```

### II.2 Data Formatting Rules
When the `$Doctor` bool is present (default true), the output MUST adhere to the following strict formatting rules:
- **No Headers**: The output MUST NOT contain column headers.
- **Quote Stripping**: All double quotes (`"`) MUST be removed from the final string.
- **Standard Delimiter**: Columns MUST be separated by a comma (`,`).
- **Array Flattening**: If a cell contains an array or list, the internal values MUST be joined with a semicolon (`;`) to prevent CSV breakage.
- **Standard Output**: The results MUST be emitted to the standard output stream (`stdout`) as the final action of the script.

---

## III. Implementation Pattern

This logic should be placed at the end of the Controller script, replacing the standard object return.

```powershell
# Phase 3: Finalization & Output
if ($Doctor) {
    # 1. Select only the fields required by the Intake Form/Consumer
    # 2. Convert to CSV and strip headers/quotes
    # 3. Handle array flattening for nested data
    $Results | ForEach-Object {
        $Object = $_
        # Flatten arrays within the object if necessary
        # Example: $Object.Tags = $Object.Tags -join ';'
        $Object
    } | Select-Object -Property 'ID', 'Status', 'Message' | 
        ConvertTo-Csv -NoTypeInformation | 
        Select-Object -Skip 1 | 
        ForEach-Object { 
            $_ -replace '^"', '' -replace '"$', '' -replace '","', ',' 
        }
}
else {
    # Standard return for interactive/PowerShell users
    return $Results
}
```

## IV. Compliance Summary
| Requirement | Standard |
| :--- | :--- |
| **Trigger** | `-Doctor` bool |
| **Content** | Headerless CSV |
| **Cleaning** | No quotes, comma-delimited |
| **Arrays** | Joined with `;` |
| **Position** | Final emission of the script |