function Get-ZertoVrachangerecoveryhostrecommendation {
    <#
    .SYNOPSIS
        Get recommendations for evacuate operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/{vraIdentifier}/changerecoveryvra/recommendation
        OperationId: getVraChangeRecoveryHostRecommendation
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier/changerecoveryvra/recommendation" -Method 'Post'  -Body $Body
    }
}
