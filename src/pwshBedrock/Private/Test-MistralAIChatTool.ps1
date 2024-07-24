<#
.SYNOPSIS
    Validates a Tools object for use with the Mistral AI Chat models.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Mistral AI Chat models.
    It checks the structure of the tools objects to ensure they are properly formatted.
.EXAMPLE
    $tools = [PSCustomObject]@{
        type     = "function"
        function = @{
            name        = "string"
            description = "string"
            parameters  = @{
                type       = "string"
                properties = @{
                    sign = @{
                        type        = "string"
                        description = "string"
                    }
                }
                required   = @(
                    "string"
                )
            }
        }
    }
    Test-MistralAIChatTool -Tools $tools

    Tests the Tools object to ensure it meets the requirements for use with the Mistral AI Chat models.
.PARAMETER Tools
    Definitions of tools that the model may use.
.OUTPUTS
    System.Boolean
.NOTES
    Not every property is validated. There are hash tables that can contain custom properties.
.COMPONENT
    pwshBedrock
#>
function Test-MistralAIChatTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools
    )

    Write-Verbose -Message 'Validating the Tools object(s)...'

    foreach ($tool in $Tools) {
        # Validate main parameters
        if (-not $tool.PSObject.Properties["type"] -or -not [string]::IsNullOrWhiteSpace($tool.type) -eq $false) {
            Write-Debug -Message 'The type property is missing or empty.'
            return $false
        }

        # Validate parameter_definitions
        if (-not $tool.PSObject.Properties["function"]) {
            Write-Debug -Message 'The function property is missing.'
            return $false
        }

        # validate parameter_definitions sub-properties
        if ([string]::IsNullOrWhiteSpace($tool.function.name)) {
            Write-Debug -Message 'The function name sub-property is missing or empty.'
            return $false
        }
        if ([string]::IsNullOrWhiteSpace($tool.function.description)) {
            Write-Debug -Message 'The function description sub-property is missing or empty.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.function.parameters)) {
            Write-Debug -Message 'The function parameters property is missing.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.function.parameters.type)) {
            Write-Debug -Message 'The function parameters type sub-property is missing or empty.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.function.parameters.properties)) {
            Write-Debug -Message 'The function parameters properties sub-property is missing or empty.'
            return $false
        }

        if ([string]::IsNullOrWhiteSpace($tool.function.parameters.required)) {
            Write-Debug -Message 'The function parameters required sub-property is missing or empty.'
            return $false
        }

    }

    return $true
} #Test-MistralAIChatTool
