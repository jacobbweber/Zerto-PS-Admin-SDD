function Set-ZertoVpgsettingscratch {
    <#
    .SYNOPSIS
        Update VPG Scratch settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vpgSettings/{vpgSettingsIdentifier}/scratch
        OperationId: editVpgSettingScratch
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scratch" -Method 'Put'  -Body $Body
    }
}
