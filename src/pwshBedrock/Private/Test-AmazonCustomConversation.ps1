<#
.SYNOPSIS
    Validates a custom conversation object for use with the Amazon Titan models.
.DESCRIPTION
    Evaluates a custom conversation object to ensure it meets the requirements for use with the Amazon Titan models.
    It checks the structure of the conversation objects to ensure they are properly formatted.
.EXAMPLE
    Test-AmazonCustomConversation -CustomConversation $customConversation

    Tests the custom conversation string $customConversation to ensure it meets the requirements for use with the Amazon Titan model.
.PARAMETER CustomConversation
    A properly formatted string that represents a custom conversation.
.OUTPUTS
    System.Boolean
.NOTES
    None
.COMPONENT
    pwshBedrock
#>
function Test-AmazonCustomConversation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'A properly formatted string that represents a custom conversation.')]
        [ValidateNotNull()]
        [string]$CustomConversation
    )

    # Split the input into lines
    $lines = $CustomConversation -split "`n"

    # Initialize expected role (User should be the first)
    $expectedRole = 'User'

    # Loop through each line to check the pattern
    foreach ($line in $lines) {
        if ($line -match "^$($expectedRole): .*$") {
            # Alternate between User and Bot
            if ($expectedRole -eq 'User') {
                $expectedRole = 'Bot'
            }
            else {
                $expectedRole = 'User'
            }
        }
        else {
            return $false
        }
    }

    return $true

} #Test-AmazonCustomConversation
