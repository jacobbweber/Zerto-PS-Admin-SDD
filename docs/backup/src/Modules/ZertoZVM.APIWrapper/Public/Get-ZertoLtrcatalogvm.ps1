function Get-ZertoLtrcatalogvm {
    <#
    .SYNOPSIS
        Get a list of available VMs in a Retention set (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/ltr/catalog/vms
        OperationId: getLtrCatalogVmAll
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'ltr/catalog/vms' -Method 'Get'  
    }
}

