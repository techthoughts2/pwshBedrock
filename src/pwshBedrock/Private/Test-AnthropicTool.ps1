<#
.SYNOPSIS
    Validates a Tools object for use with the Anthropic models.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Anthropic models.
    It checks the structure of the tools objects to ensure they are properly formatted.
.EXAMPLE
    $tools = [PSCustomObject]@{
        name         = 'top_song'
        description  = 'Get the most popular song played on a radio station.'
        input_schema = [PSCustomObject]@{
            type       = 'object'
            properties = [PSCustomObject]@{
                sign = [PSCustomObject]@{
                    type        = 'string'
                    description = 'string'
                }
            }
            required   = @( 'sign' )
        }
    }
    Test-AnthropicTool -Tools $tools

    Tests the Tools object to ensure it meets the requirements for use with the Anthropic models.
.PARAMETER Tools
    Definitions of tools that the model may use.
.OUTPUTS
    System.Boolean
.NOTES
    Not every property is validated. There are hash tables that can contain custom properties.
.COMPONENT
    pwshBedrock
#>
function Test-AnthropicTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools
    )

    Write-Verbose -Message 'Validating the Tools object(s)...'

    foreach ($tool in $Tools) {
        # Validate main parameters
        if (-not $tool.PSObject.Properties['name'] -or -not [string]::IsNullOrWhiteSpace($tool.name) -eq $false) {
            Write-Debug -Message 'The name property is missing or empty.'
            return $false
        }

        if (-not $tool.PSObject.Properties['description'] -or -not [string]::IsNullOrWhiteSpace($tool.description) -eq $false) {
            Write-Debug -Message 'The description property is missing or empty.'
            return $false
        }

        if (-not $tool.PSObject.Properties['input_schema']) {
            Write-Debug -Message 'The input_schema property is missing.'
            return $false
        }

        # validate parameter_definitions sub-properties
        if ([string]::IsNullOrWhiteSpace($tool.input_schema)) {
            Write-Debug -Message 'The input_schema name sub-property is missing or empty.'
            return $false
        }
        if ([string]::IsNullOrWhiteSpace($tool.input_schema.type)) {
            Write-Debug -Message 'The input_schema type sub-property is missing or empty.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.input_schema.properties)) {
            Write-Debug -Message 'The input_schema properties type sub-property is missing or empty.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.input_schema.required)) {
            Write-Debug -Message 'The input_schema required properties sub-property is missing or empty.'
            return $false
        }

    } #foreach_tool

    return $true
} #Test-AnthropicTool
