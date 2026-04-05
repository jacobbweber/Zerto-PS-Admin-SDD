function Remove-ZertoOutputfile {
    <#
    .SYNOPSIS
        Delete a file in output directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/recoveryScripts/output/files
        OperationId: deleteOutputFile
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/output/files' -Method 'Delete' -QueryParameters $query 
    }
}
