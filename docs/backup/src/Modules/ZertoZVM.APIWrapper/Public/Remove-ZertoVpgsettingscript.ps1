function Remove-ZertoVpgsettingscript {
    <#
    .SYNOPSIS
        Delete Scripting VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/scripting
        OperationId: deleteVpgSettingScript
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scripting" -Method 'Delete'  
    }
}
