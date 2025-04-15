BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    # $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
}

InModuleScope 'pwshBedrock' {
    Describe 'Converse API Integration Tests' -Tag Integration {
        BeforeDiscovery {
            $converseModels = @(
                'ai21.jamba-instruct-v1:0',
                'ai21.jamba-1-5-mini-v1:0',
                'ai21.jamba-1-5-large-v1:0',
                # 'amazon.titan-image-generator-v1', # *note: not supported by Converse API
                # 'amazon.titan-image-generator-v2:0', # *note: not supported by Converse API
                'amazon.titan-text-express-v1',
                'amazon.titan-text-lite-v1',
                'amazon.titan-text-premier-v1:0',
                'amazon.nova-pro-v1:0',
                'amazon.nova-lite-v1:0',
                'amazon.nova-micro-v1:0',
                'amazon.titan-tg1-large',
                'anthropic.claude-v2:1',
                'anthropic.claude-3-haiku-20240307-v1:0',
                'anthropic.claude-3-5-haiku-20241022-v1:0',
                'anthropic.claude-3-opus-20240229-v1:0',
                'anthropic.claude-3-sonnet-20240229-v1:0',
                'anthropic.claude-3-5-sonnet-20241022-v2:0',
                'anthropic.claude-3-5-sonnet-20240620-v1:0',
                'anthropic.claude-3-7-sonnet-20250219-v1:0',
                # 'cohere.command-text-v14', # *note: not supported by Converse API
                # 'cohere.command-light-text-v14', # *note: not supported by Converse API
                'cohere.command-r-v1:0',
                'cohere.command-r-plus-v1:0',
                'deepseek.r1-v1:0',
                'meta.llama3-70b-instruct-v1:0',
                'meta.llama3-8b-instruct-v1:0',
                'meta.llama3-1-8b-instruct-v1:0',
                'meta.llama3-1-70b-instruct-v1:0',
                'meta.llama3-1-405b-instruct-v1:0',
                'meta.llama3-2-1b-instruct-v1:0',
                'meta.llama3-2-3b-instruct-v1:0',
                'meta.llama3-2-11b-instruct-v1:0',
                'meta.llama3-2-90b-instruct-v1:0',
                'meta.llama3-3-70b-instruct-v1:0',
                'mistral.mistral-7b-instruct-v0:2',
                'mistral.mistral-large-2402-v1:0',
                'mistral.mistral-large-2407-v1:0',
                'mistral.mistral-small-2402-v1:0',
                'mistral.mixtral-8x7b-instruct-v0:1'
                # 'stability.stable-diffusion-xl-v1' # *note: not supported by Converse API
                # 'stability.stable-image-ultra-v1:0', # *note: not supported by Converse API
                # 'stability.stable-image-core-v1:0' # *note: not supported by Converse API
                # 'stability.sd3-large-v1:0' # *note: not supported by Converse API
                # 'stability.sd3-5-large-v1:0' # *note: not supported by Converse API
            )
        }
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'

            Set-Location -Path $PSScriptRoot
            $assetPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'assets')
            $inpaintingMainFile = [System.IO.Path]::Combine($assetPath, 'jedicat_inpainting.png')
            $docFile = [System.IO.Path]::Combine($assetPath, 'ds9.docx')

            $inpaintingMainImage = [System.IO.Path]::GetFullPath($inpaintingMainFile)
            $docPath = [System.IO.Path]::GetFullPath($docFile)
        } #beforeAll

        Context 'Standard Message' {

            BeforeEach {
                $resetModelContextSplat = @{
                    AllModels = $true
                    Verbose   = $false
                }
                Reset-ModelContext @resetModelContextSplat
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return a message when provided a standard message' {
                $invokeConverseAPISplat = @{
                    Message    = 'Return the number 1 as a string'
                    ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    MaxTokens  = 10
                    Credential = $awsCredential
                    Region     = 'us-west-2'
                    Verbose    = $false
                }
                $eval = Invoke-ConverseAPI @invokeConverseAPISplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message' {
                $invokeConverseAPISplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    SystemPrompt     = 'You are a model of very few words.'
                    StopSequences    = @('Kirk')
                    MaxTokens        = 30
                    Temperature      = 0.5
                    TopP             = 0.9
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-ConverseAPI @invokeConverseAPISplat
                $eval | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $eval.StopReason | Should -Not -BeNullOrEmpty
                $eval.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $eval.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $eval.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $eval.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $eval.Output.Message.Role | Should -BeExactly 'assistant'
                $eval.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $eval.Output.Message.Content.Text | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.Output.Message.Content.Text
            } #it

            It 'should return an object when provided a message and tools' {
                $tools = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                        }
                    }
                    required    = @(
                        'location'
                    )
                }

                $invokeConverseAPISplat = @{
                    Message          = 'Can you recommend a good restaurant in New Braunfels, TX?'
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    SystemPrompt     = 'You are a savvy foodie who loves giving restaurant recommendations.'
                    MaxTokens        = 30
                    ReturnFullObject = $true
                    Tools            = $tools
                    ToolChoice       = 'tool'
                    ToolName         = 'restaurant'
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-ConverseAPI @invokeConverseAPISplat
                $eval | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $eval.StopReason | Should -Not -BeNullOrEmpty
                $eval.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $eval.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $eval.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $eval.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $eval.Output.Message.Role | Should -BeExactly 'assistant'
                $eval.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $eval.Output.Message.Content.ToolUse | Should -BeOfType [Amazon.BedrockRuntime.Model.ToolUseBlock]
            } #it

            It 'should return an object when provided a media path' {
                $invokeConverseAPISplat = @{
                    MediaPath        = $inpaintingMainImage
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    SystemPrompt     = 'You are a star wars trivia master.'
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-ConverseAPI @invokeConverseAPISplat
                $eval | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $eval.StopReason | Should -Not -BeNullOrEmpty
                $eval.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $eval.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $eval.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $eval.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $eval.Output.Message.Role | Should -BeExactly 'assistant'
                $eval.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $eval.Output.Message.Content.Text | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.Output.Message.Content.Text
            } #it

            It 'should return an object when provided a document path' {
                $invokeConverseAPISplat = @{
                    Message          = 'Provide a one sentence summary of the document.'
                    DocumentPath     = $docPath
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    SystemPrompt     = 'You are a star trek trivia master.'
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-ConverseAPI @invokeConverseAPISplat
                $eval | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseResponse]
                $eval.StopReason | Should -Not -BeNullOrEmpty
                $eval.Metrics | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseMetrics]
                $eval.Usage | Should -BeOfType [Amazon.BedrockRuntime.Model.TokenUsage]
                $eval.Output | Should -BeOfType [Amazon.BedrockRuntime.Model.ConverseOutput]
                $eval.Output.Message | Should -BeOfType [Amazon.BedrockRuntime.Model.Message]
                $eval.Output.Message.Role | Should -BeExactly 'assistant'
                $eval.Output.Message.Content | Should -BeOfType [Amazon.BedrockRuntime.Model.ContentBlock]
                $eval.Output.Message.Content.Text | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.Output.Message.Content.Text
            } #it

        } #context_standard_message

    } #describe
} #inModule
