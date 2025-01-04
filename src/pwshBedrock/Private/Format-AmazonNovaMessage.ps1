<#
.SYNOPSIS
    Formats a message to be sent to the Amazon Nova model.
.DESCRIPTION
    This function formats a message to be sent to the Amazon Nova model. The message can be either text or a media file.
    If a media file is specified, it is converted to base64. The function can also persist the conversation context history,
    unless the NoContextPersist parameter is specified.
.EXAMPLE
    Format-AmazonNovaMessage -Role 'user' -Message 'Hello, how are you?' -ModelID 'amazon.nova-pro-v1:01'

    Formats a text message to be sent to the Amazon Nova model.
.EXAMPLE
    Format-AmazonNovaMessage -Role 'user' -Message 'Hello, how are you?' -MediaPath 'C:\path\to\media.jpg' -ModelID 'amazon.nova-pro-v1:01'

    Formats a media message to be sent to the Amazon Nova model by converting the media file to base64.
.EXAMPLE
    Format-AmazonNovaMessage -Role 'user' -Message 'Hello, how are you?' -ModelID 'amazon.nova-pro-v1:01' -NoContextPersist

    Formats a text message to be sent to the Amazon Nova model without persisting the conversation context history.
.EXAMPLE
    $standardToolsResult = [PSCustomObject]@{
        toolUseId = 'id123'
        content   = 'Elemental Hotel'
    }
    $formatAmazonNovaMessageSplat = @{
        Role         = 'user'
        ToolsResults = $standardToolsResult
        ModelID      = $_
    }
    Format-AmazonNovaMessage @formatAmazonNovaMessageSplat

    Formats a message with tools results to be sent to the Amazon Nova model.
.EXAMPLE
    $standardToolsCall = [PSCustomObject]@{
        type  = 'tool_use'
        id    = 'id123'
        name  = 'top_song'
        input = [PSCustomObject]@{
            sign = 'WZPZ'
        }
    }
    $formatAmazonNovaMessageSplat = @{
        Role     = 'assistant'
        ToolCall = $standardToolsCall
        ModelID  = $_
    }
    Format-AmazonNovaMessage @formatAmazonNovaMessageSplat

    Formats a message with a tool call to be sent to the Amazon Nova model.
.PARAMETER Role
    The role of the message sender. Valid values are 'user' or 'assistant'.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER MediaPath
    File path to local media file.
.PARAMETER S3Location
    The S3 location of the media file.
    This parameter is only supported if providing a video file to the model.
    The video file must adhere to the model's media requirements.
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
function Format-AmazonNovaMessage {
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

        # TODO: Implement S3Location for video files
        # [Parameter(Mandatory = $false,
        #     HelpMessage = 'The S3 location of the media file.',
        #     ParameterSetName = 'Standard')]
        # [ValidateNotNull()]
        # [ValidateNotNullOrEmpty()]
        # [string]$S3Location,

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
            'amazon.nova-pro-v1:0',
            'amazon.nova-lite-v1:0',
            'amazon.nova-micro-v1:0'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Amazon Nova Message'

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
                throw 'Unable to format Amazon Nova message. Failed to convert media to base64.'
            }

            Write-Verbose -Message ('Getting file info for {0}' -f $media)
            try {
                $mediaFileInfo = Get-Item -Path $media -ErrorAction Stop
            }
            catch {
                throw 'Unable to format Amazon Nova message. Failed to get media file info.'
            }

            if ($mediaFileInfo) {
                $extension = $mediaFileInfo.Extension.TrimStart('.')
                Write-Debug -Message ('Media extension: {0}' -f $extension)
            }
            else {
                throw 'Unable to format Amazon Nova message. Media extension not found.'
            }

            #region determine media type

            $script:supportedImageExtensions = @(
                'PNG'
                'JPG'
                'JPEG'
                'GIF'
                'WEBP'
            )
            $script:supportedVideoExtensions = @(
                'MP4'
                'MOV'
                'MKV'
                'WebM'
                'FLV'
                'MPEG'
                'MPG'
                'WMV'
                '3GP'
            )
            $script:supportedDocumentExtensions = @(
                'csv'
                'xls'
                'xlsx'
                'html'
                'txt'
                'md'
                'doc'
                'docx'
                'pdf'
            )

            if ($script:supportedImageExtensions -contains $extension) {
                Write-Debug -Message 'Media type is an image.'
                $obj.content += [PSCustomObject]@{
                    image = [PSCustomObject]@{
                        format = $extension
                        source = [PSCustomObject]@{
                            bytes = $base64
                        }
                    }
                }
            }
            elseif ($script:supportedVideoExtensions -contains $extension) {
                Write-Debug -Message 'Media type is a video.'
                $obj.content += [PSCustomObject]@{
                    video = [PSCustomObject]@{
                        format = $extension
                        source = [PSCustomObject]@{
                            bytes = $base64
                        }
                    }
                }
            }
            elseif ($script:supportedDocumentExtensions -contains $extension) {
                Write-Debug -Message 'Media type is a document.'
                $obj.content += [PSCustomObject]@{
                    document = [PSCustomObject]@{
                        format = $extension
                        name   = $mediaFileInfo.BaseName
                        source = [PSCustomObject]@{
                            bytes = $base64
                        }
                    }
                }
            }

            #endregion

        } #foreach_MediaPath

        if ($Message) {
            $obj.content += [PSCustomObject]@{
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
                    text = $Message
                }
            )
        }
    } #elseif_Message
    elseif ($ToolCall) {
        Write-Verbose -Message 'Formatting tool call message'
        $obj = [PSCustomObject]@{
            role    = $Role
            content = @()
        }
        # foreach tool in tool call, add to content
        foreach ($tool in $ToolCall) {
            Write-Debug -Message ('Processing tool call: {0}' -f $tool.toolUseId)
            # check for null or whitespace and only add if not
            if (-not ([string]::IsNullOrWhiteSpace($tool.toolUseId))) {
                Write-Debug -Message ('Adding tool call: {0}' -f $tool.toolUseId)
                $obj.content += [PSCustomObject]@{
                    toolUse = [PSCustomObject]@{
                        toolUseId = $tool.toolUseId
                        name      = $tool.name
                        input     = $tool.input
                    }
                }
            }
            else {
                Write-Debug -Message 'Skipping tool call with null or whitespace toolUseId'
            }
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
                if ($tool.Status -eq 'success') {
                    Write-Debug -Message ('Processing STRING success tool call: {0}' -f $tool.toolUseId)
                    $obj.content += [PSCustomObject]@{
                        toolResult = [PSCustomObject]@{
                            toolUseId = $tool.toolUseId
                            content   = @(
                                $tool.content
                            )
                            status    = 'success'
                        }
                    }
                }
                else {
                    Write-Debug -Message ('Processing STRING error tool call: {0}' -f $tool.toolUseId)
                    $obj.content += [PSCustomObject]@{
                        toolResult = [PSCustomObject]@{
                            toolUseId = $tool.toolUseId
                            content   = @() #must be null array
                            status    = 'error'
                        }
                    }
                }

            } #if_String
            else {
                # Construct a hashtable so "json" becomes a single object
                $contentHash = @{}

                if ($tool.Status -eq 'success') {
                    Write-Debug -Message ('Processing OBJECT success tool call: {0}' -f $tool.toolUseId)
                    # Populate the hashtable with each property
                    $tool.content.PSObject.Properties | ForEach-Object {
                        $contentHash[$_.Name] = $_.Value
                    }

                    # Wrap the hashtable in a PSCustomObject so it appears properly in JSON
                    $obj.content += [PSCustomObject]@{
                        toolResult = [PSCustomObject]@{
                            toolUseId = $tool.toolUseId
                            content   = @(
                                [PSCustomObject]@{
                                    json = [PSCustomObject]$contentHash
                                }
                            )
                            status    = 'success'
                        }
                    }
                }
                else {
                    Write-Debug -Message ('Processing OBJECT error tool call: {0}' -f $tool.toolUseId)
                    $obj.content += [PSCustomObject]@{
                        toolResult = [PSCustomObject]@{
                            toolUseId = $tool.toolUseId
                            content   = @() #must be null array
                            status    = 'error'
                        }
                    }
                }
            } #else_Object
        } #foreach_ToolsResults

        Write-Debug -Message ($obj.content | Out-String)

    } #elseif_ToolsResults

    Write-Debug -Message 'FINAL formatted message:'
    Write-Debug -Message ($obj | Out-String)

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        Write-Debug ($contextObj | Out-String)
        $contextObj.Context.Add($obj)
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $obj
    }

    return $returnContext

} #Format-AmazonNovaMessage
