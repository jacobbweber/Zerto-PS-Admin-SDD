function Get-ZertoVpgsettingscratch {
    <#
    .SYNOPSIS
        Get VPG Scratch settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/{vpgSettingsIdentifier}/scratch
        OperationId: getVpgSettingScratch
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scratch" -Method 'Get'  
    }
}
