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
    Describe 'Test-ConverseAPITool Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll
        # Context 'Error' {

        # } #context_Error

        Context 'Success' {

            BeforeEach {
                # ! the properties field must be a hashtable
                $standardTools = [PSCustomObject]@{
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
                $incorrectStandardTools1 = [PSCustomObject]@{
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
                $incorrectStandardTools2 = [PSCustomObject]@{
                    Name       = 'restaurant'
                    Properties = @{
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
                    required   = @(
                        'location'
                    )
                }
                $incorrectStandardTools3 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    required    = @(
                        'location'
                    )
                }
                $incorrectStandardTools4 = [PSCustomObject]@{
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
                }
                $incorrectStandardTools5 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
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
                $incorrectStandardTools6 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type = 'string'
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
                $incorrectStandardTools7 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = [PSCustomObject]@{
                                Name = 'Value'
                            }
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
                $incorrectStandardTools8 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                        location = [PSCustomObject]@{
                            type        = 'string'
                            description = $null
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
                $incorrectStandardTools9 = [PSCustomObject]@{
                    Name        = 'restaurant'
                    Description = 'This tool will look up restaurant information in a provided geographic area.'
                    Properties  = @{
                    }
                    required    = @(
                        'location'
                    )
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
                $result = Test-ConverseAPITool -Tools $standardTools
                $result | Should -Be $true
            } #it

            It 'Should return false if missing name property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools1
                $result | Should -Be $false
            } #it

            It 'Should return false if missing description property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools2
                $result | Should -Be $false
            } #it

            It 'Should return false if missing properties property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools3
                $result | Should -Be $false
            } #it

            It 'Should return false if missing required property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools4
                $result | Should -Be $false
            } #it

            It 'Should return false if missing type sub-property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools5
                $result | Should -Be $false
            } #it

            It 'Should return false if missing description sub-property' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools6
                $result | Should -Be $false
            } #it

            It 'Should return false if type sub-property is not a string' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools7
                $result | Should -Be $false
            } #it

            It 'Should return false if description sub-property is null' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools8
                $result | Should -Be $false
            } #it

            It 'Should return false if properties property is empty' {
                $result = Test-ConverseAPITool -Tools $incorrectStandardTools9
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object' {
                $result = Test-ConverseAPITool -Tools $malformedTools
                $result | Should -Be $false
            } #it

            It 'Should return false for a malformed tool object with a single object' {
                $result = Test-ConverseAPITool -Tools $malformedTools2
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-ConverseAPITool
} #inModule
