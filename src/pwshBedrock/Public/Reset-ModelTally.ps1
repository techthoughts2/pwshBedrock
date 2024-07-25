<#
.SYNOPSIS
    Resets the tally for specified model(s).
.DESCRIPTION
    Resets the tally for a specific model or all models. The tally includes the total cost, input token count,
    output token count, input token cost, and output token cost. This is useful for starting fresh estimates of model usage.
.EXAMPLE
    Reset-ModelTally -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Resets the tally for the model 'anthropic.claude-3-sonnet-20240229-v1:0'.
.EXAMPLE
    Reset-ModelTally -AllModels

    Resets the tally for all models. Use this when you want to also reset the total cost estimate.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER AllModels
    Resets the tally for all models.
.PARAMETER Force
    Skip Confirmation
.OUTPUTS
    None
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
    https://www.pwshbedrock.dev/en/latest/Reset-ModelTally/
.LINK
    https://aws.amazon.com/bedrock/pricing/
#>
function Reset-ModelTally {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
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
            'mistral.mistral-7b-instruct-v0:2',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'stability.stable-diffusion-xl-v1'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Resets the tally for all models.',
            ParameterSetName = 'All')]
        [switch]$AllModels,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip confirmation')]
        [switch]$Force
    )

    Begin {

        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }

        Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
        Write-Verbose -Message ('ParameterSetName: {0}' -f $PSCmdlet.ParameterSetName)
    } #begin

    Process {

        Write-Verbose -Message 'Processing Reset-ModelTally'

        switch ($PSCmdlet.ParameterSetName) {
            'Single' {
                if ($Force -or $PSCmdlet.ShouldProcess($ModelID, 'Reset-ModelTally')) {
                    Write-Verbose -Message ('Resetting model tally for {0}' -f $ModelID)
                    $modelTally = $Global:pwshBedRockSessionModelTally | Where-Object { $_.ModelID -eq $ModelID }
                    $modelTally.TotalCost = 0
                    $modelTally.InputTokenCount = 0
                    $modelTally.OutputTokenCount = 0
                    $modelTally.InputTokenCost = 0
                    $modelTally.OutputTokenCost = 0
                    Write-Debug -Message ($modelTally | Out-String)
                }
            }
            'All' {
                if ($Force -or $PSCmdlet.ShouldProcess('AllModels', 'Reset-ModelTally')) {
                    Write-Verbose -Message 'Resetting all model tallies'
                    $Global:pwshBedRockSessionCostEstimate = 0
                    $Global:pwshBedRockSessionModelTally | ForEach-Object {
                        # if the object has the ImageCount property, we will reset an image object, otherwise we will reset a token object
                        if ($null -ne $_.ImageCount) {
                            $_.ImageCount = 0
                            $_.ImageCost = 0
                        }
                        else {
                            $_.TotalCost = 0
                            $_.InputTokenCount = 0
                            $_.OutputTokenCount = 0
                            $_.InputTokenCost = 0
                            $_.OutputTokenCost = 0
                        }
                    }
                    Write-Debug -Message ('Total cost estimate: {0}' -f $Global:pwshBedRockSessionCostEstimate)
                    Write-Debug -Message ($Global:pwshBedRockSessionModelTally | Out-String)
                }
            }
        }
    }
    End {
        Write-Verbose -Message 'Reset-ModelTally complete'
    }

} #Reset-ModelTally
