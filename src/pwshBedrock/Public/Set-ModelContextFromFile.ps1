<#
.SYNOPSIS
    Loads and sets the message context for a model from a file.
.DESCRIPTION
    This function loads and sets the message context for a model from a file.
    It allows you to maintain a continuous conversation with the model by reloading previously saved context history.
    If you have saved the context history using Save-ModelContext, you can reload it using this function.
    This will overwrite the current context for the model, enabling you to continue the conversation from where you left off.
.EXAMPLE
    Set-ModelContextFromFile -FilePath 'C:\temp\context.xml'

    Sets the message context for the specified model from a file.
.PARAMETER FilePath
    File path to retrieve model context from.
.PARAMETER Force
    Skip Confirmation
.OUTPUTS
    None
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    This function only supports loading context from files saved using Save-ModelContext.
    Use this function to reload model context previously saved with Save-ModelContext.
.COMPONENT
    pwshBedrock
.LINK
    https://www.pwshbedrock.dev/en/latest/Set-ModelContextFromFile/
#>
function Set-ModelContextFromFile {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    param (
        [ValidateScript({
                if (-Not ($_ | Test-Path -PathType Leaf)) {
                    throw 'The Path argument must be a file. Folder paths are not allowed.'
                }
                if (-Not ($_ | Test-Path)) {
                    throw 'File or folder does not exist'
                }
                return $true
            })]
        [Parameter(Mandatory = $true,
            HelpMessage = 'File path to retrieve model context from.')]
        [string]$FilePath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip confirmation')]
        [switch]$Force
    )

    Begin {

        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }

        Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
        Write-Verbose -Message ('ParameterSetName: {0}' -f $PSCmdlet.ParameterSetName)
    } #begin

    Process {

        Write-Verbose -Message 'Processing Set-ModelContextFromFile'

        Write-Verbose -Message ('Loading context from {0}' -f $FilePath)

        try {
            $rawXML = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        }
        catch {
            Write-Error ('Error reading file {0}: {1}' -f $FilePath, $_.Exception.Message)
            throw $_
        }

        if ($null -eq $rawXML) {
            throw ('{0} returned null content' -f $FilePath)
        }

        try {
            $contextObj = ConvertFrom-Clixml -String $rawXML -ErrorAction Stop
        }
        catch {
            Write-Error ('Error converting XML from {0}: {1}' -f $FilePath, $_.Exception.Message)
            throw $_
        }

        Write-Verbose 'Validating context object'
        if ($null -eq $contextObj -or $null -eq $contextObj.ModelID -or $null -eq $contextObj.Context) {
            throw ('{0} returned a null object when converting from XML' -f $FilePath)
        }

        Write-Verbose -Message ('Validating ModelID {0} is supported' -f $contextObj.ModelID)
        $allModelIDs = (Get-ModelInfo -AllModels).ModelID
        if ($allModelIDs -notcontains $contextObj.ModelID) {
            throw ('ModelID {0} not found in the list of supported models' -f $contextObj.ModelID)
        }

        $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq $contextObj.ModelID }
        if ($Force -or $PSCmdlet.ShouldProcess($contextObj.ModelID, 'Set-ModelContextFromFile')) {
            Write-Verbose -Message ('Resetting message context for {0}' -f $contextObj.ModelID)
            $context.Context = $contextObj.Context
        }
    }
    End {
        Write-Verbose -Message 'Set-ModelContextFromFile complete'
    }

} #Set-ModelContextFromFile
