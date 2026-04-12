# Spec: Set-JournalAndScratch

Script Name: Set-JournalAndScratch

**Goal**:

Update journal and scratch disk sizes for all VPG[s] on a ZVM be a value passed in as a parameter. If the restore switch is used, restore the journal and scratch sizes to default values. If the restore switch is not used, the journal and scratch sizes will be set to the values passed in as parameters. If an existing backup exists for a ZVM, the script should throw and not process. When the script is ran once, a backup should be created with the planned journal and scratch sizes. When the -restore swtich is supplied it should process the backup file to restore original values and and append a 'processed' tag to the backup file. The backup file should be located at E:\scripts\log\{scriptname}\backup\{zvmname}\{date-time}.json. The script should be able to handle multiple ZVMs and multiple VPGs on each ZVM.

---

## Orchestration (The Steps)

1. Get VPGs
2. Get journal and scratch sizes
3. Get desired journal and scratch sizes
4. Compare current and desired sizes
5. Create a state.json backup located at E:\scripts\log\{scriptname}\backup\{zvmname}\{date-time}.json
6. Update journal and scratch sizes if needed
7. Submit Telemetry
8. Submit CSV Report
9. Submit Email
10. Submit Doctor

---

## Input Parameters

Parameters:
- Name: ZVMHost
- Type: [string]
- Required: No
- Default: *(read from zvmservers.txt)*
- Description: Specific ZVM to target

- Name: VpgName
- Type: [string[]]
- Required: No
- Default: N/A
- Description: Limit audit to a single VPG name or multiple VPG names. If not specified, all VPGs will be processed.

- Name: JournalSizeGB
- Type: [int]
- Required: Yes
- Default: N/A
- Description: Desired journal size in GB

- Name: ScratchSizeGB
- Type: [int]
- Required: Yes
- Default: N/A
- Description: Desired scratch size in GB

- Name: Restore
- Type: [switch]
- Required: No
- Default: N/A
- Description: Restore journal and scratch sizes to default values

---

## Script Completion

- [X] Submit Telemetry
- [X] Submit CSV Report
- [X] Submit Email
- [X] Submit Doctor

---

## Completion Details

> [REQUIRED for each checked item above] Fill in the details for each checked completion action.
> Remove subsections for unchecked items.

### Submit Telemetry

Telemetry - Yes


KPIs to Collect:
- KPI: `vpgs_processed` — Number of VPGs processed
- KPI: `vpgs_updated` — Number of VPGs updated
- KPI: `vpgs_failed` — Number of VPGs failed
- KPI: `desired_journal_size_gb` — Desired journal size in GB
- KPI: `desired_scratch_size_gb` — Desired scratch size in GB


### Submit CSV Report

CSV Report - Yes
Columns: zvm, vpg, journal size, scratch size, vpgs_processed, vpgs_updated, vpgs_failed, desired journal size, desired scratch size


### Submit Email

Email Notification - Yes
Subject: Set-JournalAndScratch
Attach the CSV Report: Yes

### Submit Doctor

Doctor - Yes
return zvm, vpg, journal size, scratch size, vpgs_processed, vpgs_updated, vpgs_failed

---

## Error Handling Notes

ZVM and VPGs are all processed in a single run. If a ZVM fails, the script should continue to the next ZVM. If a VPG fails, the script should continue to the next VPG. If a VPG fails, it should be logged and the script should continue to the next VPG.

If 3 ore more fail in a row, the script should log and stop.


---

## Notes & Constraints

