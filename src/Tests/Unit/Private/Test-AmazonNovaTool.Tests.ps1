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
    Describe 'Test-AmazonNovaTool Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                $standardTools = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools1 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools2 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name        = 'top_song'
                        description = 'Get the most popular song played on a radio station.'
                    }
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = $null
                    }
                }
                $incorrectStandardTools5 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools6 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
                                }
                            }
                            required   = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools7 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type     = 'object'
                            required = @( 'sign' )
                        }
                    }
                }
                $incorrectStandardTools8 = [PSCustomObject]@{
                    toolSpec = [PSCustomObject]@{
                        name         = 'top_song'
                        description  = 'Get the most popular song played on a radio station.'
                        inputSchema = [PSCustomObject]@{
                            type       = 'object'
                            properties = [PSCustomObject]@{
                                sign = [PSCustomObject]@{
                                    type        = 'string'
                                    description = 'string'
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
                $result = Test-AmazonNovaTool -Tools $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return false if missing name property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false if missing description property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false if missing inputSchema property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false if inputSchema is empty' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false if missing parameters type sub-property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools5
                $result | Should -Be $false
            } #it

            It 'Should return false if missing parameters properties sub-property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools6
                $result | Should -Be $false
            } #it

            It 'should return false if missing parameters properties sub-property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools7
                $result | Should -Be $false
            } #it

            It 'Should return false if missing required sub-property' {
                $result = Test-AmazonNovaTool -Tools $incorrectStandardTools8
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-AmazonNovaTool -Tools $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object with a single object' {
                $result = Test-AmazonNovaTool -Tools $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-AmazonNovaTool
} #inModule
