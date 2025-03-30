# 使用官方Python精简镜像
FROM python:3.11-slim-bullseye

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# 从项目克隆
RUN git clone https://github.com/A-normal/JMComic-Crawler-Python.git /app

# 设置容器时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app
# 复制依赖文件并安装，注意手动安装jmcomic模块
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir .

# 复制应用程序代码
COPY /src/jm_auto.py /app/src/jmcomic/jm_auto.py

RUN mkdir -p /data/Auto_Download

# 设置入口点
ENTRYPOINT ["python", "/app/src/jmcomic/jm_auto.py"]