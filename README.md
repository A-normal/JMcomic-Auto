# JMcomic 自动下载打包工具

[![Docker Build Status](https://img.shields.io/docker/cloud/build/yourusername/jm-auto-downloader)](https://hub.docker.com/r/yourusername/jm-auto-downloader)
[![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)

基于 [JMComic-Crawler-Python](https://github.com/hect0x7/JMComic-Crawler) 的自动化监控下载工具，支持文件打包和 Docker 容器化部署。

## 功能特性

- 📁 监控 `pack.txt` 文件变化，自动解析、下载并打包（默认打包，如有需要请参考(https://github.com/hect0x7/JMComic-Crawler-Python/blob/master/assets/docs/sources/option_file_syntax.md#3-option%E6%8F%92%E4%BB%B6%E9%85%8D%E7%BD%AE%E9%A1%B9) 配置option.yml文件）
- 📦 集成 JMComic-Crawler 下载核心功能
- 🐳 提供 Docker 镜像部署方案
- ⏲️ 可配置轮询间隔时间（默认 120 秒）

## 快速开始

### 前置要求
- Python 3.8+
- Docker 20.10+ (可选)
- - 也支持 WSL + Docker Desktop 实现win平台运行 

### 本地运行
```bash
# 克隆仓库
git clone https://github.com/A-normal/JMcomic-Auto.git
cd JMcomic-Auto

# 安装依赖
pip install -r requirements.txt

cd ./tests

# 启动监控
python ./test.py
```

### 容器运行
- 本项目已经打包镜像并建立Docker Hub仓库，如果你只是想用的话也可以直接部署容器（注意目前不支持镜像仓库加速）
```bash
docker run -d \
  --restart=unless-stopped \
 -v /你的下载文件夹:/data/Auto_Download \            #必须，压缩文件保存路径
 -v /你的监控文件路径/pack.txt:/data/pack.txt \      #必须，监控的文件路径，程序会从这个文件读取漫画ID
  --name=JMcomic-auto \
bjrsteam1848/jmcomic-auto:latest
```
- 注意：***镜像自身并没有配置代理***，因此如果漫画下载失败就应该考虑自己的网络问题了

- 以下附容器工作文件夹结构，如有必要请根据自身需求调整容器配置：
```bash
/data/
├──Auto_Download/        # 漫画打包目录（必须）
├──pack.txt              # 监控文件（必须）
├──auto_option.yml       # 模块配置文件
├──option.yml            # 下载配置
├──history.yml           # 下载历史记录
└──jmauto.log            # 运行日志
```

## 作者

- 修仙者一号 (GitHub: [A-normal](https://github.com/A-normal))