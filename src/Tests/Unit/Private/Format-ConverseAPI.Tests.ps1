BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {

    Describe 'Format-ConverseAPI Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
                Mock -CommandName Convert-MediaToMemoryStream -MockWith {
                    [System.IO.MemoryStream]::new()
                } #endMock
            } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-ConverseAPI -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-ConverseAPI -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'Converse' } | Should -Throw
            } #it

            It 'should throw if an error is encountered while getting media file info' {
                Mock -CommandName Get-Item -MockWith { throw 'Failed to get media file info' }
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        ImagePath = 'path/to/media.jpg'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Get-Item does not return an extension' {
                Mock -CommandName Get-Item -MockWith { $null }
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        ImagePath = 'path/to/media.jpg'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Convert-MediaToMemoryStream fails' {
                Mock -CommandName Convert-MediaToMemoryStream -MockWith {
                    throw 'Failed to convert base64 to memory stream'
                } #endMock
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        ImagePath = 'path/to/media.jpg'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered while getting document file info' {
                Mock -CommandName Get-Item -MockWith { throw 'Failed to get document file info' }
                {
                    $formatConverseAPISplat = @{
                        Role         = 'user'
                        Message      = 'Live long and prosper!'
                        ModelID      = 'Converse'
                        DocumentPath = 'path/to/document.pdf'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Get-Item does not return an extension' {
                Mock -CommandName Get-Item -MockWith { $null }
                {
                    $formatConverseAPISplat = @{
                        Role         = 'user'
                        Message      = 'Live long and prosper!'
                        ModelID      = 'Converse'
                        DocumentPath = 'path/to/document.pdf'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Convert-MediaToMemoryStream fails' {
                Mock -CommandName Convert-MediaToMemoryStream -MockWith {
                    throw 'Failed to convert base64 to memory stream'
                } #endMock
                {
                    $formatConverseAPISplat = @{
                        Role         = 'user'
                        Message      = 'Live long and prosper!'
                        ModelID      = 'Converse'
                        DocumentPath = 'path/to/document.pdf'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if an error is encountered while getting video file info' {
                Mock -CommandName Get-Item -MockWith { throw 'Failed to get video file info' }
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        VideoPath = 'path/to/video.mp4'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Get-Item does not return an extension for video' {
                Mock -CommandName Get-Item -MockWith { $null }
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        VideoPath = 'path/to/video.mp4'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Convert-MediaToMemoryStream fails for video' {
                Mock -CommandName Convert-MediaToMemoryStream -MockWith {
                    throw 'Failed to convert video to memory stream'
                } #endMock
                {
                    $formatConverseAPISplat = @{
                        Role      = 'user'
                        Message   = 'Live long and prosper!'
                        ModelID   = 'Converse'
                        VideoPath = 'path/to/video.mp4'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

            It 'should throw if Get-S3Extension returns null' {
                Mock -CommandName Get-S3Extension -MockWith {
                    return $null
                } #endMock
                {
                    $formatConverseAPISplat = @{
                        Role       = 'user'
                        Message    = 'Live long and prosper!'
                        ModelID    = 'Converse'
                        S3Location = 's3://my-bucket/path/to/video'
                    }
                    Format-ConverseAPI @formatConverseAPISplat
                } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {
            BeforeEach {
                Reset-ModelContext -AllModels -Force
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{ Extension = '.jpg' }
                } #endMock
                Mock -CommandName Convert-MediaToMemoryStream -MockWith {
                    [System.IO.MemoryStream]::new()
                } #endMock
                Mock -CommandName Get-S3Extension -MockWith {
                    return 'mp4'
                } #endMock
                $toolResult = [PSCustomObject]@{
                    ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name    = 'Gristmill River Restaurant & Bar'
                            address = '1287 Gruene Rd, New Braunfels, TX 78130'
                            rating  = '4.5'
                            cuisine = 'American'
                            budget  = '2'
                        }
                    }
                    status    = 'success'
                }
                $toolResultError = [PSCustomObject]@{
                    ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                    Content   = 'I am sorry, I could not find any restaurants in New Braunfels, TX.'
                    status    = 'error'
                }
                #_______________________________________________________________
                $assistantMessage = [Amazon.BedrockRuntime.Model.Message]::new()
                $assistantMessage.Role = 'assistant'
                $assistantMessageContent = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                $assistantMessageContent.Text = 'I am a model'
                $assistantMessage.Content = $assistantMessageContent
                #_______________________________________________________________
                $assistantToolCallMessage = [Amazon.BedrockRuntime.Model.Message]::new()
                $assistantToolCallMessage.Role = 'assistant'
                $assistantToolCallMessageContentBlock = [Amazon.BedrockRuntime.Model.ContentBlock]::new()
                $assistantToolUse = [Amazon.BedrockRuntime.Model.ToolUseBlock]::new()
                $assistantToolUse.ToolUseId = 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                $assistantToolUse.Name = 'restaurant'
                $inputObj = [PSCustomObject]@{
                    location = 'New Braunfels, TX'
                }
                $assistantToolUse.Input = [Amazon.Runtime.Documents.Document]::FromObject($inputObj)
                $assistantToolCallMessageContentBlock.ToolUse = $assistantToolUse
                $assistantToolCallMessage.Content = $assistantToolCallMessageContentBlock
            } #beforeEach

            It 'should return a Amazon.BedrockRuntime.Model.Message with the expected values for a standard message' {
                $formatConverseAPISplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'Converse'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Role | Should -BeExactly 'user'
                $result.Content.Text | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.Message with the expected values for an assistant message' {
                $formatConverseAPISplat = @{
                    Role          = 'assistant'
                    ReturnMessage = $assistantMessage
                    ModelID       = 'Converse'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Role | Should -BeExactly 'assistant'
                $result.Content.Text | Should -BeExactly 'I am a model'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.ImageBlock with the expected values if media is provided' {
                $formatConverseAPISplat = @{
                    Role      = 'user'
                    ModelID   = 'Converse'
                    ImagePath = 'path/to/media.jpg'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Image | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageBlock'
                $result.Content.Image.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageSource'
                $result.Content.Image.Format.Value | Should -BeExactly 'jpeg'
                $result.Content.Image.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
            } #it

            It 'should add on a message if a message is specified along with media' {
                $formatConverseAPISplat = @{
                    Role      = 'user'
                    Message   = 'The needs of the many outweigh the needs of the few.'
                    ModelID   = 'Converse'
                    ImagePath = 'path/to/media.jpg'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content[1].Text | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return the expected results if multiple media is provided' {
                $formatConverseAPISplat = @{
                    Role      = 'user'
                    ModelID   = 'Converse'
                    ImagePath = @('path/to/media1.jpg', 'path/to/media2.jpg')
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content[0].Image | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageBlock'
                $result.Content[0].Image.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageSource'
                $result.Content[0].Image.Format.Value | Should -BeExactly 'jpeg'
                $result.Content[0].Image.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
                $result.Content[1].Image | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageBlock'
                $result.Content[1].Image.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.ImageSource'
                $result.Content[1].Image.Format.Value | Should -BeExactly 'jpeg'
                $result.Content[1].Image.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.DocumentBlock with the expected values if document is provided' {
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        BaseName  = 'document'
                        Extension = '.pdf'
                    }
                } #endMock
                $formatConverseAPISplat = @{
                    Role         = 'user'
                    ModelID      = 'Converse'
                    DocumentPath = 'path/to/document.pdf'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Document | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentBlock'
                $result.Content.Document.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentSource'
                $result.Content.Document.Format.Value | Should -BeExactly 'pdf'
                $result.Content.Document.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
                $result.Content.Document.Name | Should -BeExactly 'document'
            } #it

            It 'should add on a message if a message is specified along with document' {
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        BaseName  = 'document'
                        Extension = '.pdf'
                    }
                } #endMock
                $formatConverseAPISplat = @{
                    Role         = 'user'
                    Message      = 'The needs of the many outweigh the needs of the few.'
                    ModelID      = 'Converse'
                    DocumentPath = 'path/to/document.pdf'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content[1].Text | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.VideoBlock with the expected values if video is provided' {
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Extension = '.mp4'
                    }
                } #endMock
                $formatConverseAPISplat = @{
                    Role      = 'user'
                    ModelID   = 'Converse'
                    VideoPath = 'path/to/video.mp4'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Video | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoBlock'
                $result.Content.Video.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoSource'
                $result.Content.Video.Format.Value | Should -BeExactly 'mp4'
                $result.Content.Video.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream' } #it

            It 'should return a Amazon.BedrockRuntime.Model.VideoBlock with the expected values if S3Location is provided' {
                $formatConverseAPISplat = @{
                    Role       = 'user'
                    ModelID    = 'Converse'
                    S3Location = 's3://my-bucket/path/to/video.mp4'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Video | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoBlock'
                $result.Content.Video.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoSource'
                $result.Content.Video.Format.Value | Should -BeExactly 'mp4'
                $result.Content.Video.Source.S3Location | Should -BeOfType 'Amazon.BedrockRuntime.Model.S3Location'
                $result.Content.Video.Source.S3Location.Uri | Should -BeExactly 's3://my-bucket/path/to/video.mp4'
            } #it

            It 'should include S3BucketOwner in the S3Location if provided' {
                $formatConverseAPISplat = @{
                    Role          = 'user'
                    ModelID       = 'Converse'
                    S3Location    = 's3://my-bucket/path/to/video.mp4'
                    S3BucketOwner = '123456789012'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Video | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoBlock'
                $result.Content.Video.Source.S3Location.BucketOwner | Should -BeExactly '123456789012'
            } #it

            It 'should convert jpg to jpeg in S3Location' {
                Mock -CommandName Get-S3Extension -MockWith {
                    return 'jpg'
                } #endMock
                $formatConverseAPISplat = @{
                    Role       = 'user'
                    ModelID    = 'Converse'
                    S3Location = 's3://my-bucket/path/to/image.jpg'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content.Video | Should -BeOfType 'Amazon.BedrockRuntime.Model.VideoBlock'
                $result.Content.Video.Format.Value | Should -BeExactly 'jpeg'
            } #it

            It 'should return the expected results if multiple media is provided' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        $obj = [PSCustomObject]@{
                            BaseName  = 'document1'
                            Extension = '.pdf'
                        }
                        return $obj
                    }
                    elseif ($script:mockCalled -eq 2) {
                        $obj = [PSCustomObject]@{
                            BaseName  = 'document2'
                            Extension = '.pdf'
                        }
                        return $obj
                    }
                }
                Mock -CommandName Get-Item -MockWith $mockInvoke
                $formatConverseAPISplat = @{
                    Role         = 'user'
                    ModelID      = 'Converse'
                    DocumentPath = @('path/to/document1.pdf', 'path/to/document2.pdf')
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Content[0].Document | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentBlock'
                $result.Content[0].Document.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentSource'
                $result.Content[0].Document.Format.Value | Should -BeExactly 'pdf'
                $result.Content[0].Document.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
                $result.Content[0].Document.Name | Should -BeExactly 'document1'
                $result.Content[1].Document | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentBlock'
                $result.Content[1].Document.Source | Should -BeOfType 'Amazon.BedrockRuntime.Model.DocumentSource'
                $result.Content[1].Document.Format.Value | Should -BeExactly 'pdf'
                $result.Content[1].Document.Source.Bytes | Should -BeOfType 'System.IO.MemoryStream'
                $result.Content[1].Document.Name | Should -BeExactly 'document2'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.Message with the expected values for a successful tool results message' {
                $formatConverseAPISplat = @{
                    Role         = 'user'
                    ToolsResults = $toolResult
                    ModelID      = 'Converse'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Role | Should -BeExactly 'user'
                $result.Content.ToolResult.ToolUseId | Should -BeExactly 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                $result.Content.ToolResult.Status | Should -BeExactly 'success'
                # $result.Content.ToolResult.Content.Json | Should -BeOfType 'Amazon.Runtime.Documents.Document'
            } #it

            It 'should return a Amazon.BedrockRuntime.Model.Message with the expected values for a failed tool results message' {
                $formatConverseAPISplat = @{
                    Role         = 'user'
                    ToolsResults = $toolResultError
                    ModelID      = 'Converse'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Role | Should -BeExactly 'user'
                $result.Content.ToolResult.ToolUseId | Should -BeExactly 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                $result.Content.ToolResult.Status | Should -BeExactly 'error'
                $result.Content.ToolResult.Content.Text | Should -BeExactly 'I am sorry, I could not find any restaurants in New Braunfels, TX.'
            } #it

            It 'should properly format an assistant message if tool call is provided' {
                $formatConverseAPISplat = @{
                    Role          = 'assistant'
                    ReturnMessage = $assistantToolCallMessage
                    ModelID       = 'Converse'
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Message'
                $result.Role | Should -BeExactly 'assistant'
                $result.Content.ToolUse.ToolUseId | Should -BeExactly 'tooluse_ihA1_9blR3S1QJixGq5gwg'
                $result.Content.ToolUse.Name | Should -BeExactly 'restaurant'
            } #it

            It 'should not populate context if NoContextPersist is set to true' {
                $formatConverseAPISplat = @{
                    Role             = 'user'
                    Message          = 'I am not a merry man.'
                    ModelID          = 'Converse'
                    NoContextPersist = $true
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context.Context | Should -BeNullOrEmpty
            } #it

            It 'should populate context if NoContextPersist is set to false' {
                $formatConverseAPISplat = @{
                    Role             = 'user'
                    Message          = 'I am not a merry man.'
                    ModelID          = 'Converse'
                    NoContextPersist = $false
                }
                $result = Format-ConverseAPI @formatConverseAPISplat
                $context = $Global:pwshBedrockModelContext | Where-Object { $_.ModelID -eq 'Converse' }
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context.Context | Should -Not -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-ConverseAPI
} #inModule
