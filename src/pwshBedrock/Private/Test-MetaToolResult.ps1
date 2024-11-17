<#
.SYNOPSIS
    Validates a Tools Results object for use with the Meta models.
.DESCRIPTION
    Evaluates a Tools Results object to ensure it meets the requirements for use with the Meta models.
    It checks the structure of the tools results objects to ensure they are properly formatted.
.EXAMPLE
    $toolResults = [PSCustomObject]@{
        output = @(
            [PSCustomObject]@{
                name = "John"
                age  = 30
            },
            [PSCustomObject]@{
                name = "Jane"
                age  = 25
            }
        )
    }
    Test-MetaToolResult -ToolResults $toolsResults

    Tests the Tools Results object to ensure it meets the requirements for use with the Meta models.
.PARAMETER ToolResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-MetaToolResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject]$ToolResults
    )

    Write-Verbose -Message 'Validating the ToolResults object(s)...'

    foreach ($toolResult in $ToolResults) {

        # Validate output array
        if (-not $toolResult.PSObject.Properties["output"]) {
            Write-Debug -Message 'The outputs property is missing.'
            return $false
        }

        $outputs = $toolResult.output
        if (-not ($outputs -is [System.Array])) {
            Write-Debug -Message 'The outputs property is not an array.'
            return $false
        }
        if ($outputs.Count -eq 0) {
            Write-Debug -Message 'The outputs array is empty.'
            return $false
        }

        # each item in the outputs array should be a PSCustomObject
        foreach ($output in $outputs) {
            if (-not ($output -is [PSCustomObject])) {
                Write-Debug -Message 'The output is not a PSCustomObject.'
                return $false
            }
        } #foreach_output

    } #foreach_toolResult

    return $true
} #Test-MetaToolResult
