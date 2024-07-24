<#
.SYNOPSIS
    Formats a message to be sent to a AI21 Labs Jamba Model.
.DESCRIPTION
    This function formats a message to be sent to a AI21 Labs Jamba Model.
.EXAMPLE
    Format-AI21LabsJambaModel -Role 'User' -Message 'Hello, how are you?' -ModelID 'ai21.jamba-instruct-v1:0'

    This example formats a message to be sent to the AI21 Labs Jamba Model 'ai21.jamba-instruct-v1:0'.
.PARAMETER Role
    The role of the message sender.
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
    This model uses object based updates to the context instead of a single string.
.COMPONENT
    pwshBedrock
#>
function Format-AI21LabsJambaModel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('user', 'assistant', 'system')]
        [string]$Role,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'ai21.jamba-instruct-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting AI 21 Labs Jamba Message'

    $contextEval = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
    if ($contextEval.Context -eq '' -or $null -eq $contextEval.Context -or $contextEval.Context.Count -eq 0) {
        Write-Debug -Message 'No context found. First message.'
        $firstMessage = $true
    }
    else {
        $firstMessage = $false
    }

    switch ($Role) {
        'system' {
            if ($firstMessage -eq $true) {
                $obj = [PSCustomObject]@{
                    role    = 'system'
                    content = $Message
                }
            }
            else {
                # we need to determine if the context already has a system message
                # if it does, we need to replace it with the new system message
                # if it does not, we need to add the new system message
                $obj = $contextEval.Context | Where-Object { $_.role -eq 'system' }
                if ($null -eq $obj) {
                    $obj = [PSCustomObject]@{
                        role    = 'system'
                        content = $Message
                    }
                }
                else {
                    $obj.content = $Message
                    return
                }
            }
        }
        'user' {
            $obj = [PSCustomObject]@{
                role    = 'user'
                content = $Message
            }
        }
        'assistant' {
            $obj = [PSCustomObject]@{
                role    = 'assistant'
                content = $Message
            }
        }
    } #switch_role

    Write-Debug -Message ('Formatted message: {0}' -f ($obj | Out-String) )

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context.Add($obj)
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $obj
    }
    Write-Debug 'out of Format-AI21LabsJambaModel'
    return $returnContext

} #Format-AI21LabsJambaModel
