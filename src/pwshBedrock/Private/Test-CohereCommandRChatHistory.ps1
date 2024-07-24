<#
.SYNOPSIS
    Validates a Chat History object for use with the Cohere Command R models.
.DESCRIPTION
    Evaluates a Chat History object to ensure it meets the requirements for use with the Cohere Command R models.
    It checks the structure of the conversation objects to ensure they are properly formatted.
.EXAMPLE
    Test-CohereCommandRChatHistory -ChatHistory @(
        [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
        [PSCustomObject]@{ role = 'CHATBOT'; message = 'I am fine, thank you. How can I assist you today?' },
        [PSCustomObject]@{ role = 'USER'; message = 'I need help with my account.' },
        [PSCustomObject]@{ role = 'CHATBOT'; message = 'Sure, I can help with that. What seems to be the issue?' }
    )

    Tests the Chat History to ensure it meets the requirements for use with the Cohere Command R models.
.PARAMETER ChatHistory
    Previous messages between the user and the model
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-CohereCommandRChatHistory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = "Previous messages between the user and the model, meant to give the model conversational context for responding to the user's message.")]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject[]]$ChatHistory
    )

    Write-Verbose -Message 'Validating the ChatHistory object(s)...'

    # Initialize a variable to keep track of the expected role sequence
    $expectedRole = 'USER'

    # Iterate through each item in the ChatHistory array
    foreach ($item in $ChatHistory) {
        Write-Debug -Message ($item | Out-String)

        # Check if the 'role' is either 'USER' or 'CHATBOT'
        if ($item.role -ne 'USER' -and $item.role -ne 'CHATBOT') {
            Write-Debug -Message 'Item role is not USER or CHATBOT.'
            return $false
        }

        # Check if the 'message' is a non-null, non-empty string
        if ([string]::IsNullOrWhiteSpace($item.message)) {
            Write-Debug -Message 'Item message is null or empty.'
            return $false
        }

        # Check if the role matches the expected sequence
        if ($item.role -ne $expectedRole) {
            Write-Debug -Message 'Item role does not match the expected sequence.'
            return $false
        }

        # Toggle the expected role for the next item
        if ($expectedRole -eq 'USER') {
            $expectedRole = 'CHATBOT'
        }
        else {
            $expectedRole = 'USER'
        }
    }

    # If all checks passed, return true
    return $true
} #Test-CohereCommandRChatHistory
