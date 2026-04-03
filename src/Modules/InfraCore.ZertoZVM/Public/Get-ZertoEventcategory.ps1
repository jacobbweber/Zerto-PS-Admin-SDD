function Get-ZertoEventcategory {
    <#
    .SYNOPSIS
        Get a list of all available event categories. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/events/categories
        OperationId: getEventCategoryAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'events/categories' -Method 'Get'  
    }
}

