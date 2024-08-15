BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    Describe 'Add-ModelCostEstimate Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $converseUsage = [Amazon.BedrockRuntime.Model.TokenUsage]::new()
                $converseUsage.InputTokens = 1000
                $converseUsage.OutputTokens = 1000
                $converseUsage.TotalTokens = 2000
                $anthropicUsage = [PSCustomObject]@{
                    input_tokens  = 1000
                    output_tokens = 1000
                }
                $amazonUsage = [PSCustomObject]@{
                    inputTextTokenCount = 1000
                    results             = [PSCustomObject]@{
                        tokenCount = 1000
                    }
                }
                $ai21LabsJambaUsage = [PSCustomObject]@{
                    prompt_tokens     = 1000
                    completion_tokens = 1000
                }
                $ai21LabsUsage = [PSCustomObject]@{
                    id          = 1234
                    prompt      = @{
                        text   = 'Hi there, how are you?'
                        tokens = @(
                            @{
                                textRange = @{
                                    end = 500
                                }
                            },
                            @{
                                textRange = @{
                                    end = 1000
                                }
                            }
                        )
                    }
                    completions = @(
                        @{
                            data = @{
                                tokens = @(
                                    @{
                                        textRange = @{
                                            end = 500
                                        }
                                    },
                                    @{
                                        textRange = @{
                                            end = 1000
                                        }
                                    }
                                )
                            }
                        }
                    )
                }
                $cohereCommandUsage = [PSCustomObject]@{
                    generations = @{
                        finish_reason = 'COMPLETE'
                        id            = 'c28eadc4-966d-4157-a9b5-58ab921d0f92'
                        text          = 'Captain Picard.'
                    }
                    id          = '1658248f-eb86-4723-9c23-be47bdcbbcb3'
                    prompt      = 'Star Trek: The Next Generation'
                }
                $cohereCommandRUsage = [PSCustomObject]@{
                    response_id   = '1658248f-eb86-4723-9c23-be47bdcbbcb3'
                    text          = 'Captain Picard.'
                    generation_id = 'c28eadc4-966d-4157-a9b5-58ab921d0f92'
                    chat_history  = @(
                        @{
                            role = 'USER'
                            text = 'Who is the best Star Trek captain?'
                        },
                        @{
                            agent = 'CHATBOT'
                            text  = 'Captain Picard.'
                        }
                    )
                    finish_reason = 'COMPLETE'
                }
                $metaUsage = [PSCustomObject]@{
                    prompt_token_count     = 1000
                    generation_token_count = 1000
                }
                $mistralAIUsage = [PSCustomObject]@{
                    outputs = @{
                        text        = 'Captain Picard.'
                        stop_reason = 'stop'
                    }
                }
                $mistraAIChatToolsCallUsage = [PSCustomObject]@{
                    choices = @{
                        index       = 0
                        message     = @{
                            role       = 'assistant'
                            content    = ''
                            tool_calls = @{
                                function = @{
                                    name      = 'star_trek_trivia_lookup'
                                    arguments = '{"character": "Lt. Commander Data", "series": "Star Trek: The Next Generation"}'
                                }
                            }
                        }
                        stop_reason = 'tool_calls'
                    }
                }
                $mistraAIChatUsage = [PSCustomObject]@{
                    choices = @{
                        index       = 0
                        message     = @{
                            role    = 'assistant'
                            content = 'Captain Picard.'
                        }
                        stop_reason = 'complete'
                    }
                }
                Mock -CommandName Get-ModelCostEstimate -MockWith {
                    [PSCustomObject]@{
                        Total      = 1
                        InputCost  = 1
                        OutputCost = 1
                    }
                } #endMock
                Mock -CommandName Get-TokenCountEstimate -MockWith {
                    1000
                } #endMock
            } #beforeEach

            It 'should update the tally for a Converse API called model' {
                Add-ModelCostEstimate -Usage $converseUsage -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0' -Converse
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq 'anthropic.claude-3-sonnet-20240229-v1:0' }
                $eval = Get-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_> model' -ForEach $script:anthropicModelInfo.ModelId {
                $modelName = $_
                Add-ModelCostEstimate -Usage $anthropicUsage -ModelID $modelName
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelName }
                $eval = Get-ModelTally -ModelID $modelName
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:amazonModelInfo | Where-Object { $_.Vision -eq $false }) {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $amazonUsage -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:amazonModelInfo | Where-Object { $_.Vision -eq $true }) {
                $modelId = $_.ModelId
                Mock -CommandName Get-ModelCostEstimate -MockWith {
                    [PSCustomObject]@{
                        ImageCount = 1
                        ImageCost  = 1
                    }
                } #endMock
                Add-ModelCostEstimate -ImageCount 2 -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.ImageCount | Should -BeGreaterThan 0
                $eval.ImageCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:ai21ModelInfo | Where-Object { $_.ModelId -ne 'ai21.jamba-instruct-v1:0' }) {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $ai21LabsUsage -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for ai21.jamba-instruct-v1:0 model' {
                $modelId = 'ai21.jamba-instruct-v1:0'
                Add-ModelCostEstimate -Usage $ai21LabsJambaUsage -ModelID $modelId
                $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-text-v14' -or $_.ModelId -eq 'cohere.command-light-text-v14' }) {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $cohereCommandUsage -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:cohereModelInfo | Where-Object { $_.ModelId -eq 'cohere.command-r-v1:0' -or $_.ModelId -eq 'cohere.command-r-plus-v1:0' }) {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $cohereCommandRUsage -Message 'Hi there'  -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach ($script:metaModelInfo) {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $metaUsage -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach $script:mistralAIModelInfo {
                $modelId = $_.ModelId
                Add-ModelCostEstimate -Usage $mistralAIUsage -ModelID $modelId -Message 'Hi there'
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for the large chat model' {
                $modelId = 'mistral.mistral-large-2407-v1:0'
                Add-ModelCostEstimate -Usage $mistraAIChatUsage -ModelID $modelId -Message 'Hi there'
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for the large chat when tool_calls are returned model' {
                $modelId = 'mistral.mistral-large-2407-v1:0'
                Add-ModelCostEstimate -Usage $mistraAIChatToolsCallUsage -ModelID $modelId -Message 'Hi there'
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.TotalCost | Should -BeGreaterThan 0
                $eval.InputTokenCount | Should -BeGreaterThan 0
                $eval.OutputTokenCount | Should -BeGreaterThan 0
                $eval.InputTokenCost | Should -BeGreaterThan 0
                $eval.OutputTokenCost | Should -BeGreaterThan 0
            } #it

            It 'should update the tally for <_.ModelId> model' -ForEach $script:stabilityAIModelInfo {
                $modelId = $_.ModelId
                Mock -CommandName Get-ModelCostEstimate -MockWith {
                    [PSCustomObject]@{
                        ImageCount = 1
                        ImageCost  = 1
                    }
                } #endMock
                Add-ModelCostEstimate -ImageCount 1 -ModelID $modelId
                # $eval = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelId -eq $modelId }
                $eval = Get-ModelTally -ModelID $modelId
                $eval.ImageCount | Should -BeGreaterThan 0
                $eval.ImageCost | Should -BeGreaterThan 0
            } #it

        } #context_Success

    } #describe_Add-ModelCostEstimate
} #inModule
