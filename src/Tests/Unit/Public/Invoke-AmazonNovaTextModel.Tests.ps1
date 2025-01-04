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
    Describe 'Invoke-AmazonNovaTextModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $mediaMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            image = [PSCustomObject]@{
                                format = 'jpeg'
                                source = [PSCustomObject]@{
                                    bytes = 'bast64encodedstring'
                                }
                            }
                        }
                    )
                }
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            text = 'Hello, how are you?'
                        }
                    )
                }
                $standardTool = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name        = 'top_song'
                        description = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'The call sign for the radio station for which you want the most popular song. Example calls signs are WZPZ and WKRP.'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $formattedStandardTool = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name        = 'top_song'
                        description = 'Get the most popular song played on a radio station.'
                        inputSchema = @'
{
    "type": "object",
    "properties": {
        "sign": {
            "type": "string",
            "description": "string"
        }
    },
    "required": [
        "sign"
    ]
}
'@
                    }
                }
                $standardToolResult = [PSCustomObject]@{
                    toolUseId = 'string'
                    content   = 'string'
                }
                Mock -CommandName Test-AmazonNovaMedia -MockWith { $true }
                Mock -CommandName Test-AmazonNovaCustomConversation -MockWith { $true }
                Mock -CommandName Format-AmazonNovaToolConfig -MockWith {
                    $formattedStandardTool
                } #endMock
                Mock -CommandName Format-AmazonNovaMessage -MockWith {
                    $standardMessage
                } #endMock
                Mock -CommandName Test-AmazonNovaTool -MockWith { $true }
                Mock -CommandName Test-AmazonNovaToolResult -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": "msg_bdrk_01Wx4nruDxEM31SY86JYzNLU",
    "type": "message",
    "role": "assistant",
    "model": "claude-3-sonnet-20240229",
    "stop_sequence": null,
    "usage": {
        "input_tokens": 14,
        "output_tokens": 47
    },
    "content": [
        {
            "type": "text",
            "text": "Hello! As an AI language model, I don't have subjective experiences like emotions, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?"
        }
    ],
    "stop_reason": "end_turn"
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
    "output": {
        "message": {
            "content": [
                {
                    "text": "Zero-point energy (ZPE) is the lowest possible energy that a quantum mechanical system may have."
                }
            ],
            "role": "assistant"
        }
    },
    "stopReason": "end_turn",
    "usage": {
        "inputTokens": 8,
        "outputTokens": 59,
        "totalTokens": 67
    }
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the user does not provide at least a message, mediapath, or custom conversation' {
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        SystemPrompt = 'You are an expert engineer solving a problem with a broken ship. What do you say?'
                        ModelID      = 'amazon.nova-micro-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a model is specified that does not support vision and media is provided' {
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message     = 'In the event of a water landing, I have been designed as a floatation device.'
                        ModelID     = 'amazon.nova-micro-v1:0'
                        MediaPath   = 'C:\images\image.jpeg'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if media is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonNovaMedia -MockWith { $false }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message     = 'I will always be puzzled by the human predilection for piloting vehicles at unsafe velocity.'
                        ModelID     = 'amazon.nova-lite-v1:0'
                        MediaPath   = 'C:\images\image.zip'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'amazon.nova-lite-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.nova-lite-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'amazon.nova-lite-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'Hello Nova, how are you?'
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'assistant'
                        content = @(
                            [PSCustomObject]@{
                                text = "I'm doing well, thanks for asking!"
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = "How is the weather in digital land?"
                            }
                        )
                    })
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
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'amazon.nova-lite-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.nova-micro-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'amazon.nova-micro-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'Hello Nova, how are you?'
                            }
                        )
                    })
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'amazon.nova-micro-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'amazon.nova-micro-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.nova-micro-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'amazon.nova-micro-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'Hello Nova, how are you?'
                            }
                        )
                    })
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'amazon.nova-micro-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw and remove the last context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'amazon.nova-micro-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'amazon.nova-micro-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = 'Hello Nova, how are you?'
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'assistant'
                        content = @(
                            [PSCustomObject]@{
                                text = "I'm doing well, thanks for asking!"
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                text = "How is the weather in digital land?"
                            }
                        )
                    })
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'amazon.nova-micro-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a custom conversation is provided that does not pass validation' {
                Mock -CommandName Test-AmazonNovaCustomConversation -MockWith { $false }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        ModelID            = 'amazon.nova-micro-v1:0'
                        CustomConversation = $mediaMessage
                        AccessKey          = 'ak'
                        SecretKey          = 'sk'
                        Region             = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if the model returns no text response' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "output": {
        "message": {
            "content": [
                {
                    "text": ""
                }
            ],
            "role": "assistant"
        }
    },
    "stopReason": "end_turn",
    "usage": {
        "inputTokens": 8,
        "outputTokens": 59,
        "totalTokens": 67
    }
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'amazon.nova-micro-v1:0'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if tools results do not pass validation' {
                Mock -CommandName Test-AmazonNovaToolResult -MockWith { $false }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        ToolsResults = $standardToolResult
                        Tools        = $standardTool
                        ModelID      = 'amazon.nova-micro-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if tools are provided that do not pass validation' {
                Mock -CommandName Test-AmazonNovaTool -MockWith { $false }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        Message   = 'Make it so.'
                        Tools     = $standardTool
                        ModelID   = 'amazon.nova-micro-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

            It 'should throw if toolsresults are provided but tools is not' {
                Mock -CommandName Test-AmazonNovaToolResult -MockWith { $true }
                {
                    $invokeAmazonNovaTextModelSplat = @{
                        ToolsResults = $standardToolResult
                        ModelID      = 'amazon.nova-micro-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $mediaMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            image = [PSCustomObject]@{
                                format = 'jpeg'
                                source = [PSCustomObject]@{
                                    bytes = 'bast64encodedstring'
                                }
                            }
                        }
                    )
                }
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            text = 'Hello, how are you?'
                        }
                    )
                }
                $standardTool = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name        = 'top_song'
                        description = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'The call sign for the radio station for which you want the most popular song. Example calls signs are WZPZ and WKRP.'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $formattedStandardTool = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name        = 'top_song'
                        description = 'Get the most popular song played on a radio station.'
                        inputSchema = @'
{
    "type": "object",
    "properties": {
        "sign": {
            "type": "string",
            "description": "string"
        }
    },
    "required": [
        "sign"
    ]
}
'@
                    }
                }
                $standardToolResult = [PSCustomObject]@{
                    toolUseId = 'string'
                    content   = 'string'
                }
                Mock -CommandName Test-AmazonNovaMedia -MockWith { $true }
                Mock -CommandName Test-AmazonNovaCustomConversation -MockWith { $true }
                Mock -CommandName Format-AmazonNovaToolConfig -MockWith {
                    $formattedStandardTool
                } #endMock
                Mock -CommandName Format-AmazonNovaMessage -MockWith {
                    $standardMessage
                } #endMock
                Mock -CommandName Test-AmazonNovaTool -MockWith { $true }
                Mock -CommandName Test-AmazonNovaToolResult -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": "msg_bdrk_01Wx4nruDxEM31SY86JYzNLU",
    "type": "message",
    "role": "assistant",
    "model": "claude-3-sonnet-20240229",
    "stop_sequence": null,
    "usage": {
        "input_tokens": 14,
        "output_tokens": 47
    },
    "content": [
        {
            "type": "text",
            "text": "Hello! As an AI language model, I don't have subjective experiences like emotions, but I'm operating properly and ready to assist you with any questions or tasks you may have. How can I help you today?"
        }
    ],
    "stop_reason": "end_turn"
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
    "output": {
        "message": {
            "content": [
                {
                    "text": "Zero-point energy (ZPE) is the lowest possible energy that a quantum mechanical system may have."
                }
            ],
            "role": "assistant"
        }
    },
    "stopReason": "end_turn",
    "usage": {
        "inputTokens": 8,
        "outputTokens": 59,
        "totalTokens": 67
    }
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeAmazonNovaTextModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'amazon.nova-micro-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Zero-point energy (ZPE) is the lowest possible energy that a quantum mechanical system may have.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAmazonNovaTextModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'amazon.nova-micro-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.output.message.content.text | Should -BeExactly 'Zero-point energy (ZPE) is the lowest possible energy that a quantum mechanical system may have.'
                $result.output.message.role | Should -BeExactly 'assistant'
                $result.stopReason | Should -BeExactly 'end_turn'
                $result.usage.inputTokens | Should -BeExactly 8
                $result.usage.outputTokens | Should -BeExactly 59
                $result.usage.totalTokens | Should -BeExactly 67
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeAmazonNovaTextModelSplat = @{
                    Message       = 'Shaka, when the walls fell.'
                    MediaPath     = 'C:\images\image.jpeg'
                    ModelID       = 'amazon.nova-pro-v1:0'
                    MaxTokens     = 100
                    SystemPrompt  = 'You are an expert engineer solving a problem with a broken ship. What do you say?'
                    Temperature   = 0.5
                    TopP          = 0.9
                    TopK          = 0.9
                    StopSequences = @('conversation_end')
                    AccessKey     = 'ak'
                    SecretKey     = 'sk'
                    Region        = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Zero-point energy (ZPE) is the lowest possible energy that a quantum mechanical system may have.'
            } #it

            It 'should run all expected subcommands' {
                $invokeAmazonNovaTextModelSplat = @{
                    Message   = 'Bonjour, mon Capitaine!'
                    MediaPath = 'C:\images\image.jpeg'
                    ModelID   = 'amazon.nova-pro-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                Should -Invoke Test-AmazonNovaMedia -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a custom conversation is provided' {
                $invokeAmazonNovaTextModelSplat = @{
                    CustomConversation = $mediaMessage
                    ModelID            = 'amazon.nova-micro-v1:0'
                    AccessKey          = 'ak'
                    SecretKey          = 'sk'
                    Region             = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                Should -Invoke Test-AmazonNovaMedia -Exactly 0 -Scope It
                Should -Invoke Test-AmazonNovaCustomConversation -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaMessage -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a tool is provided' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "output": {
        "message": {
            "content": [
                {
                    "text": "<thinking> To recommend the best restaurant in New Braunfels, TX, I need to use the provided tool to look up restaurant information in that geographic area. </thinking>\n"
                },
                {
                    "toolUse": {
                        "name": "restaurant",
                        "toolUseId": "39dde39f-5c15-426b-88c1-13a728dc2ace",
                        "input": {
                            "location": "New Braunfels, TX"
                        }
                    }
                }
            ],
            "role": "assistant"
        }
    },
    "stopReason": "tool_use",
    "usage": {
        "inputTokens": 415,
        "outputTokens": 85,
        "totalTokens": 500
    }
}
'@
                } #endMock
                $invokeAmazonNovaTextModelSplat = @{
                    Message   = 'Make it so.'
                    Tools     = $standardTool
                    ModelID   = 'amazon.nova-micro-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                Should -Invoke Test-AmazonNovaMedia -Exactly 0 -Scope It
                Should -Invoke Test-AmazonNovaTool -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaToolConfig -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a tool result is provided' {
                $invokeAmazonNovaTextModelSplat = @{
                    ToolsResults = $standardToolResult
                    Tools        = $standardTool
                    ModelID      = 'amazon.nova-micro-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat
                Should -Invoke Test-AmazonNovaMedia -Exactly 0 -Scope It
                Should -Invoke Test-AmazonNovaTool -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaToolConfig -Exactly 1 -Scope It
                Should -Invoke Test-AmazonNovaToolResult -Exactly 1 -Scope It
                Should -Invoke Format-AmazonNovaMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'amazon.nova-pro-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonNovaTextModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    MediaPath = 'C:\images\image.jpeg'
                    ModelID   = 'amazon.nova-pro-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'amazon.nova-pro-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonNovaTextModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    MediaPath         = 'C:\images\image.jpeg'
                    ModelID           = 'amazon.nova-pro-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-AmazonNovaMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-AmazonNovaMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeAmazonNovaTextModelSplat = @{
                    Message          = 'Fascinating.'
                    ModelID          = 'amazon.nova-micro-v1:0'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-AmazonNovaTextModel @invokeAmazonNovaTextModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-AmazonNovaTextModel
} #inModule
