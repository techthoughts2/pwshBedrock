#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Invoke-CohereCommandRModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-plus-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $standardChatHistory = @(
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'I am fine, thank you. How can I assist you today?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'I need help with my account.' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Sure, I can help with that. What seems to be the issue?' }
                )
                $standardTools = [PSCustomObject]@{
                    name                  = "string"
                    description           = "string"
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = "string"
                            type        = "string"
                            required    = $true
                        }
                    }
                }
                $standardToolsResults = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                Mock -CommandName Reset-ModelContext -MockWith { }
                Mock -CommandName Test-CohereCommandRTool -MockWith { $true }
                Mock -CommandName Test-CohereCommandRToolResult -MockWith { $true }
                Mock -CommandName Test-CohereCommandRChatHistory -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "response_id": "0c9d451a-3951-4f78-8d71-d398d40ee299",
    "text": "Captain Picard.",
    "generation_id": "fc5e1139-c93b-4131-ba34-bebed5a161d5",
    "chat_history": [
        {
            "role": "USER",
            "message": "Best Starfleet captain?"
        },
        {
            "role": "CHATBOT",
            "message": "Captain Picard."
        }
    ],
    "finish_reason": "COMPLETE"
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
    "response_id": "0c9d451a-3951-4f78-8d71-d398d40ee299",
    "text": "Captain Picard.",
    "generation_id": "fc5e1139-c93b-4131-ba34-bebed5a161d5",
    "chat_history": [
        {
            "role": "USER",
            "message": "Best Starfleet captain?"
        },
        {
            "role": "CHATBOT",
            "message": "Captain Picard."
        }
    ],
    "finish_reason": "COMPLETE"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'cohere.command-r-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
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
                    $invokeCohereCommandRModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-plus-v1:0'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-plus-v1:0'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a chat history is provided that does not pass validation' {
                Mock -CommandName Test-CohereCommandRChatHistory -MockWith { $false }
                $chatHistory = @(
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'I am fine, thank you. How can I assist you today?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'I need help with my account.' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Sure, I can help with that. What seems to be the issue?' }
                )
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message     = 'Make it so.'
                        ModelID     = 'cohere.command-r-plus-v1:0'
                        ChatHistory = $chatHistory
                        AccessKey   = 'ak'
                        SecretKey   = 'sk'
                        Region      = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if tools parameter is provided and does not pass validation' {
                Mock -CommandName Test-CohereCommandRTool -MockWith { $false }
                $standardTools = [PSCustomObject]@{
                    name                  = "string"
                    description           = "string"
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = "string"
                            type        = "string"
                            required    = $true
                        }
                    }
                }
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        Tools     = $standardTools
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw if toolResults parameter is provided and does not pass validation' {
                Mock -CommandName Test-CohereCommandRToolResult -MockWith { $false }
                $standardTools = [PSCustomObject]@{
                    name                  = "string"
                    description           = "string"
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = "string"
                            type        = "string"
                            required    = $true
                        }
                    }
                }
                $standardToolsResults = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                {
                    $invokeCohereCommandRModelSplat = @{
                        ModelID      = 'cohere.command-r-plus-v1:0'
                        Tools        = $standardTools
                        ToolsResults = $standardToolsResults
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'Should throw if toolsresults is provided but tools is not' {
                {
                    $invokeCohereCommandRModelSplat = @{
                        ModelID      = 'cohere.command-r-plus-v1:0'
                        ToolsResults = $standardToolsResults
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "response_id": "0c9d451a-3951-4f78-8d71-d398d40ee299",
    "text": "",
    "generation_id": "fc5e1139-c93b-4131-ba34-bebed5a161d5",
    "chat_history": [
        {
            "role": "USER",
            "message": "Best Starfleet captain?"
        },
        {
            "role": "CHATBOT",
            "message": "Captain Picard."
        }
    ],
    "finish_reason": "COMPLETE"
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeCohereCommandRModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'cohere.command-r-plus-v1:0'
                        MaxTokens = 10
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-plus-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $standardChatHistory = @(
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'I am fine, thank you. How can I assist you today?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'I need help with my account.' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Sure, I can help with that. What seems to be the issue?' }
                )
                $standardTools = [PSCustomObject]@{
                    name                  = "string"
                    description           = "string"
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = "string"
                            type        = "string"
                            required    = $true
                        }
                    }
                }
                $standardToolsResults = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                Mock -CommandName Reset-ModelContext -MockWith { }
                Mock -CommandName Test-CohereCommandRTool -MockWith { $true }
                Mock -CommandName Test-CohereCommandRToolResult -MockWith { $true }
                Mock -CommandName Test-CohereCommandRChatHistory -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "response_id": "0c9d451a-3951-4f78-8d71-d398d40ee299",
    "text": "Captain Picard.",
    "generation_id": "fc5e1139-c93b-4131-ba34-bebed5a161d5",
    "chat_history": [
        {
            "role": "USER",
            "message": "Best Starfleet captain?"
        },
        {
            "role": "CHATBOT",
            "message": "Captain Picard."
        }
    ],
    "finish_reason": "COMPLETE"
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
    "response_id": "0c9d451a-3951-4f78-8d71-d398d40ee299",
    "text": "Captain Picard.",
    "generation_id": "fc5e1139-c93b-4131-ba34-bebed5a161d5",
    "chat_history": [
        {
            "role": "USER",
            "message": "Best Starfleet captain?"
        },
        {
            "role": "CHATBOT",
            "message": "Captain Picard."
        }
    ],
    "finish_reason": "COMPLETE"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeCohereCommandRModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'cohere.command-r-plus-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeCohereCommandRModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'cohere.command-r-plus-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.response_id | Should -BeExactly '0c9d451a-3951-4f78-8d71-d398d40ee299'
                $result.text | Should -BeExactly 'Captain Picard.'
                $result.finish_reason | Should -BeExactly 'COMPLETE'
            } #it

            It 'should return a message when all parameters are provided' {
                $documents = [PSCustomObject]@{
                    title   = 'Making it so.'
                    snippet = 'The line must be drawn here! This far, no further!'
                }
                $invokeCohereCommandRModelSplat = @{
                    Message           = 'Shaka, when the walls fell.'
                    ModelID           = 'cohere.command-r-plus-v1:0'
                    NoContextPersist  = $true
                    Documents         = $documents
                    SearchQueriesOnly = $true
                    Preamble          = 'You are a StarTrek trivia master.'
                    MaxTokens         = 3000
                    Temperature       = 0.5
                    TopP              = 0.9
                    TopK              = 50
                    PromptTruncation  = 'OFF'
                    FrequencyPenalty  = 0.5
                    PresencePenalty   = 0.5
                    Seed              = 42
                    ReturnPrompt      = $true
                    Tools             = $standardTools
                    StopSequences     = @('Kirk')
                    RawPrompting      = $true
                    AccessKey         = 'ak'
                    SecretKey         = 'sk'
                    Region            = 'us-west-2'
                }
                $result = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeCohereCommandRModelSplat = @{
                    Message   = 'Bonjour, mon Capitaine!'
                    ModelID   = 'cohere.command-r-plus-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                Should -Invoke Test-CohereCommandRTool -Exactly 0 -Scope It
                Should -Invoke Test-CohereCommandRToolResult -Exactly 0 -Scope It
                Should -Invoke Test-CohereCommandRChatHistory -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when checked parameters are provided' {
                $invokeCohereCommandRModelSplat = @{
                    ChatHistory  = $standardChatHistory
                    Tools        = $standardTools
                    ToolsResults = $standardToolsResults
                    ModelID      = 'cohere.command-r-plus-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat
                Should -Invoke Test-CohereCommandRTool -Exactly 1 -Scope It
                Should -Invoke Test-CohereCommandRToolResult -Exactly 1 -Scope It
                Should -Invoke Test-CohereCommandRChatHistory -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                $result | Should -Not -BeNullOrEmpty
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'cohere.command-r-plus-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeCohereCommandRModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'cohere.command-r-plus-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'cohere.command-r-plus-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeCohereCommandRModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'cohere.command-r-plus-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-CohereCommandRModel @invokeCohereCommandRModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-CohereCommandRModel
} #inModule
