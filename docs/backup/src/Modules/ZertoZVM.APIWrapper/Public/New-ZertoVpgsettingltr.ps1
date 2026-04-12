function New-ZertoVpgsettingltr {
    <#
    .SYNOPSIS
        Create Extended Journal Copy VPG settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/{vpgSettingsIdentifier}/ltr
        OperationId: newVpgSettingLtr
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/ltr" -Method 'Post'  -Body $Body
    }
}
