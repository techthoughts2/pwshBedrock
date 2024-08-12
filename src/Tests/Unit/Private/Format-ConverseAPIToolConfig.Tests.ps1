BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}

InModuleScope 'pwshBedrock' {

    Describe 'Format-ConverseAPIToolConfig Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        # Context 'Error' {

        #     BeforeEach {

        #     } #beforeEach

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $toolsConfig = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The geographic location or locale. This could be a city, state, country, or full address.'
                        }
                        cuisine  = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The type of cuisine to look up. This could be a specific type of food or a general category like "Italian" or "Mexican". If the user does not specify a cuisine, do not include this parameter in the response.'
                        }
                        budget   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The budget range for the restaurant. This has to be returned as a number from 1 to 5. The user could use words like "cheap", "moderate", or "expensive". They could provide "high end", or refer to a dollar amount like $$ or $$$$.'
                        }
                        rating   = [PSCustomObject]@{
                            type        = 'string'
                            description = 'The minimum rating for the restaurant. This has to be returned as a number from 1 to 5. The user may specify phrases like "good" or "excellent", or "highly rated"'
                        }
                    }
                    required    = @(
                        'location'
                    )
                }
            } #beforeEach

            It 'should return a Amazon.BedrockRuntime.Model.Tool with the expected values' {
                $formatConverseAPIToolConfigSplat = @{
                    ToolsConfig = $toolsConfig
                }
                $result = Format-ConverseAPIToolConfig @formatConverseAPIToolConfigSplat
                $result | Should -BeOfType 'Amazon.BedrockRuntime.Model.Tool'
                $result.ToolSpec | Should -BeOfType 'Amazon.BedrockRuntime.Model.ToolSpecification'
                $result.ToolSpec.Name | Should -BeExactly 'restaurant'
                $result.ToolSpec.Description | Should -BeExactly 'This tool will look up restaurant information in a provided geographic area.'
                $result.ToolSpec.InputSchema | Should -BeOfType 'Amazon.BedrockRuntime.Model.ToolInputSchema'
            } #it

        } #context_Success

    } #describe_Format-ConverseAPIToolConfig
} #inModule
