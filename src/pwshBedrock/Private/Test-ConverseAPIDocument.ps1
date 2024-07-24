<#
.SYNOPSIS
    Tests if a document file is compatible with Converse API's requirements.
.DESCRIPTION
    Evaluates the specified document file to ensure it meets Converse API's compatibility requirements
    based on their public documentation. It checks the file's presence, type, and size. If the file is not found,
    the function returns false. If the file type is not supported, the function returns false. If the file name
    does not meet the Converse API requirements, the function returns false.
.EXAMPLE
    Test-ConverseAPIDocument -DocumentPath 'C:\path\to\document.pdf'

    Tests the document located at 'C:\path\to\document.pdf' for Converse API compatibility.
.PARAMETER MediaPath
    File path to local media file.
.OUTPUTS
    System.Boolean
.NOTES
    The name of the document can only contain the following characters:
        Alphanumeric characters
        Whitespace characters (no more than one in a row)
        Hyphens
        Parentheses
        Square brackets
    Each document's size must be no more than 4.5 MB.
.LINK
    https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference.html - document tab
.COMPONENT
    pwshBedrock
#>
function Test-ConverseAPIDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'File path to local document.')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]$DocumentPath
    )

    $result = $true # Assume success

    Write-Verbose -Message 'Verifying presence of document...'
    try {
        $pathEval = Test-Path -Path $DocumentPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying document path: {0}' -f $DocumentPath)
        Write-Error $_
        $result = $false
        return $result
    }
    if ($pathEval -ne $true) {
        Write-Warning -Message ('The specified document path: {0} was not found.' -f $PhotoPath)
        $result = $false
        return $result
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying media type...'
    $supportedMediaExtensions = @(
        'pdf'
        'csv'
        'doc'
        'docx'
        'xls'
        'xlsx'
        'html'
        'txt'
        'md'
    )
    Write-Verbose -Message ('Splitting document path: {0}' -f $DocumentPath)
    $divide = $DocumentPath.Split('.')
    $rawExtension = $divide[$divide.Length - 1]
    $extension = $rawExtension.ToUpper()
    Write-Verbose -Message "Verifying discovered extension: $extension"
    if ($supportedMediaExtensions -notcontains $extension) {
        Write-Warning -Message ('The specified document type: {0} is not supported.' -f $extension)
        $result = $false
        return $result
    } #if_supportedMediaExtensions
    else {
        Write-Verbose -Message 'Document type verified.'
    } #else_supportedMediaExtensions

    Write-Verbose -Message 'Verifying document file size...'
    try {
        $mediaFileInfo = Get-Item -Path $DocumentPath -ErrorAction Stop
    }
    catch {
        Write-Error ('Error verifying document file info: {0}' -f $DocumentPath)
        Write-Error $_
        $result = $false
        return $result
    }

    $mediaSize = $mediaFileInfo.Length
    if ($mediaSize -gt 4.5MB) {
        Write-Warning -Message ('The specified document size: {0} exceeds the Converse API maximum allowed document file size of 4.5MB.' -f $mediaSize)
        $result = $false
        return $result
    } #if_mediaSize
    else {
        Write-Verbose -Message 'Document size verified.'
    } #else_mediaSize


    Write-Verbose -Message 'Verifying document file name...'
    $documentName = $mediaFileInfo.BaseName
    Write-Debug -Message ('Document base name: {0}' -f $documentName)
    if ($documentName -notmatch '^[a-zA-Z0-9\-\(\)\[\]]+(\s[a-zA-Z0-9\-\(\)\[\]]+)*$') {
        Write-Warning -Message ('The specified document name: {0} contains invalid characters.' -f $documentName)
        $result = $false
        return $result
    }

    return $result

} #Test-ConverseAPIDocument
