# 这是多段构建法创建的最小镜像包，完全移除了所有构建工具，仅保留模块编译结果，体积减小至300M
# 如有需要，使用该文件替换已有的Dockerfile文件
# 前排提示：二段构建消耗时间较长（>500s）且极度依赖网络环境，如果不是确实需要严格控制镜像体积，开发版本（RE）与当前版本（SLIM）功能上并无任何区别，更建议使用前者
# 阶段1：构建阶段（安装依赖并编译）
FROM python:3.11-slim-bullseye as builder

RUN apt-get update && \
    apt-get install -y git build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

# 克隆源码
RUN git clone https://github.com/A-normal/JMComic-Crawler-Python.git /app
WORKDIR /app

# 安装项目到临时目录（避免污染系统路径）
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt && \
    pip install --user --no-cache-dir . 

# 阶段2：运行阶段（仅保留必要文件）
FROM python:3.11-slim-bullseye

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 从构建阶段复制已安装的Python包
COPY --from=builder /root/.local/lib /usr/local/lib
COPY --from=builder /root/.local/bin /usr/local/bin

# 复制入口文件
COPY /src/jm_auto.py /usr/local/bin/jm_auto.py

# 创建数据目录
RUN mkdir -p /data/Auto_Download

# 默认下载配置
COPY /public/option.yml /data/option.yml
# 历史记录留档
COPY /public/history.txt /data/history.txt

ENTRYPOINT ["python", "/usr/local/bin/jm_auto.py"]