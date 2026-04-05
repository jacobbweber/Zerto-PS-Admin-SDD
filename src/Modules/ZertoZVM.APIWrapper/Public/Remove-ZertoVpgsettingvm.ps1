function Remove-ZertoVpgsettingvm {
    <#
    .SYNOPSIS
        Delete the VPG settings of a single VM (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}
        OperationId: removeVpgSettingVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier" -Method 'Delete'  
    }
}
