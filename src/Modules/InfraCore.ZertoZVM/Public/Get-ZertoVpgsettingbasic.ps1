function Get-ZertoVpgsettingbasic {
    <#
    .SYNOPSIS
        Get Basic VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/basic
        OperationId: getVpgSettingBasic
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/basic" -Method 'Get'  
    }
}
