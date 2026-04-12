function Undo-ZertoVm {
    <#
    .SYNOPSIS
        Rolls back a restored journal VM. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vms/{vmIdentifier}/RestoreRollback
        OperationId: rollbackVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vms/$Vmidentifier/RestoreRollback" -Method 'Post'  -Body $Body
    }
}
