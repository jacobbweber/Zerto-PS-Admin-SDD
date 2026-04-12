#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'Test-JournalScratchBackupExists' {

    Context 'No backup directory' {
        It 'Should return $false when directory does not exist' {
            $Result = Test-JournalScratchBackupExists -ZVMHost 'zvm-nodir' -BackupRoot 'TestDrive:\BackupRoot'
            $Result | Should -Be $false
        }
    }

    Context 'Backup directory exists — no files' {
        BeforeEach {
            New-Item -Path 'TestDrive:\BackupRoot\zvm01' -ItemType Directory -Force | Out-Null
        }

        It 'Should return $false when directory is empty' {
            $Result = Test-JournalScratchBackupExists -ZVMHost 'zvm01' -BackupRoot 'TestDrive:\BackupRoot'
            $Result | Should -Be $false
        }
    }

    Context 'Backup directory with unprocessed file' {
        BeforeEach {
            New-Item -Path 'TestDrive:\BackupRoot\zvm02' -ItemType Directory -Force | Out-Null
            New-Item -Path 'TestDrive:\BackupRoot\zvm02\20260412-120000.json' -ItemType File -Force | Out-Null
        }

        It 'Should return $true when an unprocessed JSON exists' {
            $Result = Test-JournalScratchBackupExists -ZVMHost 'zvm02' -BackupRoot 'TestDrive:\BackupRoot'
            $Result | Should -Be $true
        }
    }

    Context 'Backup directory with only processed files' {
        BeforeEach {
            New-Item -Path 'TestDrive:\BackupRoot\zvm03' -ItemType Directory -Force | Out-Null
            New-Item -Path 'TestDrive:\BackupRoot\zvm03\20260412-120000_processed.json' -ItemType File -Force | Out-Null
        }

        It 'Should return $false when only processed backups exist' {
            $Result = Test-JournalScratchBackupExists -ZVMHost 'zvm03' -BackupRoot 'TestDrive:\BackupRoot'
            $Result | Should -Be $false
        }
    }

    Context 'Backup directory with both processed and unprocessed files' {
        BeforeEach {
            New-Item -Path 'TestDrive:\BackupRoot\zvm04' -ItemType Directory -Force | Out-Null
            New-Item -Path 'TestDrive:\BackupRoot\zvm04\20260412-100000_processed.json' -ItemType File -Force | Out-Null
            New-Item -Path 'TestDrive:\BackupRoot\zvm04\20260412-120000.json' -ItemType File -Force | Out-Null
        }

        It 'Should return $true when at least one unprocessed file exists alongside processed ones' {
            $Result = Test-JournalScratchBackupExists -ZVMHost 'zvm04' -BackupRoot 'TestDrive:\BackupRoot'
            $Result | Should -Be $true
        }
    }
}
