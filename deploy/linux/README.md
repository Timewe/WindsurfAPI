# WindsurfAPI — Linux 免安装分发包

## 自己构建（可选）

分发包里的二进制由 CI 打好；想在本机构建：

```bash
npm i --no-save esbuild@0.28.1 @yao-pkg/pkg@6.21.0   # 仅构建期依赖，运行时仍是零依赖
npm run build:exe:linux          # → dist-linux/windsurfapi
npm run smoke:exe                # 启动自检：/health + /dashboard 必须都 200
```

`smoke:exe` 与 CI 用的是同一个脚本（`scripts/exe-boot-smoke.mjs`）——`pkg` 退出码为 0 也可能产出坏二进制（ESM→CJS 打包或 `pkg.assets` 漏项只在运行时暴露），所以判据是"能否启动并提供服务"。

## 文件说明

| 文件 | 说明 |
|---|---|
| `windsurfapi` | Linux x64 版本单文件可执行程序 |
| `run.sh` | 前台启动（终端窗口显示日志） |
| `run-background.sh` | 后台启动（关闭终端仍运行） |
| `stop.sh` | 停止后台进程 |

## 快速上手

### 1. 启动方式

**前台（看日志）：**
```bash
chmod +x run.sh && ./run.sh
```

**后台（关终端继续跑）：**
```bash
chmod +x run-background.sh stop.sh && ./run-background.sh
```

### 2. 首次启动

首次运行会自动：
- 生成随机 `API_KEY` 和 `DASHBOARD_PASSWORD`，写入 `.env`
- 打开浏览器到 `http://127.0.0.1:3003/dashboard`
- 在面板里贴上 Devin session token 即可使用

`.env` 文件在可执行文件旁边，重启会沿用。

### 3. 日志

```bash
tail -f windsurfapi.log
```

### 4. 系统服务（systemd，可选）

如果需要开机自启，可以创建 systemd 服务：

```bash
sudo nano /etc/systemd/system/windsurfapi.service
```

内容：

```ini
[Unit]
Description=WindsurfAPI
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/windsurfapi
ExecStart=/path/to/windsurfapi/windsurfapi
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable windsurfapi
sudo systemctl start windsurfapi
sudo systemctl status windsurfapi
```

## 注意事项

- **数据目录**：`Windsurf_data/` 在可执行文件旁边，包含账号池和统计数据。
- **仅本机访问**：默认绑定 `127.0.0.1`，不对局域网暴露。若需对外，编辑 `.env` 改 `HOST=0.0.0.0` 并设置强 `API_KEY`。
- **防火墙**：如需对外提供服务，记得开放端口 3003：
  ```bash
  sudo ufw allow 3003/tcp  # Ubuntu/Debian
  sudo firewall-cmd --add-port=3003/tcp --permanent && sudo firewall-cmd --reload  # CentOS/RHEL
  ```
