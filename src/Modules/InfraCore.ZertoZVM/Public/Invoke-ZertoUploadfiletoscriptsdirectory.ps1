function Invoke-ZertoUploadfiletoscriptsdirectory {
    <#
    .SYNOPSIS
        Upload a file to scripts directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/recoveryScripts/repository/files
        OperationId: uploadFileToScriptsDirectory
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/files' -Method 'Post'  -Body $Body
    }
}
