function Remove-ZertoVpgsettingltr {
    <#
    .SYNOPSIS
        Delete Extended Journal Copy VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/ltr
        OperationId: removeVpgSettingLtr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/ltr" -Method 'Delete'  
    }
}
