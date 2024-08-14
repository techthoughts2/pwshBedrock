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
    Describe 'Invoke-AI21LabsJambaModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $Global:pwshBedrockModelContext = @(
                [PSCustomObject]@{
                    ModelId = 'ai21.jamba-instruct-v1:0'
                    Context = ''
                }
            )
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'ai21.jamba-instruct-v1:0' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                Mock -CommandName Format-AI21LabsJambaModel -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": "cmpl-a125e6c102b046a28d0b936e20d339c4",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 105,
        "completion_tokens": 48,
        "total_tokens": 153
    },
    "meta": {
        "requestDurationMillis": 716
    }
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
    "id": "cmpl-a125e6c102b046a28d0b936e20d339c4",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 105,
        "completion_tokens": 48,
        "total_tokens": 153
    },
    "meta": {
        "requestDurationMillis": 716
    }
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if multiple parameter sets are provided' {
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message      = 'Make it so.'
                        ToolsResults = $toolsResults
                        ModelID      = 'ai21.jamba-instruct-v1:0'
                        ProfileName  = 'default'
                        Region       = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'ai21.jamba-instruct-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
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
                    $invokeAI21LabsJambaModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'ai21.jamba-instruct-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'ai21.jamba-instruct-v1:0'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        System    = $systemMessage
                        ModelID   = 'ai21.jamba-instruct-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'ai21.jamba-instruct-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'ai21.jamba-instruct-v1:0'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'ai21.jamba-instruct-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'ai21.jamba-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = 'Best StarFleet captain?'
                            }
                            [PSCustomObject]@{
                                role    = 'user'
                                content = 'Best StarFleet captain?'
                            }
                        )
                    }

                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message      = 'Make it so.'
                        SystemPrompt = 'Make it so.'
                        ModelID      = 'ai21.jamba-instruct-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw if ResponseNumber is more than 1 while Temperature is 0' {
                Mock -CommandName Test-MistralAIChatTool -MockWith { $false }
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message        = 'Make it so.'
                        ModelID        = 'ai21.jamba-instruct-v1:0'
                        ResponseNumber = 2
                        Temperature    = 0
                        AccessKey      = 'ak'
                        SecretKey      = 'sk'
                        Region         = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if no message text is returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "id": "cmpl-a125e6c102b046a28d0b936e20d339c4",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": ""
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 105,
        "completion_tokens": 48,
        "total_tokens": 153
    },
    "meta": {
        "requestDurationMillis": 716
    }
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeAI21LabsJambaModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'ai21.jamba-instruct-v1:0'
                        MaxTokens = 10
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'ai21.jamba-instruct-v1:0' }
                $context.Context = New-Object System.Collections.Generic.List[object]
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    })
                $standardMessage = 'What is the airspeed velocity of an unladen swallow?'
                $systemMessage = 'You are a Star Trek trivia master.'
                Mock -CommandName Format-AI21LabsJambaModel -MockWith {
                    [PSCustomObject]@{
                        role    = 'user'
                        content = 'Best StarFleet captain?'
                    }
                } #endMock

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": "cmpl-a125e6c102b046a28d0b936e20d339c4",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 105,
        "completion_tokens": 48,
        "total_tokens": 153
    },
    "meta": {
        "requestDurationMillis": 716
    }
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
    "id": "cmpl-a125e6c102b046a28d0b936e20d339c4",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Captain Picard."
            },
            "finish_reason": "stop"
        }
    ],
    "usage": {
        "prompt_tokens": 105,
        "completion_tokens": 48,
        "total_tokens": 153
    },
    "meta": {
        "requestDurationMillis": 716
    }
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'ai21.jamba-instruct-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'ai21.jamba-instruct-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.choices.index | Should -BeExactly 0
                $result.choices.message.role | Should -BeExactly 'assistant'
                $result.choices.message.content | Should -BeExactly 'Captain Picard.'
                $result.choices.finish_reason | Should -BeExactly 'stop'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message          = 'Shaka, when the walls fell.'
                    ModelID          = 'ai21.jamba-instruct-v1:0'
                    NoContextPersist = $true
                    MaxTokens        = 3000
                    Temperature      = 0.5
                    TopP             = 0.9
                    StopSequences    = @('end', 'stop', 'finish')
                    ResponseNumber   = 3
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeAI21LabsJambaModelSplat = @{
                    Message   = 'Make it so.'
                    ModelID   = 'ai21.jamba-instruct-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat
                Should -Invoke Format-AI21LabsJambaModel -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'ai21.jamba-instruct-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAI21LabsJambaModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'ai21.jamba-instruct-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'ai21.jamba-instruct-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAI21LabsJambaModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'ai21.jamba-instruct-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AI21LabsJambaModel @invokeAI21LabsJambaModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-AI21LabsJambaModel
} #inModule
