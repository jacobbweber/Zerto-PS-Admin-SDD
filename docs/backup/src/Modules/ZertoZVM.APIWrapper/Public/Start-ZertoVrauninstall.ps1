function Start-ZertoVrauninstall {
    <#
    .SYNOPSIS
        UnInstall VRA. Returns TaskIdentifier (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for DELETE /v1/vras/{vraIdentifier}
        OperationId: startVraUninstall
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier" -Method 'Delete'  
    }
}
