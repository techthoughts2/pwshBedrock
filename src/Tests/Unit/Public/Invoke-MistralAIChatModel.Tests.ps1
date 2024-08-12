BeforeAll {
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
    Describe 'Invoke-MistralAIChatModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $Global:pwshBedrockModelContext = @(
                [PSCustomObject]@{
                    ModelId = 'mistral.mistral-large-2402-v1:0'
                    Context = ''
                }
            )
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'mistral.mistral-large-2402-v1:0' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                $toolsResults = [PSCustomObject]@{
                    role         = 'tool'
                    tool_call_id = 'adN1ifNCSJy4bpwrpJt5tw'
                    content      = '{"character": "Lt. Commander Data", "answer": "Data weighed 100 kilograms."}'
                }
                $standardTools = [PSCustomObject]@{
                    type     = 'function'

                    function = @{
                        name        = 'star_trek_trivia_lookup'
                        description = 'This tool will look up the answers to a Star Trek trivia question.'
                        parameters  = @{
                            type       = 'object'
                            properties = @{
                                character = @{
                                    type        = 'string'
                                    description = 'The Star Trek character to look up.'
                                }
                                series    = @{
                                    type        = 'string'
                                    description = 'The Star Trek series to look up.'
                                }
                                question  = @{
                                    type        = 'string'
                                    description = 'The Star Trek trivia question to look up.'
                                }
                            }
                            required   = @('character', 'series', 'question')
                        }
                    }
                }
                Mock -CommandName Format-MistralAIChatModel -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock
                Mock -CommandName Get-ModelContext -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock
                Mock -CommandName Test-MistralAIChatTool -MockWith { $true }
                Mock -CommandName Test-MistralAIChatToolResult -MockWith { $true }

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "stop_reason": "stop"
        }
    ]
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
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if multiple parameter sets are provided' {
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message      = 'Make it so.'
                        ToolsResults = $toolsResults
                        ModelID      = 'mistral.mistral-large-2402-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'mistral.mistral-large-2402-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
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
                    $invokeMistralAIChatModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mistral-large-2402-v1:0'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        System    = $systemMessage
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'mistral.mistral-large-2402-v1:0'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if tools parameter is provided and does not pass validation' {
                Mock -CommandName Test-MistralAIChatTool -MockWith { $false }
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        Tools     = $standardTools
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw if toolResults parameter is provided and does not pass validation' {
                Mock -CommandName Test-MistralAIChatToolResult -MockWith { $false }
                {
                    $invokeMistralAIChatModelSplat = @{
                        ModelID      = 'mistral.mistral-large-2402-v1:0'
                        Tools        = $standardTools
                        ToolsResults = $toolsResults
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": ""
            },
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeMistralAIChatModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'mistral.mistral-large-2402-v1:0'
                        MaxTokens = 10
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw and warn the user if no tool_calls data is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "",
                "tool_calls": []
            },
            "stop_reason": "tool_calls"
        }
    ]
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeMistralAIChatModelSplat = @{
                        Tools        = $standardTools
                        ToolsResults = $toolsResults
                        ModelID      = 'mistral.mistral-large-2402-v1:0'
                        MaxTokens    = 10
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 1
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'mistral.mistral-large-2402-v1:0' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                $toolsResults = [PSCustomObject]@{
                    role         = 'tool'
                    tool_call_id = 'adN1ifNCSJy4bpwrpJt5tw'
                    content      = '{"character": "Lt. Commander Data", "answer": "Data weighed 100 kilograms."}'
                }
                $standardTools = [PSCustomObject]@{
                    type     = 'function'

                    function = @{
                        name        = 'star_trek_trivia_lookup'
                        description = 'This tool will look up the answers to a Star Trek trivia question.'
                        parameters  = @{
                            type       = 'object'
                            properties = @{
                                character = @{
                                    type        = 'string'
                                    description = 'The Star Trek character to look up.'
                                }
                                series    = @{
                                    type        = 'string'
                                    description = 'The Star Trek series to look up.'
                                }
                                question  = @{
                                    type        = 'string'
                                    description = 'The Star Trek trivia question to look up.'
                                }
                            }
                            required   = @('character', 'series', 'question')
                        }
                    }
                }
                Mock -CommandName Format-MistralAIChatModel -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock
                Mock -CommandName Get-ModelContext -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock
                Mock -CommandName Test-MistralAIChatTool -MockWith { $true }
                Mock -CommandName Test-MistralAIChatToolResult -MockWith { $true }

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "stop_reason": "stop"
        }
    ]
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
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "stop_reason": "stop"
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeMistralAIChatModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'mistral.mistral-large-2402-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'mistral.mistral-large-2402-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.choices.index | Should -BeExactly 0
                $result.choices.message.role | Should -BeExactly 'assistant'
                $result.choices.message.content | Should -BeExactly 'Captain Picard.'
                $result.choices.stop_reason | Should -BeExactly 'stop'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'Shaka, when the walls fell.'
                    ModelID          = 'mistral.mistral-large-2402-v1:0'
                    NoContextPersist = $true
                    Tools            = $standardTools
                    ToolChoice       = 'auto'
                    MaxTokens        = 3000
                    Temperature      = 0.5
                    TopP             = 0.9
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeMistralAIChatModelSplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'mistral.mistral-large-2402-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                Should -Invoke Test-MistralAIChatTool -Exactly 0 -Scope It
                Should -Invoke Test-MistralAIChatToolResult -Exactly 0 -Scope It
                Should -Invoke Format-MistralAIChatModel -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when checked parameters are provided' {
                $invokeMistralAIChatModelSplat = @{
                    Tools        = $standardTools
                    ToolsResults = $toolsResults
                    ModelID      = 'mistral.mistral-large-2402-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                Should -Invoke Test-MistralAIChatTool -Exactly 1 -Scope It
                Should -Invoke Test-MistralAIChatToolResult -Exactly 1 -Scope It
                Should -Invoke Format-MistralAIChatModel -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                $result | Should -Not -BeNullOrEmpty
            } #it

            It 'should run all expected subcommands when tool_calls are returned' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "",
                "tool_calls": {
                    name: "star_trek_trivia_lookup",
                    arguments: "{'character': 'Lt. Commander Data', 'series': 'Star Trek: The Next Generation'}"
                }
            },
            "stop_reason": "tool_calls"
        }
    ]
}
'@
                } #endMock
                $invokeMistralAIChatModelSplat = @{
                    Message          = 'How much does Lt. Commander Data weigh?'
                    Tools            = $standardTools
                    ReturnFullObject = $true
                    ModelID          = 'mistral.mistral-large-2402-v1:0'
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat
                Should -Invoke Test-MistralAIChatTool -Exactly 1 -Scope It
                Should -Invoke Test-MistralAIChatToolResult -Exactly 0 -Scope It
                Should -Invoke Format-MistralAIChatModel -Exactly 2 -Scope It
                Should -Invoke Get-ModelContext -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                $result | Should -Not -BeNullOrEmpty
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'mistral.mistral-large-2402-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeMistralAIChatModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'mistral.mistral-large-2402-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'mistral.mistral-large-2402-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeMistralAIChatModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'mistral.mistral-large-2402-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-MistralAIChatModel @invokeMistralAIChatModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-MistralAIChatModel
} #inModule
