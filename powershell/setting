function ll { Get-ChildItem -Force $args }
function gac {
    [CmdletBinding()]    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message
    )
    Write-Host "--- Git Automate Commit ---" -ForegroundColor Cyan
    try {
        if (-not (Test-Path ".git")) {
            Write-Error "Current directory is not a Git repository."
            return
        }
        Write-Host "Staging all changes (git add -A)..." -ForegroundColor Yellow
        git add -A | Out-Null
        Write-Host "Committing with message: '$Message' (git commit -m)..." -ForegroundColor Yellow
        git commit -m $Message
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Git commit successful!" -ForegroundColor Green
        } else {
            Write-Error "Git commit failed. Check for uncommitted changes or other issues."
        }
    }
    catch {
        Write-Error "An error occurred during git operations: $($_.Exception.Message)"
    }
    Write-Host "--- End of Git Automate Commit ---" -ForegroundColor Cyan
}
function server { npx serve -s . -l 8080 }
function proxy { $env:HTTP_PROXY="http://127.0.0.1:7897"; $env:HTTPS_PROXY="http://127.0.0.1:7897"; $env:no_proxy="" }
function Stop-PortProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [int]$Port
    )
    Write-Host "--- Stopping Process on Port $Port ---" -ForegroundColor Cyan
    try {
        $pids = (netstat -ano | Select-String ":${Port}" | ForEach-Object { $_ -split '\s+' | Select-Object -Last 1 }) | Sort-Object -Unique | Where-Object { $_ -ne $null -and $_ -ne "" }
        if (-not $pids) {
            Write-Host "No process found using port $Port." -ForegroundColor Green
            return
        }
        Write-Host "Found processes using port ${Port}:" -ForegroundColor Yellow
        $processesToKill = @()
        foreach ($currentPid in $pids) {
            $process = Get-Process -Id $currentPid -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "  PID: $($process.Id), Process Name: $($process.ProcessName)" -ForegroundColor Yellow
                $processesToKill += $process
            } else {
                Write-Host "  PID: $currentPid (Process already terminated or not found)" -ForegroundColor DarkYellow
            }
        }
        if ($processesToKill.Count -eq 0) {
            Write-Host "All processes found using port $Port are already terminated or inaccessible." -ForegroundColor Green
            return
        }
        $confirm = Read-Host "Do you want to force kill these processes? (y/n)"
        if ($confirm -eq 'y' -or $confirm -eq 'Y') {
            foreach ($process in $processesToKill) {
                Write-Host "Attempting to force kill process $($process.ProcessName) with PID $($process.Id)..." -ForegroundColor Magenta
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
                Write-Host "Process $($process.ProcessName) (PID $($process.Id)) killed successfully." -ForegroundColor Green
            }
        } else {
            Write-Host "Operation cancelled by user." -ForegroundColor DarkYellow
        }
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
    }
    Write-Host "--- End of Port Process Stopper ---" -ForegroundColor Cyan
}
