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
    Describe 'Format-AI21LabsJambaModel Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should throw if an unsupported model is provided' {
                { Format-AI21LabsJambaModel -Role 'user' -Message 'These are the voyages...' -ModelID 'unsupported.model' } | Should -Throw
            } #it

            It 'should throw if an unsupported role is provided' {
                { Format-AI21LabsJambaModel -Role 'unsupported.role' -Message 'Live long and prosper!' -ModelID 'ai21.jamba-instruct-v1:0' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a PSObject with the expected values for a standard message' {
                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'user'
                $result.content | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for a assistant message' {
                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'assistant'
                    Message = 'I have been and always shall be your friend.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'assistant'
                $result.content | Should -BeExactly 'I have been and always shall be your friend.'
            } #it

            It 'should return a PSObject with the expected values for a system message' {
                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'system'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $result | Should -BeOfType 'System.Management.Automation.PSObject'
                $result.role | Should -BeExactly 'system'
                $result.content | Should -BeExactly 'The needs of the many outweigh the needs of the few.'
            } #it

            It 'should return a PSObject with the expected values for an updated system message' {
                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'system'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result1 = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat

                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'system'
                    Message = 'You are a helpful android.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result2 = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $context = Get-ModelContext -ModelID 'ai21.jamba-instruct-v1:0'
                $systemContext = $context | Where-Object { $_.Role -eq 'system' }
                $systemContext.Content | Should -BeExactly 'You are a helpful android.'
            } #it

            It 'should return a PSObject with the expected values for an added system message' {
                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'user'
                    Message = 'The needs of the many outweigh the needs of the few.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result1 = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat

                $formatAI21LabsJambaModelSplat = @{
                    Role    = 'system'
                    Message = 'You are a helpful android.'
                    ModelID = 'ai21.jamba-instruct-v1:0'
                }
                $result2 = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $context = Get-ModelContext -ModelID 'ai21.jamba-instruct-v1:0'
                $systemContext = $context | Where-Object { $_.Role -eq 'system' }
                $systemContext.Content | Should -BeExactly 'You are a helpful android.'
            } #it

            It 'should not populate context if NoContextPersist is set to true' {
                $formatAI21LabsJambaModelSplat = @{
                    Role             = 'user'
                    Message          = 'I am not a'
                    ModelID          = 'ai21.jamba-instruct-v1:0'
                    NoContextPersist = $true
                }
                $result = Format-AI21LabsJambaModel @formatAI21LabsJambaModelSplat
                $context = Get-ModelContext -ModelID 'ai21.jamba-instruct-v1:0'
                Write-Verbose -Message ('Context Count: {0}' -f $context.Count)
                $context | Should -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Format-AI21LabsJambaModel
} #inModule
