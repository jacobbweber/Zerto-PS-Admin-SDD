function Remove-ZertoVpgsetting {
    <#
    .SYNOPSIS
        Delete VPG settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}
        OperationId: removeVpgSetting
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier" -Method 'Delete'  
    }
}
