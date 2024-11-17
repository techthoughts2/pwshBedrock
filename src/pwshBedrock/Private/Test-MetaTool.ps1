<#
.SYNOPSIS
    Validates a Tools object for use with the Meta models.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Meta models.
    It checks the structure of the tools objects to ensure they are properly formatted.
.EXAMPLE
    $tools = [PSCustomObject]@{
        name                  = "string"
        description           = "string"
        parameters = @{
            "parameter name" = [PSCustomObject]@{
                param_type        = "string"
                description = "string"
                required    = $true
            }
        }
    }
    Test-MetaTool -Tools $tools

    Tests the Tools object to ensure it meets the requirements for use with the Meta models.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-MetaTool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of available tools (functions) that the model may suggest invoking before producing a text response.')]
        [PSCustomObject[]]$Tools
    )

    Write-Verbose -Message 'Validating the Tools object(s)...'

    foreach ($tool in $Tools) {
        # Validate main parameters
        if (-not $tool.PSObject.Properties["name"] -or -not [string]::IsNullOrWhiteSpace($tool.name) -eq $false) {
            Write-Debug -Message 'The name property is missing or empty.'
            return $false
        }
        if (-not $tool.PSObject.Properties["description"] -or -not [string]::IsNullOrWhiteSpace($tool.description) -eq $false) {
            Write-Debug -Message 'The description property is missing or empty.'
            return $false
        }

        # Validate parameters
        if (-not $tool.PSObject.Properties["parameters"]) {
            Write-Debug -Message 'The parameters property is missing.'
            return $false
        }
        # Validate each parameter definition
        foreach ($parameterName in $tool.parameters.Keys) {
            $parameter = $tool.parameters[$parameterName]
            if (-not ($parameter -is [PSCustomObject])) {
                Write-Error "Error: Parameter definition for '$parameterName' is not a PSCustomObject."
                return $false
            }

            # Validate 'description' property within parameter definition
            if (-not $parameter.description) {
                Write-Error "Error: 'description' property missing or null in parameter definition for '$parameterName'."
                return $false
            }

            # Validate 'param_type' property within parameter definition
            if (-not $parameter.param_type) {
                Write-Error "Error: 'param_type' property missing or null in parameter definition for '$parameterName'."
                return $false
            }

            # Validate 'required' property within parameter definition
            if (-not ($parameter.required -is [bool])) {
                Write-Error "Error: 'required' property missing or not a PSProperty in parameter definition for '$parameterName'."
                return $false
            }
        } #foreach_parameterName

    } #foreach_tool

    return $true
} #Test-MetaTool
