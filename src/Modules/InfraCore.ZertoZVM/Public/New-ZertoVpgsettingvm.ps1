function New-ZertoVpgsettingvm {
    <#
    .SYNOPSIS
        Add new VMs to VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/{vpgSettingsIdentifier}/vms
        OperationId: newVpgSettingVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms" -Method 'Post'  -Body $Body
    }
}
