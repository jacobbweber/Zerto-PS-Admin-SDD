function Test-ZertoVrachangerecoveryhostsetting {
    <#
    .SYNOPSIS
        Validate change recovery host settings. (Auth)

    .DESCRIPTION
        Automatically generated cmdlet for POST /v1/vras/{vraIdentifier}/changerecoveryvra/validate
        OperationId: testVraChangeRecoveryHostSetting
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Vraidentifier,

        [Parameter(Mandatory=$false)]
        [object] $Body
    )

    process {

        Invoke-ZertoRequest -Endpoint "vras/$Vraidentifier/changerecoveryvra/validate" -Method 'Post'  -Body $Body
    }
}
