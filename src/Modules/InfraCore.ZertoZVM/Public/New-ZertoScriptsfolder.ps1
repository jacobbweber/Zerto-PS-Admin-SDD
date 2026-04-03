function New-ZertoScriptsfolder {
    <#
    .SYNOPSIS
        Create a folder in scripts directory (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/recoveryScripts/repository/folders
        OperationId: createScriptsFolder
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'recoveryScripts/repository/folders' -Method 'Post'  -Body $Body
    }
}
