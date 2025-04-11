
# based on Pester 5.0.0+
$parentPath = (Get-Item $PSScriptRoot).Parent.FullName

Remove-Module Pester -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path -Path $parentPath -ChildPath 'out\PowerShell\Modules\Pester') -Force
New-Item -Path (Join-Path -Path $parentPath -ChildPath 'out\Tests') -ItemType Directory -Force | Out-Null

$config = New-PesterConfiguration
$config.Run.Path = (Join-Path -Path $parentPath -ChildPath 'tests')
$config.run.Exit = $true # Exit with code 0 if all tests pass, 1 if any test fails
$config.Run.PassThru = $true # Run all tests, even if they are not tagged with 'Test'

$config.CodeCoverage.Path = (Join-Path -Path $parentPath -ChildPath 'out\Microsoft.AzureStack.Util.ConvertNetwork')
$config.CodeCoverage.Enabled = $true # Enable code coverage
$config.CodeCoverage.OutputPath = (Join-Path -Path $parentPath -ChildPath 'out\Tests\CodeCoverage.xml')
$config.CodeCoverage.OutputEncoding = 'UTF8'

$config.TestResult.Enabled = $true # Enable test result output
$config.TestResult.OutputPath = (Join-Path -Path $parentPath -ChildPath 'out\Tests\TestResults.xml')
$config.TestResult.OutputFormat = 'NUnitXml'
$config.TestResult.OutputEncoding = 'UTF8'

Invoke-Pester -Configuration $config