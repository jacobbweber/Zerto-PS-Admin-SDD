function Get-ZertoVpgfailovercommitpolicy {
    <#
    .SYNOPSIS
        Get the list of values for VPG failover commit policy. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/failovercommitpolicies
        OperationId: getVpgFailoverCommitPolicyAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/failovercommitpolicies' -Method 'Get'  
    }
}

