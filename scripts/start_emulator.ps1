# start_emulator.ps1 - Expert Android Emulator Automation & Health Monitor
param(
    [string]$AvdName = "Pixel_5",
    [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Android Emulator Startup & Health Check " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Locate emulator.exe
$emulatorPath = "C:\Users\hp\AppData\Local\Android\Sdk\emulator\emulator.exe"
if (-not (Test-Path $emulatorPath)) {
    $cmd = Get-Command emulator -ErrorAction SilentlyContinue
    if ($cmd) {
        $emulatorPath = $cmd.Source
    } else {
        Write-Host "[ERROR] Android emulator executable not found at $emulatorPath." -ForegroundColor Red
        exit 1
    }
}

# 2. Check current ADB devices
$devices = adb devices 2>$null
$isOffline = $devices -match "offline"
$isDevice = $devices -match "emulator-\d+\s+device"

if ($isDevice) {
    $bootCompleted = (adb shell getprop sys.boot_completed 2>$null) -replace "`r|`n", ""
    if ($bootCompleted -eq "1") {
        Write-Host "[OK] Emulator '$AvdName' is already running, online, and ready!" -ForegroundColor Green
        exit 0
    }
}

# 3. Clean up any hanging or offline zombie processes
if ($isOffline) {
    Write-Host "[WARN] Found stuck/offline emulator instance. Resetting..." -ForegroundColor Yellow
    Stop-Process -Name qemu-system-x86_64, emulator -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    adb kill-server 2>$null
    adb start-server 2>$null
}

# 4. Remove stale lock files if no emulator is running
$runningProcs = Get-Process -Name *qemu*, *emulator* -ErrorAction SilentlyContinue
if (-not $runningProcs) {
    $lockFiles = Get-ChildItem "$HOME\.android\avd\$AvdName.avd\*.lock" -Recurse -ErrorAction SilentlyContinue
    if ($lockFiles) {
        Write-Host "[INFO] Clearing stale AVD lock files..." -ForegroundColor Gray
        Remove-Item -Path "$HOME\.android\avd\$AvdName.avd\*.lock" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 5. Position emulator window to the right side of the screen (1080p layout)
$userIniPath = "$HOME\.android\avd\$AvdName.avd\emulator-user.ini"
Set-Content $userIniPath "window.x = 1440`nwindow.y = 30`nwindow.scale = 0.400000`nresizable.config.id = -1`nposture = 0"

# 6. Launch Emulator
Write-Host "[INFO] Launching emulator '$AvdName' on the right side of your screen..." -ForegroundColor Cyan
Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $AvdName, "-no-boot-anim" -WindowStyle Normal

# 6. Wait for boot completion
Write-Host "[INFO] Waiting for Android OS to boot (timeout: ${TimeoutSeconds}s)..." -NoNewline
$elapsed = 0
$booted = $false

while ($elapsed -lt $TimeoutSeconds) {
    Start-Sleep -Seconds 3
    $elapsed += 3
    Write-Host "." -NoNewline

    $status = (adb shell getprop sys.boot_completed 2>$null) -replace "`r|`n", ""
    if ($status -eq "1") {
        $booted = $true
        break
    }
}

Write-Host ""
if ($booted) {
    Write-Host "[SUCCESS] Emulator '$AvdName' is fully booted and ready for Flutter debugging!" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Emulator did not signal boot completion within $TimeoutSeconds seconds, but is launching." -ForegroundColor Yellow
}
