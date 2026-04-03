function Remove-ZertoVpgsettingbootgroup {
    <#
    .SYNOPSIS
        Delete Bootgroups VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/bootgroup
        OperationId: deleteVpgSettingBootGroup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/bootgroup" -Method 'Delete'  
    }
}
