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
}
