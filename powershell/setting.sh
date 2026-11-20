# ============================================================
#  PowerShell 7 个人配置文件 (Profile)
#  路径: $PROFILE
#        C:\Users\mrala\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#  范围: 当前用户 + 当前宿主 (Windows 终端 / 独立 pwsh 窗口)
#  编辑: code $PROFILE    或   notepad $PROFILE
#  重载: . $PROFILE       (不重开窗口也能让改动生效)
#  自检: 取消下面这行的注释，新开窗口看到提示即代表已加载
# Write-Host 'PowerShell 7 profile 已加载' -ForegroundColor DarkGray
#
#  备注: 若希望 VS Code 等「所有宿主」都加载，把内容放到
#        $PROFILE.CurrentUserAllHosts
#        (C:\Users\mrala\Documents\PowerShell\profile.ps1)
# ============================================================

# 可选：更严格的错误检查（按需取消注释）
# Set-StrictMode -Version Latest
# $ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# 1. 别名 / 短命令
#    注意：不要覆盖内置别名，例如 ls / cd / cat / pwd
# ------------------------------------------------------------
# Set-Alias -Name ll -Value Get-ChildItem

# ------------------------------------------------------------
# 2. 函数 / 快捷操作  ← 主要写在这里
# ------------------------------------------------------------
# function mkcd {
#     param([Parameter(Mandatory)][string]$Path)
#     New-Item -ItemType Directory -Force -Path $Path | Out-Null
#     Set-Location -LiteralPath $Path
# }
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
function kill-port {
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
function dns {
    <#
    .SYNOPSIS
        查看当前各网卡的 DNS 服务器配置，并测试 DNS 解析是否正常。
    .EXAMPLE
        dns              # 查看全部网卡的 DNS
        dns baidu.com    # 查看并测试解析指定域名
    #>
    param(
        [string]$TestDomain = "www.baidu.com"
    )

    Write-Host ""
    Write-Host "=== 各网卡当前使用的 DNS 服务器 ===" -ForegroundColor Cyan
    Get-DnsClientServerAddress |
        Where-Object { $_.ServerAddresses.Count -gt 0 } |
        Select-Object InterfaceAlias,
                      AddressFamily,
                      ServerAddresses |
        Format-Table -AutoSize

    Write-Host "=== 系统摘要（ipconfig /all 中 DNS 部分）===" -ForegroundColor Cyan
    # 兼容中英文系统
    ipconfig /all | Select-String -Pattern "DNS Servers|DNS 服务器"
    Write-Host ""

    if ($TestDomain) {
        Write-Host "=== 解析测试: $TestDomain ===" -ForegroundColor Cyan
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $result = Resolve-DnsName -Name $TestDomain -ErrorAction Stop |
                      Select-Object -First 3 Name, Type, IPAddress
            $sw.Stop()
            $result | Format-Table -AutoSize
            Write-Host ("解析耗时: {0} ms" -f $sw.ElapsedMilliseconds) -ForegroundColor Green
        }
        catch {
            $sw.Stop()
            Write-Host "解析失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
# ------------------------------------------------------------
# 3. 环境变量 / PATH
#    注意：嵌套启动 pwsh 时本文件会重复加载，追加 PATH 前先判重
# ------------------------------------------------------------
# $env:MY_VAR = 'value'

# ------------------------------------------------------------
# 4. 模块 / 补全 / 提示符
# ------------------------------------------------------------
# Import-Module PSReadLine
# Set-PSReadLineOption -PredictionSource History
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (& mise activate pwsh) | Out-String | Invoke-Expression
}
