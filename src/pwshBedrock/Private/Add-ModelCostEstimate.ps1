<#
.SYNOPSIS
    Updates the cost estimate for a model based on the usage.
.DESCRIPTION
    This function updates the global variables that tally the cost of models used during the session.
    It calculates the cost based on token usage and adds it to the global session total.
.EXAMPLE
    Add-ModelCostEstimate -Usage $usage -ModelID 'anthropic.claude-v2:1'

    Adds the cost estimate for the model 'anthropic.claude-v2:1' to the global tally variables.
.PARAMETER Usage
    Token usage object returned by the API.
.PARAMETER Message
    The message that was sent to the model.
.PARAMETER ImageCount
    Image count returned by the API.
.PARAMETER Steps
    Number of steps to run the image model for.
.PARAMETER ModelID
    The unique identifier of the model.
.OUTPUTS
    None
.NOTES
    Tally estimates are approximations. The actual cost may vary.
    * Note: Image models pass their image count and steps to the cost estimate function.
.COMPONENT
    pwshBedrock
#>
function Add-ModelCostEstimate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Token usage object returned by the API.',
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [object]$Usage,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message that was sent to the model.',
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Image count returned by the API.',
            ParameterSetName = 'Image')]
        [ValidateNotNullOrEmpty()]
        [int]$ImageCount,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Number of steps to run the image model for.',
            ParameterSetName = 'Image')]
        [int]$Steps,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'ai21.jamba-instruct-v1:0',
            'ai21.jamba-1-5-mini-v1:0',
            'ai21.jamba-1-5-large-v1:0',
            'amazon.nova-pro-v1:0',
            'amazon.nova-lite-v1:0',
            'amazon.nova-micro-v1:0',
            'amazon.nova-canvas-v1:0',
            'amazon.nova-reel-v1:0',
            'amazon.titan-image-generator-v1',
            'amazon.titan-image-generator-v2:0',
            'amazon.titan-text-express-v1',
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-premier-v1:0',
            'amazon.titan-tg1-large',
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-5-haiku-20241022-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20241022-v2:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            'cohere.command-text-v14',
            'cohere.command-light-text-v14',
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-8b-instruct-v1:0',
            'meta.llama3-1-8b-instruct-v1:0',
            'meta.llama3-1-70b-instruct-v1:0',
            'meta.llama3-1-405b-instruct-v1:0',
            'meta.llama3-2-1b-instruct-v1:0',
            'meta.llama3-2-3b-instruct-v1:0',
            'meta.llama3-2-11b-instruct-v1:0',
            'meta.llama3-2-90b-instruct-v1:0',
            'meta.llama3-3-70b-instruct-v1:0',
            'mistral.mistral-7b-instruct-v0:2',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'stability.stable-diffusion-xl-v1',
            'stability.stable-image-ultra-v1:0',
            'stability.stable-image-core-v1:0',
            'stability.sd3-large-v1:0',
            'stability.sd3-5-large-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Indicates that model was called through the Converse API.',
            ParameterSetName = 'Token' )]
        [switch]$Converse
    )
    $modelTally = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelID -eq $ModelID }

    switch ($PSCmdlet.ParameterSetName) {
        Token {
            if ($Converse) {
                $inputTokenCount = $Usage.InputTokens
                $outputTokenCount = $Usage.OutputTokens
            } #if_converse
            else {
                switch ($ModelID) {
                    'ai21.jamba-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_tokens
                        $outputTokenCount = $Usage.completion_tokens
                    }
                    'ai21.jamba-1-5-mini-v1:0' {
                        $inputTokenCount = $Usage.prompt_tokens
                        $outputTokenCount = $Usage.completion_tokens
                    }
                    'ai21.jamba-1-5-large-v1:0' {
                        $inputTokenCount = $Usage.prompt_tokens
                        $outputTokenCount = $Usage.completion_tokens
                    }
                    'amazon.titan-text-express-v1' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.titan-text-lite-v1' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.titan-text-premier-v1:0' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.titan-tg1-large' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.nova-pro-v1:0' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.nova-lite-v1:0' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'amazon.nova-micro-v1:0' {
                        $inputTokenCount = $Usage.'inputTextTokenCount'
                        $outputTokenCount = $Usage.results.tokenCount
                    }
                    'anthropic.claude-v2:1' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-haiku-20240307-v1:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-5-haiku-20241022-v1:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-opus-20240229-v1:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-sonnet-20240229-v1:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-5-sonnet-20241022-v2:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'anthropic.claude-3-5-sonnet-20240620-v1:0' {
                        $inputTokenCount = $Usage.'input_tokens'
                        $outputTokenCount = $Usage.'output_tokens'
                    }
                    'cohere.command-text-v14' {
                        # this model does not return token counts, but does return the prompt and completion text
                        # so, we can calculate the token counts based on the text length
                        $inputTokenCount = Get-TokenCountEstimate -Text $Usage.prompt
                        # because this model supports multiple generations, we need to sum the token counts
                        foreach ($textGeneration in $Usage.generations.text) {
                            $outputTokenCount += Get-TokenCountEstimate -Text $textGeneration
                        }
                    }
                    'cohere.command-light-text-v14' {
                        # this model does not return token counts, but does return the prompt and completion text
                        # so, we can calculate the token counts based on the text length
                        $inputTokenCount = Get-TokenCountEstimate -Text $Usage.prompt
                        foreach ($textGeneration in $Usage.generations.text) {
                            $outputTokenCount += Get-TokenCountEstimate -Text $textGeneration
                        }
                    }
                    'cohere.command-r-v1:0' {
                        $inputTokenCount = Get-TokenCountEstimate -Text $Message
                        $outputTokenCount = Get-TokenCountEstimate -Text $Usage.text
                    }
                    'cohere.command-r-plus-v1:0' {
                        $inputTokenCount = Get-TokenCountEstimate -Text $Message
                        $outputTokenCount = Get-TokenCountEstimate -Text $Usage.text
                    }
                    'meta.llama3-70b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-8b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-1-8b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-1-70b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-1-405b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-2-1b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-2-3b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-2-11b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-2-90b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'meta.llama3-3-70b-instruct-v1:0' {
                        $inputTokenCount = $Usage.prompt_token_count
                        $outputTokenCount = $Usage.generation_token_count
                    }
                    'mistral.mistral-7b-instruct-v0:2' {
                        $inputTokenCount = Get-TokenCountEstimate -Text $Message
                        $outputTokenCount = Get-TokenCountEstimate -Text $Usage.outputs.text
                    }
                    'mistral.mistral-large-2402-v1:0' {
                        # this model can return different results depending on the calling API used
                        if ($Usage.choices.message.role -is [string]) {
                            $inputTokenCount = Get-TokenCountEstimate -Text $Message
                            if ($Usage.choices.stop_reason -eq 'tool_calls') {
                                $outputTokenCount = Get-TokenCountEstimate -Text $Usage.choices.message.tool_calls.function.arguments
                            }
                            else {
                                $outputTokenCount = Get-TokenCountEstimate -Text $Usage.choices.message.content
                            }
                        }
                        else {
                            $inputTokenCount = Get-TokenCountEstimate -Text $Message
                            $outputTokenCount = Get-TokenCountEstimate -Text $Usage.outputs.text
                        }
                    }
                    'mistral.mistral-large-2407-v1:0' {
                        # this model can return different results depending on the calling API used
                        if ($Usage.choices.message.role -is [string]) {
                            $inputTokenCount = Get-TokenCountEstimate -Text $Message
                            if ($Usage.choices.stop_reason -eq 'tool_calls') {
                                $outputTokenCount = Get-TokenCountEstimate -Text $Usage.choices.message.tool_calls.function.arguments
                            }
                            else {
                                $outputTokenCount = Get-TokenCountEstimate -Text $Usage.choices.message.content
                            }
                        }
                        else {
                            $inputTokenCount = Get-TokenCountEstimate -Text $Message
                            $outputTokenCount = Get-TokenCountEstimate -Text $Usage.outputs.text
                        }
                    }
                    'mistral.mistral-small-2402-v1:0' {
                        $inputTokenCount = Get-TokenCountEstimate -Text $Message
                        $outputTokenCount = Get-TokenCountEstimate -Text $Usage.outputs.text
                    }
                    'mistral.mixtral-8x7b-instruct-v0:1' {
                        $inputTokenCount = Get-TokenCountEstimate -Text $Message
                        $outputTokenCount = Get-TokenCountEstimate -Text $Usage.outputs.text
                    }
                }
            } #else_converse


            if ($null -eq $Steps -or $Steps -eq 0) {
                $Steps = 1
            }

            Write-Verbose -Message ('Adding cost estimates for model {0}' -f $ModelID)

            $costInfo = Get-ModelCostEstimate -InputTokenCount $inputTokenCount -OutputTokenCount $outputTokenCount -ModelID $ModelID

            Write-Debug -Message ($costInfo | Out-String)

            $Global:pwshBedRockSessionCostEstimate += $costInfo.Total
            $modelTally.TotalCost += $costInfo.Total
            $modelTally.InputTokenCount += $inputTokenCount
            $modelTally.OutputTokenCount += $outputTokenCount
            $modelTally.InputTokenCost += $costInfo.InputCost
            $modelTally.OutputTokenCost += $costInfo.OutputCost
        } #token
        Image {
            $costInfo = Get-ModelCostEstimate -ImageCount $ImageCount -Steps $StepsCount -ModelID $ModelID

            Write-Debug -Message ($costInfo | Out-String)
            $Global:pwshBedRockSessionCostEstimate += $costInfo.ImageCost
            $modelTally.ImageCount += $ImageCount
            $modelTally.ImageCost += $costInfo.ImageCost
        } #image
    } #switch_parameterSetName

} #Add-ModelCostEstimate
