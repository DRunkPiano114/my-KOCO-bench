#!/bin/bash
# 纯净模式执行代码评估 - 不做任何额外处理

# load common config
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# 数据源类型：data 或 rag（默认：data）
DATA_SOURCE="${DATA_SOURCE:-data}"

# check required parameters
validate_required_params
if [ -z "${TEST_EXAMPLE:-}" ]; then
    echo "❌ Error: TEST_EXAMPLE is not set (required a single test example as argument)"
    echo "Usage: FRAMEWORK=xxx MODEL_NAME=xxx TEST_EXAMPLE=xxx bash $0"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_DIR_NAME=$(basename "${MODEL_NAME}")
SOURCE_DIR="${PROJECT_ROOT}/${FRAMEWORK}/test_examples/${TEST_EXAMPLE}/code"
DATA_DIR="${PROJECT_ROOT}/scripts/${DATA_SOURCE}/${FRAMEWORK}/${MODEL_DIR_NAME}"
INPUT_FILE="${DATA_DIR}/algorithm_methods_data_${TEST_EXAMPLE}_output.jsonl"
OUTPUT_FILE="${DATA_DIR}/algorithm_methods_data_${TEST_EXAMPLE}_result.jsonl"

echo "========================================================"
echo "🔬 纯净模式执行代码评估"
echo "========================================================"
echo "框架: ${FRAMEWORK}"
echo "模型: ${MODEL_NAME}"
echo "数据源: ${DATA_SOURCE}"
echo "测试示例: ${TEST_EXAMPLE}"
echo "源代码目录: ${SOURCE_DIR}"
echo "输入文件: ${INPUT_FILE}"
echo "输出文件: ${OUTPUT_FILE}"
echo "========================================================"
echo ""

# Select Docker image based on framework
case "${FRAMEWORK}" in
    verl|open-r1)                DOCKER_IMAGE="koco-eval-verl" ;;
    raganything|smolagents)       DOCKER_IMAGE="koco-eval-rag"  ;;
    tensorrt_model_optimizer)     DOCKER_IMAGE="koco-eval-trt"  ;;
    *) echo "❌ Error: Unknown framework '${FRAMEWORK}' — cannot select Docker image"; exit 1 ;;
esac

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
    echo "❌ Error: Docker daemon is not running"
    echo ""
    echo "Please start Docker first:"
    echo "  - macOS/Windows: Start Docker Desktop"
    echo "  - Linux: sudo systemctl start docker"
    exit 1
fi

# Check if Docker image exists
if [ -z "$(docker images -q "$DOCKER_IMAGE" 2>/dev/null)" ]; then
    echo "❌ Error: Docker image '${DOCKER_IMAGE}' does not exist"
    echo ""
    echo "Please build the image first:"
    echo "  cd $(cd "$SCRIPTS_DIR/../../.." && pwd)/Build-Env/Docker"
    echo "  make FRAMEWORK=${FRAMEWORK}"
    exit 1
fi

echo "🐳 Docker image: ${DOCKER_IMAGE}"
echo ""

# 检查文件
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ 错误: 源代码目录不存在: $SOURCE_DIR"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ 错误: 输入文件不存在: $INPUT_FILE"
    exit 1
fi

# Run execution evaluation in Docker container
CONTAINER_MNT="/workspace/project"

# Map host path to container path (PROJECT_ROOT -> /workspace/project)
CONTAINER_SOURCE_DIR="${SOURCE_DIR/${PROJECT_ROOT}/${CONTAINER_MNT}}"
CONTAINER_INPUT_FILE="${INPUT_FILE/${PROJECT_ROOT}/${CONTAINER_MNT}}"
CONTAINER_OUTPUT_FILE="${OUTPUT_FILE/${PROJECT_ROOT}/${CONTAINER_MNT}}"

docker run --rm \
    --user "$(id -u):$(id -g)" \
    -v "${PROJECT_ROOT}:${CONTAINER_MNT}" \
    "${DOCKER_IMAGE}" \
    python3 "${CONTAINER_MNT}/scripts/execution_evaluation_pure.py" \
        --source_dir "$CONTAINER_SOURCE_DIR" \
        --input_file "$CONTAINER_INPUT_FILE" \
        --output_file "$CONTAINER_OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================================"
    echo "✅ 评估完成！"
    echo "结果文件: ${OUTPUT_FILE}"
    
    # 显示指标
    METRICS_FILE="${OUTPUT_FILE//_result.jsonl/_result.metrics.json}"
    if [ -f "$METRICS_FILE" ]; then
        echo "指标文件: ${METRICS_FILE}"
        echo ""
        echo "Pass@k 结果:"
        cat "$METRICS_FILE" | python3 -m json.tool 2>/dev/null || cat "$METRICS_FILE"
    fi
    echo "========================================================"
else
    echo ""
    echo "❌ 评估失败"
    exit 1
fi

