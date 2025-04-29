<#
.SYNOPSIS
    Formats a message to be sent to the Converse API.
.DESCRIPTION
    This function formats a message to be sent to the Converse API.
.EXAMPLE
    Format-ConverseAPI -Role 'User' -Message 'Hello, how are you?' -ModelID 'Converse'

    This example formats a message to be sent to the Converse API.
.EXAMPLE
    $toolResult = [PSCustomObject]@{
        ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
        Content   = [PSCustomObject]@{
            restaurant = [PSCustomObject]@{
                name    = 'Gristmill River Restaurant & Bar'
                address = '1287 Gruene Rd, New Braunfels, TX 78130'
                rating  = '4.5'
                cuisine = 'American'
                budget  = '2'
            }
        }
        status    = 'success'
    }
    $formatConverseAPISplat = @{
        Role         = 'user'
        ToolsResults = $toolResult
        ModelID      = 'Converse'
    }
    $result = Format-ConverseAPI @formatConverseAPISplat
.PARAMETER Role
    The role of the message sender.
.PARAMETER Message
    The message to be sent to the model.
.PARAMETER ImagePath
    File path to local image file.
.PARAMETER VideoPath
    File path to local video file.
.PARAMETER DocumentPath
    File path to local document.
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
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/NBedrockRuntimeModel.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/?page=TMessage.html&tocid=Amazon_BedrockRuntime_Model_Message
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TContentBlock.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TToolResultBlock.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/Runtime/TDocument.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/items/BedrockRuntime/TImageBlock.html
.LINK
    https://docs.aws.amazon.com/sdkfornet/v3/apidocs/?page=TDocumentBlock.html&tocid=Amazon_BedrockRuntime_Model_DocumentBlock
.COMPONENT
    pwshBedrock
#>
function Format-ConverseAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The role of the message sender.')]
        [ValidateSet('user', 'assistant')]
        [string]$Role,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message to be sent to the model.')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local image file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$ImagePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local video file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local document.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$DocumentPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'The message construct returned by the model.')]
        [Amazon.BedrockRuntime.Model.Message]$ReturnMessage,

        [Parameter(Mandatory = $false,
            HelpMessage = 'A list of results from invoking tools recommended by the model in the previous chat turn.')]
        [ValidateNotNull()]
        [object]$ToolsResults,

        # [Parameter(Mandatory = $false,
        #     HelpMessage = 'The tool calls that were returned by the model.')]
        # [ValidateNotNullOrEmpty()]
        # [object[]]$ToolCalls,

        [Parameter(Mandatory = $true,
            HelpMessage = 'The unique identifier of the model.')]
        [ValidateSet(
            'Converse'
        )]
        [string]$ModelID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Do not persist the conversation context history.')]
        [bool]$NoContextPersist = $false
    )

    Write-Verbose -Message 'Formatting Converse Message'

    switch ($Role) {
        'user' {
            if ($ToolsResults) {

                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'user'
                $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()

                $toolResultBlock = [Amazon.BedrockRuntime.Model.ToolResultBlock]::new()
                $toolResultBlock.Status = $ToolsResults.Status
                $toolResultBlock.ToolUseId = $ToolsResults.ToolUseId

                $toolResultContentBlock = [Amazon.BedrockRuntime.Model.ToolResultContentBlock]::new()

                if ($ToolsResults.Status -eq 'error') {
                    $toolResultContentBlock.Text = $ToolsResults.Content
                }
                else {
                    $toolResultContentBlock.Json = [Amazon.Runtime.Documents.Document]::FromObject($ToolsResults.Content)
                }

                $toolResultBlock.Content = $toolResultContentBlock

                $messageContentBlock.ToolResult = $toolResultBlock

                $messageObj.Content = $messageContentBlock
            }
            elseif ($ImagePath) {
                Write-Verbose -Message 'Formatting image vision message'

                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'user'

                foreach ($media in $ImagePath) {
                    #____________________
                    # resets
                    $memoryStream = $null
                    $mediaFileInfo = $null
                    $extension = $null
                    $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $imageBlock = $null
                    $imageFormat = $null
                    $imageSource = $null
                    #____________________

                    Write-Verbose -Message 'Converting image media to memory stream'
                    try {
                        $memoryStream = Convert-MediaToMemoryStream -MediaPath $media -ErrorAction Stop
                    }
                    catch {
                        throw 'Unable to format Converse API vision message. Unable to convert image media to memory stream.'
                    }

                    Write-Verbose -Message ('Getting file info for {0}' -f $media)
                    try {
                        $mediaFileInfo = Get-Item -Path $media -ErrorAction Stop
                    }
                    catch {
                        throw 'Unable to format Converse API vision message. Failed to get image media file info.'
                    }

                    Write-Verbose -Message ('Getting file extension for {0}' -f $media)
                    if ($mediaFileInfo) {
                        $extension = $mediaFileInfo.Extension.TrimStart('.')
                        # special case
                        if ($extension -eq 'jpg') {
                            $extension = 'jpeg'
                        }
                        Write-Debug -Message ('Media extension: {0}' -f $extension)
                    }
                    else {
                        throw 'Unable to format Converse API vision message. Image Media extension not found.'
                    }

                    $imageBlock = [Amazon.BedrockRuntime.Model.ImageBlock]::new()
                    $imageFormat = [Amazon.BedrockRuntime.ImageFormat]::new($extension)
                    $imageSource = [Amazon.BedrockRuntime.Model.ImageSource]::new()
                    $imageSource.Bytes = $memoryStream
                    $imageBlock.Format = $imageFormat
                    $imageBlock.Source = $imageSource

                    $messageContentBlock.Image = $imageBlock

                    $messageObj.Content.Add($messageContentBlock)

                } #foreach_MediaPath


                if ($Message) {
                    $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $messageContentBlock.Text = $Message
                    $messageObj.Content.Add($messageContentBlock)
                }

            } #if_ImagePath
            elseif ($VideoPath) {
                Write-Verbose -Message 'Formatting video vision message'

                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'user'

                Write-Verbose -Message 'Converting video media to memory stream'
                try {
                    $memoryStream = Convert-MediaToMemoryStream -MediaPath $VideoPath -ErrorAction Stop
                }
                catch {
                    throw 'Unable to format Converse API vision message. Unable to convert video media to memory stream.'
                }

                Write-Verbose -Message ('Getting file info for {0}' -f $VideoPath)
                try {
                    $mediaFileInfo = Get-Item -Path $VideoPath -ErrorAction Stop
                }
                catch {
                    throw 'Unable to format Converse API vision message. Failed to get video media file info.'
                }

                Write-Verbose -Message ('Getting file extension for {0}' -f $VideoPath)
                if ($mediaFileInfo) {
                    $extension = $mediaFileInfo.Extension.TrimStart('.')
                    # special case
                    Write-Debug -Message ('Media extension: {0}' -f $extension)
                }
                else {
                    throw 'Unable to format Converse API vision message. Video Media extension not found.'
                }

                $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()

                $videoBlock = [Amazon.BedrockRuntime.Model.VideoBlock]::new()
                $videoFormat = [Amazon.BedrockRuntime.VideoFormat]::new($extension)
                $videoSource = [Amazon.BedrockRuntime.Model.VideoSource]::new()
                $videoSource.Bytes = $memoryStream
                $videoBlock.Format = $videoFormat
                $videoBlock.Source = $videoSource

                $messageContentBlock.Video = $videoBlock

                $messageObj.Content.Add($messageContentBlock)

            } #elseif_videoPath
            elseif ($DocumentPath) {
                Write-Verbose -Message 'Formatting document message'

                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'user'

                foreach ($document in $DocumentPath) {
                    #____________________
                    # resets
                    $memoryStream = $null
                    $documentFileInfo = $null
                    $extension = $null
                    $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $imageBlock = $null
                    $imageFormat = $null
                    $imageSource = $null
                    #____________________

                    Write-Verbose -Message 'Converting document to memory stream'
                    try {
                        $memoryStream = Convert-MediaToMemoryStream -MediaPath $document -ErrorAction Stop
                    }
                    catch {
                        throw 'Unable to format Converse API document message. Unable to convert document to memory stream.'
                    }

                    Write-Verbose -Message ('Getting file info for {0}' -f $document)
                    try {
                        $documentFileInfo = Get-Item -Path $document -ErrorAction Stop
                    }
                    catch {
                        throw 'Unable to format Converse API document message. Failed to get document file info.'
                    }

                    Write-Verbose -Message ('Getting file extension for {0}' -f $document)
                    if ($documentFileInfo) {
                        $extension = $documentFileInfo.Extension.TrimStart('.')
                        # special case
                        Write-Debug -Message ('Media extension: {0}' -f $extension)
                    }
                    else {
                        throw 'Unable to format Converse API document message. Document extension not found.'
                    }

                    $documentBlock = [Amazon.BedrockRuntime.Model.DocumentBlock]::new()
                    $documentFormat = [Amazon.BedrockRuntime.DocumentFormat]::new($extension)
                    $documentSource = [Amazon.BedrockRuntime.Model.DocumentSource]::new()
                    $documentSource.Bytes = $memoryStream
                    $documentBlock.Format = $documentFormat
                    $documentBlock.Name = $documentFileInfo.BaseName
                    $documentBlock.Source = $documentSource

                    $messageContentBlock.Document = $documentBlock

                    $messageObj.Content.Add($messageContentBlock)

                } #foreach_MediaPath


                if ($Message) {
                    $messageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                    $messageContentBlock.Text = $Message
                    $messageObj.Content.Add($messageContentBlock)
                }

            }
            else {
                $messageObj = [Amazon.BedrockRuntime.Model.Message]::new()
                $messageObj.Role = 'user'
                $content = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                $content.Text = $Message
                $messageObj.Content = $content
            }
        }
        'assistant' {
            $messageObj = $ReturnMessage
        }
    } #switch_role

    Write-Debug -Message ('Formatted message: {0}' -f ($messageObj | Out-String) )
    Write-Debug -Message ('Formatted message Content: {0}' -f ($messageObj.Content | Out-String) )

    if ($NoContextPersist -eq $false) {
        $contextObj = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $ModelID }
        $contextObj.Context.Add($messageObj)
        $returnContext = $contextObj.Context
    }
    else {
        $returnContext = $messageObj
    }
    Write-Debug 'out of Format-ConverseAPI'
    return $returnContext

} #Format-ConverseAPI
