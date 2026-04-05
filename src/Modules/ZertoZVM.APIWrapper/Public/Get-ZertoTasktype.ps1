function Get-ZertoTasktype {
    <#
    .SYNOPSIS
        Get the list of acceptable values for task types. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/tasks/types
        OperationId: getTaskTypeAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'tasks/types' -Method 'Get'  
    }
}

