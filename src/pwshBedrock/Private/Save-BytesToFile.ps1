<#
.SYNOPSIS
    Saves bytes to a file.
.DESCRIPTION
    This function saves bytes to a file using the System.IO.File namespace.
    It writes the bytes to the specified file path.
.EXAMPLE
    Save-BytesToFile -Base64String $base64

    Converts the base64 string to bytes.
.PARAMETER ImageBytes
    Image bytes to save to a media file.
.PARAMETER FilePath
    File path to save the image file.
.OUTPUTS
    None
.NOTES
    This function is a wrapper around the System.IO.File namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Save-BytesToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Image bytes to save to a media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [byte[]]$ImageBytes,

        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to save the image file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath
    )

    Write-Verbose -Message 'Converting from base64'
    try {
        [System.IO.File]::WriteAllBytes($FilePath, $ImageBytes)
    }
    catch {
        Write-Warning -Message 'Failed to output bytes to file'
        throw
    }

    Write-Debug -Message 'Out of Save-BytesToFile'
} #Save-BytesToFile
