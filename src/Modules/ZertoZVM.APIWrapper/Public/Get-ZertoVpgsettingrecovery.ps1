function Get-ZertoVpgsettingrecovery {
    <#
    .SYNOPSIS
        Get Recovery VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/recovery
        OperationId: getVpgSettingRecovery
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/recovery" -Method 'Get'  
    }
}
