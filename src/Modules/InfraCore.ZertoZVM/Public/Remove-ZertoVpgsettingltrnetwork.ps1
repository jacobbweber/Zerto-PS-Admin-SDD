function Remove-ZertoVpgsettingltrnetwork {
    <#
    .SYNOPSIS
        Delete Network VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/networks
        OperationId: removeVpgSettingLtrNetwork
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/networks" -Method 'Delete'  
    }
}
