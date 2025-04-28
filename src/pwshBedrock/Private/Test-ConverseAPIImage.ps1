# filepath: c:\Users\jakew\OneDrive\Desktop\Project\0_CodeProject\1_git\pwshBedrock\src\pwshBedrock\Private\Test-ConverseAPIImage.ps1
<#
.SYNOPSIS
    Tests if an image file is compatible with Converse API's requirements.
.DESCRIPTION
    Evaluates the specified image file to ensure it meets Converse API's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Converse API's recommendations, the function returns false.
.EXAMPLE
    Test-ConverseAPIImage -ImagePath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Converse API compatibility.
.PARAMETER ImagePath
    File path to local image file.
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
function Test-ConverseAPIImage {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '',
        Justification = 'Just a collective noun.')]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local image file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Verifying presence of image...'
    try {
        $pathEval = Test-Path -Path $ImagePath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying image path: {0}' -f $ImagePath)
        Write-Error $_
        $result = $false
        return $result
    }
    if ($pathEval -ne $true) {
        Write-Warning -Message ('The specified image path: {0} was not found.' -f $PhotoPath)
        $result = $false
        return $result
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying image type...'
    $supportedMediaExtensions = @(
        'JPG'
        'JPEG'
        'PNG'
        'GIF'
        'WEBP'
    )
    Write-Verbose -Message ('Splitting image path: {0}' -f $ImagePath)
    $divide = $ImagePath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message "Verifying discovered extension: $extension"
    if ($supportedMediaExtensions -notcontains $extension) {
        Write-Warning -Message ('The specified image type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
    } #if_supportedMediaExtensions
    else {
        Write-Verbose -Message 'Image type verified.'
    } #else_supportedMediaExtensions

    Write-Verbose -Message 'Verifying image file size...'
    try {
        $mediaFileInfo = Get-Item -Path $ImagePath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying image file info: {0}' -f $ImagePath)
        Write-Error $_
        $result = $false
        return $result
    }

    $mediaSize = $mediaFileInfo.Length
    if ($mediaSize -gt 3.75MB) {
        Write-Warning -Message ('The specified image size: {0} exceeds the Converse API maximum allowed image file size of 3.75MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Image size verified.'
    } #else_mediaSize


    Write-Verbose -Message 'Verifying image resolution...'
    $resolution = Get-ImageResolution -MediaPath $ImagePath

    if ($resolution.Width -gt 8000 -or $resolution.Height -gt 8000) {
        Write-Warning -Message ('The specified image size: {0}x{1} exceeds the Converse API requirement height and width must be no more than 8,000 px, and 8,000 px, respectively.' -f $width, $height)
        $result = $false
        return $result
    } #if_size

    return $result

} #Test-ConverseAPIImage
