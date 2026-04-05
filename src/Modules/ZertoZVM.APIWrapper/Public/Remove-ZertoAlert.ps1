function Remove-ZertoAlert {
    <#
    .SYNOPSIS
        Dismiss a specific alert. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/alerts/{alertIdentifier}/dismiss
        OperationId: removeAlert
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Alertidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "alerts/$Alertidentifier/dismiss" -Method 'Post'  -Body $Body
    }
}
