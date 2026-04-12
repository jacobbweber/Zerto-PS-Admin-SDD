#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Import-Module "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psd1" -Force

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
}

InModuleScope "ZertoZVM.APIWrapper" {
    Describe "Assert-ZertoSession" {
        BeforeEach {
        $script:ZertoSession.Connected = $true
        $script:ZertoSession.BaseUri = "https://mock.zvm.local"
        $script:ZertoSession.ApiVersion = "v1"
        $script:ZertoSession.Headers = @{ 'x-zerto-session' = 'active-token-123' }
    }

    It "Should throw InvalidOperationException if completely disconnected" {
        $script:ZertoSession.Connected = $false

        { Assert-ZertoSession } | Should -Throw "*No active Zerto session*"
    }

    It "Should pass quietly natively if TokenTimestamp is younger than 5 minute TTL" {
        # Artificially subtract 2 minutes from UTC
        $script:ZertoSession.TokenTimestamp = ([DateTime]::UtcNow).AddMinutes(-2)

        Mock Connect-ZertoZVM { return $true }

        Assert-ZertoSession

        Assert-MockCalled Connect-ZertoZVM -Times 0
    }

    It "Should natively invoke Connect-ZertoZVM performing silent refreshes if TTL exceeds 5 mins" {
        # Artificially subtract 6 minutes from UTC
        $script:ZertoSession.TokenTimestamp = ([DateTime]::UtcNow).AddMinutes(-6)

        Mock Connect-ZertoZVM { return $true }

        Assert-ZertoSession

        Assert-MockCalled Connect-ZertoZVM -Times 1 -ParameterFilter {
            $ZVMHost -eq "mock.zvm.local" -and $ApiVersion -eq "v1"
        }
    }
}
}
