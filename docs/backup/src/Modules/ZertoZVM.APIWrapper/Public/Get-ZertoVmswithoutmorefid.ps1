function Get-ZertoVmswithoutmorefid {
    <#
    .SYNOPSIS
        Get VCD VMs without MorefId (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vcd/vmsWithoutMorefId
        OperationId: GetVmsWithoutMorefId
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vcd/vmsWithoutMorefId' -Method 'Get'  
    }
}

