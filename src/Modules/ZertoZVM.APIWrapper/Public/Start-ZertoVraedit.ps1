function Start-ZertoVraedit {
    <#
    .SYNOPSIS
        Edit VRA. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for PUT /v1/vras/{vraIdentifier}
        OperationId: startVraEdit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier" -Method 'Put'  -Body $Body
    }
}
