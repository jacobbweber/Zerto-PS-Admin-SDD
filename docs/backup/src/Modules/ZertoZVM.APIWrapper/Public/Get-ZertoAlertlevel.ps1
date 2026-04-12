function Get-ZertoAlertlevel {
    <#
    .SYNOPSIS
        Get a list of all available alert levels. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/alerts/levels
        OperationId: getAlertLevelAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'alerts/levels' -Method 'Get'  
    }
}

