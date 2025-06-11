<#
.SYNOPSIS
    Validates a Tools object for use with the Meta models.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Meta models.
    It checks the structure of the tools objects to ensure they are properly formatted.
    Supports both Llama 3 and Llama 4 tool formats.
.EXAMPLE
    # Llama 3 format
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
    Test-MetaTool -Tools $tools -ModelID 'meta.llama3-8b-instruct-v1:0'

    Tests the Tools object to ensure it meets the requirements for Llama 3 models.
.EXAMPLE
    # Llama 4 format
    $tools = [PSCustomObject]@{
        name        = 'get_weather'
        description = 'Get weather info for places'
        inputSchema = [PSCustomObject]@{
            type       = 'dict'
            required   = @('city')
            properties = [PSCustomObject]@{
                city = [PSCustomObject]@{
                    type        = 'string'
                    description = 'The name of the city to get the weather for'
                }
            }
        }
    }
    Test-MetaTool -Tools $tools -ModelID 'meta.llama4-maverick-17b-instruct-v1:0'

    Tests the Tools object to ensure it meets the requirements for Llama 4 models.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
.PARAMETER ModelID
    The unique identifier of the model.
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
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'meta.llama3-8b-instruct-v1:0',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-1-8b-instruct-v1:0',
            'meta.llama3-1-70b-instruct-v1:0',
            'meta.llama3-1-405b-instruct-v1:0',
            'meta.llama3-2-1b-instruct-v1:0',
            'meta.llama3-2-3b-instruct-v1:0',
            'meta.llama3-2-11b-instruct-v1:0',
            'meta.llama3-2-90b-instruct-v1:0',
            'meta.llama3-3-70b-instruct-v1:0',
            'meta.llama4-maverick-17b-instruct-v1:0',
            'meta.llama4-scout-17b-instruct-v1:0'
        )]
        [string]$ModelID
    )    Write-Verbose -Message 'Validating the Tools object(s)...'

    # Determine if this is a Llama 4 model
    $isLlama4 = $ModelID -like '*llama4*'

    foreach ($tool in $Tools) {
        # Validate main parameters (common to both formats)
        if (-not $tool.PSObject.Properties["name"] -or [string]::IsNullOrWhiteSpace($tool.name)) {
            Write-Debug -Message 'The name property is missing or empty.'
            return $false
        }
        if (-not $tool.PSObject.Properties["description"] -or [string]::IsNullOrWhiteSpace($tool.description)) {
            Write-Debug -Message 'The description property is missing or empty.'
            return $false
        }

        if ($isLlama4) {
            # Validate Llama 4 format (inputSchema)
            if (-not $tool.PSObject.Properties["inputSchema"]) {
                Write-Debug -Message 'The inputSchema property is missing for Llama 4 model.'
                return $false
            }

            $inputSchema = $tool.inputSchema
            if (-not ($inputSchema -is [PSCustomObject])) {
                Write-Error "Error: inputSchema is not a PSCustomObject."
                return $false
            }

            # Validate inputSchema type
            if (-not $inputSchema.PSObject.Properties["type"] -or [string]::IsNullOrWhiteSpace($inputSchema.type)) {
                Write-Error "Error: 'type' property missing or empty in inputSchema."
                return $false
            }

            # Validate inputSchema properties
            if (-not $inputSchema.PSObject.Properties["properties"]) {
                Write-Error "Error: 'properties' property missing in inputSchema."
                return $false
            }

            if (-not ($inputSchema.properties -is [PSCustomObject])) {
                Write-Error "Error: 'properties' in inputSchema is not a PSCustomObject."
                return $false
            }

            # Validate required array (optional but if present should be an array)
            if ($inputSchema.PSObject.Properties["required"] -and -not ($inputSchema.required -is [array])) {
                Write-Error "Error: 'required' property in inputSchema should be an array."
                return $false
            }

            # Validate each property in inputSchema.properties
            foreach ($propName in $inputSchema.properties.PSObject.Properties.Name) {
                $property = $inputSchema.properties.$propName
                if (-not ($property -is [PSCustomObject])) {
                    Write-Error "Error: Property definition for '$propName' is not a PSCustomObject."
                    return $false
                }

                # Validate 'type' property within property definition
                if (-not $property.PSObject.Properties["type"] -or [string]::IsNullOrWhiteSpace($property.type)) {
                    Write-Error "Error: 'type' property missing or empty in property definition for '$propName'."
                    return $false
                }

                # Validate 'description' property within property definition
                if (-not $property.PSObject.Properties["description"] -or [string]::IsNullOrWhiteSpace($property.description)) {
                    Write-Error "Error: 'description' property missing or empty in property definition for '$propName'."
                    return $false
                }
            }
        }
        else {
            # Validate Llama 3 format (parameters)
            if (-not $tool.PSObject.Properties["parameters"]) {
                Write-Debug -Message 'The parameters property is missing for Llama 3 model.'
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
                if (-not $parameter.PSObject.Properties["description"] -or [string]::IsNullOrWhiteSpace($parameter.description)) {
                    Write-Error "Error: 'description' property missing or empty in parameter definition for '$parameterName'."
                    return $false
                }

                # Validate 'param_type' property within parameter definition
                if (-not $parameter.PSObject.Properties["param_type"] -or [string]::IsNullOrWhiteSpace($parameter.param_type)) {
                    Write-Error "Error: 'param_type' property missing or empty in parameter definition for '$parameterName'."
                    return $false
                }

                # Validate 'required' property within parameter definition
                if (-not ($parameter.PSObject.Properties["required"]) -or -not ($parameter.required -is [bool])) {
                    Write-Error "Error: 'required' property missing or not a boolean in parameter definition for '$parameterName'."
                    return $false
                }
            } #foreach_parameterName
        }

    } #foreach_tool

    return $true
} #Test-MetaTool
