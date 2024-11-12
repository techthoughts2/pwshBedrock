<#
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
.COMPONENT
    pwshBedrock
#>
function Format-MetaTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Model')]
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
            'meta.llama2-13b-chat-v1',
            'meta.llama2-70b-chat-v1',
            'meta.llama3-8b-instruct-v1:0',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-1-8b-instruct-v1:0',
            'meta.llama3-1-70b-instruct-v1:0',
            'meta.llama3-1-405b-instruct-v1:0',
            'meta.llama3-2-1b-instruct-v1:0',
            'meta.llama3-2-3b-instruct-v1:0',
            'meta.llama3-2-11b-instruct-v1:0',
            'meta.llama3-2-90b-instruct-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Meta Message'

    # https://huggingface.co/blog/llama2#how-to-prompt-llama-2
    $standardLlama2Prompt = @'
<s>[INST] <<SYS>>
You are a helpful, respectful and honest assistant. Always answer as helpfully as possible, while being safe.  Your answers should not include any harmful, unethical, racist, sexist, toxic, dangerous, or illegal content. Please ensure that your responses are socially unbiased and positive in nature.

If a question does not make any sense, or is not factually coherent, explain why instead of answering something not correct. If you don't know the answer to a question, please don't share false information.
<</SYS>>
'@
    # https://llama.meta.com/docs/model-cards-and-prompt-formats/meta-llama-3/
    $standardLlama3Prompt = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a helpful, respectful and honest assistant. Always answer as helpfully as possible, while being safe.  Your answers should not include any harmful, unethical, racist, sexist, toxic, dangerous, or illegal content. Please ensure that your responses are socially unbiased and positive in nature.
If a question does not make any sense, or is not factually coherent, explain why instead of answering something not correct. If you don't know the answer to a question, please don't share false information.<|eot_id|>
'@

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

    if ($ModelID -like '*llama2*') {
        Write-Debug 'Processing llama2 model'
        $sysPromptRegex = '(?<=<<SYS>>\r?\n)([\s\S]*?)(?=\r?\n<</SYS>>)'
        if ($firstMessage -eq $true) {
            $str = $str + "$standardLlama2Prompt`n`n" + $Message + '[/INST]'
        }
        else {
            if ($Role -eq 'User') {
                $str = $str + "`n<s>[INST]" + $Message + '[/INST]'
            }
            elseif ($Role -eq 'Model') {
                $str = $str + $Message + '</s>'
            }
        }
    } #if_llama2
    elseif ($ModelID -like '*llama3*') {
        Write-Debug 'Processing llama3 model'
        $sysPromptRegex = '(?<=system<\|end_header_id\|>\r?\n)([\s\S]*?)(?=<\|eot_id\|>)'

        if ($ImagePrompt) {
            $str = "$standardVisionPrompt`n`n" + '<|image|>' + $ImagePrompt + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
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
    } #elseif_llama3

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
