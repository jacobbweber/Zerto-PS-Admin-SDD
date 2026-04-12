function Remove-ZertoVpgsettingscratch {
    <#
    .SYNOPSIS
        Delete VPG Scratch settings (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vpgSettings/{vpgSettingsIdentifier}/scratch
        OperationId: removeVpgSettingScratch
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgsettingsidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/$Vpgsettingsidentifier/scratch" -Method 'Delete'  
    }
}
