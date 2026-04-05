function Start-ZertoLtrrestorevm {
    <#
    .SYNOPSIS
        Restore the VM from the Repository at the recovery site. Returns a token. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/ltr/restore/vm
        OperationId: StartLtrRestoreVm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'ltr/restore/vm' -Method 'Post'  -Body $Body
    }
}
