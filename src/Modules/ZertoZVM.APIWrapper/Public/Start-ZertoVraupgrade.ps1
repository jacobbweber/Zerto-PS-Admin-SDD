function Start-ZertoVraupgrade {
    <#
    .SYNOPSIS
        Upgrade VRA. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/{vraIdentifier}/upgrade
        OperationId: startVraUpgrade
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier/upgrade" -Method 'Post'  -Body $Body
    }
}
