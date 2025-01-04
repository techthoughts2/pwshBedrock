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
                $normalizedExpectedValue1 = $expectedValue1 -replace "`r`n", "`n"
                $normalizedExpectedValue2 = $expectedValue2 -replace "`r`n", "`n"
                $normalizedExpectedValue3 = $expectedValue3 -replace "`r`n", "`n"
                $normalizedExpectedValue4 = $expectedValue4 -replace "`r`n", "`n"
                $normalizedExpectedValue5 = $expectedValue5 -replace "`r`n", "`n"
                $normalizedExpectedValue6 = $expectedValue6 -replace "`r`n", "`n"
                $normalizedExpectedValue7 = $expectedValue7 -replace "`r`n", "`n"
                $normalizedExpectedValue8 = $expectedValue8 -replace "`r`n", "`n"
                $normalizedExpectedValue9 = $expectedValue9 -replace "`r`n", "`n"
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
                    Role         = 'Model'
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
                    Role         = 'Model'
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
                    Role         = 'Model'
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
                    Role         = 'Model'
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
                    Role        = 'User'
                    ModelID     = 'meta.llama3-2-11b-instruct-v1:0'
                }
                $result = Format-MetaTextMessage @formatMetaMessageSplat
                $result | Should -BeOfType 'System.String'
                $normalizedResult = $result -replace "`r`n", "`n"
                $normalizedResult | Should -Be $normalizedExpectedValue7
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
