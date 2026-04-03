function Get-ZertoSuspectedvms {
    <#
    .SYNOPSIS
        Get a list of VMs that are suspected to have an encryption event (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/suspected/vms
        OperationId: suspectedVms
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/suspected/vms' -Method 'Get'  
    }
}

