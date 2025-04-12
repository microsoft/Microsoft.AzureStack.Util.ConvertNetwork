param (
    [Parameter(Mandatory = $true)]
    [string]$DirectoryPath, # Root directory path where the package is located

    [Parameter(Mandatory = $true)]
    [string]$PackageName, # Name of the NuGet package

    [Parameter(Mandatory = $true)]
    [string]$Version,         # Version of the NuGet package (e.g., 1.0.0)

    [Parameter(Mandatory = $true)]
    [string]$RepoUrl,

    [Parameter(Mandatory = $true)]
    [string]$Description # Description of the NuGet package
)

# Define the output directory for the nuspec file
$NuspecFilePath = Join-Path -Path $DirectoryPath -ChildPath "$PackageName.nuspec"

# Generate the .nuspec content
$NuspecContent = @"
<?xml version="1.0" encoding="utf-8"?>
<package >
  <metadata>
    <id>$PackageName</id>
    <version>$Version</version>
    <authors>Microsoft</authors>
    <owners>Microsoft</owners>
    <license type="expression">MIT</license>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <projectUrl>$RepoUrl</projectUrl>
    <description>$Description</description>
    <tags>AzureStack, Utility, Network, Subneting</tags>
    <copyright>Copyright © $(Get-Date -Format yyyy)</copyright>
    <repository url="$RepoUrl" type="git" commit="$(git rev-parse HEAD)" />
  </metadata>
  <files>
    <file src="$($DirectoryPath)\*" target="content" exclude="**\*.nupkg;**\*.nuspec" />
  </files>
</package>
"@

# Write the .nuspec file
Write-Host "$($MyInvocation.MyCommand.Name) - Generating .nuspec file at: $NuspecFilePath"
$NuspecContent | Set-Content -Path $NuspecFilePath -Encoding UTF8

Write-Host "$($MyInvocation.MyCommand.Name) - NuSpec file generated successfully!"