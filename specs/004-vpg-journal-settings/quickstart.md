# Quickstart: Get VPG Journal Settings

**Phase 1 Output**

## How to Prepare

1.  Confirm all modules are in the search path: `d:\Tech\git\local_projects\zerto-ps-admin\src\Modules\`.
2.  Ensure a ZVM server list exists: `E:\source\zvmservers.txt` (one hostname/IP per line).
3.  Ensure `config.json` is configured with valid credentials in `$Config.base.auth`.
4.  Ensure `InfraCode.Email` is configured with an SMTP server.

## How to Run

### 1. Basic Audit (CSV + Local Log)
```powershell
.\src\Controllers\Get-VPGJournalSettings.ps1 -CSV
```

### 2. Full Environmental Audit (Email + Telemetry)
```powershell
.\src\Controllers\Get-VPGJournalSettings.ps1 -CSV -Email -Telemetry
```

### 3. Targeted VPG Search
```powershell
.\src\Controllers\Get-VPGJournalSettings.ps1 -VpgName "VPG_01"
```

### 4. Simulation Mode (Offline Logic Check)
```powershell
.\src\Controllers\Get-VPGJournalSettings.ps1 -Simulation
```

### 5. Doctor Mode (Headerless CSV Output)
```powershell
.\src\Controllers\Get-VPGJournalSettings.ps1 -Doctor
```
