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
    Describe 'Amazon Titan Integration Tests' -Tag Integration {
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

        Context 'Standard Message' {

            BeforeEach {
                $resetModelContextSplat = @{
                    AllModels = $true
                    Verbose   = $false
                }
                Reset-ModelContext @resetModelContextSplat
            }
            AfterEach {
                Start-Sleep -Milliseconds 500
            }

            It 'should return a message when provided a standard message for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -ne 'amazon.titan-image-generator-v1' }) {
                $ModelID = $_.ModelId
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval
            } #it

            It 'should return an object when provided a standard message for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -ne 'amazon.titan-image-generator-v1' }) {
                $ModelID = $_.ModelId
                $invokeAmazonTextModelSplat = @{
                    Message          = 'Return the number 1 as a string'
                    ModelID          = $ModelID
                    MaxTokens        = 10
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    NoContextPersist = $true
                    ReturnFullObject = $true
                    Verbose          = $false
                }
                $eval = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.inputTextTokenCount | Should -Not -BeNullOrEmpty
                $eval.results.tokenCount | Should -Not -BeNullOrEmpty
                $eval.results.outputText | Should -Not -BeNullOrEmpty
                $eval.results.completionReason | Should -Not -BeNullOrEmpty
                Write-Verbose -Message $eval.results.outputText
            } #it

        } #context_standard_message

        Context 'Custom Message' {
            AfterEach {
                Start-Sleep -Milliseconds 500
            }

            It 'should return a message when provided a custom message for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -ne 'amazon.titan-image-generator-v1' }) {
                $ModelID = $_.ModelId
                $customConversation = @'
User: Return the number 1 as a string.
Bot: 1
User: Say the exact same thing you just said.
'@
                $invokeAmazonTextModelSplat = @{
                    CustomConversation = $customConversation
                    ModelID            = $ModelID
                    Credential         = $awsCredential
                    Region             = 'us-west-2'
                    Verbose            = $false
                }
                $eval = Invoke-AmazonTextModel @invokeAmazonTextModelSplat
                $eval | Should -BeOfType [System.String]
                $eval | Should -Not -BeNullOrEmpty
                Write-Output $eval
            } #it

            AfterAll {
                $getModelTallySplat = @{
                    JustTotalCost = $true
                    Verbose       = $false
                }
                $totalCost = Get-ModelTally @getModelTallySplat
                Write-Verbose -Message "Total cost for all models: $totalCost"
            }

        } #context_custom_message

        Context 'Image Model' {

            BeforeEach {
                $outFile = $env:TEMP
                # $outFile = 'D:\Code\Bedrock'
            }
            AfterEach {
                Start-Sleep -Milliseconds 500
            }

            It 'should return an image when using TEXT_IMAGE generation for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
                $ModelID = $_.ModelID
                $invokeAmazonImageSplat = @{
                    ImagesSavePath   = $outFile
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    Seed             = 200
                    NegativeText     = 'stars'
                    NumberOfImages   = 1
                    Width            = 1024
                    Height           = 1024
                    CfgScale         = 10
                    ModelID          = $ModelID
                    ReturnFullObject = $true
                    Credential       = $awsCredential
                    Region           = 'us-west-2'
                    Verbose          = $false
                }
                $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.images.Count | Should -Be 1
            } #it

            # ! All of these tests are currently being skipped as they flag the content filter and its not clear why.
            # It 'should return an image when using INPAINTING with a mask image for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
            #     $ModelID = $_.ModelID
            #     $invokeAmazonImageSplat = @{
            #         ImagesSavePath       = $outFile
            #         InPaintImagePath     = $inpaintingMainImage
            #         InPaintTextPrompt    = 'Make it glow.'
            #         InPaintMaskImagePath = $inpaintingMaskImage
            #         ModelID              = $ModelID
            #         ReturnFullObject     = $true
            #         Credential           = $awsCredential
            #         Region               = 'us-west-2'
            #         Verbose              = $false
            #     }
            #     $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
            #     $eval | Should -Not -BeNullOrEmpty
            #     $eval.images.Count | Should -Be 1
            # } #it

            # It 'should return an image when using INPAINTING with a mask prompt for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
            #     $ModelID = $_.ModelID
            #     $invokeAmazonImageSplat = @{
            #         ImagesSavePath       = $outFile
            #         InPaintImagePath     = $inpaintingMainImage
            #         InPaintTextPrompt    = 'Replace the cat face with the face of a wise wolf who is a jedi master.'
            #         InPaintMaskImagePath = $inpaintingMaskImage
            #         InPaintMaskPrompt    = 'The cats head.'
            #         ModelID              = $ModelID
            #         ReturnFullObject     = $true
            #         Credential           = $awsCredential
            #         Region               = 'us-west-2'
            #         Verbose              = $false
            #     }
            #     $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
            #     $eval | Should -Not -BeNullOrEmpty
            #     $eval.images.Count | Should -Be 1
            # } #it

            # It 'should return an image when using OUTPAINTING with a mask image for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
            #     $ModelID = $_.ModelID
            #     $invokeAmazonImageSplat = @{
            #         ImagesSavePath        = $outFile
            #         OutPaintImagePath     = $outpaintingMainImage
            #         OutPaintTextPrompt    = 'Extend the nebula and let us see the rest of the ship.'
            #         OutPaintMaskImagePath = $outpaintingMaskImage
            #         ModelID               = $ModelID
            #         ReturnFullObject      = $true
            #         Credential            = $awsCredential
            #         Region                = 'us-west-2'
            #         Verbose               = $false
            #     }
            #     $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
            #     $eval | Should -Not -BeNullOrEmpty
            #     $eval.images.Count | Should -Be 1
            # } #it

            # It 'should return an image when using OUTPAINTING with a mask prompt for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
            #     $ModelID = $_.ModelID
            #     $invokeAmazonImageSplat = @{
            #         ImagesSavePath     = $outFile
            #         OutPaintImagePath  = $outpaintingMainImage
            #         OutPaintTextPrompt = 'Extend the nebula and let us see the rest of the ship.'
            #         OutPaintMaskPrompt = 'The starships.'
            #         ModelID            = $ModelID
            #         ReturnFullObject   = $true
            #         Credential         = $awsCredential
            #         Region             = 'us-west-2'
            #         Verbose            = $false
            #     }
            #     $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
            #     $eval | Should -Not -BeNullOrEmpty
            #     $eval.images.Count | Should -Be 1
            # } #it

            It 'should return an image when using IMAGE_VARIATION for <_.ModelId>' -Foreach ($script:amazonModelInfo | Where-Object { $_.ModelId -eq 'amazon.titan-image-generator-v1' }) {
                $ModelID = $_.ModelID
                $invokeAmazonImageSplat = @{
                    ImagesSavePath      = $outFile
                    VariationImagePath  = $variationMainImage
                    VariationTextPrompt = 'Replace the captain with a different crew member.'
                    ModelID             = $ModelID
                    ReturnFullObject    = $true
                    Credential          = $awsCredential
                    Region              = 'us-west-2'
                    Verbose             = $false
                }
                $eval = Invoke-AmazonImageModel @invokeAmazonImageSplat
                $eval | Should -Not -BeNullOrEmpty
                $eval.images.Count | Should -Be 1
            } #it

        } #context_image_model

    } #describe
} #inModule
