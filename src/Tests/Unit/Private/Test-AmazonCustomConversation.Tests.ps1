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
    Describe 'Test-AmazonCustomConversation Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {

                $properMessage = @'
User: Hello
Bot: Hi
User: How are you?
Bot: I am good, how can I help you?
'@

                $improperMessage1 = @'
User: Hello
Bot: Hi
NOTAUSER: How are you?
'@

                $improperMessage2 = @'
Bot: Hi
User: Hello
'@

                $improperMessage3 = 'A string'


            } #beforeEach

            It 'Should return true for a properly formatted message' {
                Test-AmazonCustomConversation -CustomConversation $properMessage | Should -BeExactly $true
            } #it

            It 'Should return false for a message with an improper role' {
                Test-AmazonCustomConversation -CustomConversation $improperMessage1 | Should -BeExactly $false
            } #it

            It 'Should return false for a message with an improper order' {
                Test-AmazonCustomConversation -CustomConversation $improperMessage2 | Should -BeExactly $false
            } #it

            It 'Should return false for a message that is malformed' {
                Test-AmazonCustomConversation -CustomConversation $improperMessage3 | Should -BeExactly $false
            } #it

        } #context_Success

    } #describe_Test-AmazonCustomConversation
} #inModule
