BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Invoke-MetaModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = 'test'
                    }
                )
                $standardMessage = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]
'@
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
                Mock -CommandName Test-MetaTool -MockWith {
                    $true
                } #endMock
                Mock -CommandName Test-MetaToolResult -MockWith {
                    $true
                } #endMock
                Mock -CommandName Format-MetaTextMessage -MockWith {
                    $standardMessage
                } #endMock
                Mock -CommandName Test-MetaMedia -MockWith {
                    $true
                } #endMock
                Mock -CommandName Convert-MediaToBase64 -MockWith {
                    'base64'
                } #endMock
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
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
                $jsonPayload = @'
{
    "generation": "\n\nCaptain Picard.",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generation": "\n\nCaptain Picard.",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeMetaModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            # It 'should throw if a 3.2 model is provided in an unsupported region' {
            #     {
            #         $invokeMetaModelSplat = @{
            #             Message     = 'Resistance is futile.'
            #             ModelID     = 'meta.llama3-2-90b-instruct-v1:0'
            #             ProfileName = 'default'
            #             Region      = 'ap-northeast-1'
            #         }
            #         Invoke-MetaModel @invokeMetaModelSplat
            #     } | Should -Throw
            # } #it

            It 'should throw if a tool is provided for a model below 3.1' {
                {
                    $invokeMetaModelSplat = @{
                        Message     = 'Lookup current trek trivia information using the Star Trek trivia tool.'
                        ModelID     = 'meta.llama2-13b-chat-v1'
                        Tools       = $standardTools
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a tools result is provided for a model below 3.1' {
                {
                    $invokeMetaModelSplat = @{
                        ToolsResults = $toolResults
                        ModelID      = 'meta.llama2-13b-chat-v1'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a tool is provided that does not pass tool validation' {
                Mock -CommandName Test-MetaTool -MockWith { $false }
                {
                    $invokeMetaModelSplat = @{
                        Message     = 'Lookup current trek trivia information using the Star Trek trivia tool.'
                        ModelID     = 'meta.llama3-1-70b-instruct-v1:0'
                        Tools       = $standardTools
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a tool result is provided that does not pass tool result validation' {
                Mock -CommandName Test-MetaToolResult -MockWith { $false }
                {
                    $invokeMetaModelSplat = @{
                        ToolsResults = $toolResults
                        ModelID      = 'meta.llama3-1-70b-instruct-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if more than one image is provided' {
                {
                    $invokeMetaModelSplat = @{
                        ImagePrompt = 'Describe this image in two sentences.'
                        MediaPath   = @('image1', 'image2')
                        ModelID     = 'meta.llama3-8b-instruct-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an image is provided for a model that does not support images' {
                {
                    $invokeMetaModelSplat = @{
                        ImagePrompt = 'Describe this image in two sentences.'
                        MediaPath   = 'image'
                        ModelID     = 'meta.llama2-13b-chat-v1'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the media file evaluation does not return true' {
                Mock -CommandName Test-MetaMedia -MockWith { $false }
                {
                    $invokeMetaModelSplat = @{
                        ImagePrompt = 'Describe this image in two sentences.'
                        MediaPath   = 'image'
                        ModelID     = 'meta.llama3-2-90b-instruct-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the media file can not be converted to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeMetaModelSplat = @{
                        ImagePrompt = 'Describe this image in two sentences.'
                        MediaPath   = 'image'
                        ModelID     = 'meta.llama3-2-90b-instruct-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMetaModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'meta.llama2-13b-chat-v1'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    [System.Exception]$exception = 'You don''t have access to the model with the specified model ID.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeMetaModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMetaModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeMetaModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeMetaModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should remove last message context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = $standardMessage
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeMetaModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generation": "",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeMetaModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'meta.llama2-13b-chat-v1'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MetaModel @invokeMetaModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = 'test'
                    }
                )
                $standardVisionMessage = @'
<|begin_of_text|><|start_header_id|>user<|end_header_id|>

<|image|>Describe this image in two sentences<|eot_id|><|start_header_id|>assistant<|end_header_id|>
'@
                $standardMessage = @'
<s>[INST] <<SYS>>
You are a Star Trek trivia expert.
<</SYS>>

Who is the best captain in Star Trek?[/INST]
'@
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
                Mock -CommandName Test-MetaTool -MockWith {
                    $true
                } #endMock
                Mock -CommandName Test-MetaToolResult -MockWith {
                    $true
                } #endMock
                Mock -CommandName Format-MetaTextMessage -MockWith {
                    $standardMessage
                } #endMock
                Mock -CommandName Format-MetaTextMessage -MockWith {
                    $standardMessage
                }
                Mock -CommandName Test-MetaMedia -MockWith {
                    $true
                } #endMock
                Mock -CommandName Convert-MediaToBase64 -MockWith {
                    'base64'
                } #endMock
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
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
                $jsonPayload = @'
{
    "generation": "\n\nCaptain Picard.",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generation": "\n\nCaptain Picard.",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeMetaModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'meta.llama3-8b-instruct-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "`n`nCaptain Picard."
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeMetaModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'meta.llama2-13b-chat-v1'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.prompt_token_count | Should -BeExactly '16'
                $result.generation_token_count | Should -BeExactly '68'
                $result.generation | Should -BeExactly "`n`nCaptain Picard."
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeMetaModelSplat = @{
                    Message          = 'Shaka, when the walls fell.'
                    ModelID          = 'meta.llama2-13b-chat-v1'
                    NoContextPersist = $true
                    SystemPrompt     = 'You are a Star Trek trivia expert.'
                    MaxTokens        = 100
                    Temperature      = 0.5
                    TopP             = 0.9
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly "`n`nCaptain Picard."
            } #it

            It 'should run all expected subcommands' {
                $invokeMetaModelSplat = @{
                    Message          = 'Bonjour, mon Capitaine!'
                    ModelID          = 'meta.llama2-13b-chat-v1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                Should -Invoke Format-MetaTextMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands for a tools message' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "generation": "<function=spotify_trending_songs>{\"test\": 5}</function>",
    "prompt_token_count": 16,
    "generation_token_count": 68,
    "stop_reason": "stop"
}
'@
                } #endMock
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-1-70b-instruct-v1:0'
                        Context = 'test'
                    }
                )
                $invokeMetaModelSplat = @{
                    Message          = 'Lookup current trek trivia information using the Star Trek trivia tool.'
                    ModelID          = 'meta.llama3-1-70b-instruct-v1:0'
                    Tools            = $standardTools
                    NoContextPersist = $false
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                Should -Invoke Format-MetaTextMessage -Exactly 2 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 0 -Scope It
                Should -Invoke Test-MetaMedia -Exactly 0 -Scope It
                Should -Invoke Test-MetaTool -Exactly 1 -Scope It
                Should -Invoke Test-MetaToolResult -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands for a tools results message' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-1-70b-instruct-v1:0'
                        Context = 'test'
                    }
                )
                $invokeMetaModelSplat = @{
                    ToolsResults     = $toolResults
                    ModelID          = 'meta.llama3-1-70b-instruct-v1:0'
                    NoContextPersist = $false
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                Should -Invoke Format-MetaTextMessage -Exactly 2 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 0 -Scope It
                Should -Invoke Test-MetaMedia -Exactly 0 -Scope It
                Should -Invoke Test-MetaTool -Exactly 0 -Scope It
                Should -Invoke Test-MetaToolResult -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'meta.llama2-13b-chat-v1'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeMetaModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'meta.llama2-13b-chat-v1'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-MetaModel @invokeMetaModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'meta.llama2-13b-chat-v1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeMetaModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'meta.llama2-13b-chat-v1'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-MetaModel @invokeMetaModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 3.2 models' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'us.meta.llama3-2-90b-instruct-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeMetaModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'meta.llama3-2-90b-instruct-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-MetaModel @invokeMetaModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-MetaTextMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-MetaTextMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeMetaModelSplat = @{
                    Message          = 'Fascinating.'
                    ModelID          = 'meta.llama2-13b-chat-v1'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-MetaModel @invokeMetaModelSplat | Should -InvokeVerifiable
            } #it

            It 'should run all expected subcommands for a vision message' {
                $invokeMetaModelSplat = @{
                    ImagePrompt = 'Describe this image in two sentences.'
                    MediaPath   = 'image'
                    ModelID     = 'meta.llama3-2-90b-instruct-v1:0'
                    AccessKey   = 'ak'
                    SecretKey   = 'sk'
                    Region      = 'eu-west-1'
                }
                $result = Invoke-MetaModel @invokeMetaModelSplat
                Should -Invoke Test-MetaMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Format-MetaTextMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

        } #context_Success

    } #describe_Invoke-MetaModel
} #inModule
