function Get-ZertoAlertentity {
    <#
    .SYNOPSIS
        Get a list of all available alert entities. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/alerts/entities
        OperationId: getAlertEntityAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'alerts/entities' -Method 'Get'  
    }
}

