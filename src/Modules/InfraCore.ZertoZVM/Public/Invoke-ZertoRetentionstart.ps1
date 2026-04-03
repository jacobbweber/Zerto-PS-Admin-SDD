function Invoke-ZertoRetentionstart {
    <#
    .SYNOPSIS
        Start the Manual Retention process (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/ltr/vpgs/{vpgIdentifier}/retentionstart
        OperationId: RetentionStart
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "ltr/vpgs/$Vpgidentifier/retentionstart" -Method 'Post'  -Body $Body
    }
}
