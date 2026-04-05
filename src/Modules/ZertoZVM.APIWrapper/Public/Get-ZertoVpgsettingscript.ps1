function Get-ZertoVpgsettingscript {
    <#
    .SYNOPSIS
        Get Scripting VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/scripting
        OperationId: getVpgSettingScript
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scripting" -Method 'Get'  
    }
}
