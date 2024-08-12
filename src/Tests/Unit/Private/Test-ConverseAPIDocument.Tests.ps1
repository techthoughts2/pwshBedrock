BeforeAll {
    Set-Location -Path $PSScriptRoot
    $ModuleName = 'pwshBedrock'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
    $script:assetPath = [System.IO.Path]::Combine('..', 'assets')
    #if the module is already in memory, remove it
    Get-Module $ModuleName -ErrorAction SilentlyContinue | Remove-Module -Force
    Import-Module $PathToManifest -Force
}
$script:supportedDocumentExtensions = @(
    'pdf'
    'csv'
    'doc'
    'docx'
    'xls'
    'xlsx'
    'html'
    'txt'
    'md'
)

InModuleScope 'pwshBedrock' {
    Describe 'Test-ConverseAPIDocument Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'

        } #beforeAll

        Context 'Error' {

            It 'Should return false if an error is encountered running Test-Path' {
                Mock -CommandName Test-Path -MockWith { throw 'Test-Path Error' }
                $documentPath = 'C:\path\to\document.pdf'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it

            It 'Should return false if an error is encountered running Get-Item' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith { throw 'Get-Item Error' }
                $documentPath = 'C:\path\to\document.pdf'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it

        } #context_Error

        Context 'Success' {

            It 'Should return true for <_> type if checks pass' -ForEach $supportedDocumentExtensions {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -Mockwith {
                    [PSCustomObject]@{
                        BaseName = 'document'
                        Length   = 10000
                    }
                } #endMock
                $documentPath = 'C:\path\to\document.' + $_.ToLower()
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $true
            } #it

            It 'Should return false if file can not be found' {
                Mock -CommandName Test-Path -MockWith { $false }
                $documentPath = 'C:\path\to\document.pdf'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it

            It 'Should return false if file type is not supported' {
                Mock -CommandName Test-Path -MockWith { $true }
                $documentPath = 'C:\path\to\image.zip'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it

            It 'Should return false if the file is too large' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        BaseName = 'document'
                        Length   = 10000000
                    }
                }
                $documentPath = 'C:\path\to\document.pdf'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it

            It 'should return false if the name of the document does not meet requirements' {
                Mock -CommandName Test-Path -MockWith { $true }
                Mock -CommandName Get-Item -MockWith {
                    [PSCustomObject]@{
                        BaseName = 'document_123'
                        Length   = 10000
                    }
                }
                $documentPath = 'C:\path\to\document_123.pdf'
                $result = Test-ConverseAPIDocument -DocumentPath $documentPath
                $result | Should -Be $false
            } #it


        } #context_Success

    } #describe_Test-ConverseAPIDocument
} #inModule
