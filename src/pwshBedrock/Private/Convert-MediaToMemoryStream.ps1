<#
.SYNOPSIS
    Converts a media file to a MemoryStream.
.DESCRIPTION
    Reads the bytes of a media file and converts them to a MemoryStream.
.EXAMPLE
    Convert-MediaToMemoryStream -MediaPath 'C:\path\to\image.jpg'

    This example reads the bytes of the image.jpg file and converts them to a MemoryStream.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.String
.NOTES
    This function is a wrapper around the System.IO.File namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Convert-MediaToMemoryStream {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local media file.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$MediaPath
    )

    Write-Verbose -Message ('Reading Bytes for {0}' -f $MediaPath)
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($MediaPath)
    }
    catch {
        Write-Warning -Message ('Failed to get Bytes for {0}' -f $MediaPath)
        throw
    }

    if ($fileBytes) {
        Write-Debug -Message ('Converting Bytes to MemoryStream for {0}' -f $MediaPath)
        $memoryStream = [System.IO.MemoryStream]::new()
        $memoryStream.Write($fileBytes, 0, $fileBytes.Length)
    }
    else {
        Write-Warning -Message ('No file bytes were returned for {0}' -f $MediaPath)
        throw
    }
    return $memoryStream
} #Convert-MediaToMemoryStream
