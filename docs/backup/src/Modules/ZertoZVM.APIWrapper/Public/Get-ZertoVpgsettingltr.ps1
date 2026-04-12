function Get-ZertoVpgsettingltr {
    <#
    .SYNOPSIS
        Get Extended Journal Copy VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/ltr
        OperationId: getVpgSettingLtr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/ltr" -Method 'Get'  
    }
}
