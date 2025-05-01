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
    Describe 'Get-S3Extension Private Function Tests' -Tag Unit {
        BeforeAll {
            $WarningPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'SilentlyContinue'
            $validS3Uri = 's3://my-bucket/path/to/file.png'
            $validS3UriWithParams = 's3://my-bucket/path/to/file.jpg?param1=value1&param2=value2'
            $invalidS3Uri = 'not-a-uri'
            $s3UriWithoutExtension = 's3://my-bucket/path/to/file'
            $emptyS3Uri = ''
        } #beforeAll

        Context 'Error' {

            It 'Should throw when S3Location is empty' {
                $result = { Get-S3Extension -S3Location $emptyS3Uri }
                $result | Should -Throw
            } #it

            It 'Should return $null when S3Location is invalid' {
                $result = Get-S3Extension -S3Location $invalidS3Uri
                $result | Should -BeNullOrEmpty
            } #it

            It 'Should return $null when S3Location has no file extension' {
                $result = Get-S3Extension -S3Location $s3UriWithoutExtension
                $result | Should -BeNullOrEmpty
            } #it
        } #context_Error

        Context 'Success' {
            It 'Should return "png" for a valid S3 URI with PNG extension' {
                $result = Get-S3Extension -S3Location $validS3Uri
                $result | Should -Be 'png'
            } #it

            It 'Should return "jpg" for a valid S3 URI with JPG extension and query parameters' {
                $result = Get-S3Extension -S3Location $validS3UriWithParams
                $result | Should -Be 'jpg'
            } #it

            It 'Should extract extensions from different S3 URIs correctly' {
                $testCases = @(
                    @{ Uri = 's3://my-bucket/images/photo.jpeg'; Expected = 'jpeg' }
                    @{ Uri = 's3://my-bucket/documents/report.pdf'; Expected = 'pdf' }
                    @{ Uri = 's3://my-bucket/videos/movie.mp4'; Expected = 'mp4' }
                    @{ Uri = 's3://my-bucket/nested/path/to/file.txt'; Expected = 'txt' }
                )

                foreach ($test in $testCases) {
                    $result = Get-S3Extension -S3Location $test.Uri
                    $result | Should -Be $test.Expected
                }
            } #it
        } #context_Success

    } #describe_Get-S3Extension
} #inModule
