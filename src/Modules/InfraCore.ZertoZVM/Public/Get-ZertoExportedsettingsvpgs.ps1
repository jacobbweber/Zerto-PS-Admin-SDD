function Get-ZertoExportedsettingsvpgs {
    <#
    .SYNOPSIS
        Get list of VPGs from exported settings file. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/exportedSettings/{timeStamp}/vpgsinfo
        OperationId: getExportedSettingsVpgs
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Timestamp
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/exportedSettings/$Timestamp/vpgsinfo" -Method 'Get'  
    }
}
