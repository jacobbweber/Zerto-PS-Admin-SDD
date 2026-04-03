function Remove-ZertoOutputfolder {
    <#
    .SYNOPSIS
        Delete a folder in output directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/recoveryScripts/output/folders
        OperationId: deleteOutputFolder
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

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/output/folders' -Method 'Delete' -QueryParameters $query 
    }
}
