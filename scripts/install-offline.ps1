# ─────────────────────────────────────────────────────────────────────────────
# install-offline.ps1
# Extracts a framework's node_modules into your project directory (Windows)
#
# Usage:
#   .\install-offline.ps1 -Framework typescript-vite -TargetPath C:\myapp
#   .\install-offline.ps1 -Framework all -TargetPath C:\projects
#
# Frameworks:
#   typescript-vite, react-vite, nextjs, vuejs-vite, nuxt,
#   angular, svelte, remix, astro, gatsby, nodejs-backend, all
# ─────────────────────────────────────────────────────────────────────────────

param(
    [Parameter(Mandatory=$true)]
    [string]$Framework,

    [Parameter(Mandatory=$true)]
    [string]$TargetPath,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Frameworks = @(
    "react-vite",
    "nextjs",
    "vuejs-vite",
    "nuxt",
    "angular",
    "svelte",
    "remix",
    "astro",
    "gatsby",
    "nodejs-backend"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Header {
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  NPM Offline Package Installer (Windows)" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Usage {
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\install-offline.ps1 -Framework <name> -TargetPath <path>"
    Write-Host ""
    Write-Host "Frameworks:" -ForegroundColor Yellow
    foreach ($fw in $Frameworks) {
        Write-Host "  - $fw"
    }
    Write-Host "  - all  (installs each into <TargetPath>\<framework>\)"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\install-offline.ps1 -Framework typescript-vite -TargetPath C:\myapp"
    Write-Host "  .\install-offline.ps1 -Framework all -TargetPath C:\projects"
}

function Find-Tarball {
    param([string]$fw)
    $path = Join-Path $ScriptDir "node_modules_by_framework\${fw}-node_modules.tar.gz"
    if (Test-Path $path) { return $path }
    return $null
}

function Install-Framework {
    param([string]$fw, [string]$target)

    $tarball = Find-Tarball $fw
    if (-not $tarball) {
        Write-Host "  ✗ Tarball not found for '$fw'" -ForegroundColor Red
        Write-Host "    Expected: $ScriptDir\node_modules_by_framework\${fw}-node_modules.tar.gz"
        return $false
    }

    Write-Host "  → Installing " -NoNewline -ForegroundColor Cyan
    Write-Host "$fw" -NoNewline -ForegroundColor White
    Write-Host " into $target..." -ForegroundColor Cyan

    # Create target directory
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
    }

    # Copy package.json
    $pkgJson = Join-Path $ScriptDir "package_jsons\$fw\package.json"
    if (Test-Path $pkgJson) {
        Copy-Item $pkgJson (Join-Path $target "package.json") -Force
        Write-Host "    ✓ Copied package.json" -ForegroundColor Green
    }

    # Extract node_modules using tar (available in Windows 10+)
    $startTime = Get-Date
    try {
        tar -xzf $tarball -C $target
        $elapsed = [int]((Get-Date) - $startTime).TotalSeconds
        Write-Host "    ✓ Extracted node_modules (${elapsed}s)" -ForegroundColor Green
    } catch {
        Write-Host "    ✗ Extraction failed: $_" -ForegroundColor Red
        Write-Host "    Trying with 7-Zip..." -ForegroundColor Yellow
        if (Get-Command "7z" -ErrorAction SilentlyContinue) {
            7z x $tarball -o"$target" -y
            Write-Host "    ✓ Extracted with 7-Zip" -ForegroundColor Green
        } else {
            Write-Host "    ✗ 7-Zip not found. Install 7-Zip or use tar." -ForegroundColor Red
            return $false
        }
    }

    # Create .npmrc for offline use
    $npmrc = Join-Path $target ".npmrc"
    @"
prefer-offline=true
legacy-peer-deps=true
"@ | Set-Content $npmrc
    Write-Host "    ✓ Created .npmrc (prefer-offline mode)" -ForegroundColor Green
    Write-Host ""
    return $true
}

# ─── Main ────────────────────────────────────────────────────────────────────
Write-Header

if ($Framework -eq "all") {
    Write-Host "Installing all frameworks..." -ForegroundColor Yellow
    Write-Host ""
    $success = 0
    $failed  = 0
    foreach ($fw in $Frameworks) {
        $fwTarget = Join-Path $TargetPath $fw
        $result = Install-Framework $fw $fwTarget
        if ($result) { $success++ } else { $failed++ }
    }
    Write-Host "════════════════════════════════" -ForegroundColor White
    Write-Host "  ✓ Success: $success" -ForegroundColor Green
    if ($failed -gt 0) {
        Write-Host "  ✗ Failed:  $failed" -ForegroundColor Red
    }
} else {
    # Validate framework
    if ($Framework -notin $Frameworks) {
        Write-Host "Error: Unknown framework '$Framework'" -ForegroundColor Red
        Write-Host ""
        Write-Usage
        exit 1
    }
    $result = Install-Framework $Framework $TargetPath
    if (-not $result) { exit 1 }
}

Write-Host "Done! Your offline packages are ready." -ForegroundColor Green
Write-Host ""
Write-Host "Tip: Run 'npm install --prefer-offline --legacy-peer-deps'" -ForegroundColor Yellow
Write-Host "     inside your project if you need to resolve lockfiles." -ForegroundColor Yellow
Write-Host ""
