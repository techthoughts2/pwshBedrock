<#
.SYNOPSIS
    Get the file extension from an S3 URI.
.DESCRIPTION
    This function extracts the file extension from a given S3 URI. It handles various formats of S3 URIs and returns the extension without the leading dot.
    If the URI is invalid or does not contain an extension, it returns $null.
.EXAMPLE
    Get-S3Extension -S3Location 's3://my-bucket/path/to/file.png'

    Returns 'png'
.PARAMETER S3Location
    The S3 URI from which to extract the file extension.
    This parameter is mandatory and should be a valid S3 URI.
    If the URI is invalid or does not contain an extension, $null will be returned.
.OUTPUTS
    System.String or $null
.NOTES
    This function is a wrapper around the System.Drawing namespace, which is not mockable in tests.
.COMPONENT
    pwshBedrock
#>
function Get-S3Extension {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'The S3 URI from which to extract the file extension.')]
        [ValidateNotNullOrEmpty()]
        [string]$S3Location
    )

    if (-not $S3Location) {
        Write-Error 'S3 URI cannot be empty'
        return $null
    }

    Write-Debug -Message ('Extracting file extension from S3 URI: {0}' -f $S3Location)

    try {
        # Extract the object key from the S3 URI
        $uri = [System.Uri]$S3Location
        $objectKey = $uri.AbsolutePath.TrimStart('/')

        # Find the last dot in the object key
        $lastDotIndex = $objectKey.LastIndexOf('.')        # If no dot is found, return null
        if ($lastDotIndex -eq -1) {
            return $null
        }

        # Extract the extension (without the dot)
        $extension = $objectKey.Substring($lastDotIndex + 1)

        Write-Debug -Message ('Extracted extension: {0}' -f $extension)

        return $extension
    }
    catch {
        Write-Error $_
        return $null
    }

} #Get-S3Extension
