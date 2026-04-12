function Get-ZertoMetricsvolumes {
    <#
    .SYNOPSIS
        Get a list of volumes with encryption data (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/metrics/volumes
        OperationId: metricsVolumes
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/metrics/volumes' -Method 'Get'  
    }
}

