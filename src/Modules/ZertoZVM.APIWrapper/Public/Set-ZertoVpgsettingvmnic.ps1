function Set-ZertoVpgsettingvmnic {
    <#
    .SYNOPSIS
        Edit NICs details of specific VM in VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}/nics/{nicIdentifier}
        OperationId: editVpgSettingVmNic
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier,

        [Parameter(Mandatory)]
        [string] $Nicidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier/nics/$Nicidentifier" -Method 'Put'  -Body $Body
    }
}
