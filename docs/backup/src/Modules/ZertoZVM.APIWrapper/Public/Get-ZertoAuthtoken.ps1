function Get-ZertoAuthtoken {
    <#
    .SYNOPSIS
        Get new auth token

    .DESCRIPTION
        Automatically generated cmdlet for POST /auth/realms/zerto/protocol/openid-connect/token
        OperationId: getAuthToken
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'auth/realms/zerto/protocol/openid-connect/token' -Method 'Post'  -Body $Body
    }
}
