#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Import-Module "$PSScriptRoot\..\..\ZertoZVM.APIWrapper.psd1" -Force

BeforeAll {
    . "$PSScriptRoot\TestHelper.ps1"
}

InModuleScope "ZertoZVM.APIWrapper" {
    Describe "Connect-ZertoZVM" {
        BeforeEach {
            $script:ZertoSession.Connected = $false
            $script:ZertoSession.CachedCredential = $null
            $script:ZertoSession.TokenTimestamp = [DateTime]::MinValue
            $script:ZertoSession.Headers = @{}
        }

        It "Should successfully construct session payload and save credentials locally" {
            $mockToken = "valid-token-123"
            Mock Invoke-RestMethod { return $mockToken }

            $cred = [PSCredential]::new("admin", ("secure" | ConvertTo-SecureString -AsPlainText -Force))
        
            $result = Connect-ZertoZVM -ZVMHost "localzvm" -Credential $cred

            $result.Connected | Should -Be $true
            $script:ZertoSession.Connected | Should -Be $true
            $script:ZertoSession.Headers['x-zerto-session'] | Should -Be "valid-token-123"
            $script:ZertoSession.CachedCredential | Should -BeExactly $cred
            $script:ZertoSession.TokenTimestamp.Date | Should -Be ([DateTime]::UtcNow.Date)
        }

        It "Should bypass authentication quietly executing purely via CachedCredential" {
            $mockToken = "renewed-token-456"
            Mock Invoke-RestMethod { return $mockToken }

            $cred = [PSCredential]::new("admin2", ("pass" | ConvertTo-SecureString -AsPlainText -Force))
            $script:ZertoSession.CachedCredential = $cred
        
            $result = Connect-ZertoZVM -ZVMHost "localzvm"
        
            $result.Connected | Should -Be $true
            $script:ZertoSession.Headers['x-zerto-session'] | Should -Be "renewed-token-456"
        }

        It "Should throw appropriately upon authentication failures terminating the script" {
            Mock Invoke-RestMethod { throw "401 Unauthorized" }
            $cred = [PSCredential]::new("admin", ("wrong" | ConvertTo-SecureString -AsPlainText -Force))

            { Connect-ZertoZVM -ZVMHost "localzvm" -Credential $cred } | Should -Throw "Connect-ZertoZVM failed: 401 Unauthorized"
            $script:ZertoSession.Connected | Should -Be $false
        }
    }
}
