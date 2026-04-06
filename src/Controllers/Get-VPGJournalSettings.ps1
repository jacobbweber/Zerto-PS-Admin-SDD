<#
.SYNOPSIS
    Get VPG Journal Settings report across one or more ZVMs.

.DESCRIPTION
    Audits Zerto VPGs for journal settings. Supports multiple ZVMs via server list file.

.PARAMETER ZVMHost
    Optional hostname of a specific ZVM to audit.

.PARAMETER VpgName
    Optional VPG name to search for.

.PARAMETER EmailTo
    Optional email recipient for the report.

.PARAMETER CSV
    Export results to CSV.

.PARAMETER Email
    Send results via Email.

.PARAMETER Telemetry
    Submit KPIs to telemetry.

.PARAMETER Doctor
    Output headerless CSV to console.

.PARAMETER Simulation
    Run in simulation mode using mock data.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $false)]
    [string]$ZVMHost,

    [Parameter(Mandatory = $false)]
    [string]$VpgName,

    [Parameter(Mandatory = $false)]
    [string]$EmailTo,

    [Parameter(Mandatory = $false)]
    [switch]$CSV,

    [Parameter(Mandatory = $false)]
    [switch]$Email,

    [Parameter(Mandatory = $false)]
    [switch]$Telemetry,

    [Parameter(Mandatory = $false)]
    [switch]$Doctor,

    [Parameter(Mandatory = $false)]
    [switch]$Simulation
)

Begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # 1. Import modules from internal structure
    $ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\Modules"
    Get-ChildItem -Path $ModuleRoot -Directory | ForEach-Object {
        Import-Module $_.FullName -Force
    }

    # 2. Parse config.json into global $Config
    $ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "..\..\config.json"
    Initialize-ProjectConfig -ConfigPath $ConfigPath | Out-Null

    # 2.1 Load ZVM servers list
    [string[]]$ZVMServers = @()
    if ($ZVMHost) {
        $ZVMServers = @($ZVMHost)
    }
    else {
        $ServerListPath = "E:\source\zvmservers.txt"
        if (Test-Path -Path $ServerListPath) {
            $ZVMServers = Get-Content -Path $ServerListPath | Where-Object { $_ -match "\S" }
        }
        else {
            Write-Log -Level "Warning" -Message "Server list not found at $ServerListPath. Defaulting to localhost."
            $ZVMServers = @("localhost")
        }
    }

    # 3. Initialize results collection
    $Results = [System.Collections.Generic.List[PSObject]]::new()

    # 4. Initialize Doctor report if switch active
    if ($Doctor) {
        $global:DoctorReport = [ordered]@{}
    }

    # 5. Call New-ProjectTelemetry (Bootstrap Telemetry)
    New-ProjectTelemetry -Hostname $global:Config.base.telemetry.hostname `
        -Username $global:Config.base.telemetry.username `
        -BusinessUnit $global:Config.base.telemetry.business_unit
    
    Write-Log -Level "Info" -Message "Started Get-VPGJournalSettings audit."
}

Process {
    try {
        if ($Simulation) {
            Write-Log -Level "Info" -Message "Running in Simulation mode. Loading mock data."
            # Load mock data from simulation folder
            $MockPath = ".\src\Controllers\Tests\Shared\mocks\zvm_vpg_data.json"
            if (Test-Path -Path $MockPath) {
                $MockContent = Get-Content -Path $MockPath -Raw | ConvertFrom-Json
                foreach ($V in $MockContent) { $Results.Add($V) }
            }
            else {
                Write-Log -Level "Warning" -Message "Mock data not found at $MockPath. Using empty result set."
            }
            return # Skip live logic
        }

        foreach ($Server in $ZVMServers) {
            Write-Log -Level "Info" -Message "Processing ZVM: $Server"
            
            try {
                Connect-ZertoZVM -ZVMHost $Server -ErrorAction Stop | Out-Null
                
                if ($VpgName) {
                    $Match = $VPGs | Where-Object { $_.VPGName -eq $VpgName -or $_.VpgIdentifier -eq $VpgName }
                    if ($Match) {
                        Write-Log -Level "Info" -Message "Match found for VPG $($VpgName) on $($Server). Terminating search."
                        $Result = [PSCustomObject]@{
                            VPGName           = $Match.VPGName
                            VpgIdentifier     = $Match.VpgIdentifier
                            ProtectedSiteName = $Match.ProtectedSiteName
                            ZVMHost           = $Server
                            Status            = $Match.Status
                        }
                        $Results.Add($Result)
                        Disconnect-ZertoZVM
                        return # Early exit
                    }
                }
                else {
                    # Bulk Audit
                    foreach ($VPG in $VPGs) {
                        $Result = [PSCustomObject]@{
                            VPGName           = $VPG.VPGName
                            VpgIdentifier     = $VPG.VpgIdentifier
                            ProtectedSiteName = $VPG.ProtectedSiteName
                            ZVMHost           = $Server
                            Status            = $VPG.Status
                        }
                        $Results.Add($Result)
                    }
                }
                
                Disconnect-ZertoZVM
            }
            catch {
                Write-Log -Level "Warning" -Message "Operation failed for ZVM $($Server): $($_.Exception.Message)"
                continue
            }
        }
    }
    catch {
        Write-Log -Level "Error" -Message "Critical failure during audit: $($_.Exception.Message)"
        throw
    }
}

End {
    # 1. KPIs
    if ($global:TelemetrySession -and $global:TelemetrySession.KPIs) {
        $global:TelemetrySession.KPIs["vpg_count"] = $Results.Count
    }

    # 2. Formatters & Distribution
    if ($CSV) {
        $CsvFilename = $global:Config.base.logging.filenames.csv
        $CsvDir = $global:Config.base.logging.paths.logdir
        if (-not (Test-Path -Path $CsvDir)) { New-Item -Path $CsvDir -ItemType Directory -Force | Out-Null }
        $CsvPath = Join-Path -Path $CsvDir -ChildPath $CsvFilename
        Export-ProjectCSVReport -Results $Results -Path $CsvPath
    }

    if ($Email) {
        $TargetEmail = if ($EmailTo) { $EmailTo } else { $global:Config.base.email.default_to }
        $HtmlBody = Set-FormattedEmail -Results $Results -Title "Zerto Journal Audit Report"
        Send-FormattedEmail -HtmlBody $HtmlBody -To $TargetEmail -SmtpServer $global:Config.base.email.smpt_server
    }

    # 4. Doctor Pattern (Section VI of Constitution)
    if ($Doctor) {
        $Results | Select-Object VPGName, VpgIdentifier, ProtectedSiteName | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | ForEach-Object {
            $_ -replace '^"', '' -replace '"$', '' -replace '","', ','
        }
    }

    # 5. Telemetry Closure
    Complete-ProjectTelemetry
    if ($Telemetry) {
        Submit-ProjectTelemetry
    }

    Write-Log -Level "Info" -Message "Completed Get-VPGJournalSettings audit. Total Results: $($Results.Count)"

    $Results | Select-Object VPGName, VpgIdentifier, ProtectedSiteName | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | ForEach-Object {
        $_ -replace '^"', '' -replace '"$', '' -replace '","', ','
    }
}

