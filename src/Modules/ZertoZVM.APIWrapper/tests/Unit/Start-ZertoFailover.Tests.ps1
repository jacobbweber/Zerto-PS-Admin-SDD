#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Import-Module "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psd1" -Force

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
}

InModuleScope "ZertoZVM.APIWrapper" {
    function Assert-ZertoSession {}
    
    Describe "Start-ZertoFailover" {
    It "Should bypass HTTP proxy entirely when WhatIf natively triggers" {
        Mock Invoke-ZertoRequest { return "Should-Not-Trigger" }

        $result = Start-ZertoFailover -VpgIdentifier 'xyz-123' -WhatIf
        
        $result | Should -BeNullOrEmpty
        Assert-MockCalled Invoke-ZertoRequest -Times 0
    }

    It "Should execute HTTP mapped paths natively securely bypassing exceptions returning JSON properties" {
        Mock Invoke-ZertoRequest { return [PSCustomObject]@{ TaskId = "tsk-123" } }

        $result = Start-ZertoFailover -VpgIdentifier 'xyz-123'
        
        $result.TaskId | Should -Be 'tsk-123'
        Assert-MockCalled Invoke-ZertoRequest -Times 1 -ParameterFilter {
            $Method -eq 'POST' -and $UriPath -eq 'vpgs/xyz-123/failover'
        }
    }
}
}
