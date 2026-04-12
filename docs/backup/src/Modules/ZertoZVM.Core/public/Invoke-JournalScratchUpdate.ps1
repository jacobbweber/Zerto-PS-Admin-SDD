function Invoke-JournalScratchUpdate {
    <#
    .SYNOPSIS
        Applies desired journal and scratch disk sizes to a single VPG.

    .DESCRIPTION
        Opens a Zerto VPG settings edit session, sets the journal hard limit and
        scratch hard limit to the specified GB values (converted to MB internally),
        then commits the change. If any step fails, the uncommitted session is
        cleaned up via Remove-ZertoVpgsetting before the error is re-thrown.

        Returns a VpgUpdateResult object indicating the outcome of the operation.

    .PARAMETER ZVMHost
        The hostname of the ZVM that owns the VPG.

    .PARAMETER VpgIdentifier
        The Zerto internal GUID of the VPG.

    .PARAMETER VpgName
        The human-readable name of the VPG (for reporting purposes).

    .PARAMETER JournalSizeGB
        The desired journal disk hard limit in gigabytes. Converted to MB internally.

    .PARAMETER ScratchSizeGB
        The desired scratch disk hard limit in gigabytes. Converted to MB internally.

    .OUTPUTS
        [PSCustomObject] VpgUpdateResult — fields: ZVMHost, VpgName, VpgIdentifier,
        JournalSizeGB, ScratchSizeGB, DesiredJournalGB, DesiredScratchGB,
        Action, Status, ErrorMessage.

    .EXAMPLE
        $Result = Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'abc-123' -VpgName 'MyVPG' -JournalSizeGB 50 -ScratchSizeGB 30
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$ZVMHost,

        [Parameter(Mandatory)]
        [string]$VpgIdentifier,

        [Parameter(Mandatory)]
        [string]$VpgName,

        [Parameter(Mandatory)]
        [int]$JournalSizeGB,

        [Parameter(Mandatory)]
        [int]$ScratchSizeGB
    )

    process {
        $JournalMB = $JournalSizeGB * 1024
        $ScratchMB = $ScratchSizeGB * 1024

        Write-Verbose "Invoke-JournalScratchUpdate: vpg=$VpgName journalMB=$JournalMB scratchMB=$ScratchMB"

        $SettingsId = $null
        try {
            $SettingsId = New-ZertoVpgsetting -Body @{ VpgIdentifier = $VpgIdentifier }

            if ([string]::IsNullOrEmpty($SettingsId)) {
                throw "New-ZertoVpgsetting returned an empty session ID for vpg=$VpgName"
            }

            Set-ZertoVpgsettingjournal -Vpgsettingsidentifier $SettingsId -Body @{
                HardLimitInMB = $JournalMB
            } | Out-Null

            Set-ZertoVpgsettingscratch -Vpgsettingsidentifier $SettingsId -Body @{
                HardLimitInMB = $ScratchMB
            } | Out-Null

            Start-ZertoVpgsettingcommit -Vpgsettingsidentifier $SettingsId | Out-Null

            Write-Verbose "Invoke-JournalScratchUpdate: Committed vpg=$VpgName"

            return [PSCustomObject]@{
                ZVMHost          = $ZVMHost
                VpgName          = $VpgName
                VpgIdentifier    = $VpgIdentifier
                JournalSizeGB    = $JournalSizeGB
                ScratchSizeGB    = $ScratchSizeGB
                DesiredJournalGB = $JournalSizeGB
                DesiredScratchGB = $ScratchSizeGB
                Action           = 'Updated'
                Status           = 'Success'
                ErrorMessage     = $null
            }
        }
        catch {
            $ErrorMsg = $_.Exception.Message
            Write-Verbose "Invoke-JournalScratchUpdate: Failed vpg=$VpgName error=$ErrorMsg"

            # Clean up uncommitted session on failure
            if (-not [string]::IsNullOrEmpty($SettingsId)) {
                try {
                    Remove-ZertoVpgsetting -Vpgsettingsidentifier $SettingsId | Out-Null
                }
                catch {
                    Write-Verbose "Invoke-JournalScratchUpdate: Session cleanup failed settingsId=$SettingsId"
                }
            }

            return [PSCustomObject]@{
                ZVMHost          = $ZVMHost
                VpgName          = $VpgName
                VpgIdentifier    = $VpgIdentifier
                JournalSizeGB    = 0
                ScratchSizeGB    = 0
                DesiredJournalGB = $JournalSizeGB
                DesiredScratchGB = $ScratchSizeGB
                Action           = 'Failed'
                Status           = 'Failure'
                ErrorMessage     = $ErrorMsg
            }
        }
    }
}
