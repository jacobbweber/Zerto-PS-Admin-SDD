function New-ZertoOutputfolder {
    <#
    .SYNOPSIS
        Create a folder in output directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/recoveryScripts/output/folders
        OperationId: createOutputFolder
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/output/folders' -Method 'Post'  -Body $Body
    }
}
