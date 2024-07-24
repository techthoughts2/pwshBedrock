<#
.SYNOPSIS
    Validates a Tools Results object for use with the Mistral AI chat model.
.DESCRIPTION
    Evaluates a Tools Results object to ensure it meets the requirements for use with the Mistral AI chat model.
    It checks the structure of the tools results objects to ensure they are properly formatted.
.EXAMPLE
    $toolsResults = [PSCustomObject]@{
        role         = 'tool'
        tool_call_id = 'string'
        content      = 'string'
    }
    Test-MistralAIChatToolResult -ToolResults $toolsResults

    Tests the Tools Results object to ensure it meets the requirements for use with the Mistral AI chat model.
.PARAMETER ToolResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-MistralAIChatToolResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject[]]$ToolResults
    )

    Write-Verbose -Message 'Validating the ToolResults object(s)...'

    $allToolCallIds = New-Object System.Collections.Generic.List[string]

    foreach ($toolResult in $ToolResults) {

        if (-not $toolResult.PSObject.Properties['role']) {
            Write-Debug -Message 'The role property is missing.'
            return $false
        }

        if (-not $toolResult.PSObject.Properties['tool_call_id']) {
            Write-Debug -Message 'The tool_call_id property is missing.'
            return $false
        }

        if (-not $toolResult.PSObject.Properties['content']) {
            Write-Debug -Message 'The tool_call_id property is missing.'
            return $false
        }

        if ($toolResult.role -ne 'tool') {
            Write-Debug -Message 'The role property is not set to tool.'
            return $false
        }
        $allToolCallIds.Add($toolResult.tool_call_id)
    } #foreach_toolResult
    # each tool call id should be a unique id. we need to check for duplicates
    # Convert the list to an array and group by the IDs
    $groupedIds = $allToolCallIds | Group-Object

    # Check if any group has more than one element
    $hasDuplicates = $groupedIds | Where-Object { $_.Count -gt 1 }

    # Determine the result based on the presence of duplicates
    $hasNoDuplicates = $hasDuplicates.Count -eq 0

    if ($hasNoDuplicates -eq $false) {
        Write-Debug -Message 'The tool_call_id property is not unique.'
        return $false
    }

    return $true
} #Test-MistralAIChatToolResult
