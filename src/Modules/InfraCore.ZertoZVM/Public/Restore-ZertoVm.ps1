function Restore-ZertoVm {
    <#
    .SYNOPSIS
        Starts Journal Vm restore operation. Returns command task identifier of the operation. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vms/{vmIdentifier}/Restore
        OperationId: restoreVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vms/$Vmidentifier/Restore" -Method 'Post'  -Body $Body
    }
}
