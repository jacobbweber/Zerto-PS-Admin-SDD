function Get-ZertoVpgsettingvmvolume {
    <#
    .SYNOPSIS
        Get Volumes of specific VM in VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}/volumes
        OperationId: getVpgSettingVmVolumeAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier/volumes" -Method 'Get'  
    }
}
