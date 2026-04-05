function Set-ZertoVpgsettingvmvolume {
    <#
    .SYNOPSIS
        Update Volume details of specific VM in VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}/volumes/{volumeIdentifier}
        OperationId: editVpgSettingVmVolume
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier,

        [Parameter(Mandatory)]
        [string] $Volumeidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier/volumes/$Volumeidentifier" -Method 'Put'  -Body $Body
    }
}
