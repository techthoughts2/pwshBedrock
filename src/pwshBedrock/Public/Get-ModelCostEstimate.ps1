<#
.SYNOPSIS
    Estimates the cost of using a model.
.DESCRIPTION
    This function estimates the cost of using a model based on the provided input and output token counts.
    The cost estimate is calculated using token cost information from public AWS documentation for a single AWS region.
    Text models are estimated based on input and output token counts, while image models are estimated based on the number of images returned by the API.
.EXAMPLE
    Get-ModelCostEstimate -InputTokenCount 1000 -OutputTokenCount 1000 -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Estimates the cost of using the model 'anthropic.claude-3-sonnet-20240229-v1:0' with 1000 input tokens and 1000 output tokens.
.EXAMPLE
    Get-ModelCostEstimate -ImageCount 5 -Steps 10 -ModelID 'amazon.titan-image-generator-v2:0'

    Estimates the cost of using the model 'amazon.titan-image-generator-v2:0' with 5 images and 10 steps.
.EXAMPLE
    Get-ModelCostEstimate -Duration 6 -ModelID 'amazon.nova-reel-v1:1'

    Estimates the cost of using the model 'amazon.nova-reel-v1:1' with a duration of 6 seconds.
.PARAMETER InputTokenCount
    The number of input tokens.
.PARAMETER OutputTokenCount
    The number of output tokens.
.PARAMETER ImageCount
    Image count returned by the API.
.PARAMETER Steps
    Number of steps to run the image model for.
.PARAMETER Duration
    Duration in seconds for video generation models.
.PARAMETER ModelID
    The unique identifier of the model.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    The cost estimate provided by this function is a best effort based on available public information.
    Each model provider has its own methodology for tokenization, so you will need to understand how your provider calculates tokens to get accurate estimates.
    The estimates are based on token cost information for a single AWS region, which may not reflect your actual price as all possible regions are not considered.
    As a result, the actual costs may vary, and the estimates are likely conservative.
    You should conduct your own cost analysis for more accurate budgeting.
    Remember, model cost estimates provided by pwshBedrock are just that, estimates.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Get-ModelCostEstimate/
.LINK
    https://aws.amazon.com/bedrock/pricing/
#>
function Get-ModelCostEstimate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'The number of input tokens.',
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [int]$InputTokenCount,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The number of output tokens.',
            ParameterSetName = 'Token')]
        [ValidateNotNullOrEmpty()]
        [int]$OutputTokenCount,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Image count returned by the API.',
            ParameterSetName = 'Image')]
        [ValidateNotNullOrEmpty()]
        [int]$ImageCount,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Number of steps to run the image model for.',
            ParameterSetName = 'Image')]
        [ValidateNotNullOrEmpty()]
        [int]$Steps,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Duration in seconds for video generation models.',
            ParameterSetName = 'Video')]
        [ValidateRange(6, 120)]
        [int]$Duration,

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
            'amazon.nova-reel-v1:1',
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
            'anthropic.claude-3-7-sonnet-20250219-v1:0',
            'cohere.command-text-v14',
            'cohere.command-light-text-v14',
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0',
            'deepseek.r1-v1:0',
            'luma.ray-v2:0',
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
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'stability.stable-diffusion-xl-v1',
            'stability.stable-image-ultra-v1:0',
            'stability.stable-image-core-v1:0',
            'stability.sd3-large-v1:0',
            'stability.sd3-5-large-v1:0'
        )]
        [string]$ModelID
    )

    Write-Verbose -Message ('Getting cost model estimates for {0}' -f $ModelID)

    if ($ModelID -like 'anthropic*') {
        $modelInfo = $script:anthropicModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'amazon*') {
        $modelInfo = $script:amazonModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'ai21*') {
        $modelInfo = $script:ai21ModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'cohere*') {
        $modelInfo = $script:cohereModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'deepseek*') {
        $modelInfo = $script:deepseekModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'luma*') {
        $modelInfoRaw = $script:lumaModelInfo | Where-Object { $_.ModelID -eq $ModelID }
        $modelInfo = [PSCustomObject]@{
            ImageCost = 0
        }
        if ($Steps -gt 1) {
            $modelInfo.ImageCost = $modelInfoRaw.ImageCost.SevenTwenty
        }
        else {
            $modelInfo.ImageCost = $modelInfoRaw.ImageCost.FiveTwenty
        }
    }
    elseif ($ModelID -like 'meta*') {
        $modelInfo = $script:metaModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -like 'mistral*') {
        $modelInfo = $script:mistralAIModelInfo | Where-Object { $_.ModelID -eq $ModelID }
    }
    elseif ($ModelID -eq 'stability.stable-diffusion-xl-v1') {
        $modelInfoRaw = $script:stabilityAIModelInfo | Where-Object { $_.ModelID -eq $ModelID }
        $modelInfo = [PSCustomObject]@{
            ImageCost = 0
        }
        if ($Steps -gt 50) {
            $modelInfo.ImageCost = $modelInfoRaw.ImageCost.Over50Steps
        }
        else {
            $modelInfo.ImageCost = $modelInfoRaw.ImageCost.Under50Steps
        }
    }

    Write-Debug ($modelInfo | Out-String)

    switch ($PSCmdlet.ParameterSetName) {
        Token {
            Write-Debug ('Calculating token cost. {0} input tokens and {1} output tokens at {2} per 1000 tokens' -f $InputTokenCount, $OutputTokenCount, $modelInfo.InputTokenCost)
            [float]$inputCost = (($inputTokenCount / 1000 ) * $modelInfo.InputTokenCost)
            [float]$outputCost = (($OutputTokenCount / 1000 ) * $modelInfo.OutputTokenCost)
            [float]$total = $inputCost + $outputCost

            $costObj = [PSCustomObject]@{
                Total      = $total
                InputCost  = $inputCost
                OutputCost = $outputCost
            }
        }
        Image {
            Write-Debug ('Calculating image cost. {0} images at {1} per image' -f $ImageCount, $modelInfo.ImageCost)
            [float]$imageCost = ($ImageCount * $modelInfo.ImageCost)

            $costObj = [PSCustomObject]@{
                ImageCost = $imageCost
            }
        }
        Video {
            Write-Debug ('Calculating video cost. {0} seconds at {1} per second' -f $Duration, $modelInfo.ImageCost)
            # For video models, the cost is per second of video
            [float]$videoCost = ($Duration * $modelInfo.ImageCost)

            $costObj = [PSCustomObject]@{
                VideoCost = $videoCost
            }
        }
    } #switch_parameterSetName

    return $costObj
} #Get-ModelCostEstimate
