function Complete-JournalScratchBackup {
    <#
    .SYNOPSIS
        Marks a backup file as processed by renaming it with a '_processed' suffix.

    .DESCRIPTION
        Renames the specified backup JSON file to insert '_processed' before the '.json'
        extension. For example: '20260412-164500.json' → '20260412-164500_processed.json'

        A processed backup file is excluded from the unprocessed check performed by
        Test-JournalScratchBackupExists, which allows future apply runs to proceed for
        the same ZVM.

        Throws if the target file does not exist.

    .PARAMETER BackupFilePath
        The full path to the unprocessed backup JSON file.

    .OUTPUTS
        [string] — The new full path of the renamed (processed) backup file.

    .EXAMPLE
        $NewPath = Complete-JournalScratchBackup -BackupFilePath 'E:\scripts\log\Set-JournalAndScratch\backup\zvm01\20260412-164500.json'
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$BackupFilePath
    )

    process {
        if (-not (Test-Path -Path $BackupFilePath -PathType Leaf)) {
            throw "Complete-JournalScratchBackup: Backup file not found at path=$BackupFilePath"
        }

        $Directory = Split-Path -Path $BackupFilePath -Parent
        $BaseName  = [System.IO.Path]::GetFileNameWithoutExtension($BackupFilePath)
        $NewName   = "${BaseName}_processed.json"
        $NewPath   = Join-Path -Path $Directory -ChildPath $NewName

        Write-Verbose "Complete-JournalScratchBackup: Renaming backup=$BackupFilePath to processed=$NewPath"

        if (Test-Path -Path $NewPath) {
            Remove-Item -Path $NewPath -Force
        }

        Rename-Item -Path $BackupFilePath -NewName $NewName

        return $NewPath
    }
}
