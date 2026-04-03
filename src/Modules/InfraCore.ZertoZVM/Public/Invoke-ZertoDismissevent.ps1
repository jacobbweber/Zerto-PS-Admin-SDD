function Invoke-ZertoDismissevent {
    <#
    .SYNOPSIS
        Dismiss encryption event (resolve alert, clear tag checkpoint) (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/encryptionDetection/dismissEvent
        OperationId: dismissEvent
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/dismissEvent' -Method 'Post'  -Body $Body
    }
}
