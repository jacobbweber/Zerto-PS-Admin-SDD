function Set-ZertoAlert {
    <#
    .SYNOPSIS
        Undismiss a specific alert. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/alerts/{alertIdentifier}/undismiss
        OperationId: resetAlert
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Alertidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "alerts/$Alertidentifier/undismiss" -Method 'Post'  -Body $Body
    }
}
