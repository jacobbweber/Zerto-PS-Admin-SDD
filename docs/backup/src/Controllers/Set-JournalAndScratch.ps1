#Requires -Version 7.5
<#
.SYNOPSIS
    Set journal and scratch disk sizes for all VPGs on one or more ZVMs.

.DESCRIPTION
    In apply mode (default): validates no unprocessed backup exists, captures current
    journal and scratch sizes for each VPG, writes a dated JSON backup, then updates
    any VPG whose sizes differ from the desired values.

    In restore mode (-Restore): reads the most recent unprocessed backup for each ZVM,
    restores each VPG's journal and scratch sizes, then marks the backup as processed.

    Implements a consecutive-failure circuit-breaker per ZVM (threshold: 3 failures).
    All 4 output channels are produced on every run: Telemetry, CSV, Email, and Doctor.

.PARAMETER ZVMHost
    Hostname of a specific ZVM to target. When omitted, all ZVMs listed in
    zvmservers.txt are processed.

.PARAMETER VpgName
    One or more VPG names to limit processing to. When omitted, all VPGs are processed.

.PARAMETER JournalSizeGB
    Desired journal disk hard limit in gigabytes. Required when -Restore is not specified.

.PARAMETER ScratchSizeGB
    Desired scratch disk hard limit in gigabytes. Required when -Restore is not specified.

.PARAMETER Restore
    When specified, activates restore mode. Reads the backup file and reverts VPG sizes.
    Cannot be combined with -JournalSizeGB or -ScratchSizeGB.

.PARAMETER EmailTo
    Override the default email recipient. Falls back to value in config.json.

.PARAMETER ZertoCred
    Optional explicit Zerto credential. Falls back to Resolve-ProjectCredential.

.PARAMETER Doctor
    When $true (default), emits headerless CSV output for machine consumption.
#>
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Apply')]
param(
    [Parameter(Mandatory = $false)]
    [string]$ZVMHost,

    [Parameter(Mandatory = $false)]
    [string[]]$VpgName,

    [Parameter(Mandatory = $true, ParameterSetName = 'Apply')]
    [int]$JournalSizeGB,

    [Parameter(Mandatory = $true, ParameterSetName = 'Apply')]
    [int]$ScratchSizeGB,

    [Parameter(Mandatory = $true, ParameterSetName = 'Restore')]
    [switch]$Restore,

    [Parameter(Mandatory = $false)]
    [string]$EmailTo,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$ZertoCred,

    [Parameter(Mandatory = $false)]
    [bool]$Doctor = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────────────────────────────────────
# Phase 1: Environment & Setup
# ─────────────────────────────────────────────────────────────────────────────

# 1. Import all modules from the local Modules directory
$ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\Modules'
Get-ChildItem -Path $ModuleRoot -Directory | ForEach-Object {
    Import-Module $_.FullName -Force
}

# 2. Initialize project configuration
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\config.json'
Initialize-ProjectConfig -ConfigPath $ConfigPath | Out-Null

# 3. Derive paths from config
$ScriptName = $MyInvocation.MyCommand.Name
$LogPath    = Join-Path -Path $global:Config.base.logging.paths.logdir -ChildPath $ScriptName
$BackupRoot = "E:\scripts\log\Set-JournalAndScratch\backup"
$CsvDir     = Join-Path -Path $global:Config.base.logging.paths.logdir -ChildPath $ScriptName

# 4. Resolve ZVM server list
[string[]]$ZVMServers = @()
if ($ZVMHost) {
    $ZVMServers = @($ZVMHost)
}
else {
    $ServerListPath = 'E:\source\zvmservers.txt'
    if (Test-Path -Path $ServerListPath) {
        $ZVMServers = Get-Content -Path $ServerListPath | Where-Object { $_ -match '\S' }
    }
    else {
        Write-Log -Level 'Warning' -Message "Server list not found at path=$ServerListPath" `
            -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
        throw "No ZVM server list found at path=$ServerListPath and -ZVMHost was not provided."
    }
}

# 5. Resolve credential
if ($null -eq $ZertoCred) {
    $ZertoCred = Resolve-ProjectCredential -Provider 'Zerto'
}

# 6. Initialize results and telemetry
$Results      = [System.Collections.Generic.List[PSCustomObject]]::new()
$StartTime    = Get-Date
$Telemetry    = New-ProjectTelemetry -Namespace 'zerto.vpg' -BaseDimensions @{
    env         = $global:Config.base.telemetry.business_unit
    script_name = $ScriptName
}

# 7. KPI counters
$KpiProcessed      = 0
$KpiUpdated        = 0
$KpiFailed         = 0
$DesiredJournalGB  = if ($Restore) { 0 } else { $JournalSizeGB }
$DesiredScratchGB  = if ($Restore) { 0 } else { $ScratchSizeGB }

Write-Log -Level 'Information' -Message "Started script=$ScriptName mode=$(if ($Restore) { 'Restore' } else { 'Apply' })" `
    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

# ─────────────────────────────────────────────────────────────────────────────
# Phase 2: Functional Orchestration — ZVM Loop
# ─────────────────────────────────────────────────────────────────────────────

foreach ($Server in $ZVMServers) {

    Write-Log -Level 'Information' -Message "Processing zvm=$Server" `
        -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

    try {
        Connect-ZertoZVM -ZVMHost $Server -Credential $ZertoCred -ErrorAction Stop | Out-Null

        # ── APPLY MODE ─────────────────────────────────────────────────────────
        if (-not $Restore) {

            # Guard: block apply if an unprocessed backup already exists
            if (Test-JournalScratchBackupExists -ZVMHost $Server -BackupRoot $BackupRoot) {
                $ErrMsg = "Unprocessed backup exists for zvm=$Server — apply blocked. Run -Restore first or remove the backup."
                Write-Log -Level 'Error' -Message $ErrMsg `
                    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                Write-Error -Message $ErrMsg -ErrorAction Continue
                Disconnect-ZertoZVM | Out-Null
                continue
            }

            # Retrieve and optionally filter VPG list
            $AllVPGs = Get-ZertoVPG
            $TargetVPGs = if ($VpgName) {
                $AllVPGs | Where-Object { $_.VpgName -in $VpgName }
            }
            else {
                $AllVPGs
            }

            # Capture current state for all target VPGs
            $StateRecords = [System.Collections.Generic.List[PSCustomObject]]::new()
            foreach ($Vpg in $TargetVPGs) {
                $State = Get-VpgJournalScratchState -ZVMHost $Server -VpgIdentifier $Vpg.VpgIdentifier -VpgName $Vpg.VpgName
                $StateRecords.Add($State)
            }

            # Write backup BEFORE making any changes
            $BackupFile = New-JournalScratchBackup -ZVMHost $Server -BackupRoot $BackupRoot -StateRecords $StateRecords.ToArray()
            Write-Log -Level 'Information' -Message "Backup written for zvm=$Server file=$BackupFile" `
                -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

            # Apply desired sizes — with circuit-breaker
            $ConsecutiveFails = 0
            foreach ($State in $StateRecords) {

                $KpiProcessed++

                if ($State.JournalSizeGB -eq $JournalSizeGB -and $State.ScratchSizeGB -eq $ScratchSizeGB) {
                    # No change needed
                    $Results.Add([PSCustomObject]@{
                        ZVMHost          = $Server
                        VpgName          = $State.VpgName
                        VpgIdentifier    = $State.VpgIdentifier
                        JournalSizeGB    = $State.JournalSizeGB
                        ScratchSizeGB    = $State.ScratchSizeGB
                        DesiredJournalGB = $JournalSizeGB
                        DesiredScratchGB = $ScratchSizeGB
                        Action           = 'Skipped'
                        Status           = 'Success'
                        ErrorMessage     = $null
                    })
                    $ConsecutiveFails = 0
                    continue
                }

                $UpdateResult = Invoke-JournalScratchUpdate `
                    -ZVMHost $Server `
                    -VpgIdentifier $State.VpgIdentifier `
                    -VpgName $State.VpgName `
                    -JournalSizeGB $JournalSizeGB `
                    -ScratchSizeGB $ScratchSizeGB

                $Results.Add($UpdateResult)

                if ($UpdateResult.Status -eq 'Success') {
                    $KpiUpdated++
                    $ConsecutiveFails = 0
                    Write-Log -Level 'Information' -Message "Updated vpg=$($State.VpgName) zvm=$Server journalGB=$JournalSizeGB scratchGB=$ScratchSizeGB" `
                        -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                }
                else {
                    $KpiFailed++
                    $ConsecutiveFails++
                    Write-Log -Level 'Error' -Message "Failed to update vpg=$($State.VpgName) zvm=$Server error=$($UpdateResult.ErrorMessage)" `
                        -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

                    if ($ConsecutiveFails -ge 3) {
                        Write-Log -Level 'Error' -Message "Circuit-breaker triggered zvm=$Server consecutiveFails=$ConsecutiveFails — aborting ZVM" `
                            -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                        break
                    }
                }
            }
        }

        # ── RESTORE MODE ───────────────────────────────────────────────────────
        else {

            # Find unprocessed backup files for this ZVM
            $BackupDir = Join-Path -Path $BackupRoot -ChildPath $Server
            if (-not (Test-Path -Path $BackupDir)) {
                $ErrMsg = "No backup directory found for zvm=$Server — cannot restore."
                Write-Log -Level 'Error' -Message $ErrMsg `
                    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                Write-Error -Message $ErrMsg -ErrorAction Continue
                Disconnect-ZertoZVM | Out-Null
                continue
            }

            $UnprocessedFiles = Get-ChildItem -Path $BackupDir -Filter '*.json' -File |
                Where-Object { $_.Name -notlike '*_processed.json' } |
                Sort-Object LastWriteTime -Descending

            if ($null -eq $UnprocessedFiles -or $UnprocessedFiles.Count -eq 0) {
                $ErrMsg = "No unprocessed backup file found for zvm=$Server — cannot restore."
                Write-Log -Level 'Error' -Message $ErrMsg `
                    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                Write-Error -Message $ErrMsg -ErrorAction Continue
                Disconnect-ZertoZVM | Out-Null
                continue
            }

            if ($UnprocessedFiles.Count -gt 1) {
                Write-Log -Level 'Warning' -Message "Multiple unprocessed backups found for zvm=$Server count=$($UnprocessedFiles.Count) — using most recent" `
                    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
            }

            $BackupFilePath  = $UnprocessedFiles[0].FullName
            $BackupRecords   = Get-Content -Path $BackupFilePath -Raw | ConvertFrom-Json

            Write-Log -Level 'Information' -Message "Restoring from backup zvm=$Server file=$BackupFilePath records=$($BackupRecords.Count)" `
                -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

            # Apply VpgName filter if provided
            $TargetRecords = if ($VpgName) {
                $BackupRecords | Where-Object { $_.VpgName -in $VpgName }
            }
            else {
                $BackupRecords
            }

            # Restore each VPG — with circuit-breaker
            $ConsecutiveFails = 0
            foreach ($Record in $TargetRecords) {

                $KpiProcessed++

                $RestoreResult = Invoke-JournalScratchRestore -ZVMHost $Server -BackupRecord $Record
                $Results.Add($RestoreResult)

                if ($RestoreResult.Status -eq 'Success') {
                    $KpiUpdated++
                    $ConsecutiveFails = 0
                    Write-Log -Level 'Information' -Message "Restored vpg=$($Record.VpgName) zvm=$Server journalGB=$($Record.JournalSizeGB) scratchGB=$($Record.ScratchSizeGB)" `
                        -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                }
                else {
                    $KpiFailed++
                    $ConsecutiveFails++
                    Write-Log -Level 'Error' -Message "Failed to restore vpg=$($Record.VpgName) zvm=$Server error=$($RestoreResult.ErrorMessage)" `
                        -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

                    if ($ConsecutiveFails -ge 3) {
                        Write-Log -Level 'Error' -Message "Circuit-breaker triggered zvm=$Server consecutiveFails=$ConsecutiveFails — aborting ZVM restore" `
                            -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
                        break
                    }
                }
            }

            # Mark backup as processed after all VPGs attempted
            Complete-JournalScratchBackup -BackupFilePath $BackupFilePath | Out-Null
            Write-Log -Level 'Information' -Message "Backup marked processed zvm=$Server file=$BackupFilePath" `
                -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
        }

        Disconnect-ZertoZVM | Out-Null
    }
    catch {
        Write-Log -Level 'Error' -Message "ZVM-level failure zvm=$Server error=$($_.Exception.Message)" `
            -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'
        Write-Error -Message "ZVM-level failure zvm=$Server — $($_.Exception.Message)" -ErrorAction Continue
        try { Disconnect-ZertoZVM | Out-Null } catch { }
        continue
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# Phase 3: Finalization & Output
# ─────────────────────────────────────────────────────────────────────────────

# 1. Telemetry — mandatory baselines
$FinalResult = if ($Error.Count -eq 0) { 'Success' } else { 'Failure' }
$Duration    = (New-TimeSpan -Start $StartTime -End (Get-Date)).TotalSeconds

Add-TelemetryMetric -Session $Telemetry -Key 'script_duration'         -Value $Duration
Add-TelemetryMetric -Session $Telemetry -Key 'result'                   -Value $(if ($FinalResult -eq 'Success') { 1 } else { 0 })

# 2. Telemetry — feature KPIs
Add-TelemetryMetric -Session $Telemetry -Key 'vpgs_processed'           -Value $KpiProcessed        -Type 'gauge'
Add-TelemetryMetric -Session $Telemetry -Key 'vpgs_updated'             -Value $KpiUpdated          -Type 'gauge'
Add-TelemetryMetric -Session $Telemetry -Key 'vpgs_failed'              -Value $KpiFailed           -Type 'gauge'
Add-TelemetryMetric -Session $Telemetry -Key 'desired_journal_size_gb'  -Value $DesiredJournalGB    -Type 'gauge'
Add-TelemetryMetric -Session $Telemetry -Key 'desired_scratch_size_gb'  -Value $DesiredScratchGB    -Type 'gauge'

Submit-ProjectTelemetry -Session $Telemetry -SubmitType 'Agent' -Config $global:Config -Backup

# 3. CSV Report
if (-not (Test-Path -Path $CsvDir)) {
    New-Item -Path $CsvDir -ItemType Directory -Force | Out-Null
}
$CsvPath = Join-Path -Path $CsvDir -ChildPath 'Set-JournalAndScratch-Report.csv'
$CsvData = $Results | Select-Object `
    @{ N = 'ZVM';               E = { $_.ZVMHost } },
    @{ N = 'VPG';               E = { $_.VpgName } },
    @{ N = 'JournalSize';       E = { $_.JournalSizeGB } },
    @{ N = 'ScratchSize';       E = { $_.ScratchSizeGB } },
    @{ N = 'VpgsProcessed';     E = { $KpiProcessed } },
    @{ N = 'VpgsUpdated';       E = { $KpiUpdated } },
    @{ N = 'VpgsFailed';        E = { $KpiFailed } },
    @{ N = 'DesiredJournalSize';E = { $DesiredJournalGB } },
    @{ N = 'DesiredScratchSize';E = { $DesiredScratchGB } }

Export-ProjectCSVReport -Results $CsvData -Path $CsvPath

# 4. Email
$TargetEmail = if ($EmailTo) { $EmailTo } else { $global:Config.base.email.default_to }
$HtmlBody    = Set-FormattedEmail -Results $Results -Title 'Set-JournalAndScratch'
Send-FormattedEmail -HtmlBody $HtmlBody -To $TargetEmail -SmtpServer $global:Config.base.email.smpt_server

Write-Log -Level 'Information' -Message "Completed script=$ScriptName processed=$KpiProcessed updated=$KpiUpdated failed=$KpiFailed" `
    -LogPath $LogPath -SyslogFileName 'minimal.log' -DevLogFileName 'full.log'

# 5. Doctor output (final emission — per Doctor Contract)
if ($Doctor) {
    $Results | Select-Object `
        @{ N = 'ZVMHost';        E = { $_.ZVMHost } },
        @{ N = 'VpgName';        E = { $_.VpgName } },
        @{ N = 'JournalSizeGB';  E = { $_.JournalSizeGB } },
        @{ N = 'ScratchSizeGB';  E = { $_.ScratchSizeGB } },
        @{ N = 'vpgs_processed'; E = { $KpiProcessed } },
        @{ N = 'vpgs_updated';   E = { $KpiUpdated } },
        @{ N = 'vpgs_failed';    E = { $KpiFailed } } |
        ConvertTo-Csv -NoTypeInformation |
        Select-Object -Skip 1 |
        ForEach-Object {
            $_ -replace '^"', '' -replace '"$', '' -replace '","', ','
        }
}
else {
    return $Results
}
