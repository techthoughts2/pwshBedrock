<#
.SYNOPSIS
    Formats a message to be sent to the Anthropic model.
.DESCRIPTION
    This function formats a message to be sent to the Anthropic model. The message can be either text or a media file.
    If a media file is specified, it is converted to base64. The function can also persist the conversation context history,
    unless the NoContextPersist parameter is specified.
.EXAMPLE
    Format-AnthropicMessage -Role 'user' -Message 'Hello, how are you?' -ModelID 'anthropic.claude-v2:1'

    Formats a text message to be sent to the Anthropic model.
.EXAMPLE
    Format-AnthropicMessage -Role 'user' -Message 'Hello, how are you?' -MediaPath 'C:\path\to\media.jpg' -ModelID 'anthropic.claude-v2:1'

    Formats a media message to be sent to the Anthropic model by converting the media file to base64.
.EXAMPLE
    Format-AnthropicMessage -Role 'user' -Message 'Hello, how are you?' -ModelID 'anthropic.claude-v2:1' -NoContextPersist

    Formats a text message to be sent to the Anthropic model without persisting the conversation context history.
.EXAMPLE
    $standardToolsResult = [PSCustomObject]@{
        tool_use_id = 'id123'
        content     = 'Elemental Hotel'
    }
    $formatAnthropicMessageSplat = @{
        Role         = 'user'
        ToolsResults = $standardToolsResult
        ModelID      = $_
    }
    Format-AnthropicMessage @formatAnthropicMessageSplat

    Formats a message with tools results to be sent to the Anthropic model.
.EXAMPLE
    $standardToolsCall = [PSCustomObject]@{
        type  = 'tool_use'
        id    = 'id123'
        name  = 'top_song'
        input = [PSCustomObject]@{
            sign = 'WZPZ'
        }
    }
    $formatAnthropicMessageSplat = @{
        Role     = 'assistant'
        ToolCall = $standardToolsCall
        ModelID  = $_
    }
    Format-AnthropicMessage @formatAnthropicMessageSplat

    Formats a message with a tool call to be sent to the Anthropic model.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file.
.PARAMETER ToolsResults
    A list of results from invoking tools recommended by the model in the previous chat turn.
.PARAMETER ToolCall
    The tool call suggested to be used by the model.
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
function Format-AnthropicMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('user', 'assistant')]
        [string]$Role,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.',
            ParameterSetName = 'Standard')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.',
            ParameterSetName = 'Standard')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$MediaPath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.',
            ParameterSetName = 'Result')]
        [ValidateNotNull()]
        [PSCustomObject]$ToolsResults,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The tool call suggested to be used by the model.',
            ParameterSetName = 'Call')]
        [PSCustomObject]$ToolCall,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'anthropic.claude-v2:1',
            'anthropic.claude-3-haiku-20240307-v1:0',
            'anthropic.claude-3-sonnet-20240229-v1:0',
            'anthropic.claude-3-5-sonnet-20240620-v1:0',
            'anthropic.claude-3-opus-20240229-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Anthropic Message'

    if ($MediaPath) {
        Write-Verbose -Message 'Formatting vision message'

        $obj = [PSCustomObject]@{
            role    = $Role
            content = @()
        }

        foreach ($media in $MediaPath) {
            #____________________
            # resets
            $base64 = $null
            $mediaFileInfo = $null
            $extension = $null
            #____________________
            Write-Verbose -Message ('Converting media to base64: {0}' -f $media)
            try {
                $base64 = Convert-MediaToBase64 -MediaPath $media
            }
            catch {
                throw 'Unable to format Anthropic message. Failed to convert media to base64.'
            }

            Write-Verbose -Message ('Getting file info for {0}' -f $media)
            try {
                $mediaFileInfo = Get-Item -Path $media -ErrorAction Stop
            }
            catch {
                throw 'Unable to format Anthropic message. Failed to get media file info.'
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
                throw 'Unable to format Anthropic message. Media extension not found.'
            }

            $obj.content += [PSCustomObject]@{
                type   = 'image'
                source = [PSCustomObject]@{
                    type         = 'base64'
                    'media_type' = 'image/{0}' -f $extension
                    data         = $base64
                }
            }
        } #foreach_MediaPath

        if ($Message) {
            $obj.content += [PSCustomObject]@{
                type = 'text'
                text = $Message
            }
        }

    } #if_MediaPath
    elseif ($Message) {
        Write-Verbose -Message 'Formatting standard message'
        $obj = [PSCustomObject]@{
            role    = $Role
            content = @(
                [PSCustomObject]@{
                    type = 'text'
                    text = $Message
                }
            )
        }
    } #elseif_Message
    elseif ($ToolCall) {
        Write-Verbose -Message 'Formatting tool call message'
        $obj = [PSCustomObject]@{
            role    = $Role
            content = $ToolCall
        }
    } #elseif_ToolCall
    elseif ($ToolsResults) {
        Write-Verbose -Message 'Formatting tool results message'
        $obj = [PSCustomObject]@{
            role    = $Role
            content = @()
        }
        foreach ($tool in $ToolsResults) {

            if ($tool.content -is [string]) {
                $obj.content += [PSCustomObject]@{
                    type        = 'tool_result'
                    tool_use_id = $tool.tool_use_id
                    content     = $tool.content
                }
            }
            else {
                # Initialize the content array for the second object
                $contentArray = @()

                # Iterate over the properties of the first object and construct the content array
                $tool.content.PSObject.Properties | ForEach-Object {
                    $contentArray += [PSCustomObject]@{
                        type = 'text'
                        text = "$($_.Name) = $($_.Value)"
                    }
                }

                $obj.content += [PSCustomObject]@{
                    type        = 'tool_result'
                    tool_use_id = $tool.tool_use_id
                    content     = $contentArray
                }
            }
        } #foreach_ToolsResults

        Write-Debug -Message ($obj.content | Out-String)

    } #elseif_ToolsResults

    Write-Debug -Message ($obj | Out-String)

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context.Add($obj)
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $obj
    }

    return $returnContext

} #Format-AnthropicMessage
