param(
    [Parameter(Position = 0)]
    [string]$Workflow = "msvc-debug"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$MinimumCMakeVersion = [version]"4.3.0"

function Get-CMakeVersion
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Executable
    )

    $versionOutput = @(& $Executable --version)
    $cmakeExitCode = $LASTEXITCODE

    if ($cmakeExitCode -ne 0 -or $versionOutput.Count -eq 0)
    {
        throw "Unable to determine the CMake version for '$Executable'."
    }

    $versionMatch = [regex]::Match(
        $versionOutput[0],
        "^cmake version ([0-9]+\.[0-9]+\.[0-9]+)"
    )

    if (-not $versionMatch.Success)
    {
        throw "Unable to determine the CMake version for '$Executable'."
    }

    return [version]$versionMatch.Groups[1].Value
}

function Get-VisualStudioInstallationPath
{
    if ($env:VSINSTALLDIR -and (Test-Path $env:VSINSTALLDIR))
    {
        return (Resolve-Path $env:VSINSTALLDIR).Path
    }

    $vsWhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"

    if (-not (Test-Path $vsWhere))
    {
        throw "vswhere.exe was not found. Install Visual Studio 2026 with Desktop development with C++."
    }

    $visualStudioPath = & $vsWhere `
        -latest `
        -products * `
        -version "[18.0,19.0)" `
        -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        -requires Microsoft.VisualStudio.Component.VC.CMake.Project `
        -property installationPath

    if ($LASTEXITCODE -ne 0 -or -not $visualStudioPath)
    {
        throw "A compatible Visual Studio 2026 C++ installation was not found. Import the repository's .vsconfig with Visual Studio Installer."
    }

    return $visualStudioPath.Trim()
}

function Enter-VisualStudioEnvironment
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$VisualStudioPath
    )

    if ($env:VSCMD_VER)
    {
        return
    }

    $launchDevShell = Join-Path $VisualStudioPath "Common7\Tools\Launch-VsDevShell.ps1"

    if (-not (Test-Path $launchDevShell))
    {
        throw "Visual Studio Developer PowerShell could not be found."
    }

    & $launchDevShell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation

    if (-not $env:VSCMD_VER)
    {
        throw "Visual Studio Developer PowerShell did not initialize correctly."
    }
}

function Add-VisualStudioBuildToolsToPath
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$VisualStudioPath
    )

    $cmakeDirectory = Join-Path $VisualStudioPath "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
    $ninjaDirectory = Join-Path $VisualStudioPath "Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"

    $directories = @()

    if (Test-Path $cmakeDirectory)
    {
        $directories += $cmakeDirectory
    }

    if (Test-Path $ninjaDirectory)
    {
        $directories += $ninjaDirectory
    }

    if ($directories.Count -gt 0)
    {
        $env:PATH = ($directories -join ";") + ";" + $env:PATH
    }
}

function Get-CompatibleCMake
{
    param(
        [string]$VisualStudioPath
    )

    $candidates = @()

    if ($VisualStudioPath)
    {
        $bundledCMake = Join-Path $VisualStudioPath "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

        if (Test-Path $bundledCMake)
        {
            $candidates += $bundledCMake
        }
    }

    $pathCMake = Get-Command cmake -ErrorAction SilentlyContinue

    if ($pathCMake)
    {
        $candidates += $pathCMake.Source
    }

    foreach ($candidate in ($candidates | Select-Object -Unique))
    {
        $cmakeVersion = Get-CMakeVersion -Executable $candidate

        if ($cmakeVersion -ge $MinimumCMakeVersion)
        {
            return $candidate
        }
    }

    throw "CMake $MinimumCMakeVersion or newer is required. On Windows, importing .vsconfig installs the supported Visual Studio CMake integration."
}

$isWindowsHost = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$visualStudioPath = $null

if ($isWindowsHost)
{
    $visualStudioPath = Get-VisualStudioInstallationPath
    Enter-VisualStudioEnvironment -VisualStudioPath $visualStudioPath
    Add-VisualStudioBuildToolsToPath -VisualStudioPath $visualStudioPath
}

$cmake = Get-CompatibleCMake -VisualStudioPath $visualStudioPath
$ninja = Get-Command ninja -ErrorAction SilentlyContinue

if (-not $ninja)
{
    throw "Ninja is required by the project presets but was not found. On Windows, import the repository's .vsconfig with Visual Studio Installer."
}

if ($Workflow.StartsWith("clangcl-", [System.StringComparison]::OrdinalIgnoreCase))
{
    if (-not (Get-Command clang-cl -ErrorAction SilentlyContinue))
    {
        throw "clang-cl was requested but was not found in the Visual Studio environment."
    }
}

Write-Host "CMake executable: $cmake"
& $cmake --version
Write-Host "Ninja executable: $($ninja.Source)"
& $ninja.Source --version

& $cmake --workflow --preset $Workflow
exit $LASTEXITCODE
