function Get-ZertoVpgcheckpointstat {
    <#
    .SYNOPSIS
        Get checkpoints statistics for a VPG. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vpgs/{vpgIdentifier}/checkpoints/stats
        OperationId: getVpgCheckpointStatAll
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vpgidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vpgs/$Vpgidentifier/checkpoints/stats" -Method 'Get'  
    }
}
