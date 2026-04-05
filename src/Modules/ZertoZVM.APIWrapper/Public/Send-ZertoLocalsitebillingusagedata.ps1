function Send-ZertoLocalsitebillingusagedata {
    <#
    .SYNOPSIS
        Send billing data to the billing server (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/localsite/billing/sendUsage
        OperationId: sendLocalSiteBillingUsageData
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint 'localsite/billing/sendUsage' -Method 'Post'  -Body $Body
    }
}
