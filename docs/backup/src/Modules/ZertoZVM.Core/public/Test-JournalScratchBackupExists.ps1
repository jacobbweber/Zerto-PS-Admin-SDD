function Test-JournalScratchBackupExists {
    <#
    .SYNOPSIS
        Returns $true if an unprocessed backup file exists for the specified ZVM.

    .DESCRIPTION
        Checks the backup directory for any JSON files that do not end with
        '_processed.json'. A file without the processed suffix is considered
        an active backup that blocks a new apply run for that ZVM.

    .PARAMETER ZVMHost
        The hostname of the ZVM to check the backup directory for.

    .PARAMETER BackupRoot
        The root directory under which per-ZVM backup subdirectories are located.
        Example: 'E:\scripts\log\Set-JournalAndScratch\backup'

    .OUTPUTS
        [bool] — $true if at least one unprocessed backup file is found, otherwise $false.

    .EXAMPLE
        $HasBackup = Test-JournalScratchBackupExists -ZVMHost 'zvm01' -BackupRoot 'E:\scripts\log\Set-JournalAndScratch\backup'
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$ZVMHost,

        [Parameter(Mandatory)]
        [string]$BackupRoot
    )

    process {
        $BackupDir = Join-Path -Path $BackupRoot -ChildPath $ZVMHost

        if (-not (Test-Path -Path $BackupDir)) {
            Write-Verbose "Test-JournalScratchBackupExists: Backup directory not found for zvm=$ZVMHost — treating as no backup"
            return $false
        }

        $UnprocessedFiles = @(Get-ChildItem -Path $BackupDir -Filter '*.json' -File |
            Where-Object { $_.Name -notlike '*_processed.json' })

        $HasBackup = $UnprocessedFiles.Count -gt 0

        Write-Verbose "Test-JournalScratchBackupExists: zvm=$ZVMHost hasUnprocessedBackup=$HasBackup"
        return $HasBackup
    }
}
