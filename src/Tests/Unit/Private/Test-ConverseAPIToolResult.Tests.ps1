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
    Describe 'Test-ConverseAPIToolResult Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name = 'Gristmill River Restaurant & Bar'
                        }
                    }
                    status    = 'success'
                }
                $standardToolsMulti = @(
                    [PSCustomObject]@{
                        ToolUseId = 'string'
                        Content   = [PSCustomObject]@{
                            restaurant = [PSCustomObject]@{
                                name = 'Gristmill River Restaurant & Bar'
                            }
                        }
                        status    = 'success'
                    },
                    [PSCustomObject]@{
                        ToolUseId = 'string2'
                        Content   = [PSCustomObject]@{
                            restaurant = [PSCustomObject]@{
                                name = 'Gristmill River Restaurant & Bar'
                            }
                        }
                        status    = 'success'
                    }
                )
                $multiWithDuplicateIds = @(
                    [PSCustomObject]@{
                        ToolUseId = 'string'
                        Content   = [PSCustomObject]@{
                            restaurant = [PSCustomObject]@{
                                name = 'Gristmill River Restaurant & Bar'
                            }
                        }
                        status    = 'success'
                    },
                    [PSCustomObject]@{
                        ToolUseId = 'string'
                        Content   = [PSCustomObject]@{
                            restaurant = [PSCustomObject]@{
                                name = 'Gristmill River Restaurant & Bar'
                            }
                        }
                        status    = 'success'
                    }
                )
                $incorrectStandardTools1 = [PSCustomObject]@{
                    Content = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name = 'Gristmill River Restaurant & Bar'
                        }
                    }
                    status  = 'success'
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    ToolUseId = 'string'
                    status    = 'success'
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name = 'Gristmill River Restaurant & Bar'
                        }
                    }
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name = 'Gristmill River Restaurant & Bar'
                        }
                    }
                    status    = 'notsuccess'
                }
                $malformedTools = @(
                    [PSCustomObject]@{ role = 'zzzz'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'xxxx'; message = 'Hello, how are you?' }
                )
                $malformedTools2 = [PSCustomObject]@{
                    role = 'user'
                }
                $errorToolsCorrect = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = 'I am sorry, I could not find any restaurants in New Braunfels, TX.'
                    status    = 'error'
                }
                $errorToolsIncorrect = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = [PSCustomObject]@{
                        restaurant = [PSCustomObject]@{
                            name = 'Gristmill River Restaurant & Bar'
                        }
                    }
                    status    = 'error'
                }
                $successToolsIncorrect = [PSCustomObject]@{
                    ToolUseId = 'string'
                    Content   = 'I am sorry, I could not find any restaurants in New Braunfels, TX.'
                    status    = 'success'
                }
            } #beforeEach

            It 'Should return true for a standard tool object' {
                $result = Test-ConverseAPIToolResult -ToolResults $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return true for multiple standard tool objects' {
                $result = Test-ConverseAPIToolResult -ToolResults $standardToolsMulti
                $result | Should -Be $true
            } #it

            It 'Should return false if there are duplicate tool_call_ids' {
                $result = Test-ConverseAPIToolResult -ToolResults $multiWithDuplicateIds
                $result | Should -Be $false
            } #it

            It 'should return false if missing ToolUseId' {
                $result = Test-ConverseAPIToolResult -ToolResults $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'should return false if missing Content' {
                $result = Test-ConverseAPIToolResult -ToolResults $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'should return false if missing status' {
                $result = Test-ConverseAPIToolResult -ToolResults $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'should return false if status is not success or error' {
                $result = Test-ConverseAPIToolResult -ToolResults $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'should return false if status is error and Content is not a string' {
                $result = Test-ConverseAPIToolResult -ToolResults $errorToolsIncorrect
                $result | Should -Be $false
            } #it

            It 'should return false if status is success and Content is not an object or PSCustomObject' {
                $result = Test-ConverseAPIToolResult -ToolResults $successToolsIncorrect
                $result | Should -Be $false
            } #it

            It 'should return true if status is error and Content is a string' {
                $result = Test-ConverseAPIToolResult -ToolResults $errorToolsCorrect
                $result | Should -Be $true
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-ConverseAPIToolResult -ToolResults $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for malformed tools' {
                $result = Test-ConverseAPIToolResult -ToolResults $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-ConverseAPIToolResult
} #inModule
