# # 使用官方Python镜像
# FROM python:3.14.0a6
# FROM python:3.12
# 使用官方Python精简镜像
FROM python:3.11-slim-bullseye

# 从原项目克隆（后续处理未完成，不可使用）
# RUN git clone https://github.com/A-normal/JMComic-Crawler-Python.git /app/
# RUN echo "watchdog" >> /app/requirements-dev.txt

# 设置容器时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app
# 复制依赖文件并安装
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# 复制应用程序代码
COPY / /app

# 设置权限和用户，若不需要，注释即可
# RUN chown -R appuser:appuser /app
# USER appuser

# 设置入口点
ENTRYPOINT ["python", "/app/src/jmcomic/jm_auto.py"]