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
    Describe 'Test-ConverseAPIImage Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            It 'Should return false if an error is encountered running Test-Path' {
                Mock -CommandName Test-Path -MockWith { throw 'Test-Path Error' }
                $imagePath = 'C:\path\to\image.jpg'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $false
            } #it

            It 'Should return false if an error is encountered running Get-Item' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith { throw 'Get-Item Error' }
                $imagePath = 'C:\path\to\image.jpg'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $false
            } #it

        } #context_Error

        Context 'Success' {

            It 'Should return true for <_> type if checks pass' -ForEach $supportedMediaExtensions {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -Mockwith {
                    [PSCustomObject]@{
                        Length = 10000
                    }
                } #endMock
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 100
                        Height = 100
                    }
                } #endMock
                $imagePath = 'C:\path\to\image.' + $_.ToLower()
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $true
            } #it

            It 'Should return false if file can not be found' {
                Mock -CommandName Test-Path -MockWith { $false }
                $imagePath = 'C:\path\to\image.jpg'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $false
            } #it

            It 'Should return false if file type is not supported' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 100
                        Height = 100
                    }
                } #endMock
                $imagePath = 'C:\path\to\image.zip'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $false
            } #it

            It 'Should return false if the file is too large' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 10000000
                    }
                }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 100
                        Height = 100
                    }
                } #endMock
                $imagePath = 'C:\path\to\image.jpg'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                $result | Should -Be $false
            } #it

            It 'Should return false if the resolution is too large' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -Mockwith {
                    [PSCustomObject]@{
                        Length = 10000
                    }
                } #endMock
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 9000
                        Height = 9000
                    }
                } #endMock
                Mock Write-Warning {}
                $imagePath = 'C:\path\to\image.jpg'
                $result = Test-ConverseAPIImage -ImagePath $imagePath
                Should -Invoke Write-Warning -Exactly 1
                $result | Should -Be $false
            } #it

        } #context_Success

    } #describe_Test-ConverseAPIImage
} #inModule
