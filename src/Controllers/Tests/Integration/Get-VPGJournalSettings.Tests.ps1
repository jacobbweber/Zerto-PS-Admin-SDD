#Requires -Modules @{ModuleName='Pester';ModuleVersion='5.0.0'}

Describe "Get-VPGJournalSettings Integration" {
    BeforeAll {
        $ModuleRoot = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "../../../Modules")
        $env:PSModulePath = "$($ModuleRoot);$($env:PSModulePath)"
        
        Import-Module ZertoZVM.Core -Force
        Import-Module ZertoZVM.APIWrapper -Force
        Import-Module InfraCode.Telemetry -Force
        Import-Module InfraCode.Email -Force

        $SharedMocks = Join-Path -Path $PSScriptRoot -ChildPath "../Shared/mocks.ps1"
        if (Test-Path -Path $SharedMocks) { . $SharedMocks }
        
        $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "../../Get-VPGJournalSettings.ps1"
    }

    It "Should execute the script in Simulation mode and successfully produce results" {
        # Execute the script
        & $ScriptPath -Simulation | Out-Null
        
        # Verify telemetry was called
        Assert-MockCalled New-ProjectTelemetry -Times 1
        Assert-MockCalled Complete-ProjectTelemetry -Times 1
    }

    It "Should search all ZVMs for a specific VPG when -VpgName is provided" {
        # Execution with targeted VPG search
        & $ScriptPath -Simulation -VpgName "VPG_Production_SQL" | Out-Null
        
        # Verify VPG retrieval call
        Assert-MockCalled Get-ZertoVPG -Times 1
    }

    Context "Outputs" {
        It "Should invoke CSV export when -CSV is active" {
            & $ScriptPath -Simulation -CSV | Out-Null
            Assert-MockCalled Export-ProjectCSVReport -Times 1
        }

        It "Should invoke Email when -Email is active" {
            & $ScriptPath -Simulation -Email | Out-Null
            Assert-MockCalled Send-FormattedEmail -Times 1
        }

        It "Should output headerless CSV when -Doctor is active" {
            # Capture output
            $output = & $ScriptPath -Simulation -Doctor | Out-String
            
            # Verify it contains mock data line (at least one)
            $output | Should -Match "VPG_Production_SQL,vpg-86b208eb-21be-4161-9f93-c2d3a371879b,Site_A"
        }
    }
}
