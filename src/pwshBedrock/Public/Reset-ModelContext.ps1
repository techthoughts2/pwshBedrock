<#
.SYNOPSIS
    Resets the message context for specified model(s).
.DESCRIPTION
    Resets the message context for the specified model or all models, effectively "starting a new conversation".
    This is useful for clearing any persisted interaction histories that have been stored during interactions with the model(s).
.EXAMPLE
    Reset-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Resets the message context for the specified model.
.EXAMPLE
    Reset-ModelContext -AllModels

    Resets the message context for all models.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER AllModels
    Resets the message context for all models.
.PARAMETER Force
    Skip Confirmation
.OUTPUTS
    None
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    Use this function to clear the message context when you want to start a fresh conversation without the influence of prior interactions.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Reset-ModelContext/
#>
function Reset-ModelContext {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',
        Justification = 'The purpose of this function is to reset variables, not use them')]
    param (

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.',
            ParameterSetName = 'Single')]
        [ValidateSet(
            'Converse',
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
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20241022-v2:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            'anthropic.claude-3-7-sonnet-20250219-v1:0',
            # 'cohere.command-text-v14',
            # 'cohere.command-light-text-v14',
            'cohere.command-r-v1:0',
            'cohere.command-r-plus-v1:0',
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

        [Parameter(Mandatory = $true,
            HelpMessage = 'Resets the message context for all models.',
            ParameterSetName = 'All')]
        [switch]$AllModels,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip confirmation')]
        [switch]$Force
    )

    begin {

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

    process {

        Write-Verbose -Message 'Processing Reset-ModelContext'

        switch ($PSCmdlet.ParameterSetName) {
            'Single' {
                if ($Force -or $PSCmdlet.ShouldProcess($ModelID, 'Reset-ModelContext')) {
                    Write-Verbose -Message ('Resetting message context for {0}' -f $ModelID)
                    $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
                    Write-Debug -Message ($context | Out-String)
                    if ($model -eq 'amazon.titan-text-express-v1' -or
                        $model -eq 'amazon.titan-text-lite-v1' -or
                        $model -eq 'amazon.titan-tg1-large' -or
                        $model -eq 'meta.llama3-8b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-70b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-1-8b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-1-70b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-1-405b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-2-1b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-2-3b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-2-11b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-2-90b-instruct-v1:0' -or
                        $model -eq 'meta.llama3-3-70b-instruct-v1:0' -or
                        $model -eq 'mistral.mistral-7b-instruct-v0:2' -or
                        $model -eq 'mistral.mixtral-8x7b-instruct-v0:1' -or
                        $model -eq 'mistral.mistral-large-2402-v1:0' -or
                        $model -eq 'mistral.mistral-large-2407-v1:0' -or
                        $model -eq 'mistral.mistral-small-2402-v1:0') {
                        $context.Context = ''
                    }
                    else {
                        $context.Context = New-Object System.Collections.Generic.List[object]
                    }
                }
            }
            'All' {
                if ($Force -or $PSCmdlet.ShouldProcess('AllModels', 'Reset-ModelContext')) {
                    Write-Verbose -Message 'Resetting message context for all models.'
                    $allModelInfo = Get-ModelInfo -AllModels
                    $allModelIDs = ($allModelInfo | Where-Object {
                            $_.ModelId -ne 'amazon.titan-image-generator-v1' -and
                            $_.ModelId -ne 'amazon.titan-image-generator-v2:0' -and
                            $_.ModelId -ne 'amazon.nova-canvas-v1:0' -and
                            $_.ModelId -ne 'amazon.nova-reel-v1:0' -and
                            $_.ModelId -ne 'cohere.command-text-v14' -and
                            $_.ModelId -ne 'cohere.command-light-text-v14' -and
                            $_.ModelId -ne 'luma.ray-v2:0'
                        }).ModelID
                    foreach ($model in $allModelIDs) {
                        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $model }
                        Write-Debug -Message ($context | Out-String)
                        if ($model -eq 'amazon.titan-text-express-v1' -or
                            $model -eq 'amazon.titan-text-lite-v1' -or
                            $model -eq 'amazon.titan-tg1-large' -or
                            $model -eq 'meta.llama3-8b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-70b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-1-8b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-1-70b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-1-405b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-2-1b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-2-3b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-2-11b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-2-90b-instruct-v1:0' -or
                            $model -eq 'meta.llama3-3-70b-instruct-v1:0' -or
                            $model -eq 'mistral.mistral-7b-instruct-v0:2' -or
                            $model -eq 'mistral.mixtral-8x7b-instruct-v0:1' -or
                            $model -eq 'mistral.mistral-large-2402-v1:0' -or
                            $model -eq 'mistral.mistral-large-2407-v1:0' -or
                            $model -eq 'mistral.mistral-small-2402-v1:0') {
                            Write-Debug -Message ('Resetting message context for {0}' -f $model)
                            $context.Context = ''
                            Write-Debug -Message ($context | Out-String)
                        }
                        else {
                            Write-Debug -Message ('Resetting message context for {0}' -f $model)
                            $context.Context = New-Object System.Collections.Generic.List[object]
                            Write-Debug -Message ($context | Out-String)
                        }
                    }
                    # also reset Converse
                    $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
                    Write-Debug -Message ($context | Out-String)
                    $context.Context = New-Object System.Collections.Generic.List[object]
                }
            }
        }
    }
    end {
        Write-Verbose -Message 'Reset-ModelContext complete'
    }

} #Reset-ModelContext
