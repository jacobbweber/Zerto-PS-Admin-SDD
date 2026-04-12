function New-JournalScratchBackup {
    <#
    .SYNOPSIS
        Writes a JSON backup file of VPG journal and scratch states for a ZVM.

    .DESCRIPTION
        Serializes the provided state records to a dated JSON file in the per-ZVM
        backup subdirectory. The directory is created if it does not already exist.
        The resulting file name uses the format: yyyyMMdd-HHmmss.json

        This backup must be created BEFORE any VPG settings changes are applied,
        ensuring that every apply run is reversible via -Restore.

    .PARAMETER ZVMHost
        The hostname of the ZVM whose VPGs are being backed up.

    .PARAMETER BackupRoot
        The root backup directory. A subdirectory named after ZVMHost will be
        created within it if needed.

    .PARAMETER StateRecords
        An array of PSCustomObjects produced by Get-VpgJournalScratchState,
        representing the current journal and scratch sizes for each VPG.

    .OUTPUTS
        [string] — The full path of the backup file that was written.

    .EXAMPLE
        $Path = New-JournalScratchBackup -ZVMHost 'zvm01' -BackupRoot 'E:\scripts\log\Set-JournalAndScratch\backup' -StateRecords $StateRecords
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$ZVMHost,

        [Parameter(Mandatory)]
        [string]$BackupRoot,

        [Parameter(Mandatory)]
        [PSCustomObject[]]$StateRecords
    )

    process {
        $BackupDir = Join-Path -Path $BackupRoot -ChildPath $ZVMHost

        if (-not (Test-Path -Path $BackupDir)) {
            Write-Verbose "New-JournalScratchBackup: Creating backup directory path=$BackupDir"
            New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        }

        $Timestamp   = Get-Date -Format 'yyyyMMdd-HHmmss'
        $BackupFile  = Join-Path -Path $BackupDir -ChildPath "$Timestamp.json"

        Write-Verbose "New-JournalScratchBackup: Writing backup for zvm=$ZVMHost records=$($StateRecords.Count) file=$BackupFile"

        $StateRecords | ConvertTo-Json -Depth 5 | Out-File -FilePath $BackupFile -Encoding utf8 -Force

        return $BackupFile
    }
}
