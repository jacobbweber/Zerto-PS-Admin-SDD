function Get-ZertoFilefromscriptsdirectory {
    <#
    .SYNOPSIS
        Download a file from scripts directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/recoveryScripts/repository/files
        OperationId: downloadFileFromScriptsDirectory
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/files' -Method 'Get' -QueryParameters $query 
    }
}
