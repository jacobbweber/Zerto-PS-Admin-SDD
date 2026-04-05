function Remove-ZertoVpgsettingrecovery {
    <#
    .SYNOPSIS
        Delete Recovery VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/recovery
        OperationId: removeVpgSettingRecovery
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/recovery" -Method 'Delete'  
    }
}
