# ZAF Intake Form — Spec Template

**Instructions for the Author**:
> This form is your contract with the Zerto Automation Factory. Fill it out in plain language.
> The AI will map your responses to the correct modules, functions, and code patterns.
> Sections marked `[REQUIRED]` must be completed. `[OPTIONAL]` sections can be removed if not applicable.
> Check boxes using `[X]`. Leave unchecked with `[ ]`.

---

# Spec: {Controller-Name}

> [REQUIRED] Replace `{Controller-Name}` with the PowerShell `Verb-Noun` name of the script.
> Examples: `Get-ZertoVPGReport`, `New-ZertoVPGFromSnow`, `Set-VPGJournalPolicy`

**Goal**: {One sentence describing what this controller accomplishes and why it exists.}

> Example: "Automate VPG creation based on a ServiceNow Request, reducing manual provisioning time and human error."

---

## Integrations

> [REQUIRED] Check all that apply. These drive module imports and function calls in the generated controller.

- [ ] ServiceNow (specify actions below): `{Action: e.g., Close Task, Update CMDB}`
- [ ] Credentials: `{Logical Account Name from credentialmappaths.psd1, e.g., Zerto_Service_Account}`
- [ ] Email Notification
- [ ] Splunk Logging (structured JSON events)
- [ ] Dynatrace Telemetry (KPIs)

---

## Telemetry & KPIs

> [OPTIONAL] Remove this section if no telemetry is needed.
> KPI names MUST follow the naming convention in `contracts/kpi-contract.md`.
> Use names from the Standard KPI Catalog when possible. Add custom KPIs below the catalog names.

**KPIs to Collect**:

- KPI: `{KPI_Name}` — {brief description of what this measures}

> Examples:
> - KPI: `VM_Count` — Number of VMs included in the created VPG
> - KPI: `Provisioning_Time_Seconds` — Wall-clock time from start to VPG creation

**Destination**: `{Dynatrace | None}`

---

## Orchestration (The Steps)

> [REQUIRED] List every step the script must perform in execution order.
> Use the verbs from the Module Mapping Matrix (Constitution §III.1):
>   GET, LIST, CHECK, VERIFY, VALIDATE, CREATE, UPDATE, DELETE, CONNECT, DISCONNECT,
>   AUTHENTICATE, LOG, REPORT, SUBMIT SNOW, NOTIFY, SUBMIT TELEMETRY
>
> Each step maps to a specific module. Be explicit about WHAT resource is involved.
> If a step is conditional, describe the condition in parentheses.

1. `{VERB}` {resource/action description}.
   > Example: `GET` VPG details from the ServiceNow Ticket provided in `$Args`.

2. `{VERB}` {resource/action description}.
   > Example: `CHECK` if the Target ZVM is reachable.

3. `{VERB}` {resource/action description}.
   > Example: `VALIDATE` vCenter resource availability.

4. `{VERB}` {resource/action description}.
   > Example: `CREATE` the VPG using the validated parameters.

5. `{IF {condition}, VERB}` {resource/action description}.
   > Example: IF successful, `UPDATE` the ServiceNow CMDB record and LOG success to Splunk.

> Add as many steps as needed. Be specific — vague steps produce vague code.

---

## Input Parameters

> [REQUIRED] List the parameters this controller needs from the caller.
> For each parameter specify: Name, Type, Required?, Description.
> The ZAF will always add: -CSV, -Email, -Doctor, -Telemetry, -Simulation, -WhatIf, -Credential.
> Only list DOMAIN-SPECIFIC parameters here.

| Parameter | Type | Required? | Default | Description |
|---|---|---|---|---|
| `{ParameterName}` | `{[string]\|[int]\|[switch]}` | Yes/No | `{default or N/A}` | {What this parameter controls} |

> Examples:
> | `ZVMHost`  | `[string]` | No  | *(read from zvmservers.txt)* | Specific ZVM to target |
> | `VpgName`  | `[string]` | No  | N/A | Limit audit to a single VPG name |
> | `SnowTicket` | `[string]` | Yes | N/A | ServiceNow ticket number (e.g., REQ0012345) |
> | `EmailTo`  | `[string]` | No  | *(from config.json)* | Override default email recipient |

---

## Script Completion

> [REQUIRED] Check all output channels this controller must produce at the end of its run.

- [ ] Submit Telemetry
- [ ] Submit CSV Report
- [ ] Submit Email
- [ ] Submit Doctor

---

## Completion Details

> [REQUIRED for each checked item above] Fill in the details for each checked completion action.
> Remove subsections for unchecked items.

### Submit Telemetry

- KPI: `{KPI_Name_1}` *(must be registered in Orchestration Steps)*
- KPI: `{KPI_Name_2}`
- Destination: `Dynatrace`

### Submit CSV Report

> Columns must be a subset of properties available on the result objects produced by the Orchestration steps.

- Columns: `{Column1}`, `{Column2}`, `{Column3}`
- Destination: `{Path, e.g., C:\Logs\Zerto\{controller_name}_report.csv}`

### Submit Email

- Attach the CSV Report: `{Yes | No}`
- Subject: `{Optional custom subject line, or leave blank for auto-generated}`

### Submit Doctor

> Doctor produces a headerless CSV to stdout. Use this for integration with parent automation frameworks.

- Return Object Output: `{Field1}`, `{Field2}`, `{Field3}`
- Destination: `{Informational only — caller redirects. E.g., C:\Logs\Zerto\zvm_debug.log}`

---

## Error Handling Notes

> [OPTIONAL] Describe any non-standard error handling requirements.
> Standard behavior: each step has its own Try/Catch. Critical steps throw; non-critical steps log Warning and continue.
> Only fill this section if you need to deviate from the standard pattern.

- Step `{N}` is **critical** — failure must terminate the entire script.
- Step `{N}` is **non-critical** — failure logs a Warning and continues to the next item.
- Step `{N}` — on failure, notify via email before terminating.

---

## Notes & Constraints

> [OPTIONAL] Any additional constraints, environmental dependencies, or operational notes
> that the generated script must accommodate.

- {e.g., "Must complete within 30 minutes to avoid ServiceNow SLA breach."}
- {e.g., "Target ZVMs are listed in E:\source\zvmservers.txt — one hostname per line."}
- {e.g., "Script runs daily at 02:00 via Windows Task Scheduler as DOMAIN\zerto_svc."}

---

## Approval

> [REQUIRED] Sign off before the intake form enters the spec-kit pipeline.

| Role | Name | Date |
|---|---|---|
| Requestor | | |
| Technical Reviewer | | |

---

*Template: intake-spec-template.md — ZAF v1.0.0*
*After completing this form, run `speckit-specify` to generate the feature specification.*
