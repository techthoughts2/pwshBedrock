<#
.SYNOPSIS
    Tests if a media file is compatible with Meta's requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Meta's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Meta's recommendations, the function returns true but issues a warning.
.EXAMPLE
    Test-MetaMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Meta compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Meta can read both text and images in requests.
    Supported base64 source type for images:
    image/jpeg, image/png, image/gif, and image/webp media types.

    For optimal performance, we recommend resizing your images before uploading if they are likely to exceed size
    or token limits. Images larger than 1568 pixels on any edge or exceeding ~1600 tokens will be scaled down,
    which may increase latency. Very small images under 200 pixels on any edge may lead to degraded performance.

    https://old.reddit.com/r/LocalLLaMA/comments/1fqawht/llama_32_vision_models_image_pixel_limits/
    1120x1120 is the max supported image size.
.COMPONENT
    pwshBedrock
#>
function Test-MetaMedia {
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
    if ($mediaSize -gt 5MB) {
        Write-Warning -Message ('The specified media size: {0} exceeds the Meta maximum allowed image file size of 5MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Media size verified.'
    } #else_mediaSize


    Write-Verbose -Message 'Verifying media resolution...'
    $resolution = Get-ImageResolution -MediaPath $MediaPath

    if ($resolution.Width -gt 1120 -or $resolution.Height -gt 1120) {
        Write-Warning -Message ('The specified media size: {0}x{1} exceeds the Meta recommendation to keep the long edge of the image below 1120.' -f $width, $height)
        $result = $false
        return $result
    } #if_size

    return $result

} #Test-MetaMedia
