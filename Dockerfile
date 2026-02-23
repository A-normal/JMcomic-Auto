# 使用官方Python镜像
FROM python:3.15.0a6-slim-trixie AS builder

WORKDIR /app

# 复制依赖文件并安装
COPY requirements.txt .

# 安裝 git 和编译工具以满足 Pillow 的安装需求
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3-dev \
    libffi-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --prefix=/install -r requirements.txt

FROM python:3.15.0a6-slim-trixie AS runtime

# 设置容器时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建工作目录
WORKDIR /app

COPY --from=builder /install /usr/local

RUN apt-get update && apt-get install -y \
    git \
    libjpeg62-turbo \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/A-normal/JMComic-Crawler-Python.git

RUN pip install -e ./JMComic-Crawler-Python

# 默认依赖配置
COPY /public/option.yml /data/option.yml
# 默认模块配置
COPY /public/auto_option.yml /data/auto_option.yml
# 历史记录留档
COPY /public/history.txt /data/history.txt
# 应用程序代码
COPY /src/jm_auto.py /app/src/jm_auto.py

RUN mkdir -p /data/Auto_Download

# 设置入口点
ENTRYPOINT ["python", "/app/src/jm_auto.py"]