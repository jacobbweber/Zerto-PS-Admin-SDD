function Get-VpgJournalScratchState {
    <#
    .SYNOPSIS
        Reads the current journal and scratch disk sizes for a single VPG.

    .DESCRIPTION
        Opens a transient VPG settings edit session via New-ZertoVpgsetting, retrieves
        the journal and scratch settings, converts HardLimitInMB to GB, then discards
        the session (no commit). Returns a state object capturing the values at the time
        of the call. Used to build the pre-change backup before any modifications.

    .PARAMETER ZVMHost
        The hostname of the ZVM that owns the VPG.

    .PARAMETER VpgIdentifier
        The Zerto internal GUID of the VPG.

    .PARAMETER VpgName
        The human-readable name of the VPG (for reporting purposes).

    .OUTPUTS
        [PSCustomObject] with fields: ZVMHost, VpgName, VpgIdentifier,
        JournalSizeGB, ScratchSizeGB, CapturedAt.

    .EXAMPLE
        $State = Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'abc-123' -VpgName 'MyVPG'
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$ZVMHost,

        [Parameter(Mandatory)]
        [string]$VpgIdentifier,

        [Parameter(Mandatory)]
        [string]$VpgName
    )

    process {
        Write-Verbose "Get-VpgJournalScratchState: Opening read session for vpg=$VpgName identifier=$VpgIdentifier"

        $SettingsId = $null
        try {
            # Open a transient edit session targeting this VPG
            $SettingsId = New-ZertoVpgsetting -Body @{ VpgIdentifier = $VpgIdentifier }

            if ([string]::IsNullOrEmpty($SettingsId)) {
                throw "New-ZertoVpgsetting returned an empty session ID for vpg=$VpgName"
            }

            # Read current journal settings
            $JournalSettings = Get-ZertoVpgsettingjournal -Vpgsettingsidentifier $SettingsId
            $ScratchSettings = Get-ZertoVpgsettingscratch -Vpgsettingsidentifier $SettingsId

            # Convert MB → GB (round down to nearest GB)
            $JournalSizeGB = [int][Math]::Floor($JournalSettings.HardLimitInMB / 1024)
            $ScratchSizeGB = [int][Math]::Floor($ScratchSettings.HardLimitInMB / 1024)

            return [PSCustomObject]@{
                ZVMHost        = $ZVMHost
                VpgName        = $VpgName
                VpgIdentifier  = $VpgIdentifier
                JournalSizeGB  = $JournalSizeGB
                ScratchSizeGB  = $ScratchSizeGB
                CapturedAt     = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
            }
        }
        finally {
            # Always discard the read session — do not commit it
            if (-not [string]::IsNullOrEmpty($SettingsId)) {
                try {
                    Remove-ZertoVpgsetting -Vpgsettingsidentifier $SettingsId | Out-Null
                }
                catch {
                    Write-Verbose "Get-VpgJournalScratchState: Failed to discard session settingsId=$SettingsId — $($_.Exception.Message)"
                }
            }
        }
    }
}
