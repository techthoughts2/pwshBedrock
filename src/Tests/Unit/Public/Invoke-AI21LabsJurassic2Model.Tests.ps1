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
    Describe 'Invoke-AI21LabsJurassic2Model Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": 1234,
    "prompt": {
        "text": "Hi there, how are you?",
        "tokens": [
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -9.328269958496094,
                    "raw_logprob": -9.328269958496094
                },
                "topTokens": null,
                "textRange": {
                    "start": 0,
                    "end": 8
                }
            },
            {
                "generatedToken": {
                    "token": ",",
                    "logprob": -1.4708256721496582,
                    "raw_logprob": -1.4708256721496582
                },
                "topTokens": null,
                "textRange": {
                    "start": 8,
                    "end": 9
                }
            },
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -8.434012413024902,
                    "raw_logprob": -8.434012413024902
                },
                "topTokens": null,
                "textRange": {
                    "start": 9,
                    "end": 21
                }
            },
            {
                "generatedToken": {
                    "token": "?",
                    "logprob": -1.1350029706954956,
                    "raw_logprob": -1.1350029706954956
                },
                "topTokens": null,
                "textRange": {
                    "start": 21,
                    "end": 22
                }
            }
        ]
    },
    "completions": [
        {
            "data": {
                "text": "\nHi there, I'm good and you?",
                "tokens": [
                    {
                        "generatedToken": {
                            "token": "newline",
                            "logprob": -0.010807787999510765,
                            "raw_logprob": -0.010807787999510765
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 0,
                            "end": 1
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.974107265472412,
                            "raw_logprob": -1.974107265472412
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 1,
                            "end": 9
                        }
                    },
                    {
                        "generatedToken": {
                            "token": ",",
                            "logprob": -0.17175257205963135,
                            "raw_logprob": -0.17175257205963135
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 9,
                            "end": 10
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.9623299837112427,
                            "raw_logprob": -1.9623299837112427
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 10,
                            "end": 14
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -0.08357568830251694,
                            "raw_logprob": -0.08357568830251694
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 14,
                            "end": 19
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -2.928839683532715,
                            "raw_logprob": -2.928839683532715
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 19,
                            "end": 27
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "?",
                            "logprob": -0.2477261871099472,
                            "raw_logprob": -0.2477261871099472
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 27,
                            "end": 28
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "endoftext",
                            "logprob": -0.04161105677485466,
                            "raw_logprob": -0.04161105677485466
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 28,
                            "end": 28
                        }
                    }
                ]
            },
            "finishReason": {
                "reason": "endoftext"
            }
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
    "id": 1234,
    "prompt": {
        "text": "Hi there, how are you?",
        "tokens": [
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -9.328269958496094,
                    "raw_logprob": -9.328269958496094
                },
                "topTokens": null,
                "textRange": {
                    "start": 0,
                    "end": 8
                }
            },
            {
                "generatedToken": {
                    "token": ",",
                    "logprob": -1.4708256721496582,
                    "raw_logprob": -1.4708256721496582
                },
                "topTokens": null,
                "textRange": {
                    "start": 8,
                    "end": 9
                }
            },
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -8.434012413024902,
                    "raw_logprob": -8.434012413024902
                },
                "topTokens": null,
                "textRange": {
                    "start": 9,
                    "end": 21
                }
            },
            {
                "generatedToken": {
                    "token": "?",
                    "logprob": -1.1350029706954956,
                    "raw_logprob": -1.1350029706954956
                },
                "topTokens": null,
                "textRange": {
                    "start": 21,
                    "end": 22
                }
            }
        ]
    },
    "completions": [
        {
            "data": {
                "text": "\nHi there, I'm good and you?",
                "tokens": [
                    {
                        "generatedToken": {
                            "token": "newline",
                            "logprob": -0.010807787999510765,
                            "raw_logprob": -0.010807787999510765
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 0,
                            "end": 1
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.974107265472412,
                            "raw_logprob": -1.974107265472412
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 1,
                            "end": 9
                        }
                    },
                    {
                        "generatedToken": {
                            "token": ",",
                            "logprob": -0.17175257205963135,
                            "raw_logprob": -0.17175257205963135
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 9,
                            "end": 10
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.9623299837112427,
                            "raw_logprob": -1.9623299837112427
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 10,
                            "end": 14
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -0.08357568830251694,
                            "raw_logprob": -0.08357568830251694
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 14,
                            "end": 19
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -2.928839683532715,
                            "raw_logprob": -2.928839683532715
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 19,
                            "end": 27
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "?",
                            "logprob": -0.2477261871099472,
                            "raw_logprob": -0.2477261871099472
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 27,
                            "end": 28
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "endoftext",
                            "logprob": -0.04161105677485466,
                            "raw_logprob": -0.04161105677485466
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 28,
                            "end": 28
                        }
                    }
                ]
            },
            "finishReason": {
                "reason": "endoftext"
            }
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message     = 'Assimilate this.'
                        ModelID     = 'NotSupported'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message     = 'It is possible to commit no mistakes and still lose. That is not weakness, that is life.'
                        ModelID     = 'ai21.j2-ultra-v1'
                        ProfileName = 'default'
                        Region      = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
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
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message   = 'The line must be drawn here! This far, no further!'
                        ModelID   = 'ai21.j2-jumbo-instruct'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'ai21.j2-jumbo-instruct'
                        Context = $customMessage
                    }
                )
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message   = "There is no greater enemy than one's own fears."
                        ModelID   = 'ai21.j2-jumbo-instruct'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message   = "When a man is convinced he will die tomorrow. He'll probably find a way to make that happen."
                        ModelID   = 'ai21.j2-jumbo-instruct'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'ai21.j2-jumbo-instruct'
                        Context = 'test'
                    }
                )
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAI21LabsJurassic2ModelSplat = @{
                        Message   = 'Make it so.'
                        ModelID   = 'ai21.j2-jumbo-instruct'
                        AccessKey = 'ak'
                        SecretKey = 'sk'
                        Region    = 'us-west-2'
                    }
                    Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardMessage = "User: Hello, how are you?`n"

                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "id": 1234,
    "prompt": {
        "text": "Hi there, how are you?",
        "tokens": [
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -9.328269958496094,
                    "raw_logprob": -9.328269958496094
                },
                "topTokens": null,
                "textRange": {
                    "start": 0,
                    "end": 8
                }
            },
            {
                "generatedToken": {
                    "token": ",",
                    "logprob": -1.4708256721496582,
                    "raw_logprob": -1.4708256721496582
                },
                "topTokens": null,
                "textRange": {
                    "start": 8,
                    "end": 9
                }
            },
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -8.434012413024902,
                    "raw_logprob": -8.434012413024902
                },
                "topTokens": null,
                "textRange": {
                    "start": 9,
                    "end": 21
                }
            },
            {
                "generatedToken": {
                    "token": "?",
                    "logprob": -1.1350029706954956,
                    "raw_logprob": -1.1350029706954956
                },
                "topTokens": null,
                "textRange": {
                    "start": 21,
                    "end": 22
                }
            }
        ]
    },
    "completions": [
        {
            "data": {
                "text": "\nHi there, I'm good and you?",
                "tokens": [
                    {
                        "generatedToken": {
                            "token": "newline",
                            "logprob": -0.010807787999510765,
                            "raw_logprob": -0.010807787999510765
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 0,
                            "end": 1
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.974107265472412,
                            "raw_logprob": -1.974107265472412
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 1,
                            "end": 9
                        }
                    },
                    {
                        "generatedToken": {
                            "token": ",",
                            "logprob": -0.17175257205963135,
                            "raw_logprob": -0.17175257205963135
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 9,
                            "end": 10
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.9623299837112427,
                            "raw_logprob": -1.9623299837112427
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 10,
                            "end": 14
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -0.08357568830251694,
                            "raw_logprob": -0.08357568830251694
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 14,
                            "end": 19
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -2.928839683532715,
                            "raw_logprob": -2.928839683532715
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 19,
                            "end": 27
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "?",
                            "logprob": -0.2477261871099472,
                            "raw_logprob": -0.2477261871099472
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 27,
                            "end": 28
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "endoftext",
                            "logprob": -0.04161105677485466,
                            "raw_logprob": -0.04161105677485466
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 28,
                            "end": 28
                        }
                    }
                ]
            },
            "finishReason": {
                "reason": "endoftext"
            }
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
    "id": 1234,
    "prompt": {
        "text": "Hi there, how are you?",
        "tokens": [
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -9.328269958496094,
                    "raw_logprob": -9.328269958496094
                },
                "topTokens": null,
                "textRange": {
                    "start": 0,
                    "end": 8
                }
            },
            {
                "generatedToken": {
                    "token": ",",
                    "logprob": -1.4708256721496582,
                    "raw_logprob": -1.4708256721496582
                },
                "topTokens": null,
                "textRange": {
                    "start": 8,
                    "end": 9
                }
            },
            {
                "generatedToken": {
                    "token": "xxxxxxxxxx",
                    "logprob": -8.434012413024902,
                    "raw_logprob": -8.434012413024902
                },
                "topTokens": null,
                "textRange": {
                    "start": 9,
                    "end": 21
                }
            },
            {
                "generatedToken": {
                    "token": "?",
                    "logprob": -1.1350029706954956,
                    "raw_logprob": -1.1350029706954956
                },
                "topTokens": null,
                "textRange": {
                    "start": 21,
                    "end": 22
                }
            }
        ]
    },
    "completions": [
        {
            "data": {
                "text": "Captain Picard.",
                "tokens": [
                    {
                        "generatedToken": {
                            "token": "newline",
                            "logprob": -0.010807787999510765,
                            "raw_logprob": -0.010807787999510765
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 0,
                            "end": 1
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.974107265472412,
                            "raw_logprob": -1.974107265472412
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 1,
                            "end": 9
                        }
                    },
                    {
                        "generatedToken": {
                            "token": ",",
                            "logprob": -0.17175257205963135,
                            "raw_logprob": -0.17175257205963135
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 9,
                            "end": 10
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -1.9623299837112427,
                            "raw_logprob": -1.9623299837112427
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 10,
                            "end": 14
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -0.08357568830251694,
                            "raw_logprob": -0.08357568830251694
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 14,
                            "end": 19
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "xxxxxxxxxx",
                            "logprob": -2.928839683532715,
                            "raw_logprob": -2.928839683532715
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 19,
                            "end": 27
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "?",
                            "logprob": -0.2477261871099472,
                            "raw_logprob": -0.2477261871099472
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 27,
                            "end": 28
                        }
                    },
                    {
                        "generatedToken": {
                            "token": "endoftext",
                            "logprob": -0.04161105677485466,
                            "raw_logprob": -0.04161105677485466
                        },
                        "topTokens": null,
                        "textRange": {
                            "start": 28,
                            "end": 28
                        }
                    }
                ]
            },
            "finishReason": {
                "reason": "endoftext"
            }
        }
    ]
}
'@
                } #endMock
                Mock Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return just a message if successful' {
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message   = "There's coffee in that nebula!"
                    ModelID   = 'ai21.j2-grande-instruct'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message          = 'With the first link, the chain is forged. The first speech censured, the first thought forbidden, the first freedom denied, chains us all irrevocably.'
                    ModelID          = 'ai21.j2-jumbo-instruct'
                    ReturnFullObject = $true
                    AccessKey        = 'ak'
                    SecretKey        = 'sk'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.id | Should -BeExactly 1234
                $result.prompt.text | Should -BeExactly 'Hi there, how are you?'
                $result.completions[0].data.text | Should -BeExactly "Captain Picard."
                $result.completions[0].finishReason.reason | Should -BeExactly "endoftext"
            } #it

            It 'should return a message when all parameters are provided' {
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message                             = 'Shaka, when the walls fell.'
                    ModelID                             = 'ai21.j2-jumbo-instruct'
                    Temperature                         = 0.5
                    TopP                                = 0.9
                    MaxTokens                           = 4096
                    StopSequences                       = @('clouds')
                    CountPenaltyScale                   = 0.5
                    CountPenaltyApplyToWhiteSpaces      = $true
                    CountPenaltyApplyToPunctuations     = $true
                    CountPenaltyApplyToNumbers          = $true
                    CountPenaltyApplyToStopWords        = $true
                    CountPenaltyApplyToEmojis           = $true
                    PresencePenaltyScale                = 0.5
                    PresencePenaltyApplyToWhiteSpaces   = $true
                    PresencePenaltyApplyToPunctuations  = $true
                    PresencePenaltyApplyToNumbers       = $true
                    PresencePenaltyApplyToStopWords     = $true
                    PresencePenaltyApplyToEmojis        = $true
                    FrequencyPenaltyScale               = 100
                    FrequencyPenaltyApplyToWhiteSpaces  = $true
                    FrequencyPenaltyApplyToPunctuations = $true
                    FrequencyPenaltyApplyToNumbers      = $true
                    FrequencyPenaltyApplyToStopWords    = $true
                    FrequencyPenaltyApplyToEmojis       = $true
                    AccessKey                           = 'ak'
                    SecretKey                           = 'sk'
                    Region                              = 'us-west-2'
                }
                $result = Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                $result | Should -BeOfType [System.String]
                $result | Should -BeExactly 'Captain Picard.'
            } #it

            It 'should run all expected subcommands' {
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message   = 'Bonjour, mon Capitaine!'
                    ModelID   = 'ai21.j2-jumbo-instruct'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                $result = Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'ai21.j2-jumbo-instruct'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message   = 'Good tea, nice house.'
                    ModelID   = 'ai21.j2-jumbo-instruct'
                    AccessKey = 'ak'
                    SecretKey = 'sk'
                    Region    = 'us-west-2'
                }
                Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'ai21.j2-jumbo-instruct'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAI21LabsJurassic2ModelSplat = @{
                    Message           = "My Dear Doctor, they're all true. 'Even the lies?' Especially the lies"
                    ModelID           = 'ai21.j2-jumbo-instruct'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AI21LabsJurassic2Model @invokeAI21LabsJurassic2ModelSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-AI21LabsJurassic2Model
} #inModule
