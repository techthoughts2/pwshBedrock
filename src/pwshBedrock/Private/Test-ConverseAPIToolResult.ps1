<#
.SYNOPSIS
    Validates a Tools Results object for use with the Converse API.
.DESCRIPTION
    Evaluates a Tools Results object to ensure it meets the requirements for use with the Converse API.
    It checks the structure of the tools results objects to ensure they are properly formatted.
.EXAMPLE
    $toolsResults = [PSCustomObject]@{
        role         = 'tool'
        tool_call_id = 'string'
        content      = 'string'
    }
    Test-ConverseAPIToolResult -ToolResults $toolsResults

    Tests the Tools Results object to ensure it meets the requirements for use with the Converse API.
.PARAMETER ToolResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-ConverseAPIToolResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject[]]$ToolResults
    )

    Write-Verbose -Message 'Validating the ToolResults object(s)...'

    $allToolCallIds = New-Object System.Collections.Generic.List[string]

    foreach ($toolResult in $ToolResults) {

        if (-not $toolResult.PSObject.Properties['ToolUseId']) {
            Write-Debug -Message 'The ToolUseId property is missing.'
            return $false
        }

        if (-not $toolResult.PSObject.Properties['Content']) {
            Write-Debug -Message 'The Content property is missing.'
            return $false
        }

        if (-not $toolResult.PSObject.Properties['status']) {
            Write-Debug -Message 'The status property is missing.'
            return $false
        }

        if ($toolResult.status -ne 'success' -and $toolResult.status -ne 'error') {
            Write-Debug -Message 'The status property is not valid. It must be either "success" or "error".'
            return $false
        }

        if ($toolResult.status -eq 'error') {
            # content should be a string
            if ($toolResult.Content -isnot [string]) {
                Write-Debug -Message 'When tool status is "error", the Content property must be a string.'
                return $false
            }
        }
        elseif ($toolResult.status -eq 'success') {
            Write-Debug -Message 'Checking content for success status...'
            foreach ($content in $toolResult.Content) {
                Write-Debug -Message 'Checking content object format'
                # content should be a object or PSCustomObject
                if ($content -is [string]) {
                    Write-Debug -Message 'When tool status is "success", the Content must contain either an object or PSCustomObject.'
                    return $false
                }
            }
        }
        $allToolCallIds.Add($toolResult.ToolUseId)
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
} #Test-ConverseAPIToolResult
