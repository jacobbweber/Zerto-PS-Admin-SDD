function Get-ZertoExportedsettingsinfo {
    <#
    .SYNOPSIS
        Get all available exported settings files. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgSettings/exportedSettings
        OperationId: getExportedSettingsInfo
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgSettings/exportedSettings' -Method 'Get'  
    }
}

