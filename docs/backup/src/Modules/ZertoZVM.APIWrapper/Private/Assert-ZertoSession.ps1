function Assert-ZertoSession {
    <#
    .SYNOPSIS
        Validates that an active Zerto session exists before an API call is made.

    .DESCRIPTION
        Throws an InvalidOperationException if $script:ZertoSession.BaseUri is null or
        $script:ZertoSession.Connected is false. Call this at the top of every private
        API function to produce a clear, actionable error message.
    #>
    [CmdletBinding()]
    param()

    if ([string]::IsNullOrWhiteSpace($script:ZertoSession.BaseUri) -or
        -not $script:ZertoSession.Connected) {
        throw [System.InvalidOperationException]::new(
            'No active Zerto session. Run Connect-ZertoZVM before calling any Zerto functions.'
        )
    }

    if ($null -ne $script:ZertoSession.TokenTimestamp -and $script:ZertoSession.TokenTimestamp -ne [DateTime]::MinValue) {
        $age = ([DateTime]::UtcNow - $script:ZertoSession.TokenTimestamp).TotalMinutes
        if ($age -ge 5) {
            Write-Verbose "Assert-ZertoSession: Token exceeds 5-minute TTL ($([Math]::Round($age, 2)) mins). Automatically refreshing..."
            
            $uriBuilder = [System.UriBuilder]::new($script:ZertoSession.BaseUri)
            $connectParams = @{
                ZVMHost              = $uriBuilder.Host
                Port                 = $uriBuilder.Port
                ApiVersion           = $script:ZertoSession.ApiVersion
                SkipCertificateCheck = $script:ZertoSession.SkipCertificateCheck
            }

            try {
                $null = Connect-ZertoZVM @connectParams
                Write-Verbose "Assert-ZertoSession: Silent token refresh successfully completed."
            }
            catch {
                throw [System.InvalidOperationException]::new("Token expired and silent re-authentication failed. Details: $_")
            }
        }
    }
}
