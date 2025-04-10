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
    Describe 'Invoke-LumaAIModel Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                }
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'InProgress'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                Mock -CommandName Copy-S3Object -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
                Mock -CommandName Write-Warning -MockWith { }
                Mock -CommandName Write-Error -MockWith { }
            } #beforeEach

            It 'should throw if AttemptS3Download is used without LocalSavePath' {
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if LocalSavePath is not a valid path' {
                Mock -CommandName Test-Path -MockWith { $false }
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\invalidpath'
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a non supported model is requested' {
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'NotSupported'
                        AttemptS3Download = $false
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith { throw 'Error' }
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $false
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
            } #it

            It 'should warn the user and throw if the response indicates that you do not have access to the model' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    [System.Exception]$exception = 'You don''t have access to the model with the specified model ID.'
                    [System.String]$errorId = 'Amazon.BedrockRuntime.Model.AccessDeniedException, Amazon.PowerShell.Cmdlets.BDRR'
                    [Management.Automation.ErrorCategory]$errorCategory = [Management.Automation.ErrorCategory]::InvalidOperation
                    [System.Object]$target = 'Amazon.PowerShell.Cmdlets.BDRR'
                    $errorRecord = New-Object Management.Automation.ErrorRecord ($exception, $errorID, $errorCategory, $target)
                    [System.Management.Automation.ErrorDetails]$errorDetails = ''
                    $errorRecord.ErrorDetails = $errorDetails
                    throw $errorRecord
                }
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $false
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith { $null }
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $false
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
            } #it

            It 'should throw if error is encountered when checking async job status' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    'arn:aws:bedrock:us-west-2:123456789012:async-invoke/testarn'
                }
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    throw 'Error checking job status'
                }
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw
                Should -Invoke Write-Error -Times 1
            } #it

            It 'should throw if error is encountered when downloading file from S3' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Completed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx/output.mp4'
                            }
                        }
                    }
                    return $jobStatus
                }
                Mock -CommandName Copy-S3Object -MockWith { throw 'S3 download error' }

                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Throw

                Should -Invoke Write-Warning -Times 1
                Should -Invoke Write-Error -Times 1
            } #it

        } #context

        Context 'Success' {
            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                }
                Mock -CommandName Start-Sleep -MockWith { }
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Completed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }
                Mock -CommandName Copy-S3Object -MockWith { }
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return invocation ARN when not attempting S3 download' {

                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    AttemptS3Download = $false
                }
                $result = Invoke-LumaAIModel @invokeLumaAIModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Message | Should -Not -BeNullOrEmpty
            } #it

            It 'should successfully download video when job completes' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Completed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx/output.mp4'
                            }
                        }
                    }
                    return $jobStatus
                }
                Mock -CommandName Copy-S3Object -MockWith { }

                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-LumaAIModel @invokeLumaAIModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Status | Should -Be 'Completed'
                $result.LocalFilePath | Should -Not -BeNullOrEmpty
                $result.S3Uri | Should -Be 's3://bedrockvideotestbucket/xxxxxxxxx/output.mp4'
                Should -Invoke Copy-S3Object -Times 1
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should handle job in unexpected state' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Failed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }
                Mock -CommandName Write-Warning -MockWith { }

                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-LumaAIModel @invokeLumaAIModelSplat


                Should -Invoke Write-Warning -Times 2
                $result | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
            } #it

            It 'should just return the invocation arn if no S3 output uri is found in the job results' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Completed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = ''
                            }
                        }
                    }
                    return $jobStatus
                }

                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-LumaAIModel @invokeLumaAIModelSplat

                $result | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
            } #it

            It 'should just return the invocation arn if the S3 Uri returned is not in an expected format' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Completed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 'invalid_s3_uri'
                            }
                        }
                    }
                    return $jobStatus
                }

                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    Resolution          = '540p'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-LumaAIModel @invokeLumaAIModelSplat

                $result | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
            } #it

            It 'should return the expected result when all parameters are provided' {


                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $ModelInput.prompt | Should -Be 'Create a video of a cat playing with a ball.'
                    $ModelInput.aspect_ratio | Should -Be '16:9'
                    $ModelInput.loop | Should -Be $true
                    $ModelInput.duration | Should -Be '9s'
                    $ModelInput.resolution | Should -Be '720p'
                    $S3OutputDataConfig_BucketOwner | Should -Be '123456789012'
                    $S3OutputDataConfig_KmsKeyId | Should -Be 'arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeLumaAIModelSplat = @{
                    VideoPrompt         = 'Create a video of a cat playing with a ball.'
                    S3OutputURI         = 's3://mybucket'
                    AspectRatio         = '16:9'
                    Loop                = $true
                    Duration            = '9s'
                    Resolution          = '720p'
                    ModelID             = 'luma.ray-v2:0'
                    AttemptS3Download   = $true
                    LocalSavePath       = 'C:\temp'
                    S3OutputBucketOwner = '123456789012'
                    S3OutputKmsKeyId    = 'arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
                    AccessKey           = 'ak'
                    SecretKey           = 'sk'
                }

                Invoke-LumaAIModel @invokeLumaAIModelSplat | Should -InvokeVerifiable
            } #it

            It 'should return the expected results when the job takes too long' {
                $script:dateCallCount = 0
                $script:now = Get-Date
                $script:second = $now.AddMinutes(1)
                $script:pastTime = $now.AddMinutes(16)
                Mock -CommandName Get-Date -MockWith {
                    $script:dateCallCount++
                    if ($script:dateCallCount -eq 1) {
                        return $script:now
                    }
                    elseif ($script:dateCallCount -eq 2) {
                        return $script:second
                    }
                    elseif ($script:dateCallCount -eq 3) {
                        return $script:pastTime
                    }
                }
                $script:AsyncCallCount = 0
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $script:AsyncCallCount++
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Failed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    if ($script:AsyncCallCount -eq 1) {
                        $jobStatus.Status = 'InProgress'
                    }
                    else {
                        $jobStatus.Status = 'InProgress'
                    }
                    return $jobStatus
                }

                $result = $null
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    $result = Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Not -Throw

                Should -Invoke Get-BDRRAsyncInvoke -Times 2
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should handle timeout when job takes too long' {
                $script:AsyncCallCount = 0
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $script:AsyncCallCount++
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Failed'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    if ($script:AsyncCallCount -eq 1) {
                        $jobStatus.Status = 'InProgress'
                    }
                    else {
                        $jobStatus.Status = 'Completed'
                    }
                    return $jobStatus
                }

                $result = $null
                {
                    $invokeLumaAIModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'luma.ray-v2:0'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    $result = Invoke-LumaAIModel @invokeLumaAIModelSplat
                } | Should -Not -Throw

                Should -Invoke Get-BDRRAsyncInvoke -Times 2
            } #it

            It 'should call the API with the expected parameters - 2' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                # load a standard System.Management.Automation.PSCredential
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME', (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'luma.ray-v2:0'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'string'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable
                $invokeLumaAIModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'luma.ray-v2:0'
                    Credential        = $awsCred
                    EndpointUrl       = 'string'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    ProfileName       = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'string'
                }
                Invoke-LumaAIModel @invokeLumaAIModelSplat | Should -InvokeVerifiable
            } #it

        } #context
    } #describe
} #inModuleScope

<#
SAMPLE OUTPUT FROM ASYNC CHECK
$a = Get-BDRRAsyncInvoke -InvocationArn $rawResponse -Region 'us-west-2' -Credential $Credential

ClientRequestToken : 56acbfe4-2702-439b-b155-4a485bac8b30
EndTime            : 1/1/0001 12:00:00 AM
FailureMessage     :
InvocationArn      : arn:aws:bedrock:us-west-2:xxxxxxxxxxxx:async-invoke/xxxxxxxxxxx
LastModifiedTime   : 4/8/2025 10:52:53 PM
ModelArn           : arn:aws:bedrock:us-west-2::foundation-model/luma.ray-v2:0
OutputDataConfig   : Amazon.BedrockRuntime.Model.AsyncInvokeOutputDataConfig
Status             : InProgress
SubmitTime         : 4/8/2025 10:52:53 PM

$a.OutputDataConfig

S3OutputDataConfig
------------------
Amazon.BedrockRuntime.Model.AsyncInvokeS3OutputDataConfig

[3.08ms]
[04-08-25 22:53] C:\Users\jwm> $a.OutputDataConfig.S3OutputDataConfig

BucketOwner KmsKeyId S3Uri
----------- -------- -----
                    s3://bedrockvideotestbucket/xxxxxxxxxxx

$a = Get-BDRRAsyncInvoke -InvocationArn $rawResponse -Region 'us-west-2' -Credential $Credential
[432.14ms]
[04-08-25 22:49] C:\Users\jwm> $a

ClientRequestToken : 6fb38a8f-c029-44b6-b31a-d4f6267b08ea
EndTime            : 4/8/2025 10:40:19 PM
FailureMessage     :
InvocationArn      : arn:aws:bedrock:us-west-2:xxxxxxxxxxxx:async-invoke/tavx7wznzka0
LastModifiedTime   : 4/8/2025 10:40:20 PM
ModelArn           : arn:aws:bedrock:us-west-2::foundation-model/luma.ray-v2:0
OutputDataConfig   : Amazon.BedrockRuntime.Model.AsyncInvokeOutputDataConfig
Status             : Completed
SubmitTime         : 4/8/2025 10:38:44 PM

$a.OutputDataConfig.S3OutputDataConfig.S3Uri
s3://bedrockvideotestbucket/xxxxxxxxxxx

s3://bedrockvideotestbucket/tavx7wznzka0/output.mp4
#>
