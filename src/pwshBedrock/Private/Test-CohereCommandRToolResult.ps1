<#
.SYNOPSIS
    Validates a Tools Results object for use with the Cohere Command R models.
.DESCRIPTION
    Evaluates a Tools Results object to ensure it meets the requirements for use with the Cohere Command R models.
    It checks the structure of the tools results objects to ensure they are properly formatted.
.EXAMPLE
    $toolsResults = [PSCustomObject]@{
        call    = [PSCustomObject]@{
            name       = "string"
            parameters = [PSCustomObject]@{
                "parameter name" = "string"
            }
            generation_id = "string"
        }
        outputs = @(
            [PSCustomObject]@{
                text = "string"
            }
        )
    }
    Test-CohereCommandRToolResult -ToolResults $toolsResults

    Tests the Tools Results object to ensure it meets the requirements for use with the Cohere Command R models.
.PARAMETER ToolResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-CohereCommandRToolResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject[]]$ToolResults
    )

    Write-Verbose -Message 'Validating the ToolResults object(s)...'

    foreach ($toolResult in $ToolResults) {

        # Validate call object
        if (-not $toolResult.PSObject.Properties["call"]) {
            Write-Debug -Message 'The call property is missing.'
            return $false
        }

        # Validate outputs array
        if (-not $toolResult.PSObject.Properties["outputs"]) {
            Write-Debug -Message 'The outputs property is missing.'
            return $false
        }

        $outputs = $toolResult.outputs
        if (-not ($outputs -is [System.Array])) {
            Write-Debug -Message 'The outputs property is not an array.'
            return $false
        }
        if ($outputs.Count -eq 0) {
            Write-Debug -Message 'The outputs array is empty.'
            return $false
        }

        $call = $toolResult.call

        # Validate call.name
        if (-not $call.PSObject.Properties["name"] -or -not [string]::IsNullOrWhiteSpace($call.name) -eq $false) {
            Write-Debug -Message 'The call.name property is missing or empty.'
            return $false
        }

        # Validate call.parameters
        if (-not $call.PSObject.Properties["parameters"]) {
            Write-Debug -Message 'The call.parameters property is missing.'
            return $false
        }

        $parameters = $call.parameters

        foreach ($paramKey in $parameters.PSObject.Properties.Name) {
            if ([string]::IsNullOrWhiteSpace($parameters.$paramKey)) {
                Write-Debug -Message "The call.parameters.$paramKey property is missing or empty."
                return $false
            }
        }

    } #foreach_toolResult

    return $true
} #Test-CohereCommandRToolResult
