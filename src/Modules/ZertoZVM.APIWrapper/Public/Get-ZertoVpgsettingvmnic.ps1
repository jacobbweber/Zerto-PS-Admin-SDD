function Get-ZertoVpgsettingvmnic {
    <#
    .SYNOPSIS
        Get NICs of specific VM in VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/vms/{vmIdentifier}/nics
        OperationId: getVpgSettingVmNicAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory)]
        [string] $Vmidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/vms/$Vmidentifier/nics" -Method 'Get'  
    }
}
