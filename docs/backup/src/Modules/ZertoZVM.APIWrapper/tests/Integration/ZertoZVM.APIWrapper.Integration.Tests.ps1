#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

# Integration Tests: ZertoZVM.APIWrapper
# Requirements: A running ZVM instance and valid credentials injected via Environment Variables.
# E.g. $env:ZVM_HOST, $env:ZVM_USER, $env:ZVM_PASS

BeforeAll {
    . "$PSScriptRoot\..\..\src\Modules\InfraCore.ZertoZVM\ZertoZVM.APIWrapper.psm1"

    $script:integrationTarget = $env:ZVM_HOST
    $script:userName = $env:ZVM_USER
    $script:password = $env:ZVM_PASS

    if (-not $script:integrationTarget -or -not $script:userName -or -not $script:password) {
        Write-Warning "Skipping Integration Tests: ZVM_HOST, ZVM_USER, and ZVM_PASS environment variables are required."
    }
}

Describe "ZertoZVM.APIWrapper Live Integration" -Skip:(-not $script:integrationTarget) {
    
    It "Should connect successfully and establish session state natively" {
        $cred = [PSCredential]::new($script:userName, ($script:password | ConvertTo-SecureString -AsPlainText -Force))
        
        $result = Connect-ZertoZVM -ZVMHost $script:integrationTarget -Credential $cred -SkipCertificateCheck
        
        $result.Connected | Should -Be $true
        $script:ZertoSession.Connected | Should -Be $true
        $script:ZertoSession.Headers['x-zerto-session'] | Should -Not -BeNullOrEmpty
    }

    It "Should retrieve at least one VPG or safely return empty arrays utilizing GET methods" {
        $vpgs = Get-ZertoVPG
        
        # Validates standard REST extraction natively mapped
        if ($null -ne $vpgs) {
            $vpgs[0].VpgIdentifier | Should -Not -BeNullOrEmpty
        }
    }

    It "Should safely execute -WhatIf against mutative Actions without side effects" {
        $vpgs = Get-ZertoVPG
        if ($null -ne $vpgs -and $vpgs.Count -gt 0) {
            $id = $vpgs[0].VpgIdentifier
            
            # This must bypass the HTTP logic securely
            $result = Start-ZertoFailover -VpgIdentifier $id -WhatIf
            $result | Should -BeNullOrEmpty
        }
        else {
            Set-ItResult -Inconclusive -Message "No VPGs available to test WhatIf logic natively."
        }
    }

    It "Should disconnect safely and completely eradicate memory dependencies organically" {
        Disconnect-ZertoZVM
        
        $script:ZertoSession.Connected | Should -Be $false
        $script:ZertoSession.CachedCredential | Should -BeNullOrEmpty
        $script:ZertoSession.Headers.Count | Should -Be 0
    }
}
