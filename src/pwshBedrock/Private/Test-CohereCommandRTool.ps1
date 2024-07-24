<#
.SYNOPSIS
    Validates a Tools object for use with the Cohere Command R models.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Cohere Command R models.
    It checks the structure of the tools objects to ensure they are properly formatted.
.EXAMPLE
    $tools = [PSCustomObject]@{
        name                  = "string"
        description           = "string"
        parameter_definitions = @{
            "parameter name" = [PSCustomObject]@{
                description = "string"
                type        = "string"
                required    = $true
            }
        }
    }
    Test-CohereCommandRTool -Tools $tools

    Tests the Tools object to ensure it meets the requirements for use with the Cohere Command R models.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-CohereCommandRTool {
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

        # Validate parameter_definitions
        if (-not $tool.PSObject.Properties["parameter_definitions"]) {
            Write-Debug -Message 'The parameter_definitions property is missing.'
            return $false
        }
        # Validate each parameter definition
        foreach ($parameterName in $tool.parameter_definitions.Keys) {
            $parameter = $tool.parameter_definitions[$parameterName]
            if (-not ($parameter -is [PSCustomObject])) {
                Write-Error "Error: Parameter definition for '$parameterName' is not a PSCustomObject."
                return $false
            }

            # Validate 'description' property within parameter definition
            if (-not $parameter.description) {
                Write-Error "Error: 'description' property missing or null in parameter definition for '$parameterName'."
                return $false
            }

            # Validate 'type' property within parameter definition
            if (-not $parameter.type) {
                Write-Error "Error: 'type' property missing or null in parameter definition for '$parameterName'."
                return $false
            }

            # Validate 'required' property within parameter definition
            if (-not ($parameter.required -is [bool])) {
                Write-Error "Error: 'required' property missing or not a PSProperty in parameter definition for '$parameterName'."
                return $false
            }
        } #foreach_parameterName

        # # validate parameter_definitions sub-properties
        # if ([string]::IsNullOrWhiteSpace($tool.'parameter_definitions'.'parameter name'.description)) {
        #     Write-Debug -Message 'The parameter_definitions description sub-property is missing or empty.'
        #     return $false
        # }
        # if ([string]::IsNullOrWhiteSpace($tool.'parameter_definitions'.'parameter name'.type)) {
        #     Write-Debug -Message 'The parameter_definitions type sub-property is missing or empty.'
        #     return $false
        # }
        # if ($tool.'parameter_definitions'.'parameter name'.required -eq $true -or $tool.'parameter_definitions'.'parameter name'.required -eq $false) {
        #     Write-Debug -Message 'The parameter_definitions required sub-property is valid.'
        # }
        # else {
        #     Write-Debug -Message 'The parameter_definitions required sub-property is missing or empty.'
        #     return $false
        # }

    } #foreach_tool

    return $true
} #Test-CohereCommandRTool
