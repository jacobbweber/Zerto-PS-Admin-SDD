function Remove-ZertoVpgsettingvmnic {
    <#
    .SYNOPSIS
        Delete NICs of specific VM in VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}/nics/{nicIdentifier}
        OperationId: removeVpgSettingVmNic
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier,

        [Parameter(Mandatory)]
        [string] $Nicidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier/nics/$Nicidentifier" -Method 'Delete'  
    }
}
