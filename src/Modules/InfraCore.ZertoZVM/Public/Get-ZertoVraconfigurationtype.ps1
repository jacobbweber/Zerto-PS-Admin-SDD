function Get-ZertoVraconfigurationtype {
    <#
    .SYNOPSIS
        Get the list of values for VRA IP configuration type (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vras/ipconfigurationtypes
        OperationId: getVraConfigurationTypeAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vras/ipconfigurationtypes' -Method 'Get'  
    }
}

