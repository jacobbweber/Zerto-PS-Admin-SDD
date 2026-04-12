#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModulesRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..') 
    Import-Module (Join-Path $ModulesRoot 'ZertoZVM.APIWrapper\ZertoZVM.APIWrapper.psm1') -Force
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'Get-VpgJournalScratchState' {

    BeforeEach {
        Mock New-ZertoVpgsetting { return 'test-settings-id-001' }
        Mock Get-ZertoVpgsettingjournal { return [PSCustomObject]@{ HardLimitInMB = 51200 } }  # 50 GB
        Mock Get-ZertoVpgsettingscratch { return [PSCustomObject]@{ HardLimitInMB = 30720 } }  # 30 GB
        Mock Remove-ZertoVpgsetting { }
    }

    Context 'Happy path — valid VPG' {
        It 'Should return a state object with correct GB values' {
            $Result = Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'vpg-id-001' -VpgName 'TestVPG'

            $Result.ZVMHost       | Should -Be 'zvm01'
            $Result.VpgName       | Should -Be 'TestVPG'
            $Result.VpgIdentifier | Should -Be 'vpg-id-001'
            $Result.JournalSizeGB | Should -Be 50
            $Result.ScratchSizeGB | Should -Be 30
            $Result.CapturedAt    | Should -Not -BeNullOrEmpty
        }

        It 'Should call New-ZertoVpgsetting with the VpgIdentifier in the body' {
            Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'vpg-id-001' -VpgName 'TestVPG'
            Should -Invoke New-ZertoVpgsetting -Times 1 -ParameterFilter {
                $Body.VpgIdentifier -eq 'vpg-id-001'
            }
        }

        It 'Should call Remove-ZertoVpgsetting to discard the session (no commit)' {
            Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'vpg-id-001' -VpgName 'TestVPG'
            Should -Invoke Remove-ZertoVpgsetting -Times 1 -ParameterFilter {
                $Vpgsettingsidentifier -eq 'test-settings-id-001'
            }
        }

        It 'Should NOT call Start-ZertoVpgsettingcommit' {
            Mock Start-ZertoVpgsettingcommit { }
            Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'vpg-id-001' -VpgName 'TestVPG'
            Should -Invoke Start-ZertoVpgsettingcommit -Times 0
        }

        It 'Should floor fractional GB values correctly' {
            Mock Get-ZertoVpgsettingjournal { return [PSCustomObject]@{ HardLimitInMB = 1536 } }  # 1.5 GB → 1
            Mock Get-ZertoVpgsettingscratch { return [PSCustomObject]@{ HardLimitInMB = 2047 } }  # ~1.9 GB → 1
            $Result = Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'vpg-id-001' -VpgName 'TestVPG'
            $Result.JournalSizeGB | Should -Be 1
            $Result.ScratchSizeGB | Should -Be 1
        }
    }

    Context 'Error handling — session returns empty ID' {
        It 'Should throw when New-ZertoVpgsetting returns empty' {
            Mock New-ZertoVpgsetting { return '' }
            { Get-VpgJournalScratchState -ZVMHost 'zvm01' -VpgIdentifier 'bad-id' -VpgName 'BadVPG' } |
                Should -Throw
        }
    }
}
