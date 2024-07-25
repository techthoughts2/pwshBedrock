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
    Describe 'Get-ModelContext Public Function Tests' -Tag Unit {

        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $Global:pwshBedrockModelContext = @(
                    [PSCustomObject]@{
                        ModelId = 'Converse'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    # [PSCustomObject]@{
                    #     ModelId = 'ai21.j2-grande-instruct'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    # [PSCustomObject]@{
                    #     ModelId = 'ai21.j2-jumbo-instruct'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    [PSCustomObject]@{
                        ModelId = 'ai21.jamba-instruct-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    # [PSCustomObject]@{
                    #     ModelId = 'ai21.j2-mid-v1'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    # [PSCustomObject]@{
                    #     ModelId = 'ai21.j2-ultra-v1'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    # [PSCustomObject]@{
                    #     ModelId = 'amazon.titan-image-generator-v1'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-express-v1'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-lite-v1'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-text-premier-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'amazon.titan-tg1-large'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-v2:1'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-haiku-20240307-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-opus-20240229-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-sonnet-20240229-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    # [PSCustomObject]@{
                    #     ModelId = 'cohere.command-text-v14'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    # [PSCustomObject]@{
                    #     ModelId = 'cohere.command-light-text-v14'
                    #     Context = [PSCustomObject]@{
                    #     role    = 'user'
                    #     content = 'test'
                    # }
                    # }
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'cohere.command-r-plus-v1:0'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-13b-chat-v1'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama2-70b-chat-v1'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-70b-instruct-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-8b-instruct-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-1-8b-instruct-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'meta.llama3-1-70b-instruct-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'mistral.mistral-7b-instruct-v0:2'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'mistral.mistral-large-2402-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'mistral.mistral-small-2402-v1:0'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'mistral.mixtral-8x7b-instruct-v0:1'
                        Context = 'test'
                    }
                    [PSCustomObject]@{
                        ModelId = 'stability.stable-diffusion-xl-v1'
                        Context = [PSCustomObject]@{
                            role    = 'user'
                            content = 'test'
                        }
                    }
                )
            }

            It 'returns context for model <_>' -ForEach $Global:pwshBedrockModelContext.ModelId {
                $eval = Get-ModelContext -ModelID $_
                $eval | Should -Not -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Get-ModelContext
} #inModule