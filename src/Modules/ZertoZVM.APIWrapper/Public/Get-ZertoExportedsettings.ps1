function Get-ZertoExportedsettings {
    <#
    .SYNOPSIS
        Read exported settings from a file of given timestamp. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vpgSettings/exportedSettings/{timeStamp}
        OperationId: getExportedSettings
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Timestamp,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgSettings/exportedSettings/$Timestamp" -Method 'Post'  -Body $Body
    }
}
