<#
.SYNOPSIS
    Formats a message to be sent to an Amazon Titan model.
.DESCRIPTION
    This function formats a message to be sent to an Amazon Titan model.
.EXAMPLE
    Format-AmazonTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'amazon.titan-tg1-large'

    Formats a text message to be sent to the Amazon Titan model.
.EXAMPLE
    Format-AmazonTextMessage -Role 'User' -Message 'Hello, how are you?' -ModelID 'amazon.titan-tg1-large'

    Formats a text message to be sent to the Amazon Titan model without persisting the conversation context history.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    The model requires a specific format for the message. This function formats the message accordingly.
.COMPONENT
    pwshBedrock
#>
function Format-AmazonTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('User', 'Bot')]
        [string]$Role,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'amazon.titan-text-lite-v1',
            'amazon.titan-text-express-v1',
            'amazon.titan-tg1-large',
            'amazon.titan-text-premier-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Amazon Titan Message'

    if ($Role -eq 'User') {
        $str = "User: $Message`n"
    }
    elseif ($Role -eq 'Bot') {
        $str = "$Message`n"
    }

    Write-Debug -Message ('Formatted message: {0}' -f $str)

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context += $str
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $str
    }
    Write-Debug 'out of Format-AmazonTextMessage'
    return $returnContext

} #Format-AmazonTextMessage
