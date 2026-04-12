function Start-ZertoVrasonclusterinstall {
    <#
    .SYNOPSIS
        Installs VRAs on cluster. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/clusters
        OperationId: startVrasOnClusterInstall
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'vras/clusters' -Method 'Post'  -Body $Body
    }
}
