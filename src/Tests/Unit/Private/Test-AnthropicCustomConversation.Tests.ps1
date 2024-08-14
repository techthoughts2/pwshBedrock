BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
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
    Describe 'Test-AnthropicCustomConversation Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Hello Claude, how are you?'
                        }
                    )
                }
                $mediaMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type   = 'image'
                            source = @(
                                [PSCustomObject]@{
                                    type         = 'base64'
                                    'media_type' = 'image/jpeg'
                                    data         = 'bast64encodedstring'
                                }
                            )
                        },
                        [PSCustomObject]@{
                            type = 'text'
                            text = 'Check out this image!'
                        }

                    )
                }
                $incorrectStandardMessage = [PSCustomObject]@{
                    role    = 'nope'
                    content = @(
                        [PSCustomObject]@{
                            type = 'text'
                        }
                    )
                }
                $incorrectMediaMessage = [PSCustomObject]@{
                    # role    = 'user'
                    content = @(
                        [PSCustomObject]@{
                            type   = 'image'
                            source = @(
                                [PSCustomObject]@{
                                    type         = 'base64'
                                    'media_type' = 'image/jpeg'
                                }
                            )
                        }
                    )
                }
                $malformedMessage = [PSCustomObject]@{
                    role    = 'user'
                    content = @(
                        'nope'
                    )
                }
                $malformedMessage2 = [PSCustomObject]@{
                    role = 'user'
                }
            } #beforeEach

            It 'Should return true for a standard message' {
                $result = Test-AnthropicCustomConversation -CustomConversation $standardMessage
                $result | Should -Be $true
            } #it

            It 'Should return true for a media message' {
                $result = Test-AnthropicCustomConversation -CustomConversation $mediaMessage
                $result | Should -Be $true
            } #it

            It 'Should return false for a malformed standard message' {
                $result = Test-AnthropicCustomConversation -CustomConversation $incorrectStandardMessage
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed media message' {
                $result = Test-AnthropicCustomConversation -CustomConversation $incorrectMediaMessage
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed message' {
                $result = Test-AnthropicCustomConversation -CustomConversation $malformedMessage
                $result | Should -Be $false
            } #it

            It 'Should return false for a message missing properties' {
                $result = Test-AnthropicCustomConversation -CustomConversation $malformedMessage2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-AnthropicCustomConversation
} #inModule
