#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModulesRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..') 
    Import-Module (Join-Path $ModulesRoot 'ZertoZVM.APIWrapper\ZertoZVM.APIWrapper.psm1') -Force
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'Invoke-JournalScratchRestore' {

    BeforeAll {
        $script:BackupRecord = [PSCustomObject]@{
            ZVMHost       = 'zvm01'
            VpgName       = 'VPG-App-01'
            VpgIdentifier = 'vpg-id-001'
            JournalSizeGB = 50
            ScratchSizeGB = 30
            CapturedAt    = '2026-04-12T20:00:00Z'
        }
    }

    BeforeEach {
        Mock New-ZertoVpgsetting { return 'restore-session-id-001' }
        Mock Set-ZertoVpgsettingjournal { return $null }
        Mock Set-ZertoVpgsettingscratch { return $null }
        Mock Start-ZertoVpgsettingcommit { return $null }
        Mock Remove-ZertoVpgsetting { return $null }
    }

    Context 'Successful restore' {
        It 'Should return Action=Restored and Status=Success' {
            $Result = Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            $Result.Action | Should -Be 'Restored'
            $Result.Status | Should -Be 'Success'
            $Result.ErrorMessage | Should -BeNullOrEmpty
        }

        It 'Should use journal size from backup record (50 GB = 51200 MB)' {
            Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            Should -Invoke Set-ZertoVpgsettingjournal -Times 1 -ParameterFilter {
                $Body.HardLimitInMB -eq 51200
            }
        }

        It 'Should use scratch size from backup record (30 GB = 30720 MB)' {
            Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            Should -Invoke Set-ZertoVpgsettingscratch -Times 1 -ParameterFilter {
                $Body.HardLimitInMB -eq 30720
            }
        }

        It 'Should call Start-ZertoVpgsettingcommit to commit the restore' {
            Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            Should -Invoke Start-ZertoVpgsettingcommit -Times 1
        }

        It 'Should return DesiredJournalGB and DesiredScratchGB as 0 in restore mode' {
            $Result = Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            $Result.DesiredJournalGB | Should -Be 0
            $Result.DesiredScratchGB | Should -Be 0
        }
    }

    Context 'Failure — commit throws' {
        BeforeEach {
            Mock Start-ZertoVpgsettingcommit { throw 'Commit failed: ZVM unreachable' }
        }

        It 'Should return Action=Failed and Status=Failure' {
            $Result = Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            $Result.Action | Should -Be 'Failed'
            $Result.Status | Should -Be 'Failure'
        }

        It 'Should call Remove-ZertoVpgsetting to clean up the session' {
            Invoke-JournalScratchRestore -ZVMHost 'zvm01' -BackupRecord $script:BackupRecord
            Should -Invoke Remove-ZertoVpgsetting -Times 1
        }
    }
}
