import reprobench.core.worker as worker
from loguru import logger

if __name__ == '__main__':
    w = worker.BenchmarkWorker("tcp://127.0.0.1:31313", None, 2)
    w.run()
