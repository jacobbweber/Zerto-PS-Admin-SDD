function Get-ZertoEvententity {
    <#
    .SYNOPSIS
        Get a list of all available event entities. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/events/entities
        OperationId: getEventEntityAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'events/entities' -Method 'Get'  
    }
}

