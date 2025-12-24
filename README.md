# L4D2 Server Fast Deploy with Web Panel
# 求生之路2 服务器极速部署方案 (带 Web 面板)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)
![Shell Script](https://img.shields.io/badge/Shell-Script-green)

[中文](#中文) | [English](#english)

---


<a name="中文"></a>

## 🇨🇳 中文介绍

本项目提供了一套基于 Docker 的全自动化方案，用于快速部署带 **Web 管理面板** 的 **求生之路2 (L4D2) 专用服务器**。

传统的开服方式需要通过 SteamCMD 下载游戏文件，速度慢且不稳定。本项目利用“借鸡生蛋”的策略，直接从现成的 Docker 镜像 ([left4devops](https://www.google.com/url?sa=E&source=gmail&q=https://hub.docker.com/r/left4devops/l4d2)) 中提取游戏核心数据，并挂载到本地，最后启动由 [Q1en](https://www.google.com/url?sa=E&source=gmail&q=https://github.com/Q1en/L4D2-Manager-Panel) 开发的管理面板容器。

### ✨ 核心特性

* **🚀 极速部署**：无需漫长等待 SteamCMD 下载，直接利用 Docker 镜像层缓存提取游戏文件。
* **💻 可视化面板**：内置 Web 管理后台，轻松管理房间、RCON 指令和在线玩家。
* **🛠️ 自动修复**：脚本自动修正 Linux 文件权限 (UID 1000) 并修复源镜像中失效的软链接 (addons/cfg)。
* **📦 开箱即用**：继承了源镜像的环境，自带基础的 SourceMod 和 Metamod 支持。

### 📋 前置要求

* Linux 操作系统 (Ubuntu/Debian/CentOS/Rocky)
* 已安装 [Docker](https://docs.docker.com/get-docker/) 和 [Docker Compose](https://docs.docker.com/compose/install/)
* 已安装 Git

### 🛠️ 快速开始

#### 1. 克隆仓库

```bash
git clone https://github.com/Kogure9/L4D2-Manager-Panel.git
cd L4D2-Manager-Panel

```

#### 2. 修改配置 (可选)

编辑 `docker-compose.yml` 修改默认的管理员密码：

```yaml
environment:
  - PANEL_PASSWORD=请修改为你的强密码  # <--- 建议修改此处

```

#### 3. 运行部署脚本

赋予脚本执行权限并运行。该脚本会自动完成目录创建、文件提取、权限修复和服务启动。

```bash
chmod +x setup_game_files.sh
./setup_game_files.sh

```

#### 4. 访问面板

在浏览器访问：`http://你的服务器IP:27020`

* **默认账号**: `admin`
* **默认密码**: `password123` (或者你在第二步设置的密码)

---

<a name="english"></a>
## 🇬🇧 English Description

This project provides an automated solution to deploy a **Left 4 Dead 2 Dedicated Server** with a **Web Management Panel** in minutes.

Instead of waiting for SteamCMD to download game files from scratch (which can be slow depending on your network), this script extracts game data directly from the [left4devops](https://hub.docker.com/r/left4devops/l4d2) Docker image and mounts it to a local directory. It then launches a containerized manager panel created by [Q1en](https://github.com/Q1en/L4D2-Manager-Panel).

### ✨ Key Features
* **🚀 Lightning Fast**: Skips the lengthy SteamCMD download process by using a pre-built Docker image cache.
* **💻 Web Management**: Integrated web panel for managing server status, RCON, and players.
* **🛠️ Auto-Fixes**: Automatically handles Linux permission issues (UID 1000) and fixes broken symlinks (addons/cfg) from the source image.
* **📦 Out-of-the-Box**: Comes with basic SourceMod/Metamod environment (inherited from source image).

### 📋 Prerequisites
* Linux OS (Ubuntu/Debian/CentOS/Rocky)
* [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
* Git

### 🛠️ Quick Start

#### 1. Clone the Repository
```bash
git clone https://github.com/Kogure9/L4D2-Manager-Panel.git
cd L4D2-Manager-Panel

```

#### 2. Configuration (Optional)

Edit `docker-compose.yml` to change the default admin password:

```yaml
environment:
  - PANEL_PASSWORD=your_secure_password  # <--- Change this

```

#### 3. Run the Deployment Script

This script will initialize directories, extract game files, fix permissions, and start the server.

```bash
chmod +x setup_game_files.sh
./setup_game_files.sh

```

#### 4. Access the Panel

Visit: `http://YOUR_SERVER_IP:27020`

* **Default User**: `admin`
* **Default Password**: `password123` (or the one you set in step 2)

---

## 📁 Directory Structure / 目录结构

The script creates the following structure on your host machine (default path: `/root/docker-apps/l4d2/`)
脚本默认会在宿主机的 `/root/docker-apps/l4d2/` 下创建以下目录

* `serverfiles/`: **Game Core Files** (maps, addons, cfg, etc.) - *Mounted to container*
* `serverfiles/`：**游戏核心文件**（地图、插件、配置文件等） - *挂载到容器*
* `steamcmd/`: **SteamCMD Tool** - *For updates*
* `steamcmd/`：**SteamCMD工具** - *用于更新*
* `app/`: **Panel Source Code** - *Web panel logic*
* `app/`：**面板源代码** - *网页面板逻辑*

## ⚠️ FAQ / 常见问题

**Q: Container keeps restarting? / 容器反复重启？**

* **Check Logs**: Run `docker logs l4d2-panel`.
* **查看日志**：运行`docker logs l4d2 - panel`。
* **Module Error**: If you see `ModuleNotFoundError: No module named 'app'`, ensure your `docker-compose.yml` does not have an empty volume overwriting `/app`.
* **模块错误**：如果看到“ModuleNotFoundError: No module named 'app'”，请确保您的`docker - compose.yml`文件中没有用空卷覆盖`/app`。
* **Permission Error**: Ensure you ran the script with `root` privileges so `chown 1000:1000` works correctly.
* **权限错误**：确保您是以`root`权限运行脚本，这样`chown 1000:1000`才能正确运行。 

**Q: How to update the game? / 如何更新游戏？**

* The container handles SteamCMD updates on startup, or you can use the web panel to trigger an update.
* 容器启动时通常会检查更新，或者你可以通过 Web 面板触发更新。

## 🙏 Credits / 致谢

* **Manager Panel**: [Q1en/L4D2-Manager-Panel](https://www.google.com/url?sa=E&source=gmail&q=https://github.com/Q1en/L4D2-Manager-Panel)
* **Game Docker Image**: [Left4DevOps/l4d2-docker](https://www.google.com/url?sa=E&source=gmail&q=https://hub.docker.com/r/left4devops/l4d2)
