#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'pwshBedrock'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
$script:assetPath = [System.IO.Path]::Combine('..', 'assets')
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$script:supportedMediaExtensions = @(
    'JPG'
    'JPEG'
    'PNG'
    'GIF'
    'WEBP'
)

InModuleScope 'pwshBedrock' {
    Describe 'Test-CohereCommandRChatHistory Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardChatHistory = @(
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'I am fine, thank you. How can I assist you today?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'I need help with my account.' },
                    [PSCustomObject]@{ role = 'CHATBOT'; message = 'Sure, I can help with that. What seems to be the issue?' }
                )
                $incorrectStandardMessage = @(
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'USER'; message = 'Hello, how are you?' }
                )
                $malformedMessage = @(
                    [PSCustomObject]@{ role = 'zzzz'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'xxxx'; message = 'Hello, how are you?' }
                )
                $malformedMessage2 = [PSCustomObject]@{
                    role = 'user'
                }
            } #beforeEach

            It 'Should return true for a standard message' {
                $result = Test-CohereCommandRChatHistory -ChatHistory $standardChatHistory
                $result | Should -Be $true
            } #it

            It 'Should return false for a malformed standard message' {
                $result = Test-CohereCommandRChatHistory -ChatHistory $incorrectStandardMessage
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed message' {
                $result = Test-CohereCommandRChatHistory -ChatHistory $malformedMessage
                $result | Should -Be $false
            } #it

            It 'Should return false for a message missing properties' {
                $result = Test-CohereCommandRChatHistory -ChatHistory $malformedMessage2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-CohereCommandRChatHistory
} #inModule
