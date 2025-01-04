<#
.SYNOPSIS
    Validates a custom conversation object for use with the Amazon Nova models.
.DESCRIPTION
    Evaluates a custom conversation object to ensure it meets the requirements for use with the Amazon Nova models.
    It checks the structure and properties of the conversation objects to ensure they are properly formatted.
.EXAMPLE
    Test-AmazonNovaCustomConversation -CustomConversation $customConversation

    Tests the custom conversation object $customConversation to ensure it meets the requirements for use with the Amazon Nova model.
.PARAMETER CustomConversation
    An array of custom conversation objects.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-AmazonNovaCustomConversation {
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

            $messageType = $null
            $messageType = $message.PSObject.Properties.Name

            Write-Debug -Message ('Message type: {0}' -f $messageType)

            switch ($messageType) {
                'video' {
                    if ($message.video.format -isnot [string] -or [string]::IsNullOrWhiteSpace($message.video.format)) {
                        Write-Error -Message 'Custom conversation video message must have a format property with the extension.'
                        $result = $false
                    }
                    # validate that $message.format is of type string and validate $message.source.bytes is a base64 string
                    if ($message.video.source.bytes -is [string] -and -not [string]::IsNullOrWhiteSpace($message.video.source.bytes)) {
                        Write-Verbose -Message 'Custom conversation video message is valid.'
                    }
                    else {
                        Write-Error -Message 'Custom conversation video message must have a source property with a bytes property.'
                        $result = $false
                    }
                }
                'image' {
                    Write-Debug -Message ('Image message: {0}' -f $message.format)
                    if ($message.image.format -isnot [string] -or [string]::IsNullOrWhiteSpace($message.image.format)) {
                        Write-Error -Message 'Custom conversation image message must have a format property with the extension.'
                        $result = $false
                    }
                    # validate that $message.format is of type string and validate $message.source.bytes is a base64 string
                    if ($message.image.source.bytes -is [string] -and -not [string]::IsNullOrWhiteSpace($message.image.source.bytes)) {
                        Write-Verbose -Message 'Custom conversation image message is valid.'
                    }
                    else {
                        Write-Error -Message 'Custom conversation image message must have a source property with a bytes property.'
                        $result = $false
                    }
                }
                'text' {
                    if ($message.text -is [string] -and -not [string]::IsNullOrWhiteSpace($message)) {
                        Write-Verbose -Message 'Custom conversation message is valid.'
                    }
                    else {
                        Write-Error -Message 'Custom conversation message must have a Text property.'
                        $result = $false
                    }
                }
                default {
                    # Handle unknown
                    Write-Error -Message 'Custom conversation message must have a type property.'
                    $result = $false
                }
            } #switch_messageType
        } #foreach_message
    } #foreach_conversation

    return $result

} #Test-AmazonNovaCustomConversation
