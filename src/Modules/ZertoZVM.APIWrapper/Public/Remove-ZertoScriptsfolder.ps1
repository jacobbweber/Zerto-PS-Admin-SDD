function Remove-ZertoScriptsfolder {
    <#
    .SYNOPSIS
        Delete a folder in scripts directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/recoveryScripts/repository/folders
        OperationId: deleteScriptsFolder
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path,

        [Parameter()]
        [string] $Deleteifnotempty
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }
        if ($Deleteifnotempty) { $query['deleteIfNotEmpty'] = $Deleteifnotempty }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/folders' -Method 'Delete' -QueryParameters $query 
    }
}
