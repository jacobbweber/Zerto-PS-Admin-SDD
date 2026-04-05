function Complete-ZertoVm {
    <#
    .SYNOPSIS
        Commits a restored journal VM. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vms/{vmIdentifier}/RestoreCommit
        OperationId: commitVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vmidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vms/$Vmidentifier/RestoreCommit" -Method 'Post'  -Body $Body
    }
}
