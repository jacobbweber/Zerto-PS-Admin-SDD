#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
    $ModulesRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..') 
    Import-Module (Join-Path $ModulesRoot 'ZertoZVM.APIWrapper\ZertoZVM.APIWrapper.psm1') -Force
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
    Import-Module (Join-Path $ModuleRoot 'ZertoZVM.Core.psm1') -Force
}

Describe 'Invoke-JournalScratchUpdate' {

    BeforeEach {
        Mock New-ZertoVpgsetting { return 'settings-id-001' }
        Mock Set-ZertoVpgsettingjournal { return $null }
        Mock Set-ZertoVpgsettingscratch { return $null }
        Mock Start-ZertoVpgsettingcommit { return $null }
        Mock Remove-ZertoVpgsetting { return $null }
    }

    Context 'Successful update' {
        It 'Should return Action=Updated and Status=Success' {
            $Result = Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            $Result.Action        | Should -Be 'Updated'
            $Result.Status        | Should -Be 'Success'
            $Result.ErrorMessage  | Should -BeNullOrEmpty
        }

        It 'Should call Set-ZertoVpgsettingjournal with correct MB value (50 GB = 51200 MB)' {
            Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            Should -Invoke Set-ZertoVpgsettingjournal -Times 1 -ParameterFilter {
                $Body.HardLimitInMB -eq 51200
            }
        }

        It 'Should call Set-ZertoVpgsettingscratch with correct MB value (30 GB = 30720 MB)' {
            Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            Should -Invoke Set-ZertoVpgsettingscratch -Times 1 -ParameterFilter {
                $Body.HardLimitInMB -eq 30720
            }
        }

        It 'Should call Start-ZertoVpgsettingcommit to commit the change' {
            Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            Should -Invoke Start-ZertoVpgsettingcommit -Times 1
        }

        It 'Should return the desired GB values in the result' {
            $Result = Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            $Result.DesiredJournalGB | Should -Be 50
            $Result.DesiredScratchGB | Should -Be 30
            $Result.JournalSizeGB    | Should -Be 50
            $Result.ScratchSizeGB    | Should -Be 30
        }
    }

    Context 'Failure — API throws during set journal' {
        BeforeEach {
            Mock Set-ZertoVpgsettingjournal { throw 'API Error: journal not writable' }
        }

        It 'Should return Action=Failed and Status=Failure' {
            $Result = Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            $Result.Action  | Should -Be 'Failed'
            $Result.Status  | Should -Be 'Failure'
            $Result.ErrorMessage | Should -Not -BeNullOrEmpty
        }

        It 'Should call Remove-ZertoVpgsetting to clean up the session on failure' {
            Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            Should -Invoke Remove-ZertoVpgsetting -Times 1
        }

        It 'Should NOT call Start-ZertoVpgsettingcommit when an error occurs' {
            Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            Should -Invoke Start-ZertoVpgsettingcommit -Times 0
        }
    }

    Context 'Failure — empty session ID returned' {
        BeforeEach {
            Mock New-ZertoVpgsetting { return '' }
        }

        It 'Should return Action=Failed when session ID is empty' {
            $Result = Invoke-JournalScratchUpdate -ZVMHost 'zvm01' -VpgIdentifier 'vpg-001' -VpgName 'AppVPG' -JournalSizeGB 50 -ScratchSizeGB 30
            $Result.Action | Should -Be 'Failed'
            $Result.Status | Should -Be 'Failure'
        }
    }
}
