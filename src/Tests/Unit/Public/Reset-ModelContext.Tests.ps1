BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    $allModelInfo = Get-ModelInfo -AllModels
    $allModelIDs = ($allModelInfo | Where-Object {
            $_.ModelId -ne 'amazon.titan-image-generator-v1' -and
            $_.ModelId -ne 'amazon.titan-image-generator-v2:0' -and
            $_.ModelId -ne 'amazon.nova-canvas-v1:0' -and
            $_.ModelId -ne 'amazon.nova-reel-v1:0' -and
            $_.ModelId -ne 'cohere.command-text-v14' -and
            $_.ModelId -ne 'cohere.command-light-text-v14'
        }).ModelID
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Reset-ModelContext Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'ShouldProcess' {

            BeforeEach {
                Mock -CommandName Reset-ModelContext -MockWith { } #endMock
            } #end_beforeEach

            It 'Should process by default' {
                Reset-ModelContext -ModelID 'anthropic.claude-v2:1'

                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Reset-ModelContext -ModelID 'anthropic.claude-v2:1' -Confirm }
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Low'
                    Reset-ModelContext -ModelID 'anthropic.claude-v2:1'
                }
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Reset-ModelContext -ModelID 'anthropic.claude-v2:1' -WhatIf }
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Reset-ModelContext -ModelID 'anthropic.claude-v2:1'
                }
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Reset-ModelContext -ModelID 'anthropic.claude-v2:1' -Force
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 1
            } #it

            It 'Should process on force with All' {
                $ConfirmPreference = 'Medium'
                Reset-ModelContext -AllModels -Force
                Should -Invoke Reset-ModelContext -Scope It -Exactly -Times 1
            } #it

        } #context_shouldprocess

        Context 'Error' {

            It 'should throw if multiple parameters are provided' {
                { Reset-ModelContext -ModelID 'anthropic.claude-v2:1' -AllModels } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelID = 'Converse'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Claude v2.1 context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-v2:1'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Claude v2.1 context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-haiku-20240307-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Haiku context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-5-haiku-20241022-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = '5 Haiku context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Sonnet context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-5-sonnet-20241022-v2:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = '5 Sonnet context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = '5 Sonnet context'
                                    }
                                )
                            }
                        )
                    },
                    [PSCustomObject]@{
                        ModelID = 'anthropic.claude-3-opus-20240229-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Opus context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.titan-text-express-v1'
                        Context = @'
User: "Hi there!
'@
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.titan-text-lite-v1'
                        Context = @'
User: "Hi there!
'@
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.titan-tg1-large'
                        Context = @'
User: "Hi there!
'@
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.titan-text-premier-v1:0'
                        Context = @'
User: "Hi there!
'@
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.nova-pro-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Opus context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.nova-lite-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Opus context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'amazon.nova-micro-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Opus context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'ai21.jamba-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'test'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'ai21.jamba-1-5-mini-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'test'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'ai21.jamba-1-5-large-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'test'
                                    }
                                )
                            }
                        )
                    }
                    # [PSCustomObject]@{
                    #     ModelID = 'amazon.titan-image-generator-v1'
                    #     Context = @(
                    #         [PSCustomObject]@{
                    #             role    = 'user'
                    #             content = @(
                    #                 [PSCustomObject]@{
                    #                     type = 'text'
                    #                     text = 'Titan image generator context'
                    #                 }
                    #             )
                    #         }
                    #     )
                    # }
                    # [PSCustomObject]@{
                    #     ModelID = 'cohere.command-text-v14'
                    #     Context = @(
                    #         [PSCustomObject]@{
                    #             role    = 'user'
                    #             content = @(
                    #                 [PSCustomObject]@{
                    #                     type = 'text'
                    #                     text = 'Command text v14 context'
                    #                 }
                    #             )
                    #         }
                    #     )
                    # }
                    # [PSCustomObject]@{
                    #     ModelID = 'cohere.command-light-text-v14'
                    #     Context = @(
                    #         [PSCustomObject]@{
                    #             role    = 'user'
                    #             content = @(
                    #                 [PSCustomObject]@{
                    #                     type = 'text'
                    #                     text = 'Command light text v14 context'
                    #                 }
                    #             )
                    #         }
                    #     )
                    # }
                    [PSCustomObject]@{
                        ModelID = 'cohere.command-r-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Command r v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'cohere.command-r-plus-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Command r plus v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-8b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 8b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-70b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 70b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-1-8b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 1 8b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-1-70b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 1 70b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-1-405b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 1 405b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-2-1b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 2 1b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-2-3b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 2 3b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-2-11b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 2 11b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-2-90b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 2 90b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'meta.llama3-3-70b-instruct-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Llama3 2 90b instruct v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'mistral.mistral-7b-instruct-v0:2'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Mistral 7b instruct v0 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Mixtral 8x7b instruct v0 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'mistral.mistral-large-2402-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Mistral large 2402 v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'mistral.mistral-large-2407-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Mistral large 2407 v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'mistral.mistral-small-2402-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Mistral small 2402 v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'stability.stable-diffusion-xl-v1'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Stable diffusion xl v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'stability.stable-image-ultra-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Stable image ultra v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'stability.stable-image-core-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'Stable image core v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'stability.sd3-large-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'SD3 large v1 context'
                                    }
                                )
                            }
                        )
                    }
                    [PSCustomObject]@{
                        ModelID = 'stability.sd3-5-large-v1:0'
                        Context = @(
                            [PSCustomObject]@{
                                role    = 'user'
                                content = @(
                                    [PSCustomObject]@{
                                        type = 'text'
                                        text = 'SD3 large v1 context'
                                    }
                                )
                            }
                        )
                    }
                )
            } #beforeEach

            It 'should reset the message context for <_>' -ForEach $allModelIDs {
                Reset-ModelContext -ModelID $_
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $_ }
                $context.Context | Should -BeNullOrEmpty
            } #it

            It 'should reset the tally for all models' {
                Reset-ModelContext -AllModels
                foreach ($value in $Global:pwshBedrockModelContext.Context) {
                    $value | Should -BeNullOrEmpty
                }
            } #it

        } #context_Success
    } #describe_Reset-ModelContext
} #inModule
