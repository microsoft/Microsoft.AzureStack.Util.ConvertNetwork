
# based on Pester 5.0.0+
$parentPath = (Get-Item $PSScriptRoot).Parent.FullName

Remove-Module Pester -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path -Path $parentPath -ChildPath 'out\PowerShell\Modules\Pester') -Force
New-Item -Path (Join-Path -Path $parentPath -ChildPath 'out\Tests\TestResults') -ItemType Directory -Force | Out-Null
New-Item -Path (Join-Path -Path $parentPath -ChildPath 'out\Tests\CodeCoverage') -ItemType Directory -Force | Out-Null

$config = New-PesterConfiguration
$config.Run.Path = (Join-Path -Path $parentPath -ChildPath 'tests')

$config.CodeCoverage.Path = (Join-Path -Path $parentPath -ChildPath 'out\Microsoft.AzureStack.Util.ConvertNetwork')
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.OutputPath = (Join-Path -Path $parentPath -ChildPath 'out\Tests\CodeCoverage.xml')
$config.CodeCoverage.OutputEncoding = 'UTF8'

$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = (Join-Path -Path $parentPath -ChildPath 'out\Tests\TestResults.xml')
$config.TestResult.OutputFormat = 'NUnitXml'
$config.TestResult.OutputEncoding = 'UTF8'

Invoke-Pester -Configuration $config