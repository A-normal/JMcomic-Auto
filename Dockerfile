# 使用官方Python精简镜像
FROM python:3.11-slim-bullseye

# 设置容器时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建工作目录
WORKDIR /app
# 复制依赖文件并安装，注意手动安装jmcomic模块
COPY requirements.txt .
# 安裝 git
RUN apt-get update && apt-get install -y git
RUN pip install --no-cache-dir -r requirements.txt

# 清理下载缓存
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

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