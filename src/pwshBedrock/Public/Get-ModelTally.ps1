<#
.SYNOPSIS
    Retrieves the tally for a specific model or all models.
.DESCRIPTION
    This function retrieves the tally of a specific model or all models. The tally includes the estimated total cost, input token count,
    output token count, estimated input token cost, and estimated output token cost. pwshBedrock provides this tally to give you a general
    estimate of model use. If you want to get the estimated total cost estimate for all models, use the -JustTotalCost switch.
.EXAMPLE
    Get-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Retrieves the tally for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.
.EXAMPLE
    Get-ModelTally -AllModels

    Retrieves the tally for all models.
.EXAMPLE
    Get-ModelTally -JustTotalCost

    Retrieves the total cost estimate for all models.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER AllModels
    Gets the tally for all models.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    The model tally information provided by pwshBedrock is a best effort estimate of model use.
    pwshBedrock captures the token input and output counts if provided by the model provider. If the provider does not provide token counts,
    the counts will be estimated based on an average token length of 4 characters. The cost estimate is based on token cost information
    provided by AWS documentation for a single region, which may not reflect current prices or include all regions.
    Therefore, the actual costs may vary, and the estimates are likely conservative.
    You are responsible for monitoring your usage and costs. Tally estimates provided by pwshBedrock are just that, estimates.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Get-ModelTally/
.LINK
    https://aws.amazon.com/bedrock/pricing/
#>
function Get-ModelTally {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.',
            ParameterSetName = 'Single')]
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
        [string]$ModelID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Gets the tally for all models.',
            ParameterSetName = 'All')]
        [switch]$AllModels,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Gets the total tallied cost for all models.',
            ParameterSetName = 'Total')]
        [switch]$JustTotalCost
    )

    Write-Verbose -Message 'Processing Get-ModelTally'

    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            Write-Verbose -Message ('Getting model tally for {0}' -f $ModelID)
            $modelTally = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelID -eq $ModelID }
            Write-Debug -Message ('ModelTally: {0}' -f $modelTally)
            return $modelTally
        }
        'All' {
            Write-Verbose -Message ('AllModels: {0} - getting all models' -f $AllModels)
            return $Global:pwshBedRockSessionModelTally
        }
        'Total' {
            Write-Verbose -Message ('JustTotalCost: {0} - getting total cost' -f $JustTotalCost)
            return $Global:pwshBedRockSessionCostEstimate
        }
    }

} #Get-ModelTally
