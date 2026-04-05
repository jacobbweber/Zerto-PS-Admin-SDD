function Disconnect-ZertoZVM {
    <#
    .SYNOPSIS
        Terminates the active Zerto ZVM session and clears module-scoped state.

    .DESCRIPTION
        Issues DELETE /session to invalidate the server-side token, then clears
        all session state from the ZertoZVM.APIWrapper module scope. Safe to call
        even if the connection is already closed.

    .EXAMPLE
        Disconnect-ZertoZVM
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    if (-not $script:ZertoSession.Connected) {
        Write-Warning "Disconnect-ZertoZVM: No active session to disconnect."
        return
    }

    if ($PSCmdlet.ShouldProcess($script:ZertoSession.BaseUri, 'Disconnect Zerto ZVM session')) {
        try {
            Invoke-ZertoRequest -Method 'DELETE' -UriPath 'session'
            Write-Verbose "Disconnect-ZertoZVM: Session deleted successfully."
        }
        catch {
            Write-Warning "Disconnect-ZertoZVM: Could not cleanly delete server session — $_"
        }
        finally {
            # Always clear local state
            $script:ZertoSession.BaseUri = [string]::Empty
            $script:ZertoSession.ApiVersion = 'v1'
            $script:ZertoSession.Headers = @{}
            $script:ZertoSession.SkipCertificateCheck = $false
            $script:ZertoSession.Connected = $false
            $script:ZertoSession.TokenTimestamp = [DateTime]::MinValue
            $script:ZertoSession.CachedCredential = $null
            Write-Verbose "Disconnect-ZertoZVM: Local session state cleared."
        }
    }
}
