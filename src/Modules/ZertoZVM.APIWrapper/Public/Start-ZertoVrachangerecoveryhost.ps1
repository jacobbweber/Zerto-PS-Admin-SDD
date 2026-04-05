function Start-ZertoVrachangerecoveryhost {
    <#
    .SYNOPSIS
        Change recovery host. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/{vraIdentifier}/changerecoveryvra/execute
        OperationId: startVraChangeRecoveryHost
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier/changerecoveryvra/execute" -Method 'Post'  -Body $Body
    }
}
