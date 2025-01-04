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

    Describe 'Format-AmazonNovaToolConfig Private Function Tests' -Tag Unit {
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
            } #beforeEach

            It 'should return a System.Management.Automation.PSCustomObject with the expected values' {
                $formatConverseAPIToolConfigSplat = @{
                    ToolsConfig = $toolsConfig
                }
                $result = Format-AmazonNovaToolConfig @formatConverseAPIToolConfigSplat
                $result | Should -BeOfType 'System.Management.Automation.PSCustomObject'
                $result.toolSpec.inputSchema | Should -BeOfType 'System.String'
                $result.ToolSpec.Name | Should -BeExactly 'top_song'
                $result.ToolSpec.Description | Should -BeExactly 'Get the most popular song played on a radio station.'
            } #it

        } #context_Success

    } #describe_Format-AmazonNovaToolConfig
} #inModule
