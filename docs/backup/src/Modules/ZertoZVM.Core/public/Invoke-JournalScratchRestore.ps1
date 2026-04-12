function Invoke-JournalScratchRestore {
    <#
    .SYNOPSIS
        Restores the journal and scratch disk sizes for a single VPG from a backup record.

    .DESCRIPTION
        Opens a Zerto VPG settings edit session and sets the journal and scratch hard limits
        to the values recorded in the provided backup record (in GB, converted to MB
        internally). Commits the change, then returns a VpgUpdateResult reflecting the
        restore outcome.

        If any step fails, the uncommitted session is cleaned up via Remove-ZertoVpgsetting
        before the error is captured in the returned result object (non-terminating).

    .PARAMETER ZVMHost
        The hostname of the ZVM that owns the VPG.

    .PARAMETER BackupRecord
        A single element from the backup JSON array, as produced by New-JournalScratchBackup.
        Must have properties: VpgIdentifier, VpgName, JournalSizeGB, ScratchSizeGB.

    .OUTPUTS
        [PSCustomObject] VpgUpdateResult — fields: ZVMHost, VpgName, VpgIdentifier,
        JournalSizeGB, ScratchSizeGB, DesiredJournalGB, DesiredScratchGB,
        Action, Status, ErrorMessage.

    .EXAMPLE
        $Result = Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $BackupRecord
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$ZVMHost,

        [Parameter(Mandatory)]
        [PSCustomObject]$BackupRecord
    )

    process {
        $VpgName      = $BackupRecord.VpgName
        $VpgId        = $BackupRecord.VpgIdentifier
        $JournalSizeGB = [int]$BackupRecord.JournalSizeGB
        $ScratchSizeGB = [int]$BackupRecord.ScratchSizeGB
        $JournalMB    = $JournalSizeGB * 1024
        $ScratchMB    = $ScratchSizeGB * 1024

        Write-Verbose "Invoke-JournalScratchRestore: vpg=$VpgName journalMB=$JournalMB scratchMB=$ScratchMB"

        $SettingsId = $null
        try {
            $SettingsId = New-ZertoVpgsetting -Body @{ VpgIdentifier = $VpgId }

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

            Write-Verbose "Invoke-JournalScratchRestore: Committed restore for vpg=$VpgName"

            return [PSCustomObject]@{
                ZVMHost          = $ZVMHost
                VpgName          = $VpgName
                VpgIdentifier    = $VpgId
                JournalSizeGB    = $JournalSizeGB
                ScratchSizeGB    = $ScratchSizeGB
                DesiredJournalGB = 0
                DesiredScratchGB = 0
                Action           = 'Restored'
                Status           = 'Success'
                ErrorMessage     = $null
            }
        }
        catch {
            $ErrorMsg = $_.Exception.Message
            Write-Verbose "Invoke-JournalScratchRestore: Failed vpg=$VpgName error=$ErrorMsg"

            if (-not [string]::IsNullOrEmpty($SettingsId)) {
                try {
                    Remove-ZertoVpgsetting -Vpgsettingsidentifier $SettingsId | Out-Null
                }
                catch {
                    Write-Verbose "Invoke-JournalScratchRestore: Session cleanup failed settingsId=$SettingsId"
                }
            }

            return [PSCustomObject]@{
                ZVMHost          = $ZVMHost
                VpgName          = $VpgName
                VpgIdentifier    = $VpgId
                JournalSizeGB    = 0
                ScratchSizeGB    = 0
                DesiredJournalGB = 0
                DesiredScratchGB = 0
                Action           = 'Failed'
                Status           = 'Failure'
                ErrorMessage     = $ErrorMsg
            }
        }
    }
}
