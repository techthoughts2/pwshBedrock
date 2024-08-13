<#
.SYNOPSIS
    Saves the message context history for the specified model to a file.
.DESCRIPTION
    This function saves the message context history for the specified model to a file. The context history is used to maintain
    a continuous conversation with the model, allowing you to save the current state and reload it later.
    This can be used in conjunction with Set-ModelContextFromFile to save and load context for later use.
.EXAMPLE
    Save-ModelContext -ModelID 'anthropic.claude-3-sonnet-20240229-v1:0' -FilePath 'C:\temp'

    Saves the message context history for the specified model to a file.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER FilePath
    File path to save the context to.
.OUTPUTS
    None
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    As you interact with models, message context history is stored in memory by pwshBedrock to maintain a continuous conversation.
    Use this function to save the message context history for a specific model.
    You can later load the context back into memory using Get-ModelContext -FilePath 'C:\temp\context.xml'.
    Use this function in conjunction with Set-ModelContextFromFile to save and load context for later use.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Save-ModelContext/
#>
function Save-ModelContext {
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
            'amazon.titan-text-express-v1',
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-premier-v1:0',
            'amazon.titan-tg1-large',
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0',
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
            'stability.stable-diffusion-xl-v1'
        )]
        [string]$ModelID,

        [ValidateScript({
                if (-Not ($_ | Test-Path -PathType Container)) {
                    throw 'The Path argument must be a folder. File paths are not allowed.'
                }
                if (-Not ($_ | Test-Path)) {
                    throw 'File or folder does not exist'
                }
                return $true
            })]
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to save the context to.')]
        [string]$FilePath
    )

    $context = Get-ModelContext -ModelID $ModelID
    $exportObject = [PSCustomObject]@{
        ModelID = $ModelID
        Context = $context
    }

    # check if null or whitespace
    if (-not ($null -eq $context)) {

        # some model ids have a colon in them, which is not allowed in file names
        # remove the colon and replace with a hyphen
        $modelIDFile = $ModelID -replace ':', '-'

        Write-Debug -Message ('Adjusted ModelID: {0}' -f $modelIDFile)

        $fileName = '{0}-{1}.xml' -f $modelIDFile, (Get-Date -Format 'yyyyMMdd-HHmmss')
        $outFilePath = [System.IO.Path]::Combine($FilePath, $fileName)

        Write-Verbose -Message ('Saving context to {0}.' -f $outFilePath)

        try {
            ConvertTo-Clixml -InputObject $exportObject | Out-File -FilePath $outFilePath -Force -ErrorAction Stop
        }
        catch {
            Write-Error -Message ('Failed to save context to {0}.' -f $FilePath)
            throw $_
        }
    }
    else {
        Write-Warning -Message ('No context was found for {0}.' -f $ModelID)
    }

} #Save-ModelContext
