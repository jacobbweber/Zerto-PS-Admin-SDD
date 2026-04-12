function Get-ZertoEventtype {
    <#
    .SYNOPSIS
        Get a list of all available event types (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/events/types
        OperationId: getEventTypeAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'events/types' -Method 'Get'  
    }
}

