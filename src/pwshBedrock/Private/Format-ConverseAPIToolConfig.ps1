<#
.SYNOPSIS
    Formats a Amazon.BedrockRuntime.Model.Tool to be sent to the Converse API.
.DESCRIPTION
    Formats a Amazon.BedrockRuntime.Model.ToolSpecification to be sent to the Converse API.
    Converse requires very specific object types for a tool configuration.
.EXAMPLE
    Format-ConverseAPIToolConfig -ToolsConfig $ToolsConfig

    This example formats a tool configuration to be sent to the Converse API.
.PARAMETER ToolsConfig
    The tool configuration to be formatted.
.OUTPUTS
    Amazon.BedrockRuntime.Model.Tool
.NOTES
    Amazon.BedrockRuntime.Model.Tool
    Amazon.BedrockRuntime.Model.ToolSpecification
    Amazon.BedrockRuntime.Model.ToolInputSchema
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TTool.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/?page=TToolSpecification.html&tocid=Amazon_BedrockRuntime_Model_ToolSpecification
.COMPONENT
    pwshBedrock
#>
function Format-ConverseAPIToolConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Tool provided to model.')]
        [ValidateNotNull()]
        [object[]]$ToolsConfig
    )

    Write-Verbose -Message 'Formatting Converse Tool Config'

    $allTools = New-Object System.Collections.Generic.List[object]

    foreach ($toolConfig in $ToolsConfig) {
        $tool = [Amazon.BedrockRuntime.Model.Tool]::new()
        $toolspec = [Amazon.BedrockRuntime.Model.ToolSpecification]::new()
        $toolspec.Name = $toolConfig.Name
        $toolspec.Description = $toolConfig.Description
        $toolspecInputSchema = [Amazon.BedrockRuntime.Model.ToolInputSchema]::new()

        # add a type property set to object on the $toolConfig.Properties object
        $newPropertiesObj = [ordered]@{
            type       = 'object'
            properties = $toolConfig.Properties
            required   = $toolConfig.Required
        }

        $toolspecInputSchema.Json = [Amazon.Runtime.Documents.Document]::FromObject($newPropertiesObj)
        $toolspec.InputSchema = $toolspecInputSchema
        $tool.ToolSpec = $toolspec

        $allTools.Add($tool)
    }

    return $allTools

} #Format-ConverseAPIToolConfig


