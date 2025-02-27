﻿<#
.SYNOPSIS
    Formats a message to be sent to a Meta model.
.DESCRIPTION
    This function formats a message to be sent to a Meta model.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'meta.llama3-1-8b-instruct-v1:0'

    Formats a text message to be sent to the Meta model.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'meta.llama3-1-8b-instruct-v1:0' -NoContextPersist

    Formats a text message to be sent to the Meta model without persisting the conversation context history.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -SystemPrompt 'You are a Star Trek trivia expert.' -ModelID 'meta.llama3-1-8b-instruct-v1:0'

    Formats a text message to be sent to the Meta model with a system prompt.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -ImagePrompt 'Describe this image in two sentences.' -ModelID 'meta.llama3-2-11b-instruct-v1:0'

    Formats a text message to be sent to the Meta model with an image prompt.
.EXAMPLE
    $standardTools = @(
        [PSCustomObject]@{
            name        = 'string'
            description = 'string'
            parameters  = @{
                'parameter_name' = [PSCustomObject]@{
                    param_type  = 'string'
                    description = 'string'
                    required    = $true
                }
            }
        }
    )
    Format-MetaTextMessage -Role 'ipython' -Message 'Use the tool to find the info' -Tools $standardTools -ModelID 'meta.llama3-2-11b-instruct-v1:0'

    Formats a text message to be sent to the Meta model with a tool prompt.
.EXAMPLE
    $toolResults = [PSCustomObject]@{
        output = @(
            [PSCustomObject]@{
                name = "John"
                age  = 30
            },
            [PSCustomObject]@{
                name = "Jane"
                age  = 25
            }
        )
    }
    $formatMetaMessageSplat = @{
        Role         = 'ipython'
        ToolsResults = $toolResults
        ModelID      = 'meta.llama3-1-70b-instruct-v1:0'
    }
    $result = Format-MetaTextMessage @formatMetaMessageSplat

    Formats a text message to be sent to the Meta model with a tool result prompt.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ImagePrompt
    The image prompt to be sent to the model.
.PARAMETER SystemPrompt
    The system prompt to be sent to the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model.
.PARAMETER Tools
    A list of available tools (functions) that the model may suggest invoking before producing a text response.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    The model requires a specific format for the message. This function formats the message accordingly.
    The logic in this function actually replaces the context history in memory with the newly crafted message.
    This is because the logic adds to the string.

    Llama 3 information:
    There are 4 different roles that are supported by Llama text models:
        system: Sets the context in which to interact with the AI model. It typically includes rules, guidelines, or necessary information that help the model respond effectively.
        user: Represents the human interacting with the model. It includes the inputs, commands, and questions to the model.
        ipython: A new role introduced in Llama 3.1. Semantically, this role means "tool". This role is used to mark messages with the output of a tool call when sent back to the model from the executor.
        assistant: Represents the response generated by the AI model based on the context provided in the system, ipython and user prompts.
    using tools to perform some actions

    built-in: the model has built-in knowledge of tools like search or code interpreter
    zero-shot: the model can learn to call tools using previously unseen, in-context tool definitions
.COMPONENT
    pwshBedrock
#>
function Format-MetaTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Model', 'ipython')]
        [string]$Role,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.',
            ParameterSetName = 'MessageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The prompt to the Vision-Instruct model.',
            ParameterSetName = 'ImageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePrompt,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system prompt to be sent to the model.')]
        [string]$SystemPrompt,

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
            'meta.llama3-3-70b-instruct-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of available tools (functions) that the model may suggest invoking before producing a text response.')]
        [PSCustomObject[]]$Tools,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ToolsResultsSet',
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [PSCustomObject]$ToolsResults

    )

    Write-Verbose -Message 'Formatting Meta Message'

    # https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/
    $standardLlama3Prompt = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a helpful, respectful and honest assistant. Always answer as helpfully as possible, while being safe.  Your answers should not include any harmful, unethical, racist, sexist, toxic, dangerous, or illegal content. Please ensure that your responses are socially unbiased and positive in nature.
If a question does not make any sense, or is not factually coherent, explain why instead of answering something not correct. If you don't know the answer to a question, please don't share false information.<|eot_id|>
'@

    if ($Tools) {
        # https://www.llama.com/docs/model-cards-and-prompt-formats/llama3_1/#user-defined-custom-tool-calling
        # get date in the format of day month year
        $date = Get-Date -Format "dd MMMM yyyy"

        # the user may provide several tools to the model
        # we will need to loop through each and convert them to json to a variable that can then be added to the prompt
        $json = ''
        foreach ($tool in $Tools) {
            $toolJson = $tool | ConvertTo-Json -Depth 10
            $json = $json + $toolJson
        }

        $toolLlama31Prompt = @"
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

Environment: ipython
Tools: brave_search, wolfram_alpha
Cutting Knowledge Date: December 2023
Today Date: $date

# Tool Instructions
- Always execute python code in messages that you share.
- When looking for real time information use relevant functions if available else fallback to brave_search

You have access to the following functions:
$json

If a you choose to call a function ONLY reply in the following format:
<{start_tag}={function_name}>{parameters}{end_tag}
where

start_tag => `<function`
parameters => a JSON dict with the function argument name as key and function argument value as value.
end_tag => `</function>`

Here is an example,
<function=example_function_name>{"example_name": "example_value"}</function>

Reminder:
- Function calls MUST follow the specified format
- Required parameters MUST be specified
- Only call one function at a time
- Put the entire function call reply on one line
- Always add your sources when using search results to answer the user query

You are a helpful assistant.<|eot_id|><|start_header_id|>user<|end_header_id|>
"@
    } #if_tools

    if ($ToolsResults) {
        $toolResultsJson = $ToolsResults | ConvertTo-Json -Depth 10 -Compress
        $toolResultsLlama31Prompt = @"
$toolResultsJson<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"@
    }

    # https://github.com/meta-llama/llama-models/blob/main/models/llama3_2/vision_prompt_format.md
    $standardVisionPrompt = @'
<|begin_of_text|><|start_header_id|>user<|end_header_id|>
'@

    # we need to determine if this is the first message in the conversation
    # if it is, we need to create the system prompt scaffolding
    $contextEval = Get-ModelContext -ModelID $ModelID
    if ([string]::IsNullOrEmpty($contextEval)) {
        Write-Debug -Message 'No context found. Creating new context.'
        $firstMessage = $true
        $str = ''
    }
    else {
        Write-Debug -Message 'Context found. Using existing context.'
        $firstMessage = $false
        $str = $contextEval
    }

    Write-Debug 'Processing llama3 model'
    $sysPromptRegex = '(?<=system<\|end_header_id\|>\r?\n)([\s\S]*?)(?=<\|eot_id\|>)'

    if ($ImagePrompt) {
        $str = "$standardVisionPrompt`n`n" + '<|image|>' + $ImagePrompt + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
    }
    elseif ($Tools) {
        $str = $toolLlama31Prompt + "`n`n" + $Message + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
    }
    elseif ($ToolsResults) {
        $str = $toolResultsLlama31Prompt
    }
    elseif ($Role -eq 'ipython') {
        $str = $str + "`n`n" + $Message + '<|eom_id|><|start_header_id|>ipython<|end_header_id|>'
    }
    elseif ($firstMessage -eq $true) {
        $str = $str + "$standardLlama3Prompt`n`n" + $Message + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
    }
    else {
        if ($Role -eq 'User') {
            $str = $str + "`n`n" + $Message + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
        }
        elseif ($Role -eq 'Model') {
            $str = $str + "`n`n" + $Message + '<|eot_id|><|start_header_id|>user<|end_header_id|>'
        }
    }

    if ($SystemPrompt) {
        Write-Debug -Message 'System prompt provided'
        Write-Debug -Message ('System prompt: {0}' -f $SystemPrompt)
        Write-Debug -Message ('System prompt regex: {0}' -f $sysPromptRegex)
        $str = $str -replace $sysPromptRegex, $SystemPrompt
    }

    Write-Debug -Message ('Formatted message: {0}' -f $str)

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context = $str
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $str
    }
    Write-Debug 'out of Format-MetaTextMessage'
    return $returnContext

} #Format-MetaTextMessage
