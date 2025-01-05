<#
.SYNOPSIS
    Tests if a media file is compatible with Amazon Nova's requirements.
.DESCRIPTION
    Evaluates the specified media file to ensure it meets Amazon Nova's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file resolution
    exceeds Amazon Nova's recommendations, the function returns true but issues a warning.
.EXAMPLE
    Test-AmazonNovaMedia -MediaPath 'C:\path\to\image.jpg'

    Tests the image located at 'C:\path\to\image.jpg' for Amazon Nova compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    Amazon Nova models allow you to include multiple images in the payload with a limitation of total payload size to not go beyond 25MB
.COMPONENT
    pwshBedrock
#>
function Test-AmazonNovaMedia {
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
    $mediaType = ''

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
    $supportedImageExtensions = @(
        'PNG'
        'JPG'
        'JPEG'
        'GIF'
        'WEBP'
    )
    $supportedVideoExtensions = @(
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
    $supportedDocumentExtensions = @(
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
    Write-Verbose -Message ('Splitting media path: {0}' -f $MediaPath)
    $divide = $MediaPath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message ('Verifying discovered extension: {0}' -f $extension)

    if ($supportedImageExtensions -contains $extension) {
        Write-Debug -Message 'Media type is an image.'
        $mediaType = 'image'
    }
    elseif ($supportedVideoExtensions -contains $extension) {
        Write-Debug -Message 'Media type is a video.'
        $mediaType = 'video'
    }
    elseif ($supportedDocumentExtensions -contains $extension) {
        Write-Debug -Message 'Media type is a document.'
        $mediaType = 'document'
    }
    else {
        Write-Warning -Message ('The specified media type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
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
    Write-Debug -Message ('Media size: {0} bytes' -f $mediaSize)

    switch ($mediaType) {
        'image' {
            $permittedSize = 25MB
        }
        'video' {
            $permittedSize = 25MB
        }
        'document' {
            $permittedSize = 4.5MB
        }
    }
    Write-Debug -Message ('Permitted size: {0} bytes' -f $permittedSize)

    if ($mediaSize -gt $permittedSize) {
        Write-Warning -Message ('The specified media size: {0} exceeds the Amazon Nova maximum allowed image file size for {1} of {2}.' -f $mediaSize, $extension, $permittedSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Media size verified.'
    } #else_mediaSize

    # Write-Verbose -Message 'Verifying media resolution...'
    # $resolution = Get-ImageResolution -MediaPath $MediaPath

    # if ($resolution.Width -gt 1568 -or $resolution.Height -gt 1568) {
    #     Write-Warning -Message ('The specified media size: {0}x{1} exceeds the Amazon Nova recommendation to keep the long edge of the image below 1568.' -f $width, $height)
    #     Write-Warning -Message 'The image will be scaled down to meet the size requirements.'
    #     Write-Warning -Message 'Scaling down the image may increase latency of time-to-first-token, without giving you any additional model performance.'
    # } #if_size

    return $result

} #Test-AmazonNovaMedia
