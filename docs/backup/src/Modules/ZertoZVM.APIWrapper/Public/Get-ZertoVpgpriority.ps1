function Get-ZertoVpgpriority {
    <#
    .SYNOPSIS
        Get the list of values for VPG priority. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/priorities
        OperationId: getVpgPriorityAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/priorities' -Method 'Get'  
    }
}

