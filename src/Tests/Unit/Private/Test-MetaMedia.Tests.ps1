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
    Describe 'Test-MetaMedia Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $modelID = 'meta.llama4-scout-17b-instruct-v1:0'
        } #beforeAll

        Context 'Error' {

            It 'Should return false if an error is encountered running Test-Path' {
                Mock -CommandName Test-Path -MockWith { throw 'Test-Path Error' }
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false if an error is encountered running Get-Item' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith { throw 'Get-Item Error' }
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
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
                $mediaPath = 'C:\path\to\image.' + $_.ToLower()
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
                $result | Should -Be $true
            } #it

            It 'Should return false if file can not be found' {
                Mock -CommandName Test-Path -MockWith { $false }
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
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
                $mediaPath = 'C:\path\to\image.zip'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
                $result | Should -Be $false
            } #it

            It 'Should return false if the file is too large' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 29000000
                    }
                }
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 100
                        Height = 100
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID $ModelID
                $result | Should -Be $false
            } #it

            It 'should return false if the image resolution is too large for a 3.2 model' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 10000
                    }
                } #endMock
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 1200
                        Height = 1200
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID 'meta.llama3-2-90b-instruct-v1:0'
                $result | Should -Be $false
            } #it

            It 'should not check resolution for non-3.2 models' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 10000
                    }
                } #endMock
                Mock -CommandName Get-ImageResolution -MockWith {
                    [PSCustomObject]@{
                        Width  = 1200
                        Height = 1200
                    }
                } #endMock
                $mediaPath = 'C:\path\to\image.jpg'
                $result = Test-MetaMedia -MediaPath $mediaPath -ModelID 'meta.llama4-scout-17b-instruct-v1:0'
                $result | Should -Be $true
                Should -Invoke Get-ImageResolution -Exactly 0 -Scope It
            } #it

        } #context_Success

    } #describe_Test-MetaMedia
} #inModule
