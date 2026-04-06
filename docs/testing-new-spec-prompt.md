Spec: Get VPG Journal Settings-script
Script Name: Get-VPGJournalSettings.ps1

Inputs: Optional, ZVM, VPG, $EmailTo (defaults from constitution)

Business logic:
User will execute the script and either supply a ZVM, VPG, or both.
If No ZVM is supplied, being block will load a zvm server list from E:\source\zvmservers.txt. If no ZVM but a VPG is supplied, it will connect to the ZVMs to find the VPG and then use that ZVM to continue.

Get all VPGs and then return the following:
[string]VPGName:
[string]VpgIdentifier:
[string]ProtectedSiteName: 

Telemetry KPIs:
script_name:
vpg_count:

outputs:
Email, CSV, Telemetry, Doctor