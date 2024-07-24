<#
.SYNOPSIS
    Formats a message to be sent to a Mistral AI model.
.DESCRIPTION
    This function formats a message to be sent to a Mistral AI model.
.EXAMPLE
    Format-MistralAIChatModel -Role 'User' -Message 'Hello, how are you?' -ModelID 'mistral.mistral-large-2402-v1:0'

    This example formats a message to be sent to the Mistral AI model 'mistral.mistral-large-2402-v1:0'.
.PARAMETER Role
    The role of the message sender.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.PARAMETER ToolCalls
    The tool calls that were returned by the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    The model requires a specific format for the message. This function formats the message accordingly.
    This model uses object based updates to the context instead of a single string.
.COMPONENT
    pwshBedrock
#>
function Format-MistralAIChatModel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('system', 'user', 'assistant', 'tool')]
        [string]$Role,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [ValidateNotNull()]
        [object]$ToolsResults,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The tool calls that were returned by the model.')]
        [ValidateNotNullOrEmpty()]
        [object[]]$ToolCalls,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'mistral.mistral-large-2402-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Mistral AI Chat Message'

    # we need to account for a special condition where the import global variable is default set to string
    # the mistral chat model context is unique in that it is a collection of objects instead of a single string

    $contextEval = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
    if ($contextEval.Context -eq '' -or $null -eq $contextEval.Context -or $contextEval.Context.Count -eq 0) {
        Write-Debug -Message 'No context found. Creating new object based context.'
        $contextEval.Context = New-Object System.Collections.Generic.List[object]
        $firstMessage = $true
    }
    else {
        $firstMessage = $false
    }

    switch ($Role) {
        'system' {
            if ($firstMessage -eq $true) {
                $obj = [PSCustomObject]@{
                    role    = 'system'
                    content = $Message
                }
            }
            else {
                # we need to determine if the context already has a system message
                # if it does, we need to replace it with the new system message
                # if it does not, we need to add the new system message
                $obj = $contextEval.Context | Where-Object { $_.role -eq 'system' }
                if ($null -eq $obj) {
                    $obj = [PSCustomObject]@{
                        role    = 'system'
                        content = $Message
                    }
                }
                else {
                    $obj.content = $Message
                    return
                }
            }
        }
        'user' {
            $obj = [PSCustomObject]@{
                role    = 'user'
                content = $Message
            }
        }
        'assistant' {
            if ($ToolCalls) {
                $obj = [PSCustomObject]@{
                    role       = 'assistant'
                    content    = $Message
                    tool_calls = $ToolCalls
                }
            }
            else {
                $obj = [PSCustomObject]@{
                    role    = 'assistant'
                    content = $Message
                }
            }
        }
        'tool' {
            # we essentially recreate the same object passed in with one important difference
            # the powershell object in content must be converted to a json string
            # the upstream ConvertTo-Json for the body payload should not process the content conversion.

            $obj = [PSCustomObject]@{
                role         = 'tool'
                tool_call_id = $ToolsResults.tool_call_id
                content      = $ToolsResults.content | ConvertTo-Json -Compress
            }
        }
    } #switch_role

    Write-Debug -Message ('Formatted message: {0}' -f ($obj | Out-String) )

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context.Add($obj)
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $obj
    }
    Write-Debug 'out of Format-MistralAIChatModel'
    return $returnContext

} #Format-MistralAIChatModel
