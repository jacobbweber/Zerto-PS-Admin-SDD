function Get-ZertoSystemdatetimeserviceGetdatetimeutc {
    <#
    .SYNOPSIS
        Get current system date-time in UTC format (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for GET /v1/serverDateTime/serverDateTimeUtc
        OperationId: SystemDateTimeService_GetDateTimeUtc
    #>
    [CmdletBinding()]
    param()

    process {

        Invoke-ZertoRequest -Endpoint 'serverDateTime/serverDateTimeUtc' -Method 'Get'  
    }
}

