function Get-ZertoVrachangerecoveryhostpotential {
    <#
    .SYNOPSIS
        Get potential replacement hosts for a change recovery host operation. 

Returns a list for a specified VmIdentifer. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/vras/{vraIdentifier}/changerecoveryvra/potentials
        OperationId: getVraChangeRecoveryHostPotential
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter()]
        [string] $Vmidentifier
    )

    process {
    $query = @{}
        if ($Vmidentifier) { $query['vmIdentifier'] = $Vmidentifier }

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier/changerecoveryvra/potentials" -Method 'Get' -QueryParameters $query 
    }
}
