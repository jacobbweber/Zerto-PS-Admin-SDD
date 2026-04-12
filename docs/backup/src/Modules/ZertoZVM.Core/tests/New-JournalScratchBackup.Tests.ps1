#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'New-JournalScratchBackup' {

    BeforeAll {
        $script:BackupRoot = 'TestDrive:\BackupRoot'
        $script:StateRecords = @(
            [PSCustomObject]@{
                ZVMHost       = 'zvm01'
                VpgName       = 'VPG-App-01'
                VpgIdentifier = 'vpg-id-001'
                JournalSizeGB = 50
                ScratchSizeGB = 30
                CapturedAt    = '2026-04-12T20:00:00Z'
            },
            [PSCustomObject]@{
                ZVMHost       = 'zvm01'
                VpgName       = 'VPG-App-02'
                VpgIdentifier = 'vpg-id-002'
                JournalSizeGB = 40
                ScratchSizeGB = 20
                CapturedAt    = '2026-04-12T20:00:01Z'
            }
        )
    }

    Context 'Directory does not exist' {
        It 'Should create the backup directory and write the file' {
            $ReturnedPath = New-JournalScratchBackup -ZVMHost 'zvm01' -BackupRoot $script:BackupRoot -StateRecords $script:StateRecords

            $ReturnedPath | Should -Not -BeNullOrEmpty
            Test-Path -Path $ReturnedPath | Should -Be $true
        }
    }

    Context 'File content validation' {
        It 'Should write valid JSON matching the input records' {
            $ReturnedPath = New-JournalScratchBackup -ZVMHost 'zvm01' -BackupRoot $script:BackupRoot -StateRecords $script:StateRecords

            $Content = Get-Content -Path $ReturnedPath -Raw | ConvertFrom-Json
            $Content.Count | Should -Be 2
            $Content[0].VpgName       | Should -Be 'VPG-App-01'
            $Content[0].JournalSizeGB | Should -Be 50
            $Content[1].VpgName       | Should -Be 'VPG-App-02'
            $Content[1].ScratchSizeGB | Should -Be 20
        }

        It 'Should name the file with yyyyMMdd-HHmmss.json format' {
            $ReturnedPath = New-JournalScratchBackup -ZVMHost 'zvm01' -BackupRoot $script:BackupRoot -StateRecords $script:StateRecords

            $FileName = Split-Path -Path $ReturnedPath -Leaf
            $FileName | Should -Match '^\d{8}-\d{6}\.json$'
        }

        It 'Should return the correct path that actually exists' {
            $ReturnedPath = New-JournalScratchBackup -ZVMHost 'zvm01' -BackupRoot $script:BackupRoot -StateRecords $script:StateRecords
            Test-Path -Path $ReturnedPath -PathType Leaf | Should -Be $true
        }
    }
}
