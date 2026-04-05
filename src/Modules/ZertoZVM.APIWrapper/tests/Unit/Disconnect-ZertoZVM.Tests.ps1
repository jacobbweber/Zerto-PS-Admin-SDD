#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
    . "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psm1"
    Get-ChildItem -Path "$PSScriptRoot\..\..\Private" -Filter '*.ps1' | ForEach-Object { . $_.FullName }
    Get-ChildItem -Path "$PSScriptRoot\..\..\Public" -Filter '*.ps1' | ForEach-Object { . $_.FullName }
}

Describe "Disconnect-ZertoZVM" {
    BeforeEach {
        $script:ZertoSession.Connected = $true
        $script:ZertoSession.BaseUri = "https://mock.zvm.local"
        $script:ZertoSession.ApiVersion = "v1"
        $script:ZertoSession.Headers = @{ 'x-zerto-session' = 'active-token-123' }
        $script:ZertoSession.TokenTimestamp = ([DateTime]::UtcNow)
        $script:ZertoSession.CachedCredential = [PSCredential]::new("admin", ("secure" | ConvertTo-SecureString -AsPlainText -Force))
    }

    It "Should invoke proxy DELETE explicitly natively tearing down server allocations then clearing memory cleanly" {
        Mock Invoke-ZertoRequest { return $true }

        Disconnect-ZertoZVM

        Assert-MockCalled Invoke-ZertoRequest -Times 1 -ParameterFilter {
            $Method -eq 'DELETE' -and $UriPath -eq 'session'
        }

        # Assert explicitly that secure CachedCredentials and tokens are permanently nullified
        $script:ZertoSession.Connected | Should -Be $false
        $script:ZertoSession.BaseUri | Should -BeNullOrEmpty
        $script:ZertoSession.Headers.Count | Should -Be 0
        $script:ZertoSession.CachedCredential | Should -BeNullOrEmpty
        $script:ZertoSession.TokenTimestamp | Should -Be ([DateTime]::MinValue)
    }

    It "Should bypass DELETE requests silently maintaining error routing naturally without exploding if ZVM is totally offline" {
        Mock Invoke-ZertoRequest { throw "Server offline" }

        { Disconnect-ZertoZVM -WarningAction SilentlyContinue } | Should -Not -Throw

        # Assert memory still destroyed defensively logically
        $script:ZertoSession.Connected | Should -Be $false
        $script:ZertoSession.CachedCredential | Should -BeNullOrEmpty
    }

    It "Should bypass HTTP proxy entirely executing specifically through -WhatIf natively safely" {
        Mock Invoke-ZertoRequest { return "Should-Not-Trigger" }

        # Act
        Disconnect-ZertoZVM -WhatIf

        # Assert nothing triggered HTTP logic defensively
        Assert-MockCalled Invoke-ZertoRequest -Times 0
        
        # In actual execution under what-if, finally block still fires logically erasing natively in this design
        # If we wanted what-if to bypass in-memory clearing, we would encapsulate the clear logic uniquely inside ShouldProcess.
        # Given current script, the finally block evaluates invariably.
    }
}
