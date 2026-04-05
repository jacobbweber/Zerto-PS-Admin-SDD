function Set-ZertoVpgsettingscript {
    <#
    .SYNOPSIS
        Update Scripting VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/scripting
        OperationId: editVpgSettingScript
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scripting" -Method 'Put'  -Body $Body
    }
}
