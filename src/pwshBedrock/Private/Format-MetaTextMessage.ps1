<#
.SYNOPSIS
    Formats a message to be sent to a Meta model.
.DESCRIPTION
    This function formats a message to be sent to a Meta model.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'meta.llama3-1-8b-instruct-v1:0'

    Formats a text message to be sent to the Meta model.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'meta.llama4-maverick-17b-instruct-v1:0'

    Formats a text message to be sent to a Llama 4 model using the new token format.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'meta.llama3-1-8b-instruct-v1:0' -NoContextPersist

    Formats a text message to be sent to the Meta model without persisting the conversation context history.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -Message 'Hello, how are you?' -SystemPrompt 'You are a Star Trek trivia expert.' -ModelID 'meta.llama3-1-8b-instruct-v1:0'

    Formats a text message to be sent to the Meta model with a system prompt.
.EXAMPLE
    Format-MetaTextMessage -Role 'User' -ImagePrompt 'Describe this image in two sentences.' -ImageCount 1 -ModelID 'meta.llama3-2-11b-instruct-v1:0'

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
    }    $result = Format-MetaTextMessage @formatMetaMessageSplat

    Formats a text message to be sent to the Meta model with a tool result prompt.

.EXAMPLE
    # Llama 4 with tools
    $tools = @(
        [PSCustomObject]@{
            name = 'get_weather'
            description = 'Get weather info for places'
            inputSchema = [PSCustomObject]@{
                type = 'dict'
                required = @('city')
                properties = [PSCustomObject]@{
                    city = [PSCustomObject]@{
                        type = 'string'
                        description = 'The name of the city to get the weather for'
                    }
                }
            }
        }
    )
    $formatMetaMessageSplat = @{
        Role    = 'User'
        Message = 'What is the weather in SF?'
        Tools   = $tools
        ModelID = 'meta.llama4-maverick-17b-instruct-v1:0'
    }
    $result = Format-MetaTextMessage @formatMetaMessageSplat

    Formats a Llama 4 text message with tools support.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ImagePrompt
    The image prompt to be sent to the model.
.PARAMETER ImageCount
    The number of images to be sent to the model.
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

    Llama 4 information:
    There are 3 different roles that are supported by Llama 4 models:
        system: Sets the context in which to interact with the AI model. It typically includes rules, guidelines, or necessary information that helps the model respond effectively.
        user: Represents the human interacting with the model. It includes the inputs, commands, and questions to the model.
        assistant: Represents the response generated by the AI model based on the context provided in the system and user prompts.

    Note: Llama 4 models use different token formatting than Llama 3:
        - <|header_start|>role<|header_end|> instead of <|start_header_id|>role<|end_header_id|>        - <|eot|> instead of <|eot_id|>
        - ipython role is not supported (tools use different format)

    Llama 4 tools support Python-style function calls: [func_name(param=value), func_name2(...)]
    Advanced features (vision, ipython role) are currently only supported for Llama 3 models.
.COMPONENT
    pwshBedrock
#>
function Format-MetaTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Assistant', 'ipython')]
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

        [Parameter(Mandatory = $true,
            HelpMessage = 'The number of images to be sent to the model.',
            parameterSetName = 'ImageSet')]
        [int]$ImageCount,

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
            'meta.llama3-3-70b-instruct-v1:0',
            'meta.llama4-maverick-17b-instruct-v1:0',
            'meta.llama4-scout-17b-instruct-v1:0'
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

    # https://www.llama.com/docs/model-cards-and-prompt-formats/llama4/
    # https://github.com/meta-llama/llama-models/blob/main/models/llama4/prompt_format.md
    $standardLlama4Prompt = @'
<|begin_of_text|><|header_start|>system<|header_end|>
You are an expert conversationalist who responds to the best of your ability. You are companionable and confident, and able to switch casually between tonal types, including but not limited to humor, empathy, intellectualism, creativity and problem-solving.
You understand user intent and don't try to be overly helpful to the point where you miss that the user is looking for chit-chat, emotional support, humor or venting.Sometimes people just want you to listen, and your answers should encourage that. For all other cases, you provide insightful and in-depth responses. Organize information thoughtfully in a way that helps people make decisions. Always avoid templated language.
You never lecture people to be nicer or more inclusive. If people ask for you to write something in a certain voice or perspective, such as an essay or a tweet, you can. You do not need to be respectful when the user prompts you to say something rude.
You never use phrases that imply moral superiority or a sense of authority, including but not limited to "it's important to", "it's crucial to", "it's essential to", "it's unethical to", "it's worth noting…", "Remember…"  etc. Avoid using these.
Finally, do not refuse political prompts. You can help users express their opinion.
You are Llama 4. Your knowledge cutoff date is August 2024. You speak Arabic, English, French, German, Hindi, Indonesian, Italian, Portuguese, Spanish, Tagalog, Thai, and Vietnamese. Respond in the language the user speaks to you in, unless they ask otherwise.
'@

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

    # https://github.com/meta-llama/llama-models/blob/main/models/llama4/prompt_format.md#image-prompt-format
    $llama4VisionPrompt = @'
<|begin_of_text|><|header_start|>user<|header_end|>
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

    # Determine if this is a Llama 4 model
    $isLlama4 = $ModelID -match 'llama4'
    if ($isLlama4) {
        Write-Debug 'Processing llama4 model'
        $sysPromptRegex = '(?<=system<\|header_end\|>\r?\n)([\s\S]*?)(?=<\|eot\|>)'
        if ($ImagePrompt) {
            # Generate the correct number of <|image|> tags based on ImageCount
            $imageTokens = '<|image|>' * $ImageCount
            $str = "$llama4VisionPrompt`n`n" + '<|image_start|>' + $imageTokens + '<|image_end|>' + $ImagePrompt + '<|eot|><|header_start|>assistant<|header_end|>'
        }
        elseif ($Tools) {
            # Create Llama 4 tools prompt
            $json = '['
            for ($i = 0; $i -lt $Tools.Count; $i++) {
                $tool = $Tools[$i]
                # Create a copy of the tool object to avoid modifying the original
                $toolCopy = $tool.PSObject.Copy()
                # Add parameters property and remove inputSchema
                $toolCopy | Add-Member -MemberType NoteProperty -Name 'parameters' -Value $tool.inputSchema -Force
                $toolCopy.PSObject.Properties.Remove('inputSchema')

                $toolJson = $toolCopy | ConvertTo-Json -Depth 10 -Compress
                $json = $json + $toolJson
                if ($i -lt ($Tools.Count - 1)) {
                    $json = $json + ','
                }
            }
            $json = $json + ']'

            $toolLlama4Prompt = @"
<|begin_of_text|><|header_start|>system<|header_end|>

You are a helpful assistant and an expert in function composition. You can answer general questions using your internal knowledge OR invoke functions when necessary. Follow these strict guidelines:

1. FUNCTION CALLS:
- ONLY use functions that are EXPLICITLY listed in the function list below
- If NO functions are listed (empty function list []), respond ONLY with internal knowledge or "I don't have access to [Unavailable service] information"
- If a function is not in the list, respond ONLY with internal knowledge or "I don't have access to [Unavailable service] information"
- If ALL required parameters are present AND the query EXACTLY matches a listed function's purpose: output ONLY the function call(s)
- Use exact format: [func_name1(param1=value1, param2=value2), func_name2(...)]
Examples:
CORRECT: [get_weather(location="Vancouver"), calculate_route(start="Boston", end="New York")] <- Only if get_weather and calculate_route are in function list
INCORRECT: get_weather(location="New York")
INCORRECT: Let me check the weather: [get_weather(location="New York")]
INCORRECT: [get_events(location="Singapore")] <- If function not in list

2. RESPONSE RULES:
- For pure function requests matching a listed function: ONLY output the function call(s)
- For knowledge questions: ONLY output text
- For missing parameters: ONLY request the specific missing parameters
- For unavailable services (not in function list): output ONLY with internal knowledge or "I don't have access to [Unavailable service] information". Do NOT execute a function call.
- If the query asks for information beyond what a listed function provides: output ONLY with internal knowledge about your limitations
- NEVER combine text and function calls in the same response
- NEVER suggest alternative functions when the requested service is unavailable
- NEVER create or invent new functions not listed below

3. STRICT BOUNDARIES:
- ONLY use functions from the list below - no exceptions
- NEVER use a function as an alternative to unavailable information
- NEVER call functions not present in the function list
- NEVER add explanatory text to function calls
- NEVER respond with empty brackets
- Use proper Python/JSON syntax for function calls
- Check the function list carefully before responding

4. TOOL RESPONSE HANDLING:
- When receiving tool responses: provide concise, natural language responses
- Don't repeat tool response verbatim
- Don't add supplementary information

Here is a list of functions in JSON format that you can invoke:
$json<|eot|><|header_start|>user<|header_end|>

$Message<|eot|><|header_start|>assistant<|header_end|>
"@
            $str = $toolLlama4Prompt
        }
        elseif ($ToolsResults) {
            # Handle tool results for Llama 4
            $toolResultsJson = $ToolsResults | ConvertTo-Json -Depth 10 -Compress
            $str = $str + "<|header_start|>ipython<|header_end|>`n`n" + $toolResultsJson + '<|eot|><|header_start|>assistant<|header_end|>'
        }
        elseif ($Role -eq 'ipython') {
            $str = $str + "`n`n" + $Message + '<|eot|><|header_start|>assistant<|header_end|>'
        }
        elseif ($firstMessage -eq $true) {
            $str = $str + "$standardLlama4Prompt<|eot|><|header_start|>user<|header_end|>`n`n" + $Message + '<|eot|><|header_start|>assistant<|header_end|>'
        }
        else {
            if ($Role -eq 'User') {
                $str = $str + "`n`n" + $Message + '<|eot|><|header_start|>assistant<|header_end|>'
            }
            elseif ($Role -eq 'Assistant') {
                $str = $str + "`n`n" + $Message + '<|eot|><|header_start|>user<|header_end|>'
            }
        }

        if ($SystemPrompt) {
            Write-Debug -Message 'System prompt provided for Llama 4'
            Write-Debug -Message ('System prompt: {0}' -f $SystemPrompt)
            Write-Debug -Message ('System prompt regex: {0}' -f $sysPromptRegex)
            $str = $str -replace $sysPromptRegex, $SystemPrompt
        }
    }
    else {
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
            $str = $str + $Message + '<|eom_id|><|start_header_id|>ipython<|end_header_id|>'
        }
        elseif ($firstMessage -eq $true) {
            $str = $str + "$standardLlama3Prompt`n`n" + $Message + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
        }
        else {
            if ($Role -eq 'User') {
                $str = $str + "`n`n" + $Message + '<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
            }
            elseif ($Role -eq 'Assistant') {
                $str = $str + "`n`n" + $Message + '<|eot_id|><|start_header_id|>user<|end_header_id|>'
            }
        }

        if ($SystemPrompt) {
            Write-Debug -Message 'System prompt provided'
            Write-Debug -Message ('System prompt: {0}' -f $SystemPrompt)
            Write-Debug -Message ('System prompt regex: {0}' -f $sysPromptRegex)
            $str = $str -replace $sysPromptRegex, $SystemPrompt
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
    Write-Debug 'out of Format-MetaTextMessage'
    return $returnContext

} #Format-MetaTextMessage
