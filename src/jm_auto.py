import time
import os
import re
import threading
from watchdog.observers.polling import PollingObserver
from watchdog.events import FileSystemEventHandler
import jmcomic
import logging
import datetime
import yaml

# 该代码为容器镜像准备代码，不适合直接在本地运行，请参考README指引前往运行/tests/test.py


def load_config(config_path='/data/auto_option.yml'):
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        
        auto_config = config.get('jm_auto', {})
        
        return {
            'log_path': auto_config.get('log_path', './jmauto.log'),
            'option_path': auto_config.get('option_path', './option.yml'),
            'pack_path': auto_config.get('pack_path', './pack.txt'),
            'history_path': auto_config.get('history_path', './history.txt'),
            'delay_time': auto_config.get('delay_time', 120),
            'log_history': auto_config.get('log_history', False),
            'log_run': auto_config.get('log_run', False),
            'log_all': auto_config.get('log_all', True)
        }
    except Exception as e:
        print(f"读取配置文件失败: {e}，使用默认配置")
        return {
            'log_path': './jmauto.log',
            'option_path': './option.yml',
            'pack_path': './pack.txt',
            'history_path': './history.txt',
            'delay_time': 120,
            'log_history': False,
            'log_run': False,
            'log_all': True
        }

# 读取配置
config = load_config()

# 获取配置值
LOG_PATH = config['log_path']
OPTION_PATH = config['option_path']
PACK_PATH = config['pack_path']
HISTORY_PATH = config['history_path']
DELAY_TIME = config['delay_time']
LOG_HISTORY = config['log_history']
LOG_RUN = config['log_run']
LOG_ALL = config['log_all']

# 修改日志配置
logging.basicConfig(
    handlers=[
        logging.FileHandler(LOG_PATH),
        logging.StreamHandler(),
    ],
    level=logging.INFO
)

# 处理文件修改事件
class FileChangeHandler(FileSystemEventHandler):
    def __init__(self, target_filename):
        super().__init__()
        self.target_filename = target_filename
        # 延迟处理的秒数
        self.delay = DELAY_TIME
        # 用于控制延迟处理的计时器
        self.timer = None
        # 线程锁防止资源竞争
        self.lock = threading.Lock()
    
    def on_modified(self, event):
        # 只处理pack.txt文件的修改事件
        if not event.is_directory and os.path.basename(event.src_path) == "pack.txt":
            with self.lock:
                # 如果已有计时器在运行，先取消
                if self.timer is not None:
                    self.timer.cancel()
                # 创建新计时器，延迟执行处理
                self.timer = threading.Timer(self.delay, self.process_pack_file, args=(event.src_path,))
                self.timer.start()
                if LOG_ALL | LOG_RUN :
                    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    logging.info(f"[{current_time}] 检测到文件修改，等待 {self.delay} 秒后处理...")

    def process_pack_file(self, PACK_PATH):
        # 读取pack.txt中的所有行
        with open(PACK_PATH, "r", encoding='utf-8') as f:
            lines = f.readlines()
        
        if (not lines) & (LOG_ALL | LOG_RUN):
            current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logging.info(f"[{current_time}] pack.txt文件为空，无需处理。")
            return

        # 使用正则表达式匹配5到7位数字
        pattern = re.compile(r"^\d{5,7}$")

        # 处理每一非空行
        for line in lines:
            id_value = line.strip()
            if pattern.match(id_value):
                if LOG_ALL | LOG_RUN | LOG_HISTORY:
                    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    logging.info(f"[{current_time}] 处理ID: {id_value}")
                try:
                    # 在此添加自定义逻辑（如调用API、写入数据库等）
                    # 注意配置文件路径，默认为项目根目录
                    jmcomic.create_option_by_file(OPTION_PATH).download_album(id_value)

                    # 每处理一行后立即添加到历史记录文件（带时间戳）
                    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    with open(HISTORY_PATH, "a", encoding='utf-8') as f:
                        f.write(f"[{current_time}] {id_value}\n")
                    
                    if LOG_ALL | LOG_RUN | LOG_HISTORY:
                        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        logging.info(f"[{current_time}] 已将 {id_value} 添加到历史记录")
        
                except Exception as e:
                    if LOG_ALL | LOG_RUN | LOG_HISTORY:
                        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        logging.info(f"[{current_time}] 处理ID {id_value} 时发生错误: {str(e)}")
                    # 记录错误到历史文件
                    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    with open(HISTORY_PATH, "a", encoding='utf-8') as f:
                        f.write(f"[{current_time}] ERROR: {id_value} - {str(e)}\n")

        # 重新打开文件后清空文件（或保留未处理内容）
        with open(PACK_PATH, "w", encoding='utf-8') as f:
            f.seek(0)
            f.truncate()

        if LOG_ALL | LOG_RUN | LOG_HISTORY:
            current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            logging.info(f"[{current_time}] 已将历史记录添加到 history.txt")

if __name__ == "__main__":
    # 获取绝对路径和目录
    target_abspath = os.path.abspath(PACK_PATH)
    target_dir = os.path.dirname(target_abspath)
    target_filename = os.path.basename(target_abspath)

    if LOG_ALL :
        logging.info("监控目标:\n路径: %s\n目录: %s\n文件名: %s", target_abspath, target_dir, target_filename)

    event_handler = FileChangeHandler(target_filename)
    # 实例化Observer对象，设置监控路径和是否递归监控子目录（recursive=False表示不递归）
    # 使用轮询监控，保证docker正常运行（容器中普通观察者只能观测到容器级别的更改，来自宿主机的外部更改无法观测）
    # 非docker用户可以使用普通观察者
    observer = PollingObserver()
    observer.schedule(event_handler, path=target_dir, recursive=False)
    observer.start()
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if LOG_ALL :
        logging.info(f"[{current_time}] 开始监控文件: {target_abspath}")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        # 确保退出前取消可能存在的计时器
        with event_handler.lock:
            if event_handler.timer is not None:
                event_handler.timer.cancel()
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if LOG_ALL :
            logging.info(f"[{current_time}] 停止监控")
    observer.join()
