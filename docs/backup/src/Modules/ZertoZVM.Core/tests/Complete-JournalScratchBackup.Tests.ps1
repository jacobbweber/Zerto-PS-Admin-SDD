#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'Complete-JournalScratchBackup' {

    Context 'Successful rename' {
        BeforeEach {
            New-Item -Path 'TestDrive:\Backup\zvm01' -ItemType Directory -Force | Out-Null
            $script:OriginalFile = 'TestDrive:\Backup\zvm01\20260412-164500.json'
            New-Item -Path $script:OriginalFile -ItemType File -Force | Out-Null
        }

        It 'Should rename the file to include _processed suffix' {
            $NewPath = Complete-JournalScratchBackup -BackupFilePath $script:OriginalFile
            $NewPath | Should -Match '_processed\.json$'
        }

        It 'Should return the path of the new processed file' {
            $NewPath = Complete-JournalScratchBackup -BackupFilePath $script:OriginalFile
            Test-Path -Path $NewPath -PathType Leaf | Should -Be $true
        }

        It 'Should remove the original unprocessed file' {
            Complete-JournalScratchBackup -BackupFilePath $script:OriginalFile
            Test-Path -Path $script:OriginalFile | Should -Be $false
        }

        It 'Should produce a correctly formatted processed filename' {
            $NewPath = Complete-JournalScratchBackup -BackupFilePath $script:OriginalFile
            $FileName = Split-Path -Path $NewPath -Leaf
            $FileName | Should -Be '20260412-164500_processed.json'
        }
    }

    Context 'Error — file does not exist' {
        It 'Should throw when the backup file is not found' {
            $FakePath = 'TestDrive:\Backup\zvm99\nonexistent.json'
            { Complete-JournalScratchBackup -BackupFilePath $FakePath } |
                Should -Throw
        }
    }
}
