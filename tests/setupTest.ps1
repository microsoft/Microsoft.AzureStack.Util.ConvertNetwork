
$parentPath = (Get-Item $PSScriptRoot).Parent.FullName

Remove-Module Pester -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path -Path $parentPath -ChildPath 'out\PowerShell\Modules\Pester') -Force

Invoke-Pester -Path (Join-Path -Path $parentPath -ChildPath 'tests\ConvertNetwork.Tests.ps1')