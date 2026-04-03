function Remove-ZertoScriptsfile {
    <#
    .SYNOPSIS
        Delete a file in scripts directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/recoveryScripts/repository/files
        OperationId: deleteScriptsFile
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/files' -Method 'Delete' -QueryParameters $query 
    }
}
