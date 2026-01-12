from pathlib import Path

TASK_MAP: dict[str, list[str]] = {
    "RST1": ["RST1"],
    "RST2": ["RST2"],
    "IDG": ["1_IDG", "2_IDG", "3_IDG"],
    "IDE": ["1_IDE", "2_IDE", "3_IDE"],
    "IDR": ["1_IDR", "2_IDR", "3_IDR"],


}
# Project root = .../eeg_pipeline_project
ROOT_DIR = Path(__file__).resolve().parent
STORAGE_DIR = ROOT_DIR / "storage"

INPUT_DIR = STORAGE_DIR / "input_data"
OUTPUT_DIR = STORAGE_DIR / "output_data"
IMAGE_DIR = STORAGE_DIR / "images"
LOGGER_DIR = STORAGE_DIR / "logs"

FS = 500
CHANNELS = 64
TAU = 10  # for f7 and f8 tau parameter
LAG = 1  # for f1 and f3 lag(tau) parameter
EMB_DIM = 2

# Default number of parallel tasks per feature channel
PARALLEL_TASK_COUNT = 3

# Memory limit threshold (adjust based on empirical observations)
MAX_WORKER_MEMORY_LIMIT = 0.01 # Minimum memory required per worker (unit depends on implementation)

# CPU utilization ratio (used in functions like safe_worker_count)
CPU_UTILIZATION_RATIO = 0.01  # Used to estimate safe_worker_count
