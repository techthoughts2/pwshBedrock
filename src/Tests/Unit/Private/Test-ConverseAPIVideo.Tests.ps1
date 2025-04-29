# filepath: c:\Users\jakew\OneDrive\Desktop\Project\0_CodeProject\1_git\pwshBedrock\src\Tests\Unit\Private\Test-ConverseAPIVideo.Tests.ps1
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
    'MKV'
    'MOV'
    'MP4'
    'WEBM'
    'FLV'
    'MPEG'
    'MPG'
    'WMV'
    '3GP'
)

InModuleScope 'pwshBedrock' {
    Describe 'Test-ConverseAPIVideo Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            It 'Should return false if an error is encountered running Test-Path' {
                Mock -CommandName Test-Path -MockWith { throw 'Test-Path Error' }
                $videoPath = 'C:\path\to\video.mp4'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $false
            } #it

            It 'Should return false if an error is encountered running Get-Item' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith { throw 'Get-Item Error' }
                $videoPath = 'C:\path\to\video.mp4'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $false
            } #it

        } #context_Error

        Context 'Success' {

            It 'Should return true for <_> type if checks pass' -ForEach $supportedMediaExtensions {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 10000
                    }
                } #endMock
                $videoPath = 'C:\path\to\video.' + $_.ToLower()
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $true
            } #it

            It 'Should return false if file can not be found' {
                Mock -CommandName Test-Path -MockWith { $false }
                $videoPath = 'C:\path\to\video.mp4'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $false
            } #it

            It 'Should return false if file type is not supported' {
                Mock -CommandName Test-Path -MockWith { $true }
                $videoPath = 'C:\path\to\video.txt'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $false
            } #it

            It 'Should return false if the file is too large' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        Length = 30 * 1024 * 1024 # 30MB (larger than 25MB limit)
                    }
                }
                $videoPath = 'C:\path\to\video.mp4'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Be $false
            } #it

            It 'Should handle incorrect path variable' {
                Mock -CommandName Write-Warning {}
                Mock -CommandName Test-Path -MockWith { $true }
                $videoPath = 'C:\path\to\video.mp4'
                $result = Test-ConverseAPIVideo -VideoPath $videoPath
                $result | Should -Not -BeNullOrEmpty
            } #it

        } #context_Success

    } #describe_Test-ConverseAPIVideo
} #inModule
