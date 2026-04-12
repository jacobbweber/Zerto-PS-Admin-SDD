function Set-ZertoVpgsettingvm {
    <#
    .SYNOPSIS
        Edit the VPG settings of a single VM (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}
        OperationId: editVpgSettingVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier" -Method 'Put'  -Body $Body
    }
}
