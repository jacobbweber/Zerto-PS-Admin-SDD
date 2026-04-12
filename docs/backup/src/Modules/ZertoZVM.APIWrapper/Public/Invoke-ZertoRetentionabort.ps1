function Invoke-ZertoRetentionabort {
    <#
    .SYNOPSIS
        End the Manual Retention process (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/ltr/vpgs/{vpgIdentifier}/retentionabort
        OperationId: RetentionAbort
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/vpgs/$Vpgidentifier/retentionabort" -Method 'Post'  -Body $Body
    }
}
