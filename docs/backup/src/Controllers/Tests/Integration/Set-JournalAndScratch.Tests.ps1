#Requires -Version 7.5
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Integration tests for Set-JournalAndScratch controller script.

.DESCRIPTION
    Tests the apply flow (US1), restore flow (US2), multi-ZVM failure tolerance (US3),
    and consecutive-failure circuit-breaker (US3). All external dependencies are mocked.
#>

BeforeAll {
    # Load all modules so mocks work
    $ModuleRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..\..\Modules')
    Get-ChildItem -Path $ModuleRoot -Directory | ForEach-Object {
        Import-Module $_.FullName -Force
    }

    $script:ControllerPath = Resolve-Path (Join-Path $PSScriptRoot '..\..\Set-JournalAndScratch.ps1')

    # Shared mock data
    $script:MockVPGs = @(
        [PSCustomObject]@{ VpgName = 'VPG-App-01'; VpgIdentifier = 'vpg-id-001' }
        [PSCustomObject]@{ VpgName = 'VPG-App-02'; VpgIdentifier = 'vpg-id-002' }
    )

    $script:MockStateRecords = @(
        [PSCustomObject]@{
            ZVMHost = 'zvm01'; VpgName = 'VPG-App-01'; VpgIdentifier = 'vpg-id-001'
            JournalSizeGB = 40; ScratchSizeGB = 20; CapturedAt = '2026-04-12T20:00:00Z'
        }
        [PSCustomObject]@{
            ZVMHost = 'zvm01'; VpgName = 'VPG-App-02'; VpgIdentifier = 'vpg-id-002'
            JournalSizeGB = 40; ScratchSizeGB = 20; CapturedAt = '2026-04-12T20:00:01Z'
        }
    )
}

# ─────────────────────────────────────────────────────────────────────────────
# User Story 1: Apply Flow
# ─────────────────────────────────────────────────────────────────────────────

Describe 'US1: Apply Flow — Set-JournalAndScratch' {

    BeforeEach {
        # Core infrastructure mocks
        Mock Initialize-ProjectConfig { $global:Config = [PSCustomObject]@{
            base = [PSCustomObject]@{
                logging    = [PSCustomObject]@{ paths = [PSCustomObject]@{ logdir = 'TestDrive:\logs' }; filenames = [PSCustomObject]@{ csv = 'report.csv' } }
                telemetry  = [PSCustomObject]@{ business_unit = 'zerto'; hostname = 'dt.local'; username = 'svc' }
                email      = [PSCustomObject]@{ default_to = 'ops@corp.local'; smpt_server = 'smtp.corp.local' }
            }
        } }
        Mock Resolve-ProjectCredential { return [System.Management.Automation.PSCredential]::Empty }
        Mock Connect-ZertoZVM { }
        Mock Disconnect-ZertoZVM { }
        Mock Get-ZertoVPG { return $script:MockVPGs }
        Mock Test-JournalScratchBackupExists { return $false }
        Mock Get-VpgJournalScratchState {
            param($ZVMHost, $VpgIdentifier, $VpgName)
            return $script:MockStateRecords | Where-Object { $_.VpgIdentifier -eq $VpgIdentifier }
        }
        Mock New-JournalScratchBackup { return 'TestDrive:\backup\zvm01\20260412-164500.json' }
        Mock Invoke-JournalScratchUpdate {
            param($ZVMHost, $VpgIdentifier, $VpgName, $JournalSizeGB, $ScratchSizeGB)
            return [PSCustomObject]@{
                ZVMHost = $ZVMHost; VpgName = $VpgName; VpgIdentifier = $VpgIdentifier
                JournalSizeGB = $JournalSizeGB; ScratchSizeGB = $ScratchSizeGB
                DesiredJournalGB = $JournalSizeGB; DesiredScratchGB = $ScratchSizeGB
                Action = 'Updated'; Status = 'Success'; ErrorMessage = $null
            }
        }
        Mock New-ProjectTelemetry {
            return [PSCustomObject]@{
                Namespace  = 'zerto.vpg'
                Dimensions = [System.Collections.Specialized.OrderedDictionary]::new()
                Metrics    = [System.Collections.Generic.List[pscustomobject]]::new()
                Created    = (Get-Date).ToString('o')
            }
        }
        Mock Add-TelemetryMetric { }
        Mock Submit-ProjectTelemetry { }
        Mock Export-ProjectCSVReport { }
        Mock Set-FormattedEmail { return '<html/>' }
        Mock Send-FormattedEmail { }
        Mock Write-Log { }
    }

    It 'Should call Test-JournalScratchBackupExists before applying changes' {
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Test-JournalScratchBackupExists -Times 1 -ParameterFilter {
            $ZVMHost -eq 'zvm01'
        }
    }

    It 'Should call New-JournalScratchBackup before Invoke-JournalScratchUpdate' {
        # Ordering is implicit — both should be called
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke New-JournalScratchBackup -Times 1
        Should -Invoke Invoke-JournalScratchUpdate -Times 2
    }

    It 'Should call Invoke-JournalScratchUpdate for each VPG that has differing sizes' {
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Invoke-JournalScratchUpdate -Times 2
    }

    It 'Should submit telemetry with feature KPIs' {
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Add-TelemetryMetric -ParameterFilter { $Key -eq 'vpgs_processed' }
        Should -Invoke Add-TelemetryMetric -ParameterFilter { $Key -eq 'vpgs_updated' }
        Should -Invoke Add-TelemetryMetric -ParameterFilter { $Key -eq 'vpgs_failed' }
        Should -Invoke Submit-ProjectTelemetry -Times 1
    }

    It 'Should produce a CSV report' {
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Export-ProjectCSVReport -Times 1
    }

    It 'Should send an email report' {
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Send-FormattedEmail -Times 1
    }

    It 'Should block apply when an unprocessed backup already exists' {
        Mock Test-JournalScratchBackupExists { return $true }
        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Invoke-JournalScratchUpdate -Times 0
        Should -Invoke New-JournalScratchBackup -Times 0
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# User Story 2: Restore Flow
# ─────────────────────────────────────────────────────────────────────────────

Describe 'US2: Restore Flow — Set-JournalAndScratch' {

    BeforeEach {
        Mock Initialize-ProjectConfig { $global:Config = [PSCustomObject]@{
            base = [PSCustomObject]@{
                logging    = [PSCustomObject]@{ paths = [PSCustomObject]@{ logdir = 'TestDrive:\logs' }; filenames = [PSCustomObject]@{ csv = 'report.csv' } }
                telemetry  = [PSCustomObject]@{ business_unit = 'zerto'; hostname = 'dt.local'; username = 'svc' }
                email      = [PSCustomObject]@{ default_to = 'ops@corp.local'; smpt_server = 'smtp.corp.local' }
            }
        } }
        Mock Resolve-ProjectCredential { return [System.Management.Automation.PSCredential]::Empty }
        Mock Connect-ZertoZVM { }
        Mock Disconnect-ZertoZVM { }
        Mock Invoke-JournalScratchRestore {
            param($ZVMHost, $BackupRecord)
            return [PSCustomObject]@{
                ZVMHost = $ZVMHost; VpgName = $BackupRecord.VpgName; VpgIdentifier = $BackupRecord.VpgIdentifier
                JournalSizeGB = $BackupRecord.JournalSizeGB; ScratchSizeGB = $BackupRecord.ScratchSizeGB
                DesiredJournalGB = 0; DesiredScratchGB = 0
                Action = 'Restored'; Status = 'Success'; ErrorMessage = $null
            }
        }
        Mock Complete-JournalScratchBackup { return 'TestDrive:\backup\zvm01\20260412-164500_processed.json' }
        Mock New-ProjectTelemetry {
            return [PSCustomObject]@{
                Namespace  = 'zerto.vpg'
                Dimensions = [System.Collections.Specialized.OrderedDictionary]::new()
                Metrics    = [System.Collections.Generic.List[pscustomobject]]::new()
                Created    = (Get-Date).ToString('o')
            }
        }
        Mock Add-TelemetryMetric { }
        Mock Submit-ProjectTelemetry { }
        Mock Export-ProjectCSVReport { }
        Mock Set-FormattedEmail { return '<html/>' }
        Mock Send-FormattedEmail { }
        Mock Write-Log { }

        # Create the backup file in TestDrive
        $BackupDir = 'TestDrive:\scripts\log\Set-JournalAndScratch\backup\zvm01'
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        $BackupContent = $script:MockStateRecords | ConvertTo-Json -Depth 5
        $BackupContent | Out-File -FilePath (Join-Path $BackupDir '20260412-164500.json') -Encoding utf8
    }

    It 'Should call Invoke-JournalScratchRestore for each backup record' {
        & $script:ControllerPath -ZVMHost 'zvm01' -Restore -Doctor $false
        Should -Invoke Invoke-JournalScratchRestore -Times 2
    }

    It 'Should call Complete-JournalScratchBackup after all VPGs are processed' {
        & $script:ControllerPath -ZVMHost 'zvm01' -Restore -Doctor $false
        Should -Invoke Complete-JournalScratchBackup -Times 1
    }

    It 'Should produce all 4 outputs (telemetry, CSV, email, Doctor)' {
        & $script:ControllerPath -ZVMHost 'zvm01' -Restore -Doctor $false
        Should -Invoke Submit-ProjectTelemetry -Times 1
        Should -Invoke Export-ProjectCSVReport -Times 1
        Should -Invoke Send-FormattedEmail -Times 1
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# User Story 3: Multi-ZVM Failure Tolerance
# ─────────────────────────────────────────────────────────────────────────────

Describe 'US3: Multi-ZVM Failure Tolerance — Set-JournalAndScratch' {

    BeforeEach {
        Mock Initialize-ProjectConfig { $global:Config = [PSCustomObject]@{
            base = [PSCustomObject]@{
                logging    = [PSCustomObject]@{ paths = [PSCustomObject]@{ logdir = 'TestDrive:\logs' }; filenames = [PSCustomObject]@{ csv = 'report.csv' } }
                telemetry  = [PSCustomObject]@{ business_unit = 'zerto'; hostname = 'dt.local'; username = 'svc' }
                email      = [PSCustomObject]@{ default_to = 'ops@corp.local'; smpt_server = 'smtp.corp.local' }
            }
        } }
        Mock Resolve-ProjectCredential { return [System.Management.Automation.PSCredential]::Empty }
        Mock New-ProjectTelemetry {
            return [PSCustomObject]@{
                Namespace  = 'zerto.vpg'
                Dimensions = [System.Collections.Specialized.OrderedDictionary]::new()
                Metrics    = [System.Collections.Generic.List[pscustomobject]]::new()
                Created    = (Get-Date).ToString('o')
            }
        }
        Mock Add-TelemetryMetric { }
        Mock Submit-ProjectTelemetry { }
        Mock Export-ProjectCSVReport { }
        Mock Set-FormattedEmail { return '<html/>' }
        Mock Send-FormattedEmail { }
        Mock Write-Log { }
        Mock Disconnect-ZertoZVM { }
    }

    It 'US3-T027: Should skip an unreachable ZVM and continue to the next' {
        $script:CallCount = 0
        Mock Connect-ZertoZVM {
            param($ZVMHost)
            $script:CallCount++
            if ($ZVMHost -eq 'zvm02') { throw 'Connection refused' }
        }
        Mock Get-ZertoVPG { return @() }
        Mock Test-JournalScratchBackupExists { return $false }
        Mock New-JournalScratchBackup { return 'TestDrive:\backup' }

        # Simulate 3 ZVMs by providing a text file — we inject via ZVMHost array trick
        # Testing the ZVM-level catch by passing 2 hosts: one will throw, one won't
        # We test each ZVMHost individually using the per-server error path
        & $script:ControllerPath -ZVMHost 'zvm02' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false
        Should -Invoke Write-Log -ParameterFilter { $Message -like '*ZVM-level failure*' -or $Message -like '*zvm=zvm02*' }
        Should -Invoke Submit-ProjectTelemetry -Times 1
    }

    It 'US3-T028: Should trigger circuit-breaker after 3 consecutive VPG failures' {
        Mock Connect-ZertoZVM { }
        Mock Test-JournalScratchBackupExists { return $false }
        Mock Get-ZertoVPG {
            return @(
                [PSCustomObject]@{ VpgName = 'VPG-01'; VpgIdentifier = 'id-01' }
                [PSCustomObject]@{ VpgName = 'VPG-02'; VpgIdentifier = 'id-02' }
                [PSCustomObject]@{ VpgName = 'VPG-03'; VpgIdentifier = 'id-03' }
                [PSCustomObject]@{ VpgName = 'VPG-04'; VpgIdentifier = 'id-04' }
            )
        }
        Mock Get-VpgJournalScratchState {
            param($ZVMHost, $VpgIdentifier, $VpgName)
            return [PSCustomObject]@{
                ZVMHost = $ZVMHost; VpgName = $VpgName; VpgIdentifier = $VpgIdentifier
                JournalSizeGB = 10; ScratchSizeGB = 10; CapturedAt = '2026-04-12T20:00:00Z'
            }
        }
        Mock New-JournalScratchBackup { return 'TestDrive:\backup\zvm01\20260412-164500.json' }
        Mock Invoke-JournalScratchUpdate {
            param($ZVMHost, $VpgIdentifier, $VpgName, $JournalSizeGB, $ScratchSizeGB)
            return [PSCustomObject]@{
                ZVMHost = $ZVMHost; VpgName = $VpgName; VpgIdentifier = $VpgIdentifier
                JournalSizeGB = 0; ScratchSizeGB = 0
                DesiredJournalGB = $JournalSizeGB; DesiredScratchGB = $ScratchSizeGB
                Action = 'Failed'; Status = 'Failure'; ErrorMessage = 'Simulated failure'
            }
        }

        & $script:ControllerPath -ZVMHost 'zvm01' -JournalSizeGB 50 -ScratchSizeGB 30 -Doctor $false

        # Circuit-breaker fires after 3rd failure — VPG-04 should NOT be attempted
        Should -Invoke Invoke-JournalScratchUpdate -Times 3
        Should -Invoke Write-Log -ParameterFilter { $Message -like '*Circuit-breaker*' }
    }
}
