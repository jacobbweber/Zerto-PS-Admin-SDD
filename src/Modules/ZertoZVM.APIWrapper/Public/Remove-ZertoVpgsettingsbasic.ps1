function Remove-ZertoVpgsettingsbasic {
    <#
    .SYNOPSIS
        Delete Basic VPG settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/basic
        OperationId: removeVpgSettingsBasic
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/basic" -Method 'Delete'  
    }
}
