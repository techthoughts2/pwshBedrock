BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
    # $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
}

InModuleScope 'pwshBedrock' {
    Describe 'Stability AI Integration Tests' -Tag Integration {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $VerbosePreference = 'Continue'

            Set-Location -Path $PSScriptRoot
            $assetPath = [System.IO.Path]::Combine($PSScriptRoot, '..', 'assets')
            $inpaintingMainFile = [System.IO.Path]::Combine($assetPath, 'jedicat_inpainting.png')
            $inpaintingMaskFile = [System.IO.Path]::Combine($assetPath, 'jedicat_inpainting_mask.png')
            $outpaintingMainFile = [System.IO.Path]::Combine($assetPath, 'battle_outpainting.png')
            $outpaintingMaskFile = [System.IO.Path]::Combine($assetPath, 'battle_outpainting_mask.png')
            $variationMainFile = [System.IO.Path]::Combine($assetPath, 'tanagra_variation.png')

            $inpaintingMainImage = [System.IO.Path]::GetFullPath($inpaintingMainFile)
            $inpaintingMaskImage = [System.IO.Path]::GetFullPath($inpaintingMaskFile)
            $outpaintingMainImage = [System.IO.Path]::GetFullPath($outpaintingMainFile)
            $outpaintingMaskImage = [System.IO.Path]::GetFullPath($outpaintingMaskFile)
            $variationMainImage = [System.IO.Path]::GetFullPath($variationMainFile)
        } #beforeAll

        Context 'Diffusion XL Model' {

            BeforeEach {
                $outFile = $env:TEMP
                # $outFile = 'D:\Code\Bedrock'
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return an image when using text-to-image for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -eq 'stability.stable-diffusion-xl-v1' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionXLModelSplat = @{
                    ImagesSavePath   = $outFile
                    CustomPrompt     = @(
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
                    Width            = 1024
                    Height           = 1024
                    ModelID          = $ModelID
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-to-Mask with a mask prompt for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -eq 'stability.stable-diffusion-xl-v1' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionXLModelSplat = @{
                    ImagesSavePath    = $outFile
                    ImagePrompt       = 'Replace the cat face with the face of a wise wolf who is a jedi master.'
                    InitMaskImagePath = $inpaintingMainImage
                    MaskSource        = 'MASK_IMAGE_BLACK'
                    MaskImagePath     = $inpaintingMaskImage
                    ModelID           = $ModelID
                    ReturnFullObject  = $true
                    Credential        = $awsCredential
                    Region            = 'us-west-2'
                    Verbose           = $false
                }
                $eval = Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-to-Mask with a extension mask prompt for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -eq 'stability.stable-diffusion-xl-v1' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionXLModelSplat = @{
                    ImagesSavePath    = $outFile
                    ImagePrompt       = 'Extend the nebula and let us see the rest of the ship.'
                    InitMaskImagePath = $outpaintingMainImage
                    MaskSource        = 'MASK_IMAGE_WHITE'
                    MaskImagePath     = $outpaintingMainImage
                    ModelID           = $ModelID
                    ReturnFullObject  = $true
                    Credential        = $awsCredential
                    Region            = 'us-west-2'
                    Verbose           = $false
                }
                $eval = Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-To-Image for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -eq 'stability.stable-diffusion-xl-v1' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionXLModelSplat = @{
                    ImagesSavePath   = $outFile
                    ImagePrompt      = 'Replace the captain with a different crew member.'
                    InitImagePath    = $variationMainImage
                    InitImageMode    = 'IMAGE_STRENGTH'
                    ImageStrength    = 1.0
                    ModelID          = $ModelID
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-StabilityAIDiffusionXLModel @invokeStabilityAIDiffusionXLModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

        } #context_DiffusionXLModel

        Context 'Image Model' {

            BeforeEach {
                $outFile = $env:TEMP
                # $outFile = 'D:\Code\Bedrock'
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return an image when using text-to-image for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -ne 'stability.stable-diffusion-xl-v1' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath   = $outFile
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    AspectRatio      = '1:1'
                    OutputFormat     = 'jpeg'
                    NegativePrompt   = 'stars'
                    ModelID          = $ModelID
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                $eval | Should -Not -BeNullOrEmpty
            } #it

            It 'should return an image when using image-to-image for <_.ModelId>' -Foreach ($script:stabilityAIModelInfo | Where-Object { $_.ModelID -like '*sd3*' }) {
                $ModelID = $_.ModelID
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath   = $outFile
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    InitImagePath    = $variationMainImage
                    AspectRatio      = '1:1'
                    OutputFormat     = 'jpeg'
                    NegativePrompt   = 'stars'
                    ModelID          = $ModelID
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                $eval | Should -Not -BeNullOrEmpty
            } #it

        } #context_ImageModel

    } #describe
} #inModule
