<#
.SYNOPSIS
    Formats a message to be sent to a DeepSeek model.
.DESCRIPTION
    This function formats a message to be sent to a DeepSeek model.
.EXAMPLE
    Format-DeepSeekTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'deepseek.r1-v1:0'

    Formats a text message to be sent to the DeepSeek model.
.EXAMPLE
    Format-DeepSeekTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'deepseek.r1-v1:0' -NoContextPersist

    Formats a text message to be sent to the DeepSeek model without persisting the conversation context history.
.EXAMPLE
    Format-DeepSeekTextMessage -Role 'User' -Message 'Hello, how are you?' -SystemPrompt 'You are a Star Trek trivia expert.' -ModelID 'deepseek.r1-v1:0'

    Formats a text message to be sent to the DeepSeek model with a system prompt.
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
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    The model requires a specific format for the message. This function formats the message accordingly.
    The logic in this function actually replaces the context history in memory with the newly crafted message.
    This is because the logic adds to the string.

    DeepSeek prompt format:
    <｜begin_of_sentence｜>{system_prompt}<｜User｜>{prompt}<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>

    DeepSeek Conversation Example 1:
    <｜begin_of_sentence｜>You are a helpful assistant.
    <｜User｜>What is 2 + 2?
    <｜Assistant｜>2 + 2 equals 4.
    <｜User｜>Can you explain why?
    <｜Assistant｜>Let’s break it down: 2 represents two units, and adding another two units gives us four units total. So, 2 + 2 = 4.
    <｜end_of_sentence｜><｜Assistant｜>
.COMPONENT
    pwshBedrock
#>
function Format-DeepSeekTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Assistant')]
        [string]$Role,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.',
            ParameterSetName = 'MessageSet')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The system prompt to be sent to the model.')]
        [string]$SystemPrompt,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'deepseek.r1-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false

    )

    Write-Verbose -Message 'Formatting DeepSeek Message'    # Check if there's existing context for this model
    $contextEval = Get-ModelContext -ModelID $ModelID
    if ([string]::IsNullOrEmpty($contextEval)) {
        Write-Debug -Message 'No context found. Creating new context.'
        $str = '<｜begin_of_sentence｜>'        # Add system prompt if provided
        if ($SystemPrompt) {
            Write-Debug -Message ('System prompt: {0}' -f $SystemPrompt)
            $str += "$SystemPrompt"
        }
    }
    else {
        Write-Debug -Message 'Context found. Using existing context.'
        $str = $contextEval
    }
    # Format message based on role and whether this is the first message
    if ($Role -eq 'User') {
        $str += "<｜User｜>$Message"
        # When user is providing input, we need to append the ending format to prepare for model response
        # $str += "<｜end_of_sentence｜><｜Assistant｜>"
    }
    elseif ($Role -eq 'Assistant') {
        $str += "<｜Assistant｜>$Message"
    }

    Write-Debug -Message ('Formatted message: {0}' -f $str)

    # Manage context persistence
    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context = $str
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $str
    }

    Write-Debug 'out of Format-DeepSeekTextMessage'
    return $returnContext

} #Format-DeepSeekTextMessage
