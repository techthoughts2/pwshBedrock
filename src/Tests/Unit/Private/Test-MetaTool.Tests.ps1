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
    Describe 'Test-MetaTool Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'        } #beforeAll

        # Context 'Error' {

        # } #context_Error

        Context 'Llama 3 Format Tests' {

            BeforeEach {
                $llama3ModelID = 'meta.llama3-8b-instruct-v1:0'

                $standardLlama3Tools = [PSCustomObject]@{
                    name        = 'restaurant'
                    description = 'This tool will look up restaurant information in a provided geographic area.'
                    parameters  = @{
                        'location' = [PSCustomObject]@{
                            param_type  = 'string'
                            description = 'The geographic location or locale.'
                            required    = $true
                        }
                        'cuisine'  = [PSCustomObject]@{
                            param_type  = 'string'
                            description = 'The type of cuisine to look up.'
                            required    = $false
                        }
                    }
                }

                $incorrectLlama3Tools1 = [PSCustomObject]@{
                    description = 'string'
                    parameters  = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            param_type  = 'string'
                            required    = $true
                        }
                    }
                }

                $incorrectLlama3Tools2 = [PSCustomObject]@{
                    name       = 'string'
                    parameters = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            param_type  = 'string'
                            required    = $true
                        }
                    }
                }

                $incorrectLlama3Tools3 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                }

                $incorrectLlama3Tools4 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                    parameters  = @{
                        "parameter name" = [PSCustomObject]@{
                            param_type = 'string'
                            required   = $true
                        }
                    }
                }

                $incorrectLlama3Tools5 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                    parameters  = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            required    = $true
                        }
                    }
                }

                $incorrectLlama3Tools6 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                    parameters  = @{
                        "parameter name" = [PSCustomObject]@{
                            description = 'string'
                            param_type  = 'string'
                        }
                    }
                }

                $incorrectLlama3Tools7 = [PSCustomObject]@{
                    name        = 'string'
                    description = 'string'
                    parameters  = @{
                        "parameter name" = 'string'
                    }
                }
            } #beforeEach

            It 'Should return true for a standard Llama 3 tool object' {
                $result = Test-MetaTool -Tools $standardLlama3Tools -ModelID $llama3ModelID
                $result | Should -Be $true
            } #it

            It 'Should return false for Llama 3 tool missing name property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools1 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool missing description property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools2 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool missing parameters property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools3 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool missing parameter description sub-property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools4 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool missing parameter param_type sub-property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools5 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool missing parameter required sub-property' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools6 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 3 tool when parameter is not a PSCustomObject' {
                $result = Test-MetaTool -Tools $incorrectLlama3Tools7 -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

        } #context_Llama3

        Context 'Llama 4 Format Tests' {

            BeforeEach {
                $llama4ModelID = 'meta.llama4-maverick-17b-instruct-v1:0'

                $standardLlama4Tools = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        required   = @('city')
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city to get the weather for'
                            }
                            country = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The country where the city is located'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools1 = [PSCustomObject]@{
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools2 = [PSCustomObject]@{
                    name        = 'get_weather'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools3 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                }

                $incorrectLlama4Tools4 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = 'not an object'
                }

                $incorrectLlama4Tools5 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools6 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type = 'dict'
                    }
                }

                $incorrectLlama4Tools7 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = 'not an object'
                    }
                }

                $incorrectLlama4Tools8 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        required   = 'not an array'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools9 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = 'not an object'
                        }
                    }
                }

                $incorrectLlama4Tools10 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $incorrectLlama4Tools11 = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type = 'string'
                            }
                        }
                    }
                }
            } #beforeEach

            It 'Should return true for a standard Llama 4 tool object' {
                $result = Test-MetaTool -Tools $standardLlama4Tools -ModelID $llama4ModelID
                $result | Should -Be $true
            } #it

            It 'Should return false for Llama 4 tool missing name property' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools1 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool missing description property' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools2 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool missing inputSchema property' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools3 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when inputSchema is not a PSCustomObject' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools4 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool missing inputSchema type property' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools5 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool missing inputSchema properties property' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools6 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when inputSchema properties is not a PSCustomObject' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools7 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when inputSchema required is not an array' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools8 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when property definition is not a PSCustomObject' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools9 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when property missing type' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools10 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for Llama 4 tool when property missing description' {
                $result = Test-MetaTool -Tools $incorrectLlama4Tools11 -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

        } #context_Llama4

        Context 'Cross-Format Validation' {

            BeforeEach {
                $llama3ModelID = 'meta.llama3-8b-instruct-v1:0'
                $llama4ModelID = 'meta.llama4-maverick-17b-instruct-v1:0'

                $llama3Tool = [PSCustomObject]@{
                    name        = 'restaurant'
                    description = 'This tool will look up restaurant information.'
                    parameters  = @{
                        'location' = [PSCustomObject]@{
                            param_type  = 'string'
                            description = 'The geographic location.'
                            required    = $true
                        }
                    }
                }

                $llama4Tool = [PSCustomObject]@{
                    name        = 'get_weather'
                    description = 'Get weather info for places'
                    inputSchema = [PSCustomObject]@{
                        type       = 'dict'
                        properties = [PSCustomObject]@{
                            city = [PSCustomObject]@{
                                type        = 'string'
                                description = 'The name of the city'
                            }
                        }
                    }
                }

                $malformedTools = @(
                    [PSCustomObject]@{ role = 'zzzz'; message = 'Hello, how are you?' },
                    [PSCustomObject]@{ role = 'xxxx'; message = 'Hello, how are you?' }
                )
            } #beforeEach

            It 'Should return false when Llama 3 tool format is used with Llama 4 model' {
                $result = Test-MetaTool -Tools $llama3Tool -ModelID $llama4ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false when Llama 4 tool format is used with Llama 3 model' {
                $result = Test-MetaTool -Tools $llama4Tool -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false for completely malformed tool objects' {
                $result = Test-MetaTool -Tools $malformedTools -ModelID $llama3ModelID
                $result | Should -Be $false
            } #it

        } #context_CrossFormat

    } #describe_Test-MetaTool
} #inModule
