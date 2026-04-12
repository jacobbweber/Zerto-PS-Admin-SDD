#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Import-Module "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psd1" -Force

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
}

InModuleScope "ZertoZVM.APIWrapper" {
    # Needs Mock for Assert-ZertoSession locally
    function Assert-ZertoSession {}

    Describe "Get-ZertoVPG" {
    It "Should invoke ZertoRequest with default path fetching all objects" {
        Mock Invoke-ZertoRequest { return "mock-all-objects" }

        $result = Get-ZertoVPG
        
        $result | Should -Be "mock-all-objects"
        Assert-MockCalled Invoke-ZertoRequest -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $UriPath -eq 'vpgs' -and $null -eq $QueryParameters
        }
    }

    It "Should invoke ZertoRequest with specific ID appended natively to UriPath" {
        Mock Invoke-ZertoRequest { return "mock-single-object" }

        $result = Get-ZertoVPG -VpgIdentifier 'xyz-123'
        
        $result | Should -Be "mock-single-object"
        Assert-MockCalled Invoke-ZertoRequest -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $UriPath -eq 'vpgs/xyz-123'
        }
    }

    It "Should inject Query Parameters strictly converting properties inside Get requests" {
        Mock Invoke-ZertoRequest { return "mock-filtered-object" }

        $result = Get-ZertoVPG -Name 'Prod' -Status 'MeetingSLA'
        
        $result | Should -Be "mock-filtered-object"
        Assert-MockCalled Invoke-ZertoRequest -Times 1 -ParameterFilter {
            $Method -eq 'GET' -and $UriPath -eq 'vpgs' -and $QueryParameters['name'] -eq 'Prod' -and $QueryParameters['status'] -eq 'MeetingSLA'
        }
    }
}
