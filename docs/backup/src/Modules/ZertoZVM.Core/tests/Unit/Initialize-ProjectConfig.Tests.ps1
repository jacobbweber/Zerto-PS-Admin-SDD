

BeforeAll {
    . "$PSScriptRoot\..\..\Public\Initialize-ProjectConfig.ps1"
}

Describe "Initialize-ProjectConfig" {
    Context "When provided a valid configuration content" {
        BeforeAll {
            $script:tempConfigPath = Join-Path $env:TEMP "test_valid_config.json"
            $mockConfigContent = @{
                base = @{
                    logging = @{
                        paths = @{
                            logdir = "C:\Logs\Zerto"
                            archive = "C:\Logs\Zerto\Archive"
                            state = "C:\Logs\Zerto\State"
                            telemetry = "C:\Logs\Zerto\Telemetry"
                        }
                    }
                    telemetry = @{
                        hostname = "dynatrace.corp.local"
                        username = "svc_zerto_auto"
                    }
                }
            } | ConvertTo-Json -Depth 5
            Set-Content -Path $script:tempConfigPath -Value $mockConfigContent -Encoding UTF8
        }
        
        AfterAll {
            if (Test-Path $script:tempConfigPath) { Remove-Item $script:tempConfigPath -Force }
        }

        It "Parses the configuration into the global scope without errors" {
            $global:Config = $null
            { Initialize-ProjectConfig -ConfigPath $script:tempConfigPath } | Should -Not -Throw
            $global:Config | Should -Not -BeNullOrEmpty
        }

        It "Contains the expected base logging paths" {
            $global:Config.base.logging.paths.logdir | Should -Be "C:\Logs\Zerto"
            $global:Config.base.telemetry.hostname | Should -Be "dynatrace.corp.local"
        }
    }

    Context "When the configuration path does not exist" {
        It "Throws an item not found exception" {
            { Initialize-ProjectConfig -ConfigPath "C:\NonExistent\Path\config.json" } | Should -Throw "path does not exist"
        }
    }
}
