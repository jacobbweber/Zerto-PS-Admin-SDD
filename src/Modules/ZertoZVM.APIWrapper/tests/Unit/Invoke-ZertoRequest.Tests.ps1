#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Import-Module "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psd1" -Force

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
}

InModuleScope "ZertoZVM.APIWrapper" {
    Describe "Invoke-ZertoRequest" {
    BeforeEach {
        # Reset Session for each context isolation
        $script:ZertoSession.BaseUri = "https://mock.zvm.local"
        $script:ZertoSession.ApiVersion = "v1"
        $script:ZertoSession.Headers = @{ 'x-zerto-session' = 'mock-123' }
        $script:ZertoSession.SkipCertificateCheck = $true
        $script:ZertoSession.Connected = $true
    }

    It "Should construct proper URI with Query Parameters and emit Write-Verbose" {
        $mockedResponse = [PSCustomObject]@{ ok = $true }
        Mock Invoke-RestMethod { return $mockedResponse }

        $queryParams = @{ filter = "status eq 'MeetingSLA'" }
        $result = Invoke-ZertoRequest -Method GET -UriPath "/vpgs" -QueryParameters $queryParams -Verbose 4>&1

        $result.ok | Should -Be $true
        
        # Verbose output checking natively through Redirection stream
        $verboseMsg = $result | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | Select-Object -ExpandProperty Message
        $verboseMsg | Should -Match "GET https://mock.zvm.local:443/vra/api/v1/vpgs\?"
    }

    It "Should explicitly throw typed errors catching HTTP Exception details natively" {
        Mock Invoke-RestMethod { 
            throw [System.Management.Automation.RuntimeException]::new("Mocked connection failure")
        }

        { Invoke-ZertoRequest -Method POST -UriPath "/vpgs/failover" } | Should -Throw "Zerto API error \[Unknown\] calling POST https://mock.zvm.local:443/vra/api/v1/vpgs/failover — Mocked connection failure"
    }
}
