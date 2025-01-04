BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    # if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

$script:supportedMediaExtensions = @(
    'JPG'
    'JPEG'
    'PNG'
    'GIF'
    'WEBP'
)

InModuleScope 'pwshBedrock' {
    Describe 'Test-AmazonNovaCustomConversation Private Function Tests' -Tag Unit {

        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        }

        Context 'Success' {

            BeforeEach {
                # A valid standard (text) conversation
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            text = 'Hello Amazon Nova, how are you?'
                        }
                    )
                }

                # A valid assistant role with text
                $assistantMessage = [PSCustomObject]@{
                    role    = 'assistant'
                    content = @(
                        [PSCustomObject]@{
                            text = 'I am fine, thank you for asking!'
                        }
                    )
                }

                # A valid image conversation
                $imageMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            image = [PSCustomObject]@{
                                format = 'jpg'
                                source = [PSCustomObject]@{
                                    bytes = 'base64encodedstring'
                                }
                            }
                        },
                        [PSCustomObject]@{
                            text = 'Check out this image!'
                        }
                    )
                }

                # A valid video conversation
                $videoMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            video = [PSCustomObject]@{
                                format = 'mp4'
                                source = [PSCustomObject]@{
                                    bytes = 'base64encodedstring'
                                }
                            }
                        },
                        [PSCustomObject]@{
                            text = 'Check out this video!'
                        }
                    )
                }
            } #beforEach

            It 'Should return true for a valid standard message' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $standardMessage
                $result | Should -Be $true
            } #it

            It 'Should return true for a valid assistant message' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $assistantMessage
                $result | Should -Be $true
            } #it

            It 'Should return true for a valid image message' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $imageMessage
                $result | Should -Be $true
            } #it

            It 'Should return true for a valid video message' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $videoMessage
                $result | Should -Be $true
            } #it
        } #context_success

        Context 'Errors / Negative Tests' {

            BeforeEach {
                # role is not user or assistant
                $incorrectRoleConversation = [PSCustomObject]@{
                    role    = 'nope'
                    content = @(
                        [PSCustomObject]@{
                            text = 'Invalid role conversation.'
                        }
                    )
                }

                # Missing role property entirely
                $missingRoleConversation = [PSCustomObject]@{
                    content = @(
                        [PSCustomObject]@{
                            text = 'Missing role property.'
                        }
                    )
                }

                # Role is present but value is null or whitespace
                $nullOrWhitespaceRoleConversation = [PSCustomObject]@{
                    role    = ''
                    content = @(
                        [PSCustomObject]@{
                            text = 'Whitespace or null role.'
                        }
                    )
                }

                # Missing content property
                $missingContentConversation = [PSCustomObject]@{
                    role = 'user'
                }

                # Content array has a valid PSCustomObject but with an unknown property
                $unknownMessageTypeConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            someOtherProperty = 'something'
                        }
                    )
                }

                # Malformed text message - text is not a string
                $malformedTextConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        # text property is an int
                        [PSCustomObject]@{
                            text = 123
                        }
                    )
                }

                # Malformed text message - text is whitespace/empty
                $emptyTextConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            text = $null
                        }
                    )
                }

                # Malformed conversation: content item is simply a string (not an object)
                $contentIsStringConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        'this is not an object'
                    )
                }

                # Image message missing required 'format'
                $imageNoFormatConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            image = [PSCustomObject]@{
                                source = [PSCustomObject]@{
                                    bytes = 'base64encodedstring'
                                }
                            }
                        }
                    )
                }

                # Image message missing required 'bytes'
                $imageNoBytesConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            image = [PSCustomObject]@{
                                format = 'png'
                                source = [PSCustomObject]@{
                                    # missing bytes
                                }
                            }
                        }
                    )
                }

                # Video message missing required 'format'
                $videoNoFormatConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            video = [PSCustomObject]@{
                                source = [PSCustomObject]@{
                                    bytes = 'base64encodedstring'
                                }
                            }
                        }
                    )
                }

                # Video message missing required 'bytes'
                $videoNoBytesConversation = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            video = [PSCustomObject]@{
                                format = 'mp4'
                                source = [PSCustomObject]@{
                                    # missing bytes
                                }
                            }
                        }
                    )
                }
            } #beforeEach

            It 'Should return false when role is invalid' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $incorrectRoleConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when role property is missing' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $missingRoleConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when role property is null/whitespace' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $nullOrWhitespaceRoleConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when content property is missing' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $missingContentConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when content item has an unknown message type' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $unknownMessageTypeConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when text is not a string' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $malformedTextConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when text is empty or whitespace' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $emptyTextConversation
                $result | Should -Be $false
            } #it

            It 'Should return false when content item is not a PSCustomObject' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $contentIsStringConversation
                $result | Should -Be $false
            } #it

            It 'Should return false for an image message missing format' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $imageNoFormatConversation
                $result | Should -Be $false
            } #it

            It 'Should return false for an image message missing bytes' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $imageNoBytesConversation
                $result | Should -Be $false
            } #it

            It 'Should return false for a video message missing format' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $videoNoFormatConversation
                $result | Should -Be $false
            } #it

            It 'Should return false for a video message missing bytes' {
                $result = Test-AmazonNovaCustomConversation -CustomConversation $videoNoBytesConversation
                $result | Should -Be $false
            } #it

        } #context_errors

    } #describe
} #inModuleScope
