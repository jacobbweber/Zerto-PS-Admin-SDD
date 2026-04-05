function Get-ZertoMetricsvpgs {
    <#
    .SYNOPSIS
        Get a list of VPGs with encryption data (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/encryptionDetection/metrics/vpgs
        OperationId: metricsVpgs
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'encryptionDetection/metrics/vpgs' -Method 'Get'  
    }
}

