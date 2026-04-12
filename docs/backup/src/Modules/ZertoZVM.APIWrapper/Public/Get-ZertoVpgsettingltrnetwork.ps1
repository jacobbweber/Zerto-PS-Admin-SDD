function Get-ZertoVpgsettingltrnetwork {
    <#
    .SYNOPSIS
        Get Network VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/networks
        OperationId: getVpgSettingLtrNetworkAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/networks" -Method 'Get'  
    }
}
