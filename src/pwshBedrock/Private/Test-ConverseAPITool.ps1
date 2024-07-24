<#
.SYNOPSIS
    Validates a Tools object for use with the Converse API.
.DESCRIPTION
    Evaluates a Tools object to ensure it meets the requirements for use with the Converse API.
    It checks the structure of the tools objects to ensure they are properly formatted.
.EXAMPLE
    $tools = [PSCustomObject]@{
        Name        = 'restaurant'
        Description = 'This tool will look up restaurant information in a provided geographic area.'
        Properties  = @{
            location = [PSCustomObject]@{
                type        = 'string'
                description = 'The geographic location or locale. This could be a city, state, country, or full address.'
            }
            cuisine  = [PSCustomObject]@{
                type        = 'string'
                description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
            }
            budget   = [PSCustomObject]@{
                type        = 'string'
                description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
            }
            rating   = [PSCustomObject]@{
                type        = 'string'
                description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
            }
        }
        required    = @(
            'location'
        )
    }
    Test-ConverseAPITool -Tools $tools

    Tests the Tools object to ensure it meets the requirements for use with the Converse API.
.PARAMETER Tools
    Definitions of tools that the model may use.
.OUTPUTS
    System.Boolean
.NOTES
    Not every property is validated. There are hash tables that can contain custom properties.

    The properties field must be a hashtable. Amazon.Runtime.Documents.Document does not handle the properties field if it is a PSCustomObject.
.COMPONENT
    pwshBedrock
#>
function Test-ConverseAPITool {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Definitions of tools that the model may use.')]
        [PSCustomObject[]]$Tools
    )

    Write-Verbose -Message 'Validating the Tools object(s)...'

    foreach ($tool in $Tools) {
        # Validate main parameters
        if (-not $tool.PSObject.Properties['Name']) {
            Write-Debug -Message 'The Name property is missing or empty.'
            return $false
        }

        if (-not $tool.PSObject.Properties['Description']) {
            Write-Debug -Message 'The Description property is missing or empty.'
            return $false
        }

        if (-not $tool.PSObject.Properties['Properties']) {
            Write-Debug -Message 'The Properties property is missing.'
            return $false
        }

        if (-not $tool.PSObject.Properties['required']) {
            Write-Debug -Message 'The required property is missing.'
            return $false
        }

        if ($tool.Properties.Keys.Count -gt 0) {
            Write-Debug -Message 'Validating the Properties object...'
            Write-Debug -Message ('Properties count: {0}' -f $tool.Properties.Keys.Count)
            foreach ($key in $tool.Properties.Keys) {
                $value = $tool.Properties[$key]

                if (-not ($value.PSObject.Properties.Name -contains 'type')) {
                    Write-Debug -Message 'The type property is missing.'
                    return $false
                }
                if (-not ($value.PSObject.Properties.Name -contains 'description')) {
                    Write-Debug -Message 'The description property is missing.'
                    return $false
                }
                if ($value.type -ne 'string') {
                    Write-Debug -Message 'The type property must be a string.'
                    return $false
                }
                if ([string]::IsNullOrWhiteSpace($value.description)) {
                    Write-Debug -Message 'The description property must not be null or whitespace.'
                    return $false
                }
            }
        }
        else {
            Write-Debug -Message 'The Properties property is empty.'
            return $false
        }
    } #foreach_tool

    return $true
} #Test-ConverseAPITool
