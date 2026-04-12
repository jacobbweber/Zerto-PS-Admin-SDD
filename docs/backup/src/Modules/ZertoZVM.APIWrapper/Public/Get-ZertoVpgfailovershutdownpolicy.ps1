function Get-ZertoVpgfailovershutdownpolicy {
    <#
    .SYNOPSIS
        Get the list of values for VPG failover shutdown policy. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/failovershutdownpolicies
        OperationId: getVpgFailoverShutdownPolicyAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/failovershutdownpolicies' -Method 'Get'  
    }
}

