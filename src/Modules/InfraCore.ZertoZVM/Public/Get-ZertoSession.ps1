function Get-ZertoSession {
    <#
    .SYNOPSIS
        Returns the current InfraCode.ZertoZVM session state.

    .DESCRIPTION
        Outputs the active session configuration (host, version, connection status).
        The auth token value is redacted for security.

    .EXAMPLE
        Get-ZertoSession

    .OUTPUTS
        PSCustomObject with session details (token redacted).
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    [PSCustomObject]@{
        BaseUri              = $script:ZertoSession.BaseUri
        ApiVersion           = $script:ZertoSession.ApiVersion
        Connected            = $script:ZertoSession.Connected
        SkipCertificateCheck = $script:ZertoSession.SkipCertificateCheck
        SessionToken         = if ($script:ZertoSession.Headers['x-zerto-session']) { '<redacted>' } else { $null }
    }
}
