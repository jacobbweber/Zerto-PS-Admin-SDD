# Contract: Output Shapes — CSV, Doctor, Email, Return Object

**Version**: 1.0.0
**Authority**: ZAF Constitution §VI.3, §XI
**Status**: Canonical

---

## Overview

Every controller produces up to four output channels, all driven by switches and completion actions defined in the intake form. This contract defines the exact format for each channel.

| Output Channel | Triggered By | Destination | Section |
|---|---|---|---|
| **CSV Report** | `-CSV` switch | File on disk | §1 |
| **Doctor Output** | `-Doctor` switch | stdout (console) | §2 |
| **Email** | `-Email` switch | SMTP → recipient | §3 |
| **Return Object** | Always (last statement) | PowerShell pipeline | §4 |

---

## §1 — CSV Report

### Format

- File format: UTF-8 CSV with a **header row**.
- Delimiter: Comma (`,`).
- Quotes: Applied per `ConvertTo-Csv` defaults (string fields quoted, numerics unquoted).
- No BOM (use `-Encoding UTF8NoBOM`).
- No trailing blank line.

### Path Resolution

```powershell
[string]$CsvPath = Join-Path -Path $ZertoContext.Config.Logging.LogDir -ChildPath "$($ZertoContext.Meta.ScriptName).csv"
```

The path is derived from `$ZertoContext.Config.Logging.LogDir` (from `config.json`). The filename is the script name without `.ps1`.

### Column Definition

Columns are explicitly defined per controller. They MUST match exactly the `Columns` list in the intake form's `Submit CSV Report` completion action.

```powershell
# Intake form: "Columns: VM_Count, Provisioning_Time_Seconds"
# Generated End block:
Export-ProjectCSVReport @{
    Results  = $ZertoContext.Results
    Columns  = @('VM_Count', 'Provisioning_Time_Seconds')
    Path     = $CsvPath
}
```

### `Export-ProjectCSVReport` Signature (ZertoZVM.Core)

```powershell
function Export-ProjectCSVReport {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[PSObject]]$Results,

        [Parameter(Mandatory = $true)]
        [string[]]$Columns,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )
}
```

---

## §2 — Doctor Output

Doctor output is a **headerless, quote-stripped CSV** written to **stdout only** (not to a log file).

### Rules

1. No header row — the first line is data.
2. No surrounding double-quotes on field values.
3. Comma-delimited, no trailing comma.
4. Exactly the fields specified in the intake form's `Submit Doctor → Return Object Output` list.
5. Written via `Write-Output` (pipeline output), NOT `Write-Host`.
6. MUST be the **final stdout emission** before `return $ZertoContext.Results`.

### Canonical Implementation

```powershell
if ($Doctor) {
    $ZertoContext.Results |
        Select-Object -Property @('VM_Count', 'Provisioning_Time_Seconds') |
        ConvertTo-Csv -NoTypeInformation |
        Select-Object -Skip 1 |
        ForEach-Object {
            $_ -replace '^"', '' -replace '"$', '' -replace '","', ','
        }
}
```

### Example Output (no quotes, no header)

```
12,47.832
```

### Doctor Destination

Per intake form `Submit Doctor → Destination`, the output path is informational for the **caller** only. The controller always writes to stdout. Destination redirection is the caller's responsibility:

```powershell
.\Get-ZertoVPGs.ps1 -Doctor > C:\Logs\Zerto\zvm_debug.log
```

---

## §3 — Email

### Composition Pattern

The Email output is a two-step process:

**Step 1: Compose HTML body** via `ZertoZVM.Email`:

```powershell
[string]$HtmlBody = Set-FormattedEmail @{
    Results = $ZertoContext.Results
    Title   = 'Zerto VPG Provisioning Report'
    Columns = @('VM_Count', 'Provisioning_Time_Seconds')
}
```

**Step 2: Send via SMTP** via `ZertoZVM.Email`:

```powershell
Send-FormattedEmail @{
    HtmlBody    = $HtmlBody
    To          = $Recipient           # From $EmailTo param or $ZertoContext.Config.Email.DefaultTo
    Subject     = "Zerto Report — $($ZertoContext.Meta.ScriptName) — $(Get-Date -Format 'yyyy-MM-dd')"
    SmtpServer  = $ZertoContext.Config.Email.SmtpServer
    Attachments = if ($CSV) { @($CsvPath) } else { @() }  # Attach CSV if both -CSV and -Email
}
```

### Recipient Resolution

```powershell
[string]$Recipient = if ($EmailTo) { $EmailTo } else { $ZertoContext.Config.Email.DefaultTo }
```

### CSV Attachment Rule

If both `-Email` and `-CSV` switches are active, the CSV file MUST be attached to the email. If only `-Email` is active (no `-CSV`), no attachment.

```markdown
# Intake form "Submit Email → Attach the CSV Report" means both -Email and -CSV switches activate CSV attachment.
```

### HTML Body Contract (`Set-FormattedEmail`)

The HTML body MUST:
- Be valid HTML5.
- Include a summary table matching the specified columns.
- Include a header row.
- Include the script name and run timestamp in the email title/header.
- Be styled minimally (inline CSS only, no external stylesheets).

---

## §4 — Return Object

Every controller MUST return `$ZertoContext.Results` as its **pipeline output** (last statement in End block). This enables PowerShell pipeline chaining:

```powershell
# End block — always the last line
return $ZertoContext.Results
```

### Return Object Schema

The return object is `[System.Collections.Generic.List[PSObject]]`. Each element is a `[PSCustomObject]` with controller-specific properties. The properties MUST be a superset of the Doctor output fields and the CSV columns.

### Type Consistency Rule

All property values MUST be typed consistently across all objects in the list. Do not mix `[int]` and `[string]` for the same property across objects.

```powershell
# Correct — consistent types
[PSCustomObject]@{
    VM_Count                  = [int]12
    Provisioning_Time_Seconds = [double]47.832
    ZVMHost                   = [string]'zvm01.domain.com'
    VPGName                   = [string]'PROD-DR-VPG-01'
}
```

---

## Output Switch Interaction Matrix

| `-CSV` | `-Email` | `-Doctor` | `-Telemetry` | Behavior |
|:---:|:---:|:---:|:---:|---|
| ✅ | | | | CSV file written to LogDir |
| | ✅ | | | HTML email sent; no attachment |
| ✅ | ✅ | | | CSV written, then attached to email |
| | | ✅ | | Headerless CSV to stdout |
| | | | ✅ | KPIs submitted to Dynatrace |
| ✅ | ✅ | ✅ | ✅ | All channels active; CSV attached to email |

All channels are **independent** — any combination is valid.

---

*Contract: output-contract.md — ZAF Constitution §VI.3, §XI*
