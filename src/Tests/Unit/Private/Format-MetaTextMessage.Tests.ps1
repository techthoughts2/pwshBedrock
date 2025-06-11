BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    $metaModels = (Get-ModelInfo -Provider Meta).ModelID
    $llama2Models = $metaModels | Where-Object { $_ -like '*llama2*' }
    $llama3Models = $metaModels | Where-Object { $_ -like '*llama3*' }
    $llama4Models = $metaModels | Where-Object { $_ -like '*llama4*' }
    Describe 'Format-MetaTextMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-MetaTextMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-MetaTextMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'meta.llama3-2-90b-instruct-v1:0' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
                $userPrompt = 'Who is the best captain in Star Trek?'
                $systemPrompt = 'You are a Star Trek trivia expert.'
                $expectedValue1 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]
'@
                $expectedValue2 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]Captain Picard</s>
'@
                $expectedValue3 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $expectedValue4 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>

Captain Picard<|eot_id|><|start_header_id|>user<|end_header_id|>
'@
                $expectedValue5 = @'
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are a Star Trek trivia expert.<|eot_id|>

Who is the best captain in Star Trek?<|eot_id|><|start_header_id|>assistant<|end_header_id|>

Captain Picard<|eot_id|><|start_header_id|>user<|end_header_id|>

Because of his fondness for Earl Grey?<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $expectedValue6 = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]Captain Picard</s>
<s>[INST]Because of his fondness for Earl Grey?[/INST]
'@

                $expectedValue7 = @'
<|begin_of_text|><|start_header_id|>user<|end_header_id|>

<|image|>Describe this image in two sentences<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $date = Get-Date -Format "dd MMMM yyyy"
                $expectedValue8 = @"
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

Environment: ipython
Tools: brave_search, wolfram_alpha
Cutting Knowledge Date: December 2023
Today Date: $date

# Tool Instructions
- Always execute python code in messages that you share.
- When looking for real time information use relevant functions if available else fallback to brave_search

You have access to the following functions:
{
  "name": "string",
  "description": "string",
  "parameters": {
    "parameter_name": {
      "param_type": "string",
      "description": "string",
      "required": true
    }
  }
}

If a you choose to call a function ONLY reply in the following format:
<{start_tag}={function_name}>{parameters}{end_tag}
where

start_tag => <function
parameters => a JSON dict with the function argument name as key and function argument value as value.
end_tag => </function>

Here is an example,
<function=example_function_name>{"example_name": "example_value"}</function>

Reminder:
- Function calls MUST follow the specified format
- Required parameters MUST be specified
- Only call one function at a time
- Put the entire function call reply on one line
- Always add your sources when using search results to answer the user query

You are a helpful assistant.<|eot_id|><|start_header_id|>user<|end_header_id|>

Use the tool to find the info<|eot_id|><|start_header_id|>assistant<|end_header_id|>
"@
                $expectedValue9 = @'
<function=spotify_trending_songs>{"n": 5}</function><|eom_id|><|start_header_id|>ipython<|end_header_id|>
'@
                $expectedValue10 = @'
{"output":[{"name":"John","age":30},{"name":"Jane","age":25}]}<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                # Expected values for Llama 4 formatting
                $expectedValueLlama4_1 = @'
<|begin_of_text|><|header_start|>system<|header_end|>
You are a Star Trek trivia expert.<|eot|><|header_start|>user<|header_end|>

Who is the best captain in Star Trek?<|eot|><|header_start|>assistant<|header_end|>
'@
                $expectedValueLlama4_2 = @'
<|begin_of_text|><|header_start|>system<|header_end|>
You are a Star Trek trivia expert.<|eot|><|header_start|>user<|header_end|>

Who is the best captain in Star Trek?<|eot|><|header_start|>assistant<|header_end|>

Captain Picard<|eot|><|header_start|>user<|header_end|>
'@
                $expectedValueLlama4_3 = @'
<|begin_of_text|><|header_start|>system<|header_end|>
You are a Star Trek trivia expert.<|eot|><|header_start|>user<|header_end|>

Who is the best captain in Star Trek?<|eot|><|header_start|>assistant<|header_end|>

Captain Picard<|eot|><|header_start|>user<|header_end|>

Because of his fondness for Earl Grey?<|eot|><|header_start|>assistant<|header_end|>
'@
                # Expected values for Llama 4 tools functionality
                $expectedValueLlama4_Tools = @'
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
[{"name":"get_weather","description":"Get weather info for places","parameters":{"type":"dict","required":["city"],"properties":{"city":{"type":"string","description":"The name of the city to get the weather for"}}}}]<|eot|><|header_start|>user<|header_end|>

What is the weather in SF?<|eot|><|header_start|>assistant<|header_end|>
'@
                $expectedValueLlama4_ToolsResults = @'
<|begin_of_text|><|header_start|>system<|header_end|>
You are a Star Trek trivia expert.<|eot|><|header_start|>user<|header_end|>

Who is the best captain in Star Trek?<|eot|><|header_start|>assistant<|header_end|><|header_start|>ipython<|header_end|>

{"output":[{"name":"John","age":30}]}<|eot|><|header_start|>assistant<|header_end|>
'@
                # Expected values for Llama 4 vision functionality
                $expectedValueLlama4_SingleImage = @'
<|begin_of_text|><|header_start|>user<|header_end|>

<|image_start|><|image|><|image_end|>Describe this image in two sentences<|eot|><|header_start|>assistant<|header_end|>
'@
                $expectedValueLlama4_MultiImage = @'
<|begin_of_text|><|header_start|>user<|header_end|>

<|image_start|><|image|><|image|><|image_end|>What do these two images have in common?<|eot|><|header_start|>assistant<|header_end|>
'@
                $expectedValueLlama4_ThreeImages = @'
<|begin_of_text|><|header_start|>user<|header_end|>

<|image_start|><|image|><|image|><|image|><|image_end|>Compare these three images<|eot|><|header_start|>assistant<|header_end|>
'@
                $normalizedExpectedValue1 = $expectedValue1 -replace "`r`n", "`n"
                $normalizedExpectedValue2 = $expectedValue2 -replace "`r`n", "`n"
                $normalizedExpectedValue3 = $expectedValue3 -replace "`r`n", "`n"
                $normalizedExpectedValue4 = $expectedValue4 -replace "`r`n", "`n"
                $normalizedExpectedValue5 = $expectedValue5 -replace "`r`n", "`n"
                $normalizedExpectedValue6 = $expectedValue6 -replace "`r`n", "`n"
                $normalizedExpectedValue7 = $expectedValue7 -replace "`r`n", "`n"
                $normalizedExpectedValue8 = $expectedValue8 -replace "`r`n", "`n"
                $normalizedExpectedValue9 = $expectedValue9 -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_1 = $expectedValueLlama4_1 -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_2 = $expectedValueLlama4_2 -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_3 = $expectedValueLlama4_3 -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_Tools = $expectedValueLlama4_Tools -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_ToolsResults = $expectedValueLlama4_ToolsResults -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_SingleImage = $expectedValueLlama4_SingleImage -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_MultiImage = $expectedValueLlama4_MultiImage -replace "`r`n", "`n"
                $normalizedExpectedValueLlama4_ThreeImages = $expectedValueLlama4_ThreeImages -replace "`r`n", "`n"
            } #beforeEach

            It 'should return a properly formatted initial message for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue1
            } #it

            It 'should properly add a model response to the context for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue2
            } #it

            It 'should handle a multi-message conversation for Llama 2 model: <_>' -ForEach $llama2Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Because of his fondness for Earl Grey?'
                    SystemPrompt = $systemPrompt
                    Role         = 'User'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue6
            } #it

            It 'should return a properly formatted initial message for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue3
            } #it

            It 'should properly add a model response to the context for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue4
            } #it

            It 'should handle a multi-message conversation for Llama 3 model: <_>' -ForEach $llama3Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Because of his fondness for Earl Grey?'
                    SystemPrompt = $systemPrompt
                    Role         = 'User'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue5
            } #it

            It 'should handle a tool prompt for Llama 3.1+ model' -Skip:($PSVersionTable.PSVersion.Major -lt 6) {
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
                $formatMetaMessageSplat = @{
                    Role    = 'ipython'
                    Message = 'Use the tool to find the info'
                    ModelID = 'meta.llama3-1-70b-instruct-v1:0'
                    Tools   = $standardTools
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue8
            } #it

            It 'should handle a tool prompt for Llama 3.1+ model with a function call' {
                $formatMetaMessageSplat = @{
                    Role    = 'ipython'
                    Message = '<function=spotify_trending_songs>{"n": 5}</function>'
                    ModelID = 'meta.llama3-1-70b-instruct-v1:0'
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue9
            } #it

            It 'should handle a tool prompt for Llama 3.1+ model with a JSON response' {
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
                $result | Should -BeOfType 'System.String'
                $result | Should -Be $expectedValue10
                # $normalizedResult = $result -replace "`r`n", "`n"
                # $normalizedResult | Should -Be $normalizedExpectedValue10
            } #it

            It 'should handle an image prompt for Llama 3 model' {
                $formatMetaMessageSplat = @{
                    ImagePrompt = 'Describe this image in two sentences'
                    ImageCount  = 1
                    Role        = 'User'
                    ModelID     = 'meta.llama3-2-11b-instruct-v1:0'
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue7
            } #it

            # Llama 4 Tests
            It 'should return a properly formatted initial message for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_1
            } #it

            It 'should properly add a model response to the context for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_2
            } #it

            It 'should handle a multi-message conversation for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Captain Picard'
                    SystemPrompt = $systemPrompt
                    Role         = 'Assistant'
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaTextMessageSplat | Out-Null
                $formatMetaTextMessageSplat = @{
                    Message      = 'Because of his fondness for Earl Grey?'
                    SystemPrompt = $systemPrompt
                    Role         = 'User'
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaTextMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_3
            } #it

            It 'should handle tools for Llama 4 model: <_>' -ForEach $llama4Models {
                $standardToolsLlama4 = @(
                    [PSCustomObject]@{
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
                )
                $formatMetaMessageSplat = @{
                    Role    = 'User'
                    Message = 'What is the weather in SF?'
                    ModelID = $_
                    Tools   = $standardToolsLlama4
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_Tools
            } #it

            It 'should handle tool results for Llama 4 model: <_>' -ForEach $llama4Models {
                # First, set up some context
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    Message      = $userPrompt
                    SystemPrompt = $systemPrompt
                    ModelID      = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat | Out-Null

                # Now test tool results
                $toolResults = [PSCustomObject]@{
                    output = @(
                        [PSCustomObject]@{
                            name = "John"
                            age  = 30
                        }
                    )
                }
                $formatMetaMessageSplat = @{
                    Role         = 'User'
                    ToolsResults = $toolResults
                    ModelID      = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_ToolsResults
            } #it

            It 'should handle single image prompt for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    ImagePrompt = 'Describe this image in two sentences'
                    ImageCount  = 1
                    Role        = 'User'
                    ModelID     = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_SingleImage
            } #it

            It 'should handle multi-image prompt for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    ImagePrompt = 'What do these two images have in common?'
                    ImageCount  = 2
                    Role        = 'User'
                    ModelID     = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_MultiImage
            } #it

            It 'should handle three-image prompt for Llama 4 model: <_>' -ForEach $llama4Models {
                $formatMetaMessageSplat = @{
                    ImagePrompt = 'Compare these three images'
                    ImageCount  = 3
                    Role        = 'User'
                    ModelID     = $_
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValueLlama4_ThreeImages
            } #it

            It 'should populate context for the <_> model' -ForEach $metaModels {
                $formatMetaMessageSplat = @{
                    Role    = 'User'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.\n'
                    ModelID = $_
                }
                Format-MetaTextMessage @formatMetaMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -Not -BeNullOrEmpty
            } #it

            It 'should not populate context if NoContextPersist is set to true' -ForEach $metaModels {
                $formatMetaMessageSplat = @{
                    Role             = 'User'
                    Message          = 'I am not a'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $context = Get-ModelContext -ModelID $_
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-MetaTextMessage
} #inModule
