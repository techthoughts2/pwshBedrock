<#
.SYNOPSIS
    Returns the message context history for the specified model.
.DESCRIPTION
    This function returns the message context history for the specified model. The context history is stored to maintain a continuous conversation with the model.
.EXAMPLE
    Get-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0'

    Returns the message context history for the specified model.
.EXAMPLE
    Get-ModelContext -ModelID 'Converse'

    Returns the Converse API context history. The Converse context history can represent whatever model you were interacting with at the time.
.PARAMETER ModelID
    The unique identifier of the model.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    As you interact with models, message context history is stored in memory by pwshBedrock for maintaining a continuous conversation.
    If you want to see the message context history for a specific model you have been interacting with, you can use this function.

    The Converse API can be used to interact with various models. The Converse history is stored in its own Converse context history.
    You can retrieve the Converse context history directly by specifying Converse as the ModelID.
    However, realize that the Converse context history can represent whatever model you were interacting with at the time.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Get-ModelContext/
#>
function Get-ModelContext {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            # 'ai21.j2-grande-instruct',
            # 'ai21.j2-jumbo-instruct',
            'ai21.jamba-instruct-v1:0',
            # 'ai21.j2-mid-v1',
            # 'ai21.j2-ultra-v1',
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
            # 'cohere.command-text-v14',
            # 'cohere.command-light-text-v14',
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
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.mistral-small-2402-v1:0',
            'mistral.mixtral-8x7b-instruct-v0:1',
            'stability.stable-diffusion-xl-v1',
            'Converse'
        )]
        [string]$ModelID
    )

    Write-Verbose -Message ('Getting current model context for {0}' -f $ModelID)

    $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }

    return $context.Context

} #Get-ModelContext
