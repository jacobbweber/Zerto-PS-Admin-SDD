function Get-ZertoFilefromoutputdirectory {
    <#
    .SYNOPSIS
        Download a file from output directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/recoveryScripts/output/files
        OperationId: downloadFileFromOutputDirectory
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Path
    )

    process {
    $query = @{}
        if ($Path) { $query['path'] = $Path }

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/output/files' -Method 'Get' -QueryParameters $query 
    }
}
