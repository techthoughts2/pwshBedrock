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
    Describe 'Test-MistralAIChatTool Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name        = "string"
                        description = "string"
                        parameters  = @{
                            type       = "string"
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                            required   = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools1 = [PSCustomObject]@{
                    function = @{
                        name        = "string"
                        description = "string"
                        parameters  = @{
                            type       = "string"
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                            required   = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    type = "function"
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        description = "string"
                        parameters  = @{
                            type       = "string"
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                            required   = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name       = "string"
                        parameters = @{
                            type       = "string"
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                            required   = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools5 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name        = "string"
                        description = "string"
                    }
                }
                $incorrectStandardTools6 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name        = "string"
                        description = "string"
                        parameters  = @{
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                            required   = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools7 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name        = "string"
                        description = "string"
                        parameters  = @{
                            type     = "string"
                            required = @(
                                "string"
                            )
                        }
                    }
                }
                $incorrectStandardTools8 = [PSCustomObject]@{
                    type     = "function"
                    function = @{
                        name        = "string"
                        description = "string"
                        parameters  = @{
                            type       = "string"
                            properties = @{
                                sign = @{
                                    type        = "string"
                                    description = "string"
                                }
                            }
                        }
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
                $result = Test-MistralAIChatTool -Tools $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return false if missing type property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false if missing function property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false if missing name sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false if missing description sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false if missing parameters sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools5
                $result | Should -Be $false
            } #it

            It 'Should return false if missing parameters type sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools6
                $result | Should -Be $false
            } #it

            It 'should return false if missing parameters properties sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools7
                $result | Should -Be $false
            } #it

            It 'Should return false if missing parameters required sub-property' {
                $result = Test-MistralAIChatTool -Tools $incorrectStandardTools8
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-MistralAIChatTool -Tools $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object with a single object' {
                $result = Test-MistralAIChatTool -Tools $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-MistralAIChatTool
} #inModule
