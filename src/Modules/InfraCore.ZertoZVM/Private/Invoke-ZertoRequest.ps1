function Invoke-ZertoRequest {
    <#
    .SYNOPSIS
        Internal HTTP proxy for all Zerto ZVM API calls.

    .DESCRIPTION
        Constructs the full URI from module session state, appends optional query
        parameters, attaches the x-zerto-session auth header, and calls
        Invoke-RestMethod. All public functions in InfraCode.ZertoZVM call this
        function exclusively — they never build URIs or set headers themselves.

    .PARAMETER Endpoint
        Relative endpoint path, e.g. "/vpgs" or "/vpgs/{id}/failover".
        Leading slash is optional.

    .PARAMETER Method
        HTTP method. Defaults to 'Get'.

    .PARAMETER QueryParameters
        Hashtable of query string key/value pairs to append to the URI.
        Example: @{ name = 'MyVPG'; status = 'MeetingSLA' }

    .PARAMETER Body
        Request body object. Will be serialized to JSON automatically.

    .OUTPUTS
        PSCustomObject — the deserialized JSON response from the API.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Endpoint,

        [Parameter()]
        [ValidateSet('Get', 'Post', 'Put', 'Delete', 'Patch')]
        [string] $Method = 'Get',

        [Parameter()]
        [hashtable] $QueryParameters,

        [Parameter()]
        [object] $Body
    )

    Assert-ZertoSession

    # -------------------------------------------------------------------------
    # Build the full URI using UriBuilder to handle ports and trailing slashes
    # -------------------------------------------------------------------------
    $builder = [System.UriBuilder]::new($script:ZertoSession.BaseUri)
    $cleanEndpoint = $Endpoint.TrimStart('/')
    $builder.Path = "/vra/api/$($script:ZertoSession.ApiVersion)/$cleanEndpoint"

    # Append query string parameters if provided
    if ($QueryParameters -and $QueryParameters.Count -gt 0) {
        $queryCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        foreach ($key in $QueryParameters.Keys) {
            if ($null -ne $QueryParameters[$key]) {
                $queryCollection.Add($key, $QueryParameters[$key].ToString())
            }
        }
        $builder.Query = $queryCollection.ToString()
    }

    $fullUri = $builder.Uri.AbsoluteUri

    # -------------------------------------------------------------------------
    # Build Invoke-RestMethod parameters
    # -------------------------------------------------------------------------
    $irmParams = @{
        Uri         = $fullUri
        Method      = $Method
        Headers     = $script:ZertoSession.Headers
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }

    if ($null -ne $Body) {
        $irmParams.Body = $Body | ConvertTo-Json -Depth 10 -Compress
    }

    if ($script:ZertoSession.SkipCertificateCheck) {
        $irmParams.SkipCertificateCheck = $true
    }

    Write-Verbose "Invoke-ZertoRequest: $Method $fullUri"

    try {
        Invoke-RestMethod @irmParams
    }
    catch [System.Net.Http.HttpRequestException] {
        $statusCode = $_.Exception.StatusCode.value__
        $reason = $_.Exception.Message
        throw [System.Net.Http.HttpRequestException]::new(
            "Zerto API error [$statusCode] calling $Method $fullUri — $reason", $_.Exception
        )
    }
    catch {
        throw
    }
}
