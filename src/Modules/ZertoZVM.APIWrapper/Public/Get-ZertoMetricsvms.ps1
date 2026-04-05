function Get-ZertoMetricsvms {
    <#
    .SYNOPSIS
        Get a list of VMs with encryption data (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/metrics/vms
        OperationId: metricsVms
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/metrics/vms' -Method 'Get'  
    }
}

