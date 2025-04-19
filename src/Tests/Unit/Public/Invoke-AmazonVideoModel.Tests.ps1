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
    Describe 'Invoke-AmazonVideoModel Public Function Tests' -Tag Unit {
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
                Mock -CommandName Join-Path -MockWith { 'afilePath' }
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64string' }
                Mock -CommandName Copy-S3Object -MockWith { }
                Mock -CommandName Start-Sleep -MockWith { }
                Mock -CommandName Write-Warning -MockWith { }
                Mock -CommandName Write-Error -MockWith { }
            } #beforeEach

            It 'should throw if AttemptS3Download is used without LocalSavePath' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'amazon.nova-reel-v1:1'
                        AttemptS3Download = $true
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if LocalSavePath is not a valid path' {
                Mock -CommandName Test-Path -MockWith { $false }
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'amazon.nova-reel-v1:1'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\invalidpath'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if TEXT_VIDEO task type is used without VideoPrompt' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'TEXT_VIDEO'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if TEXT_VIDEO task type is used with VideoPrompt exceeding 512 characters' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'a' * 513  # Exceeds 512 character limit
                        S3OutputURI = 's3://mybucket'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_AUTOMATED task type is used without VideoPrompt' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI     = 's3://mybucket'
                        TaskType        = 'MULTI_SHOT_AUTOMATED'
                        DurationSeconds = 12
                        ModelID         = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_AUTOMATED task type is used with VideoPrompt exceeding 4000 characters' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt     = 'a' * 4001  # Exceeds 4000 character limit
                        S3OutputURI     = 's3://mybucket'
                        TaskType        = 'MULTI_SHOT_AUTOMATED'
                        DurationSeconds = 12
                        ModelID         = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_MANUAL task type is used without Shots array' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_MANUAL task type is used with insufficient shots' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A cat playing with a ball."
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if a non supported model is requested' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        ModelID     = 'NotSupported'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered calling the model API' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith { throw 'Error' }
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
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
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
                Should -Invoke Write-Warning -Exactly 3
            } #it

            It 'should throw if nothing is returned from the API call' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith { $null }
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
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
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'amazon.nova-reel-v1:1'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
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
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt       = 'Create a video of a cat playing with a ball.'
                        S3OutputURI       = 's3://mybucket'
                        ModelID           = 'amazon.nova-reel-v1:1'
                        AttemptS3Download = $true
                        LocalSavePath     = 'C:\temp'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw

                Should -Invoke Write-Warning -Times 1
                Should -Invoke Write-Error -Times 1
            } #it

            It 'should throw if MediaPath does not exist' {
                Mock -CommandName Test-Path -MockWith {
                    if ($IsValid) {
                        return $true
                    }
                    return $false
                }
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        MediaPath   = 'C:\nonexistent\image.jpg'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MediaPath has an unsupported format' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        MediaPath   = 'C:\test\image.gif'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if Convert-MediaToBase64 fails' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { throw 'Base64 conversion error' }
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt = 'Create a video of a cat playing with a ball.'
                        S3OutputURI = 's3://mybucket'
                        MediaPath   = 'C:\test\image.jpg'
                        ModelID     = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
                Should -Invoke Write-Error -Times 2
            } #it

            It 'should throw if MULTI_SHOT_AUTOMATED with invalid duration is requested' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt     = 'Create a video of a cat playing with a ball.'
                        S3OutputURI     = 's3://mybucket'
                        TaskType        = 'MULTI_SHOT_AUTOMATED'
                        DurationSeconds = 7  # Not a multiple of 6
                        ModelID         = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_AUTOMATED with duration too short is requested' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt     = 'Create a video of a cat playing with a ball.'
                        S3OutputURI     = 's3://mybucket'
                        TaskType        = 'MULTI_SHOT_AUTOMATED'
                        DurationSeconds = 6   # Too short for MULTI_SHOT_AUTOMATED
                        ModelID         = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if MULTI_SHOT_AUTOMATED with duration too long is requested' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        VideoPrompt     = 'Create a video of a cat playing with a ball.'
                        S3OutputURI     = 's3://mybucket'
                        TaskType        = 'MULTI_SHOT_AUTOMATED'
                        DurationSeconds = 126  # Exceeds the 120 second limit
                        ModelID         = 'amazon.nova-reel-v1:1'
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if the shot text is missing in MULTI_SHOT_MANUAL' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A valid text"
                            },
                            @{
                                # Missing text
                                ImagePath = "C:\images\image.jpg"
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if shot text length is too long in MULTI_SHOT_MANUAL' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A valid text"
                            },
                            @{
                                Text = "a" * 513  # Exceeds 512 character limit
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if shot image path does not exist in MULTI_SHOT_MANUAL' {
                Mock -CommandName Test-Path -MockWith {
                    param($Path, $IsValid)
                    if ($IsValid -or $Path -eq 'C:\images\valid.jpg') {
                        return $true
                    }
                    return $false
                }
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A valid text"
                            },
                            @{
                                Text      = "Shot 2: With invalid image"
                                ImagePath = "C:\images\invalid.jpg"
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if shot image format is unsupported in MULTI_SHOT_MANUAL' {
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A valid text"
                            },
                            @{
                                Text      = "Shot 2: With invalid image format"
                                ImagePath = "C:\images\image.gif"  # Unsupported format
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
            } #it

            It 'should throw if image conversion fails in MULTI_SHOT_MANUAL' {
                Mock -CommandName Convert-MediaToBase64 -MockWith {
                    param($MediaPath)
                    if ($MediaPath -eq 'C:\images\problem.jpg') {
                        throw 'Base64 conversion error'
                    }
                    return 'base64string'
                }
                {
                    $invokeAmazonVideoModelSplat = @{
                        S3OutputURI = 's3://mybucket'
                        TaskType    = 'MULTI_SHOT_MANUAL'
                        ModelID     = 'amazon.nova-reel-v1:1'
                        Shots       = @(
                            @{
                                Text = "Shot 1: A valid text"
                            },
                            @{
                                Text      = "Shot 2: With problematic image"
                                ImagePath = "C:\images\problem.jpg"
                            }
                        )
                    }
                    Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat
                } | Should -Throw
                Should -Invoke Write-Error -Times 2
            } #it

            It 'should handle error in cost estimation' {
                Mock -CommandName Add-ModelCostEstimate -MockWith {
                    throw 'Cost estimation error'
                }
                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    S3OutputURI = 's3://mybucket'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }

                # Should not throw despite the cost estimation error
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'Failed to calculate cost estimate.'
                } -Times 1

                # The function should still return the expected result
                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
            } #it

            It 'should handle unexpected job status' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Failed'
                        FailureMessage   = 'Some error occurred'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }

                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }

                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'Job is in unexpected state: Failed'
                } -Times 1

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'Failure message: Some error occurred'
                } -Times 1

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'This was the returned InvocationArn: arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Times 1

                $result.Status | Should -Be 'Failed'
                $result.FailureMessage | Should -Be 'Some error occurred'
            } #it

            It 'should handle content filter rejection' {
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    $jobStatus = [PSCustomObject]@{
                        Status           = 'Failed'
                        FailureMessage   = 'Request rejected by content filters'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }

                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }

                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'The request was blocked by AWS responsible AI content filters.'
                } -Times 1

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'Please adjust your text prompt or input image to comply with AWS content policies.'
                } -Times 1

                $result.Status | Should -Be 'Failed'
            } #it

        } #context

        Context 'Success' {
            BeforeEach {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64string' }
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
                Mock -CommandName Join-Path -MockWith { 'afilePath' }
                Mock -CommandName Copy-S3Object -MockWith { }
                Mock -CommandName Add-ModelCostEstimate -MockWith { }
            } #beforeEach

            It 'should return invocation ARN when not attempting S3 download - TEXT_VIDEO' {
                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    S3OutputURI = 's3://mybucket'
                    TaskType    = 'TEXT_VIDEO'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Message | Should -Not -BeNullOrEmpty
                $result.TaskType | Should -Be 'TEXT_VIDEO'
                $result.DurationSeconds | Should -Be 6
            } #it

            It 'should return invocation ARN when not attempting S3 download - MULTI_SHOT_AUTOMATED' {
                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt     = 'Create a video of a cat playing through all four seasons.'
                    S3OutputURI     = 's3://mybucket'
                    TaskType        = 'MULTI_SHOT_AUTOMATED'
                    DurationSeconds = 24
                    ModelID         = 'amazon.nova-reel-v1:1'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Message | Should -Not -BeNullOrEmpty
                $result.TaskType | Should -Be 'MULTI_SHOT_AUTOMATED'
                $result.DurationSeconds | Should -Be 24
            } #it

            It 'should return invocation ARN when not attempting S3 download - MULTI_SHOT_MANUAL' {
                $shots = @(
                    @{
                        Text = "Shot 1: A cat plays with a red ball in spring time."
                    },
                    @{
                        Text = "Shot 2: A cat plays with a blue ball in summer time."
                    }
                )
                $invokeAmazonVideoModelSplat = @{
                    S3OutputURI = 's3://mybucket'
                    TaskType    = 'MULTI_SHOT_MANUAL'
                    Shots       = $shots
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Message | Should -Not -BeNullOrEmpty
                $result.TaskType | Should -Be 'MULTI_SHOT_MANUAL'
                $result.DurationSeconds | Should -Be 12  # 2 shots * 6 seconds each
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

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Status | Should -Be 'Completed'
                $result.LocalFilePath | Should -Not -BeNullOrEmpty
                $result.S3Uri | Should -Be 's3://bedrockvideotestbucket/xxxxxxxxx/output.mp4'
                Should -Invoke Copy-S3Object -Times 1
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should just return the invocation ARN if no S3 output URI is found in the job results' {
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

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Status | Should -Be 'Completed'
                $result.Message | Should -Not -BeNullOrEmpty
            } #it

            It 'should just return the invocation ARN if the S3 URI returned is not in an expected format' {
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

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Status | Should -Be 'Completed'
                $result.Message | Should -Not -BeNullOrEmpty
            } #it

            It 'should create the expected model input for TEXT_VIDEO task type' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $ModelInput.taskType | Should -Be 'TEXT_VIDEO'
                    $ModelInput.textToVideoParams | Should -Not -BeNullOrEmpty
                    $ModelInput.textToVideoParams.text | Should -Be 'Create a video of a cat playing with a ball.'
                    $ModelInput.videoGenerationConfig.durationSeconds | Should -Be 6
                    $ModelInput.videoGenerationConfig.fps | Should -Be 24
                    $ModelInput.videoGenerationConfig.dimension | Should -Be '1280x720'
                    $ModelInput.videoGenerationConfig.seed | Should -Be 42
                    $S3OutputDataConfig_S3Uri | Should -Be 's3://mybucket'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    S3OutputURI = 's3://mybucket'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should create the expected model input for TEXT_VIDEO with image' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $ModelInput.taskType | Should -Be 'TEXT_VIDEO'
                    $ModelInput.textToVideoParams | Should -Not -BeNullOrEmpty
                    $ModelInput.textToVideoParams.text | Should -Be 'Create a video of a cat playing with a ball.'
                    $ModelInput.textToVideoParams.images | Should -Not -BeNullOrEmpty
                    $ModelInput.textToVideoParams.images[0].format | Should -Be 'jpeg'
                    $ModelInput.textToVideoParams.images[0].source.bytes | Should -Be 'base64string'
                    $ModelInput.videoGenerationConfig.durationSeconds | Should -Be 6
                    $S3OutputDataConfig_S3Uri | Should -Be 's3://mybucket'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    MediaPath   = 'C:\images\cat.jpg'
                    S3OutputURI = 's3://mybucket'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should create the expected model input for MULTI_SHOT_AUTOMATED' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $ModelInput.taskType | Should -Be 'MULTI_SHOT_AUTOMATED'
                    $ModelInput.multiShotAutomatedParams | Should -Not -BeNullOrEmpty
                    $ModelInput.multiShotAutomatedParams.text | Should -Be 'Create a video of a cat playing through the seasons.'
                    $ModelInput.videoGenerationConfig.durationSeconds | Should -Be 24
                    $S3OutputDataConfig_S3Uri | Should -Be 's3://mybucket'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt     = 'Create a video of a cat playing through the seasons.'
                    S3OutputURI     = 's3://mybucket'
                    TaskType        = 'MULTI_SHOT_AUTOMATED'
                    DurationSeconds = 24
                    ModelID         = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should create the expected model input for MULTI_SHOT_MANUAL' {
                $shots = @(
                    @{
                        Text = "Shot 1: A cat plays with a red ball."
                    },
                    @{
                        Text      = "Shot 2: A cat plays with a blue ball."
                        ImagePath = "C:\images\cat.jpg"
                    }
                )

                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $ModelInput.taskType | Should -Be 'MULTI_SHOT_MANUAL'
                    $ModelInput.multiShotManualParams | Should -Not -BeNullOrEmpty
                    $ModelInput.multiShotManualParams.shots | Should -Not -BeNullOrEmpty
                    $ModelInput.multiShotManualParams.shots.Count | Should -Be 2
                    $ModelInput.multiShotManualParams.shots[0].text | Should -Be 'Shot 1: A cat plays with a red ball.'
                    $ModelInput.multiShotManualParams.shots[1].text | Should -Be 'Shot 2: A cat plays with a blue ball.'
                    $ModelInput.multiShotManualParams.shots[1].image | Should -Not -BeNullOrEmpty
                    $ModelInput.multiShotManualParams.shots[1].image.format | Should -Be 'jpeg'
                    $ModelInput.multiShotManualParams.shots[1].image.source.bytes | Should -Be 'base64string'
                    $S3OutputDataConfig_S3Uri | Should -Be 's3://mybucket'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    S3OutputURI = 's3://mybucket'
                    TaskType    = 'MULTI_SHOT_MANUAL'
                    Shots       = $shots
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should return the expected result when all parameters are provided' {
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput | Should -Not -BeNullOrEmpty
                    $S3OutputDataConfig_BucketOwner | Should -Be '123456789012'
                    $S3OutputDataConfig_KmsKeyId | Should -Be 'arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
                    $Region | Should -Be 'us-west-2'

                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt         = 'Create a video of a cat playing with a ball.'
                    S3OutputURI         = 's3://mybucket'
                    Seed                = 100
                    ModelID             = 'amazon.nova-reel-v1:1'
                    S3OutputBucketOwner = '123456789012'
                    S3OutputKmsKeyId    = 'arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
                    JobCheckInterval    = 60
                    JobTimeout          = 15
                    Region              = 'us-west-2'
                    AccessKey           = 'ak'
                    SecretKey           = 'sk'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call Add-ModelCostEstimate with correct duration' {
                Mock -CommandName Add-ModelCostEstimate -MockWith {
                    $Duration | Should -Be 6
                    $ModelID | Should -Be 'amazon.nova-reel-v1:1'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    S3OutputURI = 's3://mybucket'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should return the expected results when the job takes too long' {
                $script:dateCallCount = 0
                $script:now = Get-Date
                $script:second = $now.AddMinutes(1)
                $script:pastTime = $now.AddMinutes(21)
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
                        Status           = 'InProgress'
                        OutputDataConfig = [PSCustomObject]@{
                            S3OutputDataConfig = [PSCustomObject]@{
                                S3Uri = 's3://bedrockvideotestbucket/xxxxxxxxx'
                            }
                        }
                    }
                    return $jobStatus
                }

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Get-BDRRAsyncInvoke -Times 2
                $result.InvocationArn | Should -Be 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                $result.Status | Should -Be 'Timeout'
                $result.Message | Should -Not -BeNullOrEmpty
                Should -Invoke Add-ModelCostEstimate -Exactly 1 -Scope It
            } #it

            It 'should call the API with the expected credentials' {
                $awsCred = [Amazon.Runtime.BasicAWSCredentials]::new('FAKEACCESSKEY', 'FAKESECRETKEY')
                $networkCred = [System.Management.Automation.PSCredential]::new('FAKEUSERNAME',
                    (ConvertTo-SecureString -String 'FAKEPASSWORD' -AsPlainText -Force))

                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $Region             | Should -BeExactly 'us-west-2'
                    $ModelID            | Should -BeExactly 'amazon.nova-reel-v1:1'
                    $Credential         | Should -Not -BeNullOrEmpty
                    $EndpointUrl        | Should -BeExactly 'endpoint.aws'
                    $NetworkCredential  | Should -Not -BeNullOrEmpty
                    $ProfileLocation    | Should -BeExactly 'default'
                    $ProfileName        | Should -BeExactly 'default'
                    $SessionToken       | Should -BeExactly 'token'
                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a video of a cat playing with a ball.'
                    S3OutputURI       = 's3://mybucket'
                    ModelID           = 'amazon.nova-reel-v1:1'
                    Credential        = $awsCred
                    EndpointUrl       = 'endpoint.aws'
                    NetworkCredential = $networkCred
                    ProfileLocation   = 'default'
                    ProfileName       = 'default'
                    Region            = 'us-west-2'
                    SessionToken      = 'token'
                }

                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should adjust DurationSeconds to 6 for TEXT_VIDEO task type' {
                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt     = 'Create a video of a cat playing with a ball.'
                    S3OutputURI     = 's3://mybucket'
                    ModelID         = 'amazon.nova-reel-v1:1'
                    DurationSeconds = 10  # Invalid for TEXT_VIDEO, should be adjusted to 6
                }
                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'For TEXT_VIDEO task type, DurationSeconds must be 6. Setting to 6.'
                } -Times 1

                $result.DurationSeconds | Should -Be 6
            } #it

            It 'should warn when MediaPath is ignored for MULTI_SHOT_AUTOMATED task type' {
                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt     = 'Create a video of a cat playing through the seasons.'
                    S3OutputURI     = 's3://mybucket'
                    TaskType        = 'MULTI_SHOT_AUTOMATED'
                    DurationSeconds = 12
                    MediaPath       = 'C:\test\image.jpg'  # Should be ignored
                    ModelID         = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'MediaPath is ignored for MULTI_SHOT_AUTOMATED task type.'
                } -Times 1
            } #it

            It 'should warn when VideoPrompt and MediaPath are ignored for MULTI_SHOT_MANUAL task type' {
                Mock -CommandName Write-Warning -MockWith { } -Verifiable

                $shots = @(
                    @{
                        Text = "Shot 1: A cat plays with a red ball in spring time."
                    },
                    @{
                        Text = "Shot 2: A cat plays with a blue ball in summer time."
                    }
                )
                $invokeAmazonVideoModelSplat = @{
                    S3OutputURI = 's3://mybucket'
                    TaskType    = 'MULTI_SHOT_MANUAL'
                    Shots       = $shots
                    VideoPrompt = 'This should be ignored'  # Should be ignored
                    MediaPath   = 'C:\test\image.jpg'      # Should be ignored
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'VideoPrompt is ignored for MULTI_SHOT_MANUAL task type.'
                } -Times 1
                Should -Invoke Write-Warning -ParameterFilter {
                    $Message -eq 'MediaPath is ignored for MULTI_SHOT_MANUAL task type.'
                } -Times 1
            } #it

            It 'should correctly handle PNG image format for TEXT_VIDEO task type' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64string' }
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput.textToVideoParams.images[0].format | Should -Be 'png'
                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt = 'Create a video of a cat playing with a ball.'
                    MediaPath   = 'C:\images\cat.png'  # PNG format
                    S3OutputURI = 's3://mybucket'
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should correctly handle JPEG image format for MULTI_SHOT_MANUAL task type' {
                Mock -CommandName Convert-MediaToBase64 -MockWith { 'base64string' }
                Mock -CommandName Start-BDRRAsyncInvoke -MockWith {
                    $ModelInput.multiShotManualParams.shots[1].image.format | Should -Be 'jpeg'
                    return 'arn:aws:bedrock:us-west-2:XXXXXXXXXXX:async-invoke/xxxxxxxxx'
                } -Verifiable

                $shots = @(
                    @{
                        Text = "Shot 1: A cat plays with a red ball."
                    },
                    @{
                        Text      = "Shot 2: A cat plays with a blue ball."
                        ImagePath = "C:\images\cat.jpeg"  # JPEG format
                    }
                )

                $invokeAmazonVideoModelSplat = @{
                    S3OutputURI = 's3://mybucket'
                    TaskType    = 'MULTI_SHOT_MANUAL'
                    Shots       = $shots
                    ModelID     = 'amazon.nova-reel-v1:1'
                }
                Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat | Should -InvokeVerifiable
            } #it

            It 'should correctly calculate expected duration for MULTI_SHOT_AUTOMATED task type' {
                # Setup mock to verify time calculation
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    if ($script:AsyncCallCount -le 1) {
                        $script:AsyncCallCount += 1
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
                    else {
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
                }

                Mock -CommandName Start-Sleep -MockWith { }

                $script:now = Get-Date
                $script:second = $now.AddSeconds(10)
                $script:third = $now.AddSeconds(20)

                $script:dateCallCount = 0
                Mock -CommandName Get-Date -MockWith {
                    $script:dateCallCount++
                    if ($script:dateCallCount -eq 1) {
                        return $script:now
                    }
                    elseif ($script:dateCallCount -eq 2) {
                        return $script:second
                    }
                    else {
                        return $script:third
                    }
                }

                $script:AsyncCallCount = 0

                $invokeAmazonVideoModelSplat = @{
                    VideoPrompt       = 'Create a long video of a cat playing through the seasons.'
                    S3OutputURI       = 's3://mybucket'
                    TaskType          = 'MULTI_SHOT_AUTOMATED'
                    DurationSeconds   = 24  # 4 shots of 6 seconds each
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                    JobCheckInterval  = 10  # Minimum allowed value
                }

                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                # Check that the calculation path for MULTI_SHOT_AUTOMATED was covered
                $result.Status | Should -Be 'Completed'
            } #it

            It 'should correctly calculate expected duration for MULTI_SHOT_MANUAL task type' {
                # Setup mock to verify time calculation
                Mock -CommandName Get-BDRRAsyncInvoke -MockWith {
                    if ($script:AsyncCallCount -le 1) {
                        $script:AsyncCallCount += 1
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
                    else {
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
                }

                Mock -CommandName Start-Sleep -MockWith { }

                $script:now = Get-Date
                $script:second = $now.AddSeconds(10)
                $script:third = $now.AddSeconds(20)

                $script:dateCallCount = 0
                Mock -CommandName Get-Date -MockWith {
                    $script:dateCallCount++
                    if ($script:dateCallCount -eq 1) {
                        return $script:now
                    }
                    elseif ($script:dateCallCount -eq 2) {
                        return $script:second
                    }
                    else {
                        return $script:third
                    }
                }

                $script:AsyncCallCount = 0
                $shots = @(
                    @{
                        Text = "Shot 1: A cat plays with a red ball in spring time."
                    },
                    @{
                        Text = "Shot 2: A cat plays with a blue ball in summer time."
                    },
                    @{
                        Text = "Shot 3: A cat plays with a green ball in fall time."
                    }
                )
                $invokeAmazonVideoModelSplat = @{
                    S3OutputURI       = 's3://mybucket'
                    TaskType          = 'MULTI_SHOT_MANUAL'
                    Shots             = $shots  # 3 shots
                    ModelID           = 'amazon.nova-reel-v1:1'
                    AttemptS3Download = $true
                    LocalSavePath     = 'C:\temp'
                    JobCheckInterval  = 10  # Minimum allowed value
                }

                $result = Invoke-AmazonVideoModel @invokeAmazonVideoModelSplat

                # Check that the calculation path for MULTI_SHOT_MANUAL was covered
                $result.Status | Should -Be 'Completed'
            } #it

        } #context
    } #describe
} #inModuleScope
