<#
.SYNOPSIS
    Tests if an video file is compatible with Converse API's requirements.
.DESCRIPTION
    Evaluates the specified video file to ensure it meets Converse API's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Converse API's recommendations, the function returns false.
.EXAMPLE
    Test-ConverseAPIVideo -VideoPath 'C:\path\to\video.mp4'

    Tests the video located at 'C:\path\to\video.mp4' for Converse API compatibility.
.PARAMETER VideoPath
    File path to local video file.
.OUTPUTS
    System.Boolean
.NOTES
    Supported base64 source type for videos:
    Valid Values: mkv | mov | mp4 | webm | flv | mpeg | mpg | wmv | three_gp
    A video source. You can upload a smaller video as a base64-encoded string as long as the encoded file is less than 25MB. You can also transfer videos up to 1GB in size from an S3 bucket.
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html - video tab
.LINK
    https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ContentBlockDeltaEvent.html
.LINK
    https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_VideoSource.html
.COMPONENT
    pwshBedrock
#>
function Test-ConverseAPIVideo {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
        Justification = 'Just a collective noun.')]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local video file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$VideoPath
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Verifying presence of video...'
    try {
        $pathEval = Test-Path -Path $VideoPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying video path: {0}' -f $VideoPath)
        Write-Error $_
        $result = $false
        return $result
    }
    if ($pathEval -ne $true) {
        Write-Warning -Message ('The specified video path: {0} was not found.' -f $PhotoPath)
        $result = $false
        return $result
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying video type...'
    $supportedMediaExtensions = @(
        'MKV'
        'MOV'
        'MP4'
        'WEBM'
        'FLV'
        'MPEG'
        'MPG'
        'WMV'
        '3GP'
    )
    Write-Verbose -Message ('Splitting video path: {0}' -f $VideoPath)
    $divide = $VideoPath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message "Verifying discovered extension: $extension"
    if ($supportedMediaExtensions -notcontains $extension) {
        Write-Warning -Message ('The specified video type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
    } #if_supportedMediaExtensions
    else {
        Write-Verbose -Message 'video type verified.'
    } #else_supportedMediaExtensions

    Write-Verbose -Message 'Verifying video file size...'
    try {
        $mediaFileInfo = Get-Item -Path $VideoPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying video file info: {0}' -f $VideoPath)
        Write-Error $_
        $result = $false
        return $result
    }

    $mediaSize = $mediaFileInfo.Length
    if ($mediaSize -gt 25MB) {
        Write-Warning -Message ('The specified video size: {0} exceeds the Converse API maximum allowed video file size of 25MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'video size verified.'
    } #else_mediaSize

    return $result

} #Test-ConverseAPIVideo
