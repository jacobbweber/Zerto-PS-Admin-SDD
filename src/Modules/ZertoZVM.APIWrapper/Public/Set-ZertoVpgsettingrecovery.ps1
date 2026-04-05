function Set-ZertoVpgsettingrecovery {
    <#
    .SYNOPSIS
        Update Recovery VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/recovery
        OperationId: editVpgSettingRecovery
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/recovery" -Method 'Put'  -Body $Body
    }
}
