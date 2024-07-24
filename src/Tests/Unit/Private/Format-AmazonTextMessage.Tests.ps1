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

InModuleScope 'pwshBedrock' {
    $amazonModels = (Get-ModelInfo -Provider Amazon).ModelID
    $amazonModels = $amazonModels | Where-Object { $_ -ne 'amazon.titan-image-generator-v1' }
    Describe 'Format-AmazonTextMessage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-AmazonTextMessage -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-AmazonTextMessage -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'amazon.titan-tg1-large' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a string with the expected values for a standard message' {
                $formatAnthropicMessageSplat = @{
                    Role    = 'User'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'amazon.titan-tg1-large'
                }
                $result = Format-AmazonTextMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly "User: The needs of the many outweigh the needs of the few.`n"
            } #it

            It 'should return a string with the expected values for a bot message' {
                $formatAnthropicMessageSplat = @{
                    Role    = 'Bot'
                    Message = 'Today, is a good day to die!'
                    ModelID = 'amazon.titan-tg1-large'
                }
                $result = Format-AmazonTextMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly "Today, is a good day to die!`n"
            } #it

            It 'should populate context for the <_> model' -ForEach $amazonModels {
                $formatAnthropicMessageSplat = @{
                    Role    = 'User'
                    Message = 'It is possible to commit no mistakes and still lose. That is not a weakness. That is life.\n'
                    ModelID = $_
                }
                Format-AmazonTextMessage @formatAnthropicMessageSplat
                $context = Get-ModelContext -ModelID $_
                $context | Should -Not -BeNullOrEmpty
            } #it

            It 'should not populate context if NoContextPersist is set to true for the <_> model' -ForEach $amazonModels {
                $formatAnthropicMessageSplat = @{
                    Role             = 'User'
                    Message          = 'I am not a'
                    ModelID          = $_
                    NoContextPersist = $true
                }
                $result = Format-AmazonTextMessage @formatAnthropicMessageSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $context = Get-ModelContext -ModelID $_
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-AmazonTextMessage
} #inModule
