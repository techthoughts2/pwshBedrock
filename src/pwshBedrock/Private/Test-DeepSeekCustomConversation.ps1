<#
.SYNOPSIS
    Tests if a custom conversation string is properly formatted for the DeepSeek model.
.DESCRIPTION
    This function tests if a custom conversation string is properly formatted for the DeepSeek model.
    It ensures that the conversation follows the required format with proper tags.
.EXAMPLE
    $customConversation = "<｜begin_of_sentence｜><｜User｜>What is 2 + 2?<｜Assistant｜>4<｜end_of_sentence｜><｜Assistant｜>"
    Test-DeepSeekCustomConversation -CustomConversation $customConversation

    Tests if the custom conversation string is properly formatted for the DeepSeek model.
.PARAMETER CustomConversation
    The custom conversation string to test.
.OUTPUTS
    System.Boolean
    Returns $true if the conversation is properly formatted, $false otherwise.
.NOTES
    DeepSeek prompt format:
    <｜begin_of_sentence｜>{system_prompt}<｜User｜>{prompt}<｜Assistant｜><｜end_of_sentence｜><｜Assistant｜>

    DeepSeek Conversation Example:
    <｜begin_of_sentence｜>You are a helpful assistant.
    <｜User｜>What is 2 + 2?
    <｜Assistant｜>2 + 2 equals 4.
    <｜User｜>Can you explain why?
    <｜Assistant｜>Let's break it down: 2 represents two units, and adding another two units gives us four units total. So, 2 + 2 = 4.
    <｜end_of_sentence｜><｜Assistant｜>
.COMPONENT
    pwshBedrock
#>
function Test-DeepSeekCustomConversation {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The custom conversation string to test.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$CustomConversation
    )

    Write-Debug -Message 'Testing DeepSeek custom conversation format'

    # Check if the conversation starts with the begin_of_sentence tag
    if (-not $CustomConversation.StartsWith('<｜begin_of_sentence｜>')) {
        Write-Debug -Message 'Conversation does not start with <｜begin_of_sentence｜>'
        Write-Warning -Message 'DeepSeek conversation must start with <｜begin_of_sentence｜>'
        return $false
    }

    # Check if the conversation ends with the proper sequence
    if (-not $CustomConversation.EndsWith('<｜end_of_sentence｜><｜Assistant｜>')) {
        Write-Debug -Message 'Conversation does not end with <｜end_of_sentence｜><｜Assistant｜>'
        Write-Warning -Message 'DeepSeek conversation must end with <｜end_of_sentence｜><｜Assistant｜>'
        return $false
    }    # Check if there's at least one User tag
    if (-not $CustomConversation.Contains('<｜User｜>')) {
        Write-Debug -Message 'Conversation does not contain any <｜User｜> tags'
        Write-Warning -Message 'DeepSeek conversation must contain at least one <｜User｜> tag'
        return $false
    }

    # Check for alternating User and Assistant tags
    # First, extract just the conversation parts between tags
    $conversationWithoutSystemPrompt = $CustomConversation
    # Remove everything between begin_of_sentence and the first User tag (system prompt)
    $conversationWithoutSystemPrompt = $conversationWithoutSystemPrompt -replace '^<\｜begin_of_sentence\｜>(.*?)<\｜User\｜>', '<｜begin_of_sentence｜><｜User｜>'
    # Remove the ending tags
    $conversationWithoutSystemPrompt = $conversationWithoutSystemPrompt -replace '<\｜end_of_sentence\｜><\｜Assistant\｜>$', ''
    # Split by user and assistant tags
    $parts = $conversationWithoutSystemPrompt -split '(?=<\｜User\｜>|<\｜Assistant\｜>|<\｜InvalidForTest\｜>)'
    $parts = $parts | Where-Object { $_ -ne '' -and $_ -notmatch '^<\｜begin_of_sentence\｜>$' }

    Write-Debug -Message "Found $($parts.Count) parts after splitting"

    $lastTag = $null
    foreach ($part in $parts) {
        Write-Debug -Message "Processing part: $part"
        if ($part.StartsWith('<｜User｜>')) {
            if ($lastTag -eq 'User') {
                Write-Debug -Message 'Found consecutive User tags'
                Write-Warning -Message 'DeepSeek conversation cannot have consecutive User tags'
                return $false
            }
            $lastTag = 'User'
        }
        elseif ($part.StartsWith('<｜Assistant｜>')) {
            if ($lastTag -eq 'Assistant') {
                Write-Debug -Message 'Found consecutive Assistant tags'
                Write-Warning -Message 'DeepSeek conversation cannot have consecutive Assistant tags'
                return $false
            }
            $lastTag = 'Assistant'
        }
        else {
            Write-Debug -Message 'Found an invalid tag in the conversation'
            Write-Warning -Message 'DeepSeek conversation contains an invalid tag'
            return $false
        }
    }

    # Check for potential malformed tags
    $malformedTags = [regex]::Matches($CustomConversation, '<\｜[^>]+\｜?>')
    foreach ($match in $malformedTags) {
        if ($match.Value -notin @('<｜begin_of_sentence｜>', '<｜User｜>', '<｜Assistant｜>', '<｜end_of_sentence｜>')) {
            Write-Debug -Message "Found malformed tag: $($match.Value)"
            Write-Warning -Message "DeepSeek conversation contains malformed tag: $($match.Value)"
            return $false
        }
    }

    # All checks passed
    Write-Debug -Message 'DeepSeek custom conversation is valid'
    return $true
}
