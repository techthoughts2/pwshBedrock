<#
.SYNOPSIS
    Estimates the number of tokens in the provided text.
.DESCRIPTION
    Estimates the number of tokens in the provided text based on an average token length of 4 characters.
    It provides a rough estimate of token count, which can be useful for understanding potential usage costs with language models.
.EXAMPLE
    Get-TokenCountEstimate -Text 'This is a test.'

    Estimates the number of tokens in the provided text.
.EXAMPLE
    Get-TokenCountEstimate -Text (Get-Content -Path 'C:\Temp\test.txt' -Raw)

    Estimates the number of tokens in the text file.
.PARAMETER Text
    The text to estimate tokens for.
.OUTPUTS
    System.Int32
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    This function provides an estimate of the number of tokens in a given text.
    Note that it is just an estimate, as each language model (LLM) has a different tokenization strategy.
    The tokenization strategy used in this function is based on an average token length of 4 characters.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Get-TokenCountEstimate/
#>
function Get-TokenCountEstimate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The text to estimate tokens for.')]
        [string]$Text
    )
    # Calculate character count
    $charCount = $Text.Length

    Write-Debug ('Character count: {0}' -f $charCount)

    Write-Verbose -Message 'Evaluate token estimate based on character count.'
    # Estimate token count (1 token ≈ 4 characters)
    $estimatedTokens = [math]::Ceiling($charCount / 4)
    Write-Verbose -Message ('Estimated tokens: {0}' -f $estimatedTokens)

    return $estimatedTokens
} #Get-TokenCountEstimate
