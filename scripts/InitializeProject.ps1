param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ProjectDescription
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

    $versionText = & $Executable --version

    if ($LASTEXITCODE -ne 0 -or $versionText -notmatch "cmake version ([0-9]+\.[0-9]+\.[0-9]+)")
    {
        throw "Unable to determine the CMake version for '$Executable'."
    }

    return [version]$Matches[1]
}

function Get-CompatibleCMake
{
    $candidates = @()
    $isWindowsHost = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT

    if ($isWindowsHost)
    {
        $vsWhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"

        if (Test-Path $vsWhere)
        {
            $visualStudioPath = & $vsWhere `
                -latest `
                -products * `
                -version "[18.0,19.0)" `
                -requires Microsoft.VisualStudio.Component.VC.CMake.Project `
                -property installationPath

            if ($LASTEXITCODE -eq 0 -and $visualStudioPath)
            {
                $bundledCMake = Join-Path $visualStudioPath.Trim() "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

                if (Test-Path $bundledCMake)
                {
                    $candidates += $bundledCMake
                }
            }
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

$cmake = Get-CompatibleCMake
$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Write-Host "CMake executable: $cmake"
& $cmake --version

Push-Location $repositoryRoot

try
{
    & $cmake `
        "-DPROJECT_NAME=$ProjectName" `
        "-DPROJECT_DESCRIPTION=$ProjectDescription" `
        -P scripts/InitializeProject.cmake

    $exitCode = $LASTEXITCODE
}
finally
{
    Pop-Location
}

exit $exitCode
