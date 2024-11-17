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
    Describe 'Invoke-StabilityAIImageModel Public Function Tests' -Tag Unit {
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
    'seeds': [2130420379],
    'finish_reasons': [null],
    'images': ['base64']
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
    'seeds': [2130420379],
    'finish_reasons': [null],
    'images': ['base64']
}
'@
                } #endMock
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                Mock -CommandName Test-StabilityAIImageMedia -MockWith {
                    $true
                } #endMock
                [byte[]]$bytes = 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
                Mock -CommandName Convert-FromBase64ToByte -MockWith { $bytes }
                Mock -CommandName Save-BytesToFile -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
            } #beforeEach

            It 'should throw if ImagesSavePath is a file instead of a directory' {
                Mock -CommandName Test-Path -MockWith { $false }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images\image.jpeg'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
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
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images\doesnotexist'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a non supported model is requested' {
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'NotSupported'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
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
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if there is an error running Invoke-BDRRModel' {
                Mock -CommandName Invoke-BDRRModel -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Invoke-BDRRModel -MockWith { $null }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the memory stream can not be converted' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should not try to convert or save images if no images are returned by the model' {
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    "result": "failure",
    "artifacts": []
}
'@
                } #endMock
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                Should -Invoke Convert-FromBase64ToByte -Exactly 0 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 0 -Scope It
            } #it

            It 'should throw if the image returned cannot be converted from base64' {
                Mock -CommandName Convert-FromBase64ToByte -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the image cannot be saved to disk' {
                Mock -CommandName Save-BytesToFile -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an init image is specified but a supported model is not chosen' {
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        InitImagePath  = 'C:\images\init.jpg'
                        ModelID        = 'stability.stable-image-core-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an init image is provided that is not supported' {
                Mock -CommandName Test-StabilityAIImageMedia -MockWith {
                    $false
                } #endMock
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        InitImagePath  = 'C:\images\init.zip'
                        ModelID        = 'stability.sd3-large-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an init image is provided and there is an error converting it to base64' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Error' }
                {
                    $invokeStabilityAIImageModelSplat = @{
                        ImagesSavePath = 'C:\images'
                        ImagePrompt    = 'Create a starship emerging from a nebula.'
                        InitImagePath  = 'C:\images\init.jpg'
                        ModelID        = 'stability.sd3-large-v1:0'
                        ProfileName    = 'default'
                        Region         = 'us-west-2'
                    }
                    Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                } | Should -Throw
            }

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
    'seeds': [2130420379],
    'finish_reasons': [null],
    'images': ['base64']
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
    'seeds': [2130420379],
    'finish_reasons': [null],
    'images': ['base64']
}
'@
                } #endMock
                Mock -CommandName Test-StabilityAIImageMedia -MockWith {
                    $true
                } #endMock
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                [byte[]]$bytes = 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21
                Mock -CommandName Convert-FromBase64ToByte -MockWith { $bytes }
                Mock -CommandName Save-BytesToFile -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
            } #beforeEach

            It 'should run all expected subcommands for text-to-image' {
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    NegativePrompt = 'stars'
                    OutputFormat   = 'JPEG'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                Should -Invoke Test-StabilityAIDiffusionMedia -Exactly 0 -Scope It
                Should -Invoke Convert-MediaToBase64 -Exactly 0 -Scope It
                Should -Invoke Invoke-BDRRModel -Exactly 1 -Scope It
                Should -Invoke ConvertFrom-MemoryStreamToString -Exactly 1 -Scope It
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
                Should -Invoke Convert-FromBase64ToByte -Exactly 1 -Scope It
                Should -Invoke Save-BytesToFile -Exactly 1 -Scope It
            } #it

            It 'should return null if successful' {
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -BeNullOrEmpty
            } #it

            It 'should warn and return null if the model returns no images' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    'seeds': [2130420379],
    'finish_reasons': [null],
    'images': ['']
}
'@
                } #endMock
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 1
            } #it

            It 'should warn the user if the content filter is triggered' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName ConvertFrom-MemoryStreamToString -MockWith {
                    @'
{
    'seeds': [2130420379],
    'finish_reasons': ['Filter reason: output image'],
    'images': ['base64']
}
'@
                } #endMock
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    ProfileName    = 'default'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should return the full object if ReturnFullObject is provided' {
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath   = 'C:\images\image.jpeg'
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    ModelID          = 'stability.stable-image-core-v1:0'
                    ReturnFullObject = $true
                    ProfileName      = 'default'
                    Region           = 'us-west-2'
                }
                $result = Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
            } #it

            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'stability.stable-image-core-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    ModelID        = 'stability.stable-image-core-v1:0'
                    AccessKey      = 'ak'
                    SecretKey      = 'sk'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -InvokeVerifiable
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'stability.stable-image-core-v1:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ContentType        | Should -BeExactly 'application/json'
                    $Body               | Should -BeOfType [byte]
                } -Verifiable
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath    = 'C:\images\image.jpeg'
                    ImagePrompt       = 'Create a starship emerging from a nebula.'
                    ModelID           = 'stability.stable-image-core-v1:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -InvokeVerifiable
            } #it

            It 'should call the API with expected parameters for image-to-image' {
                Mock -CommandName Invoke-BDRRModel {
                    $response
                    $Region         | Should -BeExactly 'us-west-2'
                    $ModelID        | Should -BeExactly 'stability.sd3-large-v1:0'
                    $AccessKey      | Should -BeExactly 'ak'
                    $SecretKey      | Should -BeExactly 'sk'
                    $ContentType    | Should -BeExactly 'application/json'
                    $Body           | Should -BeOfType [byte]
                } -Verifiable
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath = 'C:\images\image.jpeg'
                    ImagePrompt    = 'Create a starship emerging from a nebula.'
                    InitImagePath  = 'C:\images\init.jpg'
                    ImageStrength  = 0.5
                    ModelID        = 'stability.sd3-large-v1:0'
                    AccessKey      = 'ak'
                    SecretKey      = 'sk'
                    Region         = 'us-west-2'
                }
                Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat  | Should -InvokeVerifiable
            } #it

            It 'should return the expected result when all parameters are provided' {
                $invokeStabilityAIImageModelSplat = @{
                    ImagesSavePath   = 'C:\images\image.jpeg'
                    ImagePrompt      = 'Create a starship emerging from a nebula.'
                    AspectRatio      = '1:1'
                    OutputFormat     = 'JPEG'
                    Seed             = 1234
                    NegativePrompt   = 'stars'
                    ModelID          = 'stability.stable-image-ultra-v1:0'
                    ReturnFullObject = $true
                    ProfileName      = 'default'
                    Region           = 'us-west-2'
                }
                $result = Invoke-StabilityAIImageModel @invokeStabilityAIImageModelSplat
                $result | Should -BeOfType [System.Management.Automation.PSCustomObject]
            } #it

        } #context_Success

    } #describe_Invoke-StabilityAIImageModel
} #inModule
