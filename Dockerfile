# # 使用官方Python镜像
# FROM python:3.14.0a6
# FROM python:3.12
# 使用官方Python精简镜像
FROM python:3.11-slim-bullseye

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# 从项目克隆
RUN git clone https://github.com/A-normal/JMComic-Crawler-Python.git /app/

# 设置容器时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app
# 复制依赖文件并安装
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# 复制应用程序代码
COPY /history.txt /data/history.txt
COPY /pack.txt /data/pack.txt
COPY /option.yml /data/option.yml
COPY /jmauto.log /data/jmauto.log
COPY /src/jm_auto_docker.py /app/src/jmcomic/jm_auto_docker.py

RUN mkdir /data/Auto_Download

# 设置权限和用户，若不需要，注释即可
# RUN chown -R appuser:appuser /app
# USER appuser

# 设置入口点
ENTRYPOINT ["python", "/app/src/jmcomic/jm_auto_docker.py"]