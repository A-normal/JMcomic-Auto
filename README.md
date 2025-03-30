# JM 自动下载打包工具

[![Docker Build Status](https://img.shields.io/docker/cloud/build/yourusername/jm-auto-downloader)](https://hub.docker.com/r/yourusername/jm-auto-downloader)
[![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)

基于 [JMComic-Crawler-Python](https://github.com/hect0x7/JMComic-Crawler) 的自动化监控下载工具，支持文件打包和 Docker 容器化部署。

## 功能特性

- 📁 监控 `pack.txt` 文件变化，自动解析、下载并打包（默认打包，如有需要请参考(https://github.com/hect0x7/JMComic-Crawler-Python/blob/master/assets/docs/sources/option_file_syntax.md#3-option%E6%8F%92%E4%BB%B6%E9%85%8D%E7%BD%AE%E9%A1%B9)配置option.yml文件）
- 📦 集成 JMComic-Crawler 下载核心功能
- 🐳 提供生产级 Docker 镜像部署方案
- ⏲️ 可配置轮询间隔时间（默认 100 秒）

## 快速开始

### 前置要求
- Python 3.8+
- Docker 20.10+ (可选)
- - 也支持 WSL + Docker Desktop 实现win平台运行 

### 本地运行
```bash
# 克隆仓库
git clone https://github.com/A-normal/JM-Auto.git
cd JM-Auto

# 安装依赖
pip install -r requirements.txt

cd ./tests

# 启动监控
python ./test.py