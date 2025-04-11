<#
.SYNOPSIS
    Validates a custom conversation object for use with the Anthropic models.
.DESCRIPTION
    Evaluates a custom conversation object to ensure it meets the requirements for use with the Anthropic models.
    It checks the structure and properties of the conversation objects to ensure they are properly formatted.
.EXAMPLE
    Test-AnthropicCustomConversation -CustomConversation $customConversation

    Tests the custom conversation object $customConversation to ensure it meets the requirements for use with the Anthropic model.
.PARAMETER CustomConversation
    An array of custom conversation objects.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-AnthropicCustomConversation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'An array of custom conversation objects.')]
        [ValidateNotNull()]
        [PSCustomObject[]]$CustomConversation
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Validating provided custom conversation...'

    foreach ($conversation in $CustomConversation) {
        if ([string]::IsNullOrWhiteSpace($conversation.role)) {
            Write-Error -Message 'Custom conversation object must have a role property.'
            $result = $false
        }

        if ($conversation.role -ne 'user' -and $conversation.role -ne 'assistant') {
            Write-Error -Message 'role of conversation must be user or assistant'
            $result = $false
        }

        if (-not $conversation.content) {
            Write-Error -Message 'conversation must contain content property'
            $result = $false
        }

        foreach ($message in $conversation.content) {

            switch ($message.type) {
                'text' {
                    if ($message.text -is [string] -and -not [string]::IsNullOrWhiteSpace($message)) {
                        Write-Verbose -Message 'Custom conversation message is valid.'
                    }
                    else {
                        Write-Error -Message 'Custom conversation message must have a Text property.'
                        $result = $false
                    }
                }
                'image' {
                    $type = $message.source.type
                    $media = $message.source.'media_type'
                    $data = $message.source.data
                    if ($type -ne 'base64' -or $media -ne 'image/jpeg' -or [string]::IsNullOrWhiteSpace($data)) {
                        Write-Error -Message 'Custom conversation image message must have a source property with a type, media_type, and data property.'
                        $result = $false
                    }
                }
                default {
                    Write-Error -Message 'Custom conversation message must have a Type property.'
                    $result = $false
                }
            }
        } #foreach_message
    } #foreach_conversation

    return $result

} #Test-AnthropicCustomConversation
