function Set-ZertoVpgsettingltrnetwork {
    <#
    .SYNOPSIS
        Update Network VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/networks
        OperationId: editVpgSettingLtrNetwork
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/networks" -Method 'Put'  -Body $Body
    }
}
