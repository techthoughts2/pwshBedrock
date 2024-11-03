<#
.SYNOPSIS
    Gets information for specified model(s).
.DESCRIPTION
    Retrieves detailed information for a specific model, all models, or models from a specific provider.
    The information includes model capabilities, pricing, and other relevant details.
.EXAMPLE
    Get-ModelInfo -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Retrieves information for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.
.EXAMPLE
    Get-ModelInfo -AllModels

    Retrieves information for all models.
.EXAMPLE
    Get-ModelInfo -Provider 'Amazon'

    Retrieves information for all models from the provider 'Amazon'.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER AllModels
    Gets information for all models.
.PARAMETER Provider
    Gets information for model(s) from a specific provider.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    Pricing information provided by pwshBedrock is based on publicly available pricing information from
    AWS documentation. This pricing information is for a single region, may not reflect current prices,
    and does not include all regions. As a result, the actual costs may vary, and the estimates are likely conservative.
    You should conduct your own cost analysis for more accurate budgeting.
    Remember, model cost estimates provided by pwshBedrock are just that, estimates.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Get-ModelInfo/
#>
function Get-ModelInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.',
            ParameterSetName = 'Single')]
        [ValidateSet(
            'ai21.j2-grande-instruct',
            'ai21.j2-jumbo-instruct',
            'ai21.jamba-instruct-v1:0',
            'ai21.j2-mid-v1',
            'ai21.j2-ultra-v1',
            'amazon.titan-image-generator-v1',
            'amazon.titan-image-generator-v2:0',
            'amazon.titan-text-express-v1',
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-premier-v1:0',
            'amazon.titan-tg1-large',
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            'cohere.command-text-v14',
            'cohere.command-light-text-v14',
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0',
            'meta.llama2-13b-chat-v1',
            'meta.llama2-70b-chat-v1',
            'meta.llama3-70b-instruct-v1:0',
            'meta.llama3-8b-instruct-v1:0',
            'meta.llama3-1-8b-instruct-v1:0',
            'meta.llama3-1-70b-instruct-v1:0',
            'meta.llama3-1-405b-instruct-v1:0',
            'mistral.mistral-7b-instruct-v0:2',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'stability.stable-diffusion-xl-v1',
            'stability.stable-image-ultra-v1:0',
            'stability.stable-image-core-v1:0',
            'stability.sd3-large-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Gets information for all models.',
            ParameterSetName = 'All')]
        [switch]$AllModels,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Gets information for model(s) from a specific provider.',
            ParameterSetName = 'Provider')]
        [ValidateSet(
            'Anthropic',
            'Amazon',
            'AI21 Labs',
            'Cohere',
            'Meta',
            'Mistral AI',
            'Stability AI'
        )]
        [string]$Provider
    )

    $modelInfo = @()
    $modelInfo += $script:anthropicModelInfo
    $modelInfo += $script:amazonModelInfo
    $modelInfo += $script:ai21ModelInfo
    $modelInfo += $script:cohereModelInfo
    $modelInfo += $script:metaModelInfo
    $modelInfo += $script:mistralAIModelInfo
    $modelInfo += $script:stabilityAIModelInfo

    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            Write-Verbose -Message ('Getting model information for {0}' -f $ModelID)
            $returnInfo = $modelInfo | Where-Object { $_.ModelID -eq $ModelID }
        }
        'All' {
            Write-Verbose -Message ('$AllModels is {0}. Retrieving all model info.' -f $AllModels)
            $returnInfo = $modelInfo
        }
        'Provider' {
            Write-Verbose -Message ('Getting model(s) information for {0}' -f $Provider)
            $returnInfo = $modelInfo | Where-Object { $_.ProviderName -eq $Provider }
        }
    }

    Write-Debug -Message ($returnInfo | Out-String)

    return $returnInfo

} #Get-ModelInfo
