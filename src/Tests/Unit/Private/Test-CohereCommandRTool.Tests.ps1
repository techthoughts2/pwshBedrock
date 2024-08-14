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
    Describe 'Test-CohereCommandRTool Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    name                  = 'string'
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            type        = 'string'
                            required    = $true
                        }
                    }
                }
                $incorrectStandardTools1 = [PSCustomObject]@{
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            type        = 'string'
                            required    = $true
                        }
                    }
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    name                  = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            type        = 'string'
                            required    = $true
                        }
                    }
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    name                  = 'string'
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            type     = 'string'
                            required = $true
                        }
                    }
                }
                $incorrectStandardTools5 = [PSCustomObject]@{
                    name                  = 'string'
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            required    = $true
                        }
                    }
                }
                $incorrectStandardTools6 = [PSCustomObject]@{
                    name                  = 'string'
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            type        = 'string'
                        }
                    }
                }
                $incorrectStandardTools7 = [PSCustomObject]@{
                    name                  = 'string'
                    description           = 'string'
                    parameter_definitions = @{
                        "parameter name" = 'string'
                    }
                }
                $malformedTools = @(
                    [PSCustomObject]@{ role = 'zzzz'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'xxxx'; message = 'Hello, how are you?' }
                )
                $malformedTools2 = [PSCustomObject]@{
                    role = 'user'
                }
            } #beforeEach

            It 'Should return true for a standard tool object' {
                $result = Test-CohereCommandRTool -Tools $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return false is missing name property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is missing description property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false is missing parameter_definitions property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false is missing parameter_definitions description sub-property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false is missing parameter_definitions type sub-property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools5
                $result | Should -Be $false
            } #it

            It 'Should return false is missing parameter_definitions required sub-property' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools6
                $result | Should -Be $false
            } #it

            It 'Should return false is parameter_definitions is not a PSCustomObject' {
                $result = Test-CohereCommandRTool -Tools $incorrectStandardTools7
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-CohereCommandRTool -Tools $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a tool object missing properties' {
                $result = Test-CohereCommandRTool -Tools $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-CohereCommandRTool
} #inModule
