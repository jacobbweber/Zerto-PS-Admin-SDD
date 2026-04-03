function Get-ZertoVpgsettingbootgroup {
    <#
    .SYNOPSIS
        Get Bootgroups VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/bootgroup
        OperationId: getVpgSettingBootGroup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/bootgroup" -Method 'Get'  
    }
}
