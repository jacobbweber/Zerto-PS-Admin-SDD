# Shared Mocks for Controller Integration Testing
# This file is loaded by BeforeAll in Controller tests.

function Get-MockVPGData {
    return @(
        [PSCustomObject]@{
            VPGName           = "VPG_Production_SQL"
            VpgIdentifier     = "vpg-86b208eb-21be-4161-9f93-c2d3a371879b"
            ProtectedSiteName = "Site_A"
            Status            = "MeetingSLA"
        },
        [PSCustomObject]@{
            VPGName           = "VPG_Staging_Web"
            VpgIdentifier     = "vpg-12c45d67-89ef-01ab-23cd-ef4567890abc"
            ProtectedSiteName = "Site_B"
            Status            = "MeetingSLA"
        }
    )
}

# Standard Zerto Module Mocks
Mock Connect-ZertoZVM { return $true }
Mock Disconnect-ZertoZVM { return $true }
Mock Get-ZertoVPG { return (Get-MockVPGData) }

# Core / Infrastructure Mocks
Mock New-ProjectTelemetry { return $true }
Mock Submit-ProjectTelemetry { return $true }
Mock Complete-ProjectTelemetry { return $true }
Mock Write-Log { return $true }
Mock Set-FormattedEmail { return "<html>Mock Body</html>" }
Mock Send-FormattedEmail { return $true }
Mock Export-ProjectCSVReport { return $true }
