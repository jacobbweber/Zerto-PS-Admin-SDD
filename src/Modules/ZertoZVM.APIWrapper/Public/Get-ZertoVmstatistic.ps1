function Get-ZertoVmstatistic {
    <#
    .SYNOPSIS
        Get statistics for all protected VMs (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/statistics/vms
        OperationId: getVmStatisticAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'statistics/vms' -Method 'Get'  
    }
}

