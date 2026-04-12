function Get-ZertoTask {
    <#
    .SYNOPSIS
        Retrieves asynchronous tasks from the Zerto ZVM.

    .DESCRIPTION
        Returns all tasks or a specific task by identifier. Tasks represent async
        operations such as failovers, moves, and VPG changes.

    .PARAMETER TaskIdentifier
        The identifier of a specific task to retrieve.

    .PARAMETER Type
        Filter tasks by type string (e.g. 'InitialSync', 'Failover').

    .EXAMPLE
        Get-ZertoTask

    .EXAMPLE
        Get-ZertoTask -TaskIdentifier 'task-abcd-1234'

    .OUTPUTS
        PSCustomObject or PSCustomObject[]
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [string] $TaskIdentifier,

        [Parameter(ParameterSetName = 'All')]
        [string] $Type
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-ZertoRequest -Endpoint "tasks/$TaskIdentifier"
        }
        else {
            $query = @{}
            if ($Type) { $query.type = $Type }
            Invoke-ZertoRequest -Endpoint 'tasks' -QueryParameters $query
        }
    }
}

