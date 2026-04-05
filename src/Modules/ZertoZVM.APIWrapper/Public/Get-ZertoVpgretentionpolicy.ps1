function Get-ZertoVpgretentionpolicy {
    <#
    .SYNOPSIS
        Get the list of values for VPG retention policy. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/retentionpolicies
        OperationId: getVpgRetentionPolicyAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'vpgs/retentionpolicies' -Method 'Get'  
    }
}

