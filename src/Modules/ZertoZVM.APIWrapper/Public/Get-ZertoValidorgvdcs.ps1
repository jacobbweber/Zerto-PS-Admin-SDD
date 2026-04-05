function Get-ZertoValidorgvdcs {
    <#
    .SYNOPSIS
        Get Org VDCs with valid configuration (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vcd/validOrgVdcs
        OperationId: GetValidOrgVdcs
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vcd/validOrgVdcs' -Method 'Get'  
    }
}

