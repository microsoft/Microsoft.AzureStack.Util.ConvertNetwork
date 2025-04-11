<#
.SYNOPSIS
This script updates the `ModuleVersion` field in PowerShell module manifest files (*.psd1).

.DESCRIPTION
The script performs a recursive search for PowerShell module manifest files (*.psd1) in the specified directory.
It updates the `ModuleVersion` field in each file with the provided version number.

.PARAMETER Version
The new version number to set in the `ModuleVersion` field. Must conform to the [version] type.

.PARAMETER Directory
The directory to search for *.psd1 files. The search is recursive.

.EXAMPLE
.\update-versionnumber.ps1 -Version "1.2.3" -Directory "C:\Modules"

This command updates the `ModuleVersion` field in all *.psd1 files under "C:\Modules" to "1.2.3".

.EXAMPLE
.\update-versionnumber.ps1 -Version "2.0.0" -Directory "."

This command updates the `ModuleVersion` field in all *.psd1 files in the current directory and its subdirectories to "2.0.0".

.NOTES
- Ensure you have write permissions for the files being updated.
- Use semantic versioning for the version number (e.g., "1.0.0").
#>

param (
    [Parameter(Mandatory = $true)]
    [version]$Version, # Enforces the [version] type for the parameter

    [Parameter(Mandatory = $true)]
    [string]$Directory
)

# Validate the directory
if (-not (Test-Path -Path $Directory)) {
    Write-Error "The specified directory does not exist: $Directory"
    exit 1
}

# Perform a recursive search for *.psd1 files
$psd1Files = Get-ChildItem -Path $Directory -Recurse -Filter "*.psd1"

if ($psd1Files.Count -eq 0) {
    Write-Host "No *.psd1 files found in the specified directory: $Directory"
    exit 0
}

# Update the ModuleVersion in each *.psd1 file
foreach ($file in $psd1Files) {
    try {
        # Import the .psd1 file as a hashtable
        $moduleData = Import-PowerShellDataFile -Path $file.FullName

        # Update the ModuleVersion field
        $moduleData.ModuleVersion = $Version.ToString()

        # Write the updated hashtable back to the file
        $moduleData | Out-File -FilePath $file.FullName -Encoding UTF8

        Write-Host "Updated ModuleVersion in file: $($file.FullName)" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update file: $($file.FullName). Error: $_"
    }
}

Write-Host "ModuleVersion update completed." -ForegroundColor Cyan