<#
.SYNOPSIS
    Formats a message to be sent to a Mistral AI model.
.DESCRIPTION
    This function formats a message to be sent to a Mistral AI model.
.EXAMPLE
    Format-MistralAITextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'mistral.mistral-7b-instruct-v0:2'

    This example formats a message to be sent to the Mistral AI model 'mistral.mistral-7b-instruct-v0:2'.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
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
.COMPONENT
    pwshBedrock
#>
function Format-MistralAITextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Model')]
        [string]$Role,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'mistral.mistral-7b-instruct-v0:2',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Meta Message'

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

    if ($firstMessage -eq $true) {
        $str = $str + '<s>[INST] ' + $Message + ' [/INST]'
    }
    else {
        if ($Role -eq 'User') {
            $str = $str + "`n[INST] " + $Message + ' [/INST]'
        }
        elseif ($Role -eq 'Model') {
            $str = $str + "`n" + $Message + '</s>'
        }
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
    Write-Debug 'out of Format-MistralAITextMessage'
    return $returnContext

} #Format-MistralAITextMessage
