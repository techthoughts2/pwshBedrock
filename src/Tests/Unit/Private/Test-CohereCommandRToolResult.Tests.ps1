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
    Describe 'Test-CohereCommandRToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools1 = [PSCustomObject]@{
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    call = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name = "string"
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools5 = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = ""
                        }
                    }
                    outputs = @(
                        [PSCustomObject]@{
                            text = "string"
                        }
                    )
                }
                $incorrectStandardTools6 = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = @()
                }
                $incorrectStandardTools7 = [PSCustomObject]@{
                    call    = [PSCustomObject]@{
                        name       = "string"
                        parameters = [PSCustomObject]@{
                            "parameter name" = "string"
                        }
                    }
                    outputs = 'test'
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
                $result = Test-CohereCommandRToolResult -ToolResults $standardTools -debug
                $result | Should -Be $true
            } #it

            It 'Should return false is missing call property' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false is missing outputs property' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false is missing call.parameters sub-property' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false is missing call.name sub-property' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false is call.parameters sub-property is empty' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools5
                $result | Should -Be $false
            } #it

            It 'Should return false is outputs contains no elements' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools6
                $result | Should -Be $false
            } #it

            It 'Should return false is outputs sub-property is not an array' {
                $result = Test-CohereCommandRToolResult -ToolResults $incorrectStandardTools7
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-CohereCommandRToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a tool object missing properties' {
                $result = Test-CohereCommandRToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-CohereCommandRToolResult
} #inModule
