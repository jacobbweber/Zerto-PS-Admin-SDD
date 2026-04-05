function Get-ZertoSuspectedvolumes {
    <#
    .SYNOPSIS
        Get a list of Volumes that are suspected to have an encryption event (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/suspected/volumes
        OperationId: suspectedVolumes
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/suspected/volumes' -Method 'Get'  
    }
}

