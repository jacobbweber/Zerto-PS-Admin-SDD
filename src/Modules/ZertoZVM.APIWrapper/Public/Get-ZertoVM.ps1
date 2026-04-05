function Get-ZertoVM {
    <#
    .SYNOPSIS
        Retrieves protected VMs from the Zerto ZVM.

    .DESCRIPTION
        Returns all VMs known to the ZVM, or a specific VM by ID.
        Optionally filter by VPG name.

    .PARAMETER VmIdentifier
        The identifier of a specific VM to retrieve.

    .PARAMETER VpgName
        Filter VMs to those belonging to the specified VPG name.

    .EXAMPLE
        Get-ZertoVM

    .EXAMPLE
        Get-ZertoVM -VpgName 'ProdVPG'

    .EXAMPLE
        Get-ZertoVM -VmIdentifier 'vm-abcde-1234'

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $VmIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [string] $VpgName
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "vms/$VmIdentifier"
        }
        else {
            $query = @{}
            if ($VpgName) { $query.vpgName = $VpgName }
            Invoke-ZertoRequest -Endpoint 'vms' -QueryParameters $query
        }
    }
}

