<#
.SYNOPSIS
    Tests if a media file is compatible with Mistral's requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Mistral's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Mistral's recommendations, the function returns true but issues a warning.
.EXAMPLE
    Test-MistralMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Mistral compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    We currently support the following image formats:

    PNG (.png)
    JPEG (.jpeg and .jpg)
    WEBP (.webp)
    Non-animated GIF with only one frame (.gif)

    The current file size limit is 10Mb.
.COMPONENT
    pwshBedrock
#>
function Test-MistralMedia {
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
    if ($mediaSize -gt 10MB) {
        Write-Warning -Message ('The specified media size: {0} exceeds the Mistral maximum allowed image file size of 10MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Media size verified.'
    } #else_mediaSize


    # Write-Verbose -Message 'Verifying media resolution...'
    # $resolution = Get-ImageResolution -MediaPath $MediaPath

    # if ($resolution.Width -gt 1568 -or $resolution.Height -gt 1568) {
    #     Write-Warning -Message ('The specified media size: {0}x{1} exceeds the Mistral recommendation to keep the long edge of the image below 1568.' -f $width, $height)
    #     Write-Warning -Message 'The image will be scaled down to meet the size requirements.'
    #     Write-Warning -Message 'Scaling down the image may increase latency of time-to-first-token, without giving you any additional model performance.'
    # } #if_size

    return $result

} #Test-MistralMedia
