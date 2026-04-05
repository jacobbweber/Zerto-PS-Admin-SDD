function Get-ZertoSuspectedvpgs {
    <#
    .SYNOPSIS
        Get a list of VPGs that are suspected to have an encryption event (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/suspected/vpgs
        OperationId: suspectedVpgs
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/suspected/vpgs' -Method 'Get'  
    }
}

