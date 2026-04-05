Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe "ZertoZVM.Core Module: Private Handlers" {
    BeforeAll {
        # To test private functions, we natively source them
        $privatePath = Join-Path $PSScriptRoot "..\..\private\Invoke-ThreadSafeFileWrite.ps1"
        . $privatePath
    }
    
    Context "Invoke-ThreadSafeFileWrite" {
        It "Successfully creates and writes to a file in an isolated drive" {
            $testPath = Join-Path $TestDrive "threadsafe_log.txt"
            $lines = @("First Line", "Second Line")
            
            Invoke-ThreadSafeFileWrite -FilePath $testPath -Lines $lines
            
            $content = Get-Content $testPath
            $content.Count | Should -Be 2
            $content[0] | Should -Be "First Line"
        }
        
        It "Throws if the file is completely locked indefinitely" {
            $testPath = Join-Path $TestDrive "locked.txt"
            New-Item -Path $testPath -ItemType File | Out-Null
            
            # Create a deliberate lock using System.IO
            $fileStream = [System.IO.File]::Open($testPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            
            try {
                { Invoke-ThreadSafeFileWrite -FilePath $testPath -Lines @("Failed Write") -MaxRetries 2 -DelayMilliseconds 10 } | Should -Throw
            }
            finally {
                $fileStream.Close()
            }
        }
    }

    Context "Initialize-ProjectConfig" {
        It "Successfully parses config and sets global state" {
            $testConfigStr = '{"base": {"logging": {"paths": {"logdir": "D:\\log"}}}}'
            $testConfigPath = Join-Path $TestDrive "testconfig.json"
            Set-Content -Path $testConfigPath -Value $testConfigStr
            
            # Using dot-source to ensure scope variables bind
            . (Join-Path $PSScriptRoot "..\..\public\Initialize-ProjectConfig.ps1")
            
            Initialize-ProjectConfig -Path $testConfigPath
            $Global:Config.base.logging.paths.logdir | Should -Be "D:\log"
        }
        
        It "Throws terminating error on missing file" {
            . (Join-Path $PSScriptRoot "..\..\public\Initialize-ProjectConfig.ps1")
            { Initialize-ProjectConfig -Path "C:\Does\Not\Exist.json" } | Should -Throw
        }
    }

    Context "Test-ProjectConfig" {
        It "Validates successfully when all paths are accessible" {
            $mockConfig = [PSCustomObject]@{
                base = [PSCustomObject]@{
                    logging = [PSCustomObject]@{
                        paths = [PSCustomObject]@{
                            logdir = $TestDrive
                            archive = $TestDrive
                            state = $TestDrive
                            telemetry = $TestDrive
                            syslog = Join-Path $TestDrive "syslog.log"
                            devlog = Join-Path $TestDrive "devlog.log"
                        }
                    }
                    auth = [PSCustomObject]@{
                        vmware_user = Join-Path $TestDrive "auth.xml"
                        vmware_password = Join-Path $TestDrive "auth_pass.xml"
                    }
                }
            }
            . (Join-Path $PSScriptRoot "..\..\public\Test-ProjectConfig.ps1")
            $res = Test-ProjectConfig -Config $mockConfig
            $res | Should -Be $true
        }
        
        It "Throws when a parent directory for a defined file path is missing" {
            $mockConfig = [PSCustomObject]@{
                base = [PSCustomObject]@{
                    logging = [PSCustomObject]@{
                        paths = [PSCustomObject]@{
                            logdir = $TestDrive
                            archive = $TestDrive
                            state = $TestDrive
                            telemetry = $TestDrive
                            syslog = "Z:\NonExistentDrive\syslog.log"
                            devlog = Join-Path $TestDrive "devlog.log"
                        }
                    }
                    auth = [PSCustomObject]@{
                        vmware_user = Join-Path $TestDrive "auth.xml"
                        vmware_password = Join-Path $TestDrive "auth_pass.xml"
                    }
                }
            }
            . (Join-Path $PSScriptRoot "..\..\public\Test-ProjectConfig.ps1")
            { Test-ProjectConfig -Config $mockConfig } | Should -Throw "*is missing or inaccessible.*"
        }
    }

    Context "Write-Log" {
        BeforeAll {
            . (Join-Path $PSScriptRoot "..\..\public\Write-Log.ps1")
        }
        
        It "Writes Debug only to dev stream" {
            $logPath = $TestDrive
            $sys = "sys.log"
            $dev = "dev.log"
            
            Write-Log -Level 'Debug' -Message 'Test debug' -LogPath $logPath -SyslogFileName $sys -DevLogFileName $dev
            
            $devContent = Get-Content (Join-Path $logPath $dev)
            $devContent | Should -Match "\[DEBUG\] Test debug"
            
            Test-Path (Join-Path $logPath $sys) | Should -Be $false
        }
        
        It "Writes Info to both streams" {
            $logPath = $TestDrive
            $sys = "sys2.log"
            $dev = "dev2.log"
            
            Write-Log -Level 'Info' -Message 'Test info' -LogPath $logPath -SyslogFileName $sys -DevLogFileName $dev
            
            $devContent = Get-Content (Join-Path $logPath $dev)
            $devContent | Should -Match "\[INFO\] Test info"
            
            $sysContent = Get-Content (Join-Path $logPath $sys)
            $sysContent | Should -Match "\[INFO\] Test info"
        }
    }
}
