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
    Describe 'Format-InferenceProfileID Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            # BeforeEach {

            # } #beforeEach

        } #context_Error

        Context 'Success' {

            BeforeEach {
                Reset-ModelContext -AllModels -Force
            } #beforeEach

            It 'should return a string with the expected values for a us region' {
                $formatInferenceProfileIDSplat = @{
                    ModelID = 'meta.llama3-2-90b-instruct-v1:0'
                    Region  = 'us-east-1'
                }
                $result = Format-InferenceProfileID @formatInferenceProfileIDSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly 'us.meta.llama3-2-90b-instruct-v1:0'
            } #it

            It 'should return a string with the expected values for a eu region' {
                $formatInferenceProfileIDSplat = @{
                    ModelID = 'meta.llama3-2-90b-instruct-v1:0'
                    Region  = 'eu-west-1'
                }
                $result = Format-InferenceProfileID @formatInferenceProfileIDSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly 'eu.meta.llama3-2-90b-instruct-v1:0'
            } #it

            It 'should return a string with the expected values for an ap region' {
                $formatInferenceProfileIDSplat = @{
                    ModelID = 'meta.llama3-2-90b-instruct-v1:0'
                    Region  = 'ap-southeast-1'
                }
                $result = Format-InferenceProfileID @formatInferenceProfileIDSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly 'apac.meta.llama3-2-90b-instruct-v1:0'
            } #it

            It 'should return the ModelID when InferenceProfile is false' {
                $formatInferenceProfileIDSplat = @{
                    ModelID = 'mistral.mistral-large-2407-v1:0'
                    Region  = 'us-east-1'
                }
                $result = Format-InferenceProfileID @formatInferenceProfileIDSplat
                $result | Should -BeOfType 'System.String'
                $result | Should -BeExactly 'mistral.mistral-large-2407-v1:0'
            } #it

        } #context_Success

    } #describe_Format-InferenceProfileID
} #inModule
