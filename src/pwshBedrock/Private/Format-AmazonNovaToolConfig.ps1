<#
.SYNOPSIS
    Formats a Tool Config to be sent to the Amazon Nova model.
.DESCRIPTION
    Formats a Tool ConfigSpecification to be sent to the Amazon Nova model.
    Converse requires very specific object types for a tool configuration.
.EXAMPLE
    Format-AmazonNovaToolConfig -ToolsConfig $ToolsConfig

    This example formats a tool configuration to be sent to the Amazon Nova model.
.PARAMETER ToolsConfig
    The tool configuration to be formatted.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.COMPONENT
    pwshBedrock
#>
function Format-AmazonNovaToolConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Tool provided to model.')]
        [ValidateNotNull()]
        [object[]]$ToolsConfig
    )

    Write-Verbose -Message 'Formatting Amazon Nova Tool Config'

    $allTools = New-Object System.Collections.Generic.List[object]

    foreach ($toolConfig in $ToolsConfig) {
        # Use serialize/deserialize to clone
        $newFormattedTool = [System.Management.Automation.PSSerializer]::Deserialize(
            [System.Management.Automation.PSSerializer]::Serialize($toolConfig)
        )

        [string]$tempJsonHold = ''

        $tempJsonHold = $newFormattedTool.toolSpec.inputSchema | ConvertTo-Json -Depth 10

        # replace the inputSchema with the converted json
        $newFormattedTool.toolSpec.inputSchema = $tempJsonHold

        $allTools.Add($newFormattedTool)
    }

    return $allTools

} #Format-AmazonNovaToolConfig


