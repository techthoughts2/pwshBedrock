BeforeAll {
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
    Describe 'Invoke-StabilityAIDiffusionModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Test-StabilityAIDiffusionMedia -MockWith { $true }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64-encoded-image' }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "result": "success",
    "artifacts": [
        {
            "seed": 2174245375,
            "base64": "base64",
            "finishReason": "SUCCESS"
        }
    ]
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
    "result": "success",
    "artifacts": [
        {
            "seed": 2174245375,
            "base64": "base64",
            "finishReason": "SUCCESS"
        }
    ]
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
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images\image.jpeg'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
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
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images\doesnotexist'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a non supported model is requested' {
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'NotSupported'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if ClipGuidance is specified and a non-ancestral sampler is also specified' {
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath     = 'C:\images'
                        ImagePrompt        = 'Create a starship emerging from a nebula.'
                        ClipGuidancePreset = 'SLOWER'
                        Sampler            = 'DDIM'
                        ModelID            = 'stability.stable-diffusion-xl-v1'
                        ProfileName        = 'default'
                        Region             = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if image generation is requested with incompatible width and height combination' {
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        Width          = 1024
                        Height         = 640
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Image if a main image is provided that is not supported by the model' {
                Mock -CommandName Test-StabilityAIDiffusionMedia -MockWith { $false }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Make it darker.'
                        InitImagePath  = 'C:\images\image.jpeg'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Mask if a main image is provided that is not supported by the model' {
                Mock -CommandName Test-StabilityAIDiffusionMedia -MockWith { $false }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath    = 'C:\images'
                        ImagePrompt       = 'Make it darker.'
                        InitMaskImagePath = 'C:\images\image.jpeg'
                        MaskSource        = 'MASK_IMAGE_WHITE'
                        MaskImagePath     = 'C:\images\image.jpeg'
                        ModelID           = 'stability.stable-diffusion-xl-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Mask if a mask image is provided that is not supported by the model' {
                $script:mockCalled = 0
                Mock -CommandName Test-StabilityAIDiffusionMedia -MockWith {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                } #endMock
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath    = 'C:\images'
                        ImagePrompt       = 'Make it darker.'
                        InitMaskImagePath = 'C:\images\image.jpeg'
                        MaskSource        = 'MASK_IMAGE_WHITE'
                        MaskImagePath     = 'C:\images\image.jpeg'
                        ModelID           = 'stability.stable-diffusion-xl-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Image if there is an error converting the main image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Make it darker.'
                        InitImagePath  = 'C:\images\image.jpeg'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Mask if there is an error converting the main image to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath    = 'C:\images'
                        ImagePrompt       = 'Make it darker.'
                        InitMaskImagePath = 'C:\images\image.jpeg'
                        MaskSource        = 'MASK_IMAGE_WHITE'
                        MaskImagePath     = 'C:\images\image.jpeg'
                        ModelID           = 'stability.stable-diffusion-xl-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw for Image-to-Mask if there is an error converting the mask image to base64' {
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
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath    = 'C:\images'
                        ImagePrompt       = 'Make it darker.'
                        InitMaskImagePath = 'C:\images\image.jpeg'
                        MaskSource        = 'MASK_IMAGE_WHITE'
                        MaskImagePath     = 'C:\images\image.jpeg'
                        ModelID           = 'stability.stable-diffusion-xl-v1'
                        ProfileName       = 'default'
                        Region            = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
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
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should not try to covert or save images if no images are returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "result": "failure",
    "artifacts": []
}
'@
                } #endMock
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                Should -Invoke Convert-FromBase64ToByte -Exactly 0 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 0 -Scope It
            } #it

            It 'should throw if the image returned cannot be converted from base64' {
                Mock -CommandName Convert-FromBase64ToByte -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the image cannot be saved to disk' {
                Mock -CommandName Save-BytesToFile -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIDiffusionModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-diffusion-xl-v1'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Test-StabilityAIDiffusionMedia -MockWith { $true }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64-encoded-image' }
                $response = [Amazon.BedrockRuntime.Model.InvokeModelResponse]::new()
                $response.ContentType = 'application/json'
                $jsonPayload = @'
{
    "result": "success",
    "artifacts": [
        {
            "seed": 2174245375,
            "base64": "base64",
            "finishReason": "SUCCESS"
        }
    ]
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
    "result": "success",
    "artifacts": [
        {
            "seed": 2174245375,
            "base64": "base64",
            "finishReason": "SUCCESS"
        }
    ]
}
'@
                } #endMock
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                [byte[]]$bytes = 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
                Mock -CommandName Convert-FromBase64ToByte -MockWith { $bytes }
                Mock -CommandName Save-BytesToFile -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
            } #beforeEach

            It 'should run all expected subcommands for text-to-image' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    CustomPrompt   = @(
                        [PSCustomObject]@{
                            text   = 'Create a starship emerging from a nebula.'
                            weight = 100
                        }
                        [PSCustomObject]@{
                            text   = 'Do not include stars in the image.'
                            weight = 5
                        }
                        [PSCustomObject]@{
                            text   = 'star'
                            weight = -1
                        }
                        [PSCustomObject]@{
                            text   = 'stars'
                            weight = -1
                        }
                    )
                    Width          = 1024
                    Height         = 1024
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                Should -Invoke Test-StabilityAIDiffusionMedia -Exactly 0 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 1 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands for Image-to-Image' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images'
                    ImagePrompt    = 'Make it darker.'
                    NegativePrompt = 'stars'
                    InitImagePath  = 'C:\images\image.jpeg'
                    InitImageMode  = 'IMAGE_STRENGTH'
                    ImageStrength  = 0.5
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                Should -Invoke Test-StabilityAIDiffusionMedia -Exactly 1 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 1 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 1 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 1 -Scope It
            } #it

            It 'should run all expected subcommands for Image-to-Mask' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath    = 'C:\images'
                    ImagePrompt       = 'Make it darker.'
                    InitMaskImagePath = 'C:\images\image.jpeg'
                    MaskSource        = 'MASK_IMAGE_WHITE'
                    MaskImagePath     = 'C:\images\image.jpeg'
                    ModelID           = 'stability.stable-diffusion-xl-v1'
                    ProfileName       = 'default'
                    Region            = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                Should -Invoke Test-StabilityAIDiffusionMedia -Exactly 2 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 2 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 1 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 1 -Scope It
            } #it

            It 'should return null if successful' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat | Should -BeNullOrEmpty
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
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should warn the user if the content filter is triggered' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "result": "success",
    "artifacts": [
        {
            "seed": 2174245375,
            "base64": "base64",
            "finishReason": "CONTENT_FILTERED"
        }
    ]
}
'@
                } #endMock
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 2
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath   = 'C:\images\image.jpeg'
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    ModelID          = 'stability.stable-diffusion-xl-v1'
                    ReturnFullObject = $true
                    ProfileName      = 'default'
                    Region           = 'us-west-2'
                }
                $result = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.artifacts.count | Should -BeExactly 1
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'stability.stable-diffusion-xl-v1'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-diffusion-xl-v1'
                    AccessKey      = 'ak'
                    SecretKey      = 'sk'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'stability.stable-diffusion-xl-v1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath    = 'C:\images\image.jpeg'
                    ImagePrompt       = 'Create a starship emerging from a nebula.'
                    ModelID           = 'stability.stable-diffusion-xl-v1'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat | Should -InvokeVerifiable
            } #it

            It 'should return the expected result when all parameters are provided' {
                $invokeStabilityAIDiffusionModelSplat = @{
                    ImagesSavePath     = 'C:\images\image.jpeg'
                    ImagePrompt        = 'Create a starship emerging from a nebula.'
                    CfgScale           = 1.0
                    ClipGuidancePreset = 'SLOWER'
                    Sampler            = 'K_DPMPP_2S_ANCESTRAL'
                    Samples            = 1
                    Seed               = 1234
                    Steps              = 50
                    StylePreset        = 'anime'
                    ModelID            = 'stability.stable-diffusion-xl-v1'
                    ReturnFullObject   = $true
                    ProfileName        = 'default'
                    Region             = 'us-west-2'
                }
                $result = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $result.artifacts.count | Should -BeExactly 1
            } #it

        } #context_Success

    } #describe_Invoke-StabilityAIDiffusionModel
} #inModule
