function Set-ZertoVpgsettingltr {
    <#
    .SYNOPSIS
        Edit Extended Journal Copy VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/ltr
        OperationId: editVpgSettingLtr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/ltr" -Method 'Put'  -Body $Body
    }
}
