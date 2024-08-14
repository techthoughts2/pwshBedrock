BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Invoke-AmazonImageModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Test-AmazonMedia -MockWith { $true }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64-encoded-image' }
                Mock -CommandName Test-ColorHex -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "images": [
        "base64-encoded-image-1",
        "base64-encoded-image-2"
    ],
    "error": null
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "images": [
        "base64-encoded-image-1",
        "base64-encoded-image-2"
    ],
    "error": null
}
'@
                } #endMock
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                [byte[]]$bytes = 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
                Mock -CommandName Convert-FromBase64ToByte -MockWith { $bytes }
                Mock -CommandName Save-BytesToFile -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
            } #beforeEach

            It 'should throw if ImagesSavePath is a file instead of a directory' {
                Mock -CommandName Test-Path -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images\image.jpeg'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if ImagesSavePath is not a valid path' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                }
                Mock -CommandName Test-Path -MockWith $mockInvoke
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images\doesnotexist'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'NotSupported'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if INPAINTING is specified but neither InPaintMaskPrompt nor InPaintMaskImagePath is provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath   = 'C:\images'
                        InPaintImagePath = 'C:\images\image.jpeg'
                        ModelID          = 'amazon.titan-image-generator-v1'
                        ProfileName      = 'default'
                        Region           = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if INPAINTING is specified and both InPaintMaskPrompt and InPaintMaskImagePath are provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath       = 'C:\images'
                        InPaintImagePath     = 'C:\images\image.jpeg'
                        InPaintTextPrompt    = 'Make it darker'
                        InPaintMaskPrompt    = 'The area around the starship'
                        InPaintMaskImagePath = 'C:\images\mask.jpeg'
                        ModelID              = 'amazon.titan-image-generator-v1'
                        ProfileName          = 'default'
                        Region               = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for INPAINTING if a main image is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonMedia -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath    = 'C:\images'
                        InPaintImagePath  = 'C:\images\image.jpeg'
                        InPaintTextPrompt = 'Make it darker'
                        InPaintMaskPrompt = 'The area around the starship'
                        ModelID           = 'amazon.titan-image-generator-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for INPAINTING if a mask image is provided that is not supported by the model' {
                $script:mockCalled = 0
                Mock -CommandName Test-AmazonMedia -MockWith {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                } #endMock
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath       = 'C:\images'
                        InPaintImagePath     = 'C:\images\image.jpeg'
                        InPaintTextPrompt    = 'Make it darker'
                        InPaintMaskImagePath = 'C:\images\mask.jpeg'
                        ModelID              = 'amazon.titan-image-generator-v1'
                        ProfileName          = 'default'
                        Region               = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for INPAINTING if there is an error converting the main image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath    = 'C:\images'
                        InPaintImagePath  = 'C:\images\image.jpeg'
                        InPaintTextPrompt = 'Make it darker'
                        InPaintMaskPrompt = 'The area around the starship'
                        ModelID           = 'amazon.titan-image-generator-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for INPAINTING if there is an error converting the mask image to base64' {
                $script:mockCalled = 0
                Mock -CommandName Convert-MediaToBase64 -MockWith {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return 'base64-encoded-image'
                    }
                    elseif ($script:mockCalled -eq 2) {
                        throw 'Error'
                    }
                } #endMock

                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath       = 'C:\images'
                        InPaintImagePath     = 'C:\images\image.jpeg'
                        InPaintMaskImagePath = 'C:\images\mask.jpeg'
                        ModelID              = 'amazon.titan-image-generator-v1'
                        ProfileName          = 'default'
                        Region               = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if OUTPAINTING is specified but neither OutPaintMaskPrompt nor OutPaintMaskImagePath is provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath     = 'C:\images'
                        OutPaintImagePath  = 'C:\images\image.jpeg'
                        OutPaintTextPrompt = 'Make it darker'
                        ModelID            = 'amazon.titan-image-generator-v1'
                        ProfileName        = 'default'
                        Region             = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if OUTPAINTING is specified and both OutPaintMaskPrompt and OutPaintMaskImagePath are provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        OutPaintImagePath     = 'C:\images\image.jpeg'
                        OutPaintTextPrompt    = 'Make it darker'
                        OutPaintMaskPrompt    = 'The area around the starship'
                        OutPaintMaskImagePath = 'C:\images\mask.jpeg'
                        ModelID               = 'amazon.titan-image-generator-v1'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for OUTPAINTING if a main image is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonMedia -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath     = 'C:\images'
                        OutPaintImagePath  = 'C:\images\image.jpeg'
                        OutPaintTextPrompt = 'Make it darker'
                        OutPaintMaskPrompt = 'The area around the starship'
                        ModelID            = 'amazon.titan-image-generator-v1'
                        ProfileName        = 'default'
                        Region             = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for OUTPAINTING if a mask image is provided that is not supported by the model' {
                $script:mockCalled = 0
                Mock -CommandName Test-AmazonMedia -MockWith {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                } #endMock
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        OutPaintImagePath     = 'C:\images\image.jpeg'
                        OutPaintMaskImagePath = 'C:\images\mask.jpeg'
                        OutPaintTextPrompt    = 'Make it darker'
                        ModelID               = 'amazon.titan-image-generator-v1'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for OUTPAINTING if there is an error converting the main image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath     = 'C:\images'
                        OutPaintImagePath  = 'C:\images\image.jpeg'
                        OutPaintTextPrompt = 'Make it darker'
                        OutPaintMaskPrompt = 'The area around the starship'
                        ModelID            = 'amazon.titan-image-generator-v1'
                        ProfileName        = 'default'
                        Region             = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for OUTPAINTING if there is an error converting the mask image to base64' {
                $script:mockCalled = 0
                Mock -CommandName Convert-MediaToBase64 -MockWith {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return 'base64-encoded-image'
                    }
                    elseif ($script:mockCalled -eq 2) {
                        throw 'Error'
                    }
                } #endMock
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        OutPaintImagePath     = 'C:\images\image.jpeg'
                        OutPaintMaskImagePath = 'C:\images\mask.jpeg'
                        OutPaintTextPrompt    = 'Make it darker'
                        ModelID               = 'amazon.titan-image-generator-v1'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for IMAGE_VARIATION if an image is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonMedia -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath      = 'C:\images'
                        VariationImagePath  = 'C:\images\image.jpeg'
                        VariationTextPrompt = 'Make it darker'
                        ModelID             = 'amazon.titan-image-generator-v1'
                        ProfileName         = 'default'
                        Region              = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it


            It 'should throw for IMAGE_VARIATION if an error is encountered converting the image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath      = 'C:\images'
                        VariationImagePath  = 'C:\images\image.jpeg'
                        VariationTextPrompt = 'Make it darker'
                        ModelID             = 'amazon.titan-image-generator-v1'
                        ProfileName         = 'default'
                        Region              = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for CONDITIONING if v1 model is provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath      = 'C:\images'
                        ConditionImagePath  = 'C:\images\image.jpeg'
                        ConditionTextPrompt = 'Make it darker'
                        ModelID             = 'amazon.titan-image-generator-v1'
                        ProfileName         = 'default'
                        Region              = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for CONDITIONING if an image is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonMedia -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath      = 'C:\images'
                        ConditionImagePath  = 'C:\images\image.jpeg'
                        ConditionTextPrompt = 'Make it darker'
                        ModelID             = 'amazon.titan-image-generator-v2:0'
                        ProfileName         = 'default'
                        Region              = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it


            It 'should throw for CONDITIONING if an error is encountered converting the image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath      = 'C:\images'
                        ConditionImagePath  = 'C:\images\image.jpeg'
                        ConditionTextPrompt = 'Make it darker'
                        ModelID             = 'amazon.titan-image-generator-v2:0'
                        ProfileName         = 'default'
                        Region              = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for COLOR_GUIDED_GENERATION if v1 model is provided' {
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        ColorGuidedImagePath  = 'C:\images\image.jpeg'
                        ColorGuidedTextPrompt = 'Make it darker'
                        Colors                = @('#FF0000', '#00FF00', '#0000FF')
                        ModelID               = 'amazon.titan-image-generator-v1'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for COLOR_GUIDED_GENERATION if colors are provided that are not valid hex values' {
                Mock -CommandName Test-ColorHex -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        ColorGuidedImagePath  = 'C:\images\image.jpeg'
                        ColorGuidedTextPrompt = 'Make it darker'
                        Colors                = @('#FF0000', '#00FF00', '#0000FF')
                        ModelID               = 'amazon.titan-image-generator-v2:0'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for COLOR_GUIDED_GENERATION if an image is provided that is not supported by the model' {
                Mock -CommandName Test-AmazonMedia -MockWith { $false }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        ColorGuidedImagePath  = 'C:\images\image.jpeg'
                        ColorGuidedTextPrompt = 'Make it darker'
                        Colors                = @('#FF0000', '#00FF00', '#0000FF')
                        ModelID               = 'amazon.titan-image-generator-v2:0'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw for COLOR_GUIDED_GENERATION if an error is encountered converting the image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath        = 'C:\images'
                        ColorGuidedImagePath  = 'C:\images\image.jpeg'
                        ColorGuidedTextPrompt = 'Make it darker'
                        Colors                = @('#FF0000', '#00FF00', '#0000FF')
                        ModelID               = 'amazon.titan-image-generator-v2:0'
                        ProfileName           = 'default'
                        Region                = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    [System.Exception]$exception = 'You don''t have access to the model with the specified model ID.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should warn the user and throw if the response indicates that the request was blocked by content filters' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    [System.Exception]$exception = 'This request has been blocked by our content filters. Our filters automatically flagged this prompt because it may conflict our AUP or AWS Responsible AI Policy. Please adjust your text prompt to submit a new request.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR.InvokeBDRRModelCmdlet'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should not try to covert or save images if no images are returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "images": [],
    "error": null
}
'@
                } #endMock
                $invokeAmazonImageSplat = @{
                    ImagesSavePath = 'C:\images'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'amazon.titan-image-generator-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Convert-FromBase64ToByte -Exactly 0 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 0 -Scope It
            } #it

            It 'should throw if the image returned cannot be converted from base64' {
                Mock -CommandName Convert-FromBase64ToByte -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

            It 'should throw if the image cannot be saved to disk' {
                Mock -CommandName Save-BytesToFile -MockWith { throw 'Error' }
                {
                    $invokeAmazonImageSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'amazon.titan-image-generator-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-AmazonImageModel @invokeAmazonImageSplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Test-AmazonMedia -MockWith { $true }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64-encoded-image' }
                Mock -CommandName Test-ColorHex -MockWith { $true }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "images": [
        "base64-encoded-image-1",
        "base64-encoded-image-2"
    ],
    "error": null
}
'@

                # Convert JSON payload to byte array
                $byteArray = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

                # Create a MemoryStream and write the byte array into it
                $memoryStream = [System.IO.MemoryStream]::new()
                $memoryStream.Write($byteArray, 0, $byteArray.Length)

                # Reset the position of the MemoryStream to the beginning
                $memoryStream.Position = 0

                # Assign the MemoryStream to the response body
                $response.Body = $memoryStream
                Mock -CommandName Invoke-BDRRModel -MockWith {
                    $response
                } #endMock

                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "images": [
        "base64-encoded-image-1",
        "base64-encoded-image-2"
    ],
    "error": null
}
'@
                } #endMock
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                [byte[]]$bytes = 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
                Mock -CommandName Convert-FromBase64ToByte -MockWith { $bytes }
                Mock -CommandName Save-BytesToFile -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
            } #beforeEach

            It 'should run all expected subcommands for TEXT_IMAGE' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    Seed           = 200
                    NegativeText   = 'stars'
                    NumberOfImages = 2
                    Width          = 1024
                    Height         = 1024
                    CfgScale       = 10
                    ModelID        = 'amazon.titan-image-generator-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 0 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for INPAINTING when Mask image is provided' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath       = 'C:\images'
                    InPaintImagePath     = 'C:\images\image.jpeg'
                    InPaintTextPrompt    = 'Make it darker'
                    InPaintMaskImagePath = 'C:\images\mask.jpeg'
                    ModelID              = 'amazon.titan-image-generator-v1'
                    ProfileName          = 'default'
                    Region               = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 2 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for INPAINTING when Mask prompt is provided' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath    = 'C:\images'
                    InPaintImagePath  = 'C:\images\image.jpeg'
                    InPaintTextPrompt = 'Make it darker'
                    InPaintMaskPrompt = 'The area around the starship'
                    NegativeText      = 'stars'
                    NumberOfImages    = 2
                    Width             = 1024
                    Height            = 1024
                    CfgScale          = 10
                    ModelID           = 'amazon.titan-image-generator-v1'
                    ProfileName       = 'default'
                    Region            = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for OUTPAINTING when Mask image is provided' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath        = 'C:\images'
                    OutPaintImagePath     = 'C:\images\image.jpeg'
                    OutPaintTextPrompt    = 'Make it darker'
                    OutPaintMaskImagePath = 'C:\images\mask.jpeg'
                    ModelID               = 'amazon.titan-image-generator-v1'
                    ProfileName           = 'default'
                    Region                = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 2 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for OUTPAINTING when Mask prompt is provided' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath     = 'C:\images'
                    OutPaintImagePath  = 'C:\images\image.jpeg'
                    OutPaintTextPrompt = 'Make it darker'
                    OutPaintMaskPrompt = 'The area around the starship'
                    NegativeText       = 'stars'
                    NumberOfImages     = 2
                    Width              = 1024
                    Height             = 1024
                    CfgScale           = 10
                    ModelID            = 'amazon.titan-image-generator-v1'
                    ProfileName        = 'default'
                    Region             = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for IMAGE_VARIATION' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath      = 'C:\images'
                    VariationImagePath  = 'C:\images\image.jpeg'
                    VariationTextPrompt = 'Make it darker'
                    SimilarityStrength  = 0.5
                    NegativeText        = 'stars'
                    ModelID             = 'amazon.titan-image-generator-v1'
                    ProfileName         = 'default'
                    Region              = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for CONDITIONING' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath      = 'C:\images'
                    ConditionImagePath  = 'C:\images\image.jpeg'
                    ConditionTextPrompt = 'Make it darker'
                    ControlMode         = 'CANNY_EDGE'
                    ControlStrength     = 0.5
                    NegativeText        = 'stars'
                    ModelID             = 'amazon.titan-image-generator-v2:0'
                    ProfileName         = 'default'
                    Region              = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should run all expected subcommands for COLOR_GUIDED_GENERATION' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath        = 'C:\images'
                    ColorGuidedImagePath  = 'C:\images\image.jpeg'
                    ColorGuidedTextPrompt = 'Make it darker'
                    Colors                = @('#FF0000', '#00FF00', '#0000FF')
                    NegativeText          = 'stars'
                    ModelID               = 'amazon.titan-image-generator-v2:0'
                    ProfileName           = 'default'
                    Region                = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat
                Should -Invoke Test-AmazonMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 2 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 2 -Scope It
            } #it

            It 'should return null if successful' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'amazon.titan-image-generator-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat | Should -BeNullOrEmpty
            } #it

            It 'should warn and return null if the model returns no images' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "images": [],
    "error": null
}
'@
                } #endMock
                $invokeAmazonImageSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'amazon.titan-image-generator-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeAmazonImageSplat = @{
                    ImagesSavePath   = 'C:\images\image.jpeg'
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    ModelID          = 'amazon.titan-image-generator-v1'
                    ReturnFullObject = $true
                    ProfileName      = 'default'
                    Region           = 'us-west-2'
                }
                $result = Invoke-AmazonImageModel @invokeAmazonImageSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.images.Count | Should -BeExactly 2
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'amazon.titan-image-generator-v1'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonImageSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'amazon.titan-image-generator-v1'
                    AccessKey      = 'ak'
                    SecretKey      = 'sk'
                    Region         = 'us-west-2'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'amazon.titan-image-generator-v1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeAmazonImageSplat = @{
                    ImagesSavePath    = 'C:\images\image.jpeg'
                    ImagePrompt       = 'Create a starship emerging from a nebula.'
                    ModelID           = 'amazon.titan-image-generator-v1'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-AmazonImageModel @invokeAmazonImageSplat | Should -InvokeVerifiable
            } #it

        } #context_Success

    } #describe_Invoke-AmazonImageModel
} #inModule
