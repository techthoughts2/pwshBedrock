BeforeDiscovery {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {
    $modelInfo = @()
    $modelInfo += $script:anthropicModelInfo
    $modelInfo += $script:amazonModelInfo
    $modelInfo += $script:ai21ModelInfo
    $modelInfo += $script:cohereModelInfo
    $modelInfo += $script:lumaModelInfo
    $modelInfo += $script:metaModelInfo
    $modelInfo += $script:mistralAIModelInfo
    $modelInfo += $script:stabilityAIModelInfo
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Get-ModelInfo Public Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
        } #beforeAll

        Context 'Error' {

            It 'should throw if multiple parameters are provided' {
                { Get-ModelInfo -ModelID 'anthropic.claude-v2:1' -AllModels } | Should -Throw
            } #it

            It 'should throw if no parameters are provided' {
                { Get-ModelInfo } | Should -Throw
            } #it

            It 'should throw if an invalid provider is provided' {
                { Get-ModelInfo -Provider 'FakeProvider' } | Should -Throw
            } #it

            It 'should throw if an invalid model ID is provided' {
                { Get-ModelInfo -ModelID 'FakeModelID' } | Should -Throw
            } #it

        } #context_Error

        Context 'Success' {

            # BeforeEach {

            # } #beforeEach

            It 'should return expected values for <_.ModelID>' -ForEach $modelInfo {
                $ModelID = $_.ModelID
                $eval = Get-ModelInfo -ModelID $ModelID
                $eval | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval | Should -Not -BeNullOrEmpty
                $eval.ProviderName               | Should -Not -BeNullOrEmpty
                $eval.ModelName                  | Should -Not -BeNullOrEmpty
                $eval.ModelId                    | Should -Not -BeNullOrEmpty
                $eval.Description                | Should -Not -BeNullOrEmpty
                $eval.Strength                   | Should -Not -BeNullOrEmpty
                $eval.Multilingual               | Should -Not -BeNullOrEmpty
                $eval.Text                       | Should -Not -BeNullOrEmpty
                $eval.Vision                     | Should -Not -BeNullOrEmpty
                $eval.ResponseStreamingSupported | Should -Not -BeNullOrEmpty
                $eval.ChatHistorySupported       | Should -Not -BeNullOrEmpty
                $eval.InferenceProfile          | Should -Not -BeNullOrEmpty
            } #it

            It 'should return all model values if specified' {
                $eval = Get-ModelInfo -AllModels
                # $eval[0] | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval.Count | Should -BeGreaterThan 15
            } #it

            It 'should return all model values for a specific provider' {
                $eval = Get-ModelInfo -Provider 'AI21 Labs'
                $eval[0] | Should -BeOfType [System.Management.Automation.PSCustomObject]
                $eval.Count | Should -BeExactly 3
            } #it

        } #context_Success

    } #describe_Get-ModelInfo
} #inModule
