<#
.SYNOPSIS
    Tests if a media file is compatible with Converse API's requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Converse API's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Converse API's recommendations, the function returns false.
.EXAMPLE
    Test-ConverseAPIMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Converse API compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Each image's size, height, and width must be no more than 3.75 MB, 8,000 px, and 8,000 px, respectively.
    Supported base64 source type for images:
    image/jpeg, image/png, image/gif, and image/webp media types.
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html - image tab
.COMPONENT
    pwshBedrock
#>
function Test-ConverseAPIMedia {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
        Justification = 'Just a collective noun.')]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Verifying presence of media...'
    try {
        $pathEval = Test-Path -Path $MediaPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying media path: {0}' -f $MediaPath)
        Write-Error $_
        $result = $false
        return $result
    }
    if ($pathEval -ne $true) {
        Write-Warning -Message ('The specified media path: {0} was not found.' -f $PhotoPath)
        $result = $false
        return $result
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying media type...'
    $supportedMediaExtensions = @(
        'JPG'
        'JPEG'
        'PNG'
        'GIF'
        'WEBP'
    )
    Write-Verbose -Message ('Splitting media path: {0}' -f $MediaPath)
    $divide = $MediaPath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message "Verifying discovered extension: $extension"
    if ($supportedMediaExtensions -notcontains $extension) {
        Write-Warning -Message ('The specified media type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
    } #if_supportedMediaExtensions
    else {
        Write-Verbose -Message 'Media type verified.'
    } #else_supportedMediaExtensions

    Write-Verbose -Message 'Verifying media file size...'
    try {
        $mediaFileInfo = Get-Item -Path $MediaPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying media file info: {0}' -f $MediaPath)
        Write-Error $_
        $result = $false
        return $result
    }

    $mediaSize = $mediaFileInfo.Length
    if ($mediaSize -gt 3.75MB) {
        Write-Warning -Message ('The specified media size: {0} exceeds the Converse API maximum allowed image file size of 3.75MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Media size verified.'
    } #else_mediaSize


    Write-Verbose -Message 'Verifying media resolution...'
    $resolution = Get-ImageResolution -MediaPath $MediaPath

    if ($resolution.Width -gt 8000 -or $resolution.Height -gt 8000) {
        Write-Warning -Message ('The specified media size: {0}x{1} exceeds the Converse API requirement height and width must be no more than 8,000 px, and 8,000 px, respectively.' -f $width, $height)
        $result = $false
        return $result
    } #if_size

    return $result

} #Test-ConverseAPIMedia
