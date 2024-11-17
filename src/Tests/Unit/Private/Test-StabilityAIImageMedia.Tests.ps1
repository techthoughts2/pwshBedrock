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
    'JPEG',
    'PNG',
    'WEBP'
)

InModuleScope 'pwshBedrock' {
    Describe 'Test-StabilityAIImageMedia Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            It 'Should return false if an error is encountered running Test-Path' {
                Mock -CommandName Test-Path -MockWith { throw 'Test-Path Error' }
                $mediaPath = 'C:\path\to\image.png'
                $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
                $result | Should -Be $false
            } #it

            # It 'Should return false if an error is encountered running Get-Item' {
            #     Mock -CommandName Test-Path -MockWith { $true }
            #     Mock -CommandName Get-Item -MockWith { throw 'Get-Item Error' }
            #     $mediaPath = 'C:\path\to\image.png'
            #     $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
            #     $result | Should -Be $false
            # } #it

        } #context_Error

        Context 'Success' {

            It 'Should return true for <_> type if checks pass' -ForEach $supportedMediaExtensions {
                Mock -CommandName Test-Path -MockWith { $true }
                # Mock -CommandName Get-Item -Mockwith {
                #     [PSCustomObject]@{
                #         Length = 10000
                #     }
                # } #endMock
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 1024
                        Height = 1024
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.' + $_.ToLower()
                $result = Test-StabilityAIImageMedia -MediaPath $MediaPath
                $result | Should -Be $true
            } #it

            It 'Should return false if file can not be found' {
                Mock -CommandName Test-Path -MockWith { $false }
                $mediaPath = 'C:\path\to\image.png'
                $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
                $result | Should -Be $false
            } #it

            It 'Should return false if file type is not supported' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 1024
                        Height = 1024
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.zip'
                $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
                $result | Should -Be $false
            } #it

            # It 'Should return false if the file is too large' {
            #     Mock -CommandName Test-Path -MockWith { $true }
            #     Mock -CommandName Get-Item -MockWith {
            #         [PSCustomObject]@{
            #             Length = 10000000
            #         }
            #     }
            #     Mock -CommandName Get-ImageResolution -MockWith {
            #         [PSCustomObject]@{
            #             Width  = 1024
            #             Height = 1024
            #         }
            #     } #endMock
            #     $mediaPath = 'C:\path\to\image.png'
            #     $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
            #     $result | Should -Be $false
            # } #it

            # It 'Should return false if the resolution does not match the required dimensions' {
            #     Mock -CommandName Test-Path -MockWith { $true }
            #     Mock -CommandName Get-Item -Mockwith {
            #         [PSCustomObject]@{
            #             Length = 10000
            #         }
            #     } #endMock
            #     Mock -CommandName Get-ImageResolution -MockWith {
            #         [PSCustomObject]@{
            #             Width  = 2000
            #             Height = 2000
            #         }
            #     } #endMock
            #     $mediaPath = 'C:\path\to\image.png'
            #     $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
            #     $result | Should -Be $false
            # } #it

            It 'Should return false if the resolution does not meet the minimum dimensions' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 400
                        Height = 400
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.png'
                $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
                $result | Should -Be $false
            } #it

            It 'Should return false if the resolution exceeds the maximum dimensions' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 2000
                        Height = 2000
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.png'
                $result = Test-StabilityAIImageMedia -MediaPath $mediaPath
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-StabilityAIImageMedia
} #inModule
