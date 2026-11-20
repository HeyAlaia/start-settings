# 日常命令

```powershell
mise ls -g                 # 查看全局工具
mise ls                    # 查看当前目录生效版本
mise use -g node@22        # 全局切换 Node 版本（自动下载）
mise use node@20           # 仅当前项目（写入 ./mise.toml）
mise upgrade               # 升级全局工具
mise doctor                # 体检（PATH 冲突、未激活等）
mise prune                 # 清理不再引用的版本

uv python list             # Python 版本清单
uv python install 3.12 --default   # 装并设为默认
uv add requests            # 项目依赖（有 pyproject.toml 时）
uv pip list                # 全局包
uv tool install ruff       # 装 CLI 工具（隔离环境）
```
---

# 项目级用法

在仓库根目录放 `mise.toml`，即覆盖全局版本：

```toml
[tools]
java = "temurin-8"      # 老项目用 JDK 8
maven = "3.6.3"
node = "18"
```

- 只影响该目录及其子目录，全局配置不变；
- 建议把 `mise.toml` 提交到 git，团队共享；
- 需要完全可复现时再 `mise lock` 并提交 `mise.lock`，CI 用 `mise install --locked`。

# 官方网站
https://mise.jdx.dev/shell-setup.html

# 注意
添加powershell配置: 

```powershell
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
$activation = '(&mise activate pwsh) | Out-String | Invoke-Expression'
if (-not (Select-String -Path $PROFILE -SimpleMatch $activation -Quiet)) {
    Add-Content $PROFILE $activation
}
```
