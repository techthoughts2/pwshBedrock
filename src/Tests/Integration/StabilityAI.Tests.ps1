#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
#-------------------------------------------------------------------------
#if the module is already in memory, remove it
Get-Module $ModuleName | Remove-Module -Force
$PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
#-------------------------------------------------------------------------
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
# $awsCredential = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')

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

        Context 'Image Model' {

            BeforeEach {
                $outFile = $env:TEMP
                # $outFile = 'D:\Code\Bedrock'
            }
            AfterEach {
                Start-Sleep -Milliseconds 5500
            }

            It 'should return an image when using text-to-image for <_.ModelId>' -Foreach $script:stabilityAIModelInfo {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionModelSplat = @{
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
                $eval = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-to-Mask with a mask prompt for <_.ModelId>' -Foreach $script:stabilityAIModelInfo {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionModelSplat = @{
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
                $eval = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-to-Mask with a extension mask prompt for <_.ModelId>' -Foreach $script:stabilityAIModelInfo {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionModelSplat = @{
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
                $eval = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

            It 'should return an image when using Image-To-Image for <_.ModelId>' -Foreach $script:stabilityAIModelInfo {
                $ModelID = $_.ModelID
                $invokeStabilityAIDiffusionModelSplat = @{
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
                $eval = Invoke-StabilityAIDiffusionModel @invokeStabilityAIDiffusionModelSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.artifacts.count | Should -Be 1
            } #it

        } #context_image_model

    } #describe
} #inModule
