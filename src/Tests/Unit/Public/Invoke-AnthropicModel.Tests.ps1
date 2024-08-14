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
    Describe 'Invoke-AnthropicModel Public Function Tests' -Tag Unit {
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
                            type   = 'image'
                            source = @(
                                [PSCustomObject]@{
                                    type         = 'base64'
                                    'media_type' = 'image/jpeg'
                                    data         = 'bast64encodedstring'
                                }
                            )
                        },
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Check out this image!'
                        }

                    )
                }
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Hello, how are you?'
                        }
                    )
                }
                $standardTool = [PSCustomObject]@{
                    name         = 'top_song'
                    description  = 'Get the most popular song played on a radio station.'
                    input_schema = [PSCustomObject]@{
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
                $standardToolResult = [PSCustomObject]@{
                    tool_use_id = 'string'
                    content     = 'string'
                }
                $tooManyMediaPaths = @(
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png',
                    'C:\images\image.jpeg',
                    'C:\images\image.png',
                    'C:\images\image.png'
                )
                Mock -CommandName Test-AnthropicMedia -MockWith { $true }
                Mock -CommandName Test-AnthropicCustomConversation -MockWith { $true }
                Mock -CommandName Format-AnthropicMessage -MockWith {
                    $standardMessage
                }
                Mock -CommandName Test-AnthropicTool -MockWith { $true }
                Mock -CommandName Test-AnthropicToolResult -MockWith { $true }
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
            "text": "Hello! I am an AI language model."
        }
    ],
    "stop_reason": "end_turn"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAnthropicModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the user does not provide at least a message, mediapath, or custom conversation' {
                {
                    $invokeAnthropicModelSplat = @{
                        SystemPrompt = 'You are an expert engineer solving a problem with a broken ship. What do you say?'
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a model is specified that does not support vision and media is provided' {
                {
                    $invokeAnthropicModelSplat = @{
                        Message     = 'In the event of a water landing, I have been designed as a floatation device.'
                        ModelID     = 'anthropic.claude-v2:1'
                        MediaPath   = 'C:\images\image.jpeg'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if too many media paths are provided' {
                {
                    $invokeAnthropicModelSplat = @{
                        Message     = 'I will always be puzzled by the human predilection for piloting vehicles at unsafe velocity.'
                        ModelID     = 'anthropic.claude-3-haiku-20240307-v1:0'
                        MediaPath   = $tooManyMediaPaths
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if media is provided that is not supported by the model' {
                Mock -CommandName Test-AnthropicMedia -MockWith { $false }
                {
                    $invokeAnthropicModelSplat = @{
                        Message     = 'I will always be puzzled by the human predilection for piloting vehicles at unsafe velocity.'
                        ModelID     = 'anthropic.claude-3-haiku-20240307-v1:0'
                        MediaPath   = 'C:\images\image.zip'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAnthropicModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'anthropic.claude-3-haiku-20240307-v1:0'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-haiku-20240307-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'anthropic.claude-3-haiku-20240307-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = 'Hello Claude, how are you?'
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'assistant'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = "I'm doing well, thanks for asking!"
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
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
                    $invokeAnthropicModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'anthropic.claude-3-haiku-20240307-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'anthropic.claude-3-sonnet-20240229-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = 'Hello Claude, how are you?'
                            }
                        )
                    })
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'anthropic.claude-3-sonnet-20240229-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = 'Hello Claude, how are you?'
                            }
                        )
                    })
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw and remove the last context if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Context = New-Object System.Collections.Generic.List[object]
                    }
                )
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelId -eq 'anthropic.claude-3-sonnet-20240229-v1:0' }
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = 'Hello Claude, how are you?'
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'assistant'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = "I'm doing well, thanks for asking!"
                            }
                        )
                    })
                $context.Context.Add([PSCustomObject]@{
                        role    = 'user'
                        content = @(
                            [PSCustomObject]@{
                                type = 'text'
                                text = "How is the weather in digital land?"
                            }
                        )
                    })
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a custom conversation is provided that does not pass validation' {
                Mock -CommandName Test-AnthropicCustomConversation -MockWith { $false }
                {
                    $invokeAnthropicModelSplat = @{
                        ModelID            = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        CustomConversation = $mediaMessage
                        AccessKey          = 'ak'
                        SecretKey          = 'sk'
                        Region             = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw and warn the user if the model returns no text response' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
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
            "text": ""
        }
    ],
    "stop_reason": "end_turn"
}
'@
                } #endMock
                Mock -CommandName Write-Warning {}
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        MaxTokens = 100
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if ToolChoice is set to Tools but no Tool name is provided' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAnthropicModelSplat = @{
                        Message    = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        Tools      = $standardTool
                        ToolChoice = 'tool'
                        ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey  = 'ak'
                        SecretKey  = 'sk'
                        Region     = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if anthropic.claude-v2:1 is specified with tools' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        Tools     = $standardTool
                        ModelID   = 'anthropic.claude-v2:1'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if tools results do not pass validation' {
                Mock -CommandName Test-AnthropicToolResult -MockWith { $false }
                {
                    $invokeAnthropicModelSplat = @{
                        ToolsResults = $standardToolResult
                        Tools        = $standardTool
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if tools are provided that do not pass validation' {
                Mock -CommandName Test-AnthropicTool -MockWith { $false }
                {
                    $invokeAnthropicModelSplat = @{
                        Message   = 'Make it so.'
                        Tools     = $standardTool
                        ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it

            It 'should throw if toolsresults are provided but tools is not' {
                Mock -CommandName Test-AnthropicToolResult -MockWith { $true }
                {
                    $invokeAnthropicModelSplat = @{
                        ToolsResults = $standardToolResult
                        ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        AccessKey    = 'ak'
                        SecretKey    = 'sk'
                        Region       = 'us-west-2'
                    }
                    Invoke-AnthropicModel @invokeAnthropicModelSplat
                } | Should -Throw
            } #it


        } #context_Error

        Context 'Success' {

            BeforeEach {
                $mediaMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type   = 'image'
                            source = @(
                                [PSCustomObject]@{
                                    type         = 'base64'
                                    'media_type' = 'image/jpeg'
                                    data         = 'bast64encodedstring'
                                }
                            )
                        },
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Check out this image!'
                        }

                    )
                }
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Hello, how are you?'
                        }
                    )
                }
                $standardTool = [PSCustomObject]@{
                    name         = 'top_song'
                    description  = 'Get the most popular song played on a radio station.'
                    input_schema = [PSCustomObject]@{
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
                $standardToolResult = [PSCustomObject]@{
                    tool_use_id = 'string'
                    content     = 'string'
                }
                Mock -CommandName Test-AnthropicMedia -MockWith { $true }
                Mock -CommandName Test-AnthropicCustomConversation -MockWith { $true }
                Mock -CommandName Format-AnthropicMessage -MockWith {
                    $standardMessage
                }
                Mock -CommandName Test-AnthropicTool -MockWith { $true }
                Mock -CommandName Test-AnthropicToolResult -MockWith { $true }
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
            "text": "Hello! I am an AI language model."
        }
    ],
    "stop_reason": "end_turn"
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeAnthropicModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'anthropic.claude-3-opus-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Hello! I am an AI language model.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAnthropicModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.Content.Text | Should -BeExactly 'Hello! I am an AI language model.'
                $result.id | Should -BeExactly 'msg_bdrk_01Wx4nruDxEM31SY86JYzNLU'
                $result.type | Should -BeExactly 'message'
                $result.role | Should -BeExactly 'assistant'
                $result.model | Should -BeExactly 'claude-3-sonnet-20240229'
                $result.stop_sequence | Should -BeNullOrEmpty
                $result.usage.input_tokens | Should -BeExactly 14
                $result.usage.output_tokens | Should -BeExactly 47
                $result.stop_reason | Should -BeExactly 'end_turn'
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeAnthropicModelSplat = @{
                    Message       = 'Shaka, when the walls fell.'
                    MediaPath     = 'C:\images\image.jpeg'
                    ModelID       = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    SystemPrompt  = 'You are an expert engineer solving a problem with a broken ship. What do you say?'
                    StopSequences = @('conversation_end')
                    Temperature   = 0.5
                    TopP          = 0.9
                    TopK          = 3
                    AccessKey     = 'ak'
                    SecretKey     = 'sk'
                    Region        = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Hello! I am an AI language model.'
            } #it

            It 'should run all expected subcommands' {
                $invokeAnthropicModelSplat = @{
                    Message   = 'Bonjour, mon Capitaine!'
                    MediaPath = 'C:\images\image.jpeg'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                Should -Invoke Test-AnthropicMedia -Exactly 1 -Scope It
                Should -Invoke Format-AnthropicMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a custom conversation is provided' {
                $invokeAnthropicModelSplat = @{
                    CustomConversation = $mediaMessage
                    ModelID            = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey          = 'ak'
                    SecretKey          = 'sk'
                    Region             = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                Should -Invoke Test-AnthropicMedia -Exactly 0 -Scope It
                Should -Invoke Test-AnthropicCustomConversation -Exactly 1 -Scope It
                Should -Invoke Format-AnthropicMessage -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a tool is provided' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
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
            "type": "tool_use",
            "id": "toolu_bdrk_01SnXQc6YVWD8Dom5jz7KhHy",
            "name": "top_song",
            "input": {
                "sign": "WZPZ"
            }
        }
    ],
    "stop_reason": "tool_use"
}
'@
                } #endMock
                $invokeAnthropicModelSplat = @{
                    Message    = 'Make it so.'
                    Tools      = $standardTool
                    ToolChoice = 'tool'
                    ToolName   = 'top_song'
                    ModelID    = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey  = 'ak'
                    SecretKey  = 'sk'
                    Region     = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                Should -Invoke Test-AnthropicMedia -Exactly 0 -Scope It
                Should -Invoke Test-AnthropicTool -Exactly 1 -Scope It
                Should -Invoke Format-AnthropicMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands when a tool result is provided' {
                $invokeAnthropicModelSplat = @{
                    ToolsResults = $standardToolResult
                    Tools        = $standardTool
                    ModelID      = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey    = 'ak'
                    SecretKey    = 'sk'
                    Region       = 'us-west-2'
                }
                $result = Invoke-AnthropicModel @invokeAnthropicModelSplat
                Should -Invoke Test-AnthropicMedia -Exactly 0 -Scope It
                Should -Invoke Test-AnthropicTool -Exactly 1 -Scope It
                Should -Invoke Test-AnthropicToolResult -Exactly 1 -Scope It
                Should -Invoke Format-AnthropicMessage -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'anthropic.claude-3-sonnet-20240229-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAnthropicModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    MediaPath = 'C:\images\image.jpeg'
                    ModelID   = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-AnthropicModel @invokeAnthropicModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'anthropic.claude-3-sonnet-20240229-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAnthropicModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    MediaPath         = 'C:\images\image.jpeg'
                    ModelID           = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AnthropicModel @invokeAnthropicModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call Format-AnthropicMessage with the expected parameters when NoContextPersist is specified' {
                Mock -CommandName Format-AnthropicMessage {
                    $NoContextPersist | Should -BeExactly $true
                } -Verifiable
                $invokeAnthropicModelSplat = @{
                    Message          = 'Fascinating.'
                    ModelID          = 'anthropic.claude-3-sonnet-20240229-v1:0'
                    NoContextPersist = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                Invoke-AnthropicModel @invokeAnthropicModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-AnthropicModel
} #inModule
