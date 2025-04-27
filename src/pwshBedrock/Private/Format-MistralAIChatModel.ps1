<#
.SYNOPSIS
    Formats a message to be sent to a Mistral AI model.
.DESCRIPTION
    This function formats a message to be sent to a Mistral AI model.
.EXAMPLE
    Format-MistralAIChatModel -Role 'User' -Message 'Hello, how are you?' -ModelID 'mistral.mistral-large-2407-v1:0'

    This example formats a message to be sent to the Mistral AI model 'mistral.mistral-large-2407-v1:0'.
.EXAMPLE
    Format-MistralAIChatModel -Role 'User' -Message 'Describe this image:' -MediaPath 'C:\path\to\image.jpg' -ModelID 'mistral.pixtral-large-2502-v1:0'

    This example formats a message with an image to be sent to the Mistral AI Pixtral model.
.PARAMETER Role
    The role of the message sender.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file. Only supported by image-capable models like Pixtral.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.PARAMETER ToolCalls
    The tool calls that were returned by the model.
.PARAMETER ModelID
    The unique identifier of the model.
.PARAMETER NoContextPersist
    Do not persist the conversation context history. If this parameter is specified, you will not be able to have a continuous conversation with the model.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    The model requires a specific format for the message. This function formats the message accordingly.
    This model uses object based updates to the context instead of a single string.
    The Pixtral model requires a different message format that supports images.
.COMPONENT
    pwshBedrock
#>
function Format-MistralAIChatModel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('system', 'user', 'assistant', 'tool')]
        [string]$Role,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file. Only supported by image-capable models.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$MediaPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [ValidateNotNull()]
        [object]$ToolsResults,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The tool calls that were returned by the model.')]
        [ValidateNotNullOrEmpty()]
        [object[]]$ToolCalls,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'mistral.mistral-small-2402-v1:0',
            'mistral.mistral-large-2402-v1:0',
            'mistral.mistral-large-2407-v1:0',
            'mistral.pixtral-large-2502-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Mistral AI Chat Message'

    # we need to account for a special condition where the import global variable is default set to string
    # the mistral chat model context is unique in that it is a collection of objects instead of a single string

    $contextEval = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
    if ($contextEval.Context -eq '' -or $null -eq $contextEval.Context -or $contextEval.Context.Count -eq 0) {
        Write-Debug -Message 'No context found. Creating new object based context.'
        $contextEval.Context = New-Object System.Collections.Generic.List[object]
        $firstMessage = $true
    }
    else {
        $firstMessage = $false
    }    # Check if we're using a vision-capable model that requires special formatting

    $isVisionModel = $ModelID -like '*pixtral*'
    if ($isVisionModel) {
        Write-Debug -Message 'Using vision model. Formatting message accordingly.'
    }

    switch ($Role) {
        'system' {
            Write-Debug -Message 'Formatting system message.'
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
            Write-Debug -Message 'Formatting user message.'

            if ($isVisionModel) {
                Write-Debug -Message '....Vision model handling.'

                # Vision model with content array
                $contentArray = @()

                # Add text message if provided
                if ($Message) {
                    $contentArray += [PSCustomObject]@{
                        type = 'text'
                        text = $Message
                    }
                }

                # Add images if provided
                if ($MediaPath) {
                    Write-Debug -Message '....Adding media to message.'
                    foreach ($media in $MediaPath) {
                        # Reset variables
                        $base64 = $null
                        $mediaFileInfo = $null
                        $extension = $null

                        Write-Verbose -Message ('Converting media to base64: {0}' -f $media)
                        try {
                            $base64 = Convert-MediaToBase64 -MediaPath $media
                        }
                        catch {
                            throw 'Unable to format Mistral message. Failed to convert media to base64.'
                        }

                        Write-Verbose -Message ('Getting file info for {0}' -f $media)
                        try {
                            $mediaFileInfo = Get-Item -Path $media -ErrorAction Stop
                        }
                        catch {
                            throw 'Unable to format Mistral message. Failed to get media file info.'
                        }

                        if ($mediaFileInfo) {
                            $extension = $mediaFileInfo.Extension.TrimStart('.')
                            # special case
                            if ($extension -eq 'jpg') {
                                $extension = 'jpeg'
                            }
                            Write-Debug -Message ('Media extension: {0}' -f $extension)
                        }
                        else {
                            throw 'Unable to format Mistral message. Media extension not found.'
                        }

                        $contentArray += [PSCustomObject]@{
                            type      = 'image_url'
                            image_url = [PSCustomObject]@{
                                url = 'data:image/{0};base64,{1}' -f $extension, $base64
                            }
                        }
                    }
                }

                $obj = [PSCustomObject]@{
                    role    = 'user'
                    content = $contentArray
                }
            }
            else {
                Write-Debug -Message '....Standard model handling.'
                # Standard model handling
                $obj = [PSCustomObject]@{
                    role    = 'user'
                    content = $Message
                }
            }
        }
        'assistant' {
            if ($isVisionModel) {
                if ($ToolCalls) {
                    $obj = [PSCustomObject]@{
                        role       = 'assistant'
                        content    = @([PSCustomObject]@{
                                type = 'text'
                                text = $Message
                            })
                        tool_calls = $ToolCalls
                    }
                }
                else {
                    $obj = [PSCustomObject]@{
                        role    = 'assistant'
                        content = @([PSCustomObject]@{
                                type = 'text'
                                text = $Message
                            })
                    }
                }
            }
            else {
                # Standard model handling
                if ($ToolCalls) {
                    $obj = [PSCustomObject]@{
                        role       = 'assistant'
                        content    = $Message
                        tool_calls = $ToolCalls
                    }
                }
                else {
                    $obj = [PSCustomObject]@{
                        role    = 'assistant'
                        content = $Message
                    }
                }
            }
        }
        'tool' {
            # we essentially recreate the same object passed in with one important difference
            # the powershell object in content must be converted to a json string
            # the upstream ConvertTo-Json for the body payload should not process the content conversion.

            $obj = [PSCustomObject]@{
                role         = 'tool'
                tool_call_id = $ToolsResults.tool_call_id
                content      = $ToolsResults.content | ConvertTo-Json -Compress
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
    Write-Debug 'out of Format-MistralAIChatModel'
    return $returnContext

} #Format-MistralAIChatModel
