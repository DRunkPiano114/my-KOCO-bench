#!/bin/bash
# Generate code via OpenRouter API (Steps 1-3 only, no Docker evaluation)

# Load common config (.env, SCRIPTS_DIR, PROJECT_ROOT, parse_common_args, etc.)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# Help information
show_usage() {
    echo "Usage: $0 --framework <name> --model <name> [options]"
    echo ""
    echo "Runs Steps 1-3 of the evaluation pipeline (code generation only)."
    echo "Produces _output.jsonl files without Docker execution evaluation."
    echo ""
    echo "Required:"
    echo "  --framework FRAMEWORK  Framework name (e.g., verl, raganything)"
    echo "  --model MODEL          Full model name (e.g., qwen/qwen-2.5-coder-32b-instruct)"
    echo ""
    echo "Optional:"
    echo "  --test-example NAME    Specify a single test example (default: process all)"
    echo "  --num-completions N    Number of completions per sample (default: 1)"
    echo "  --help                 Show help"
    echo ""
    echo "Supported models (not limited to):"
    echo "  meta-llama/llama-3.1-8b-instruct"
    echo "  qwen/qwen2.5-coder-7b-instruct"
    echo "  qwen/qwen-2.5-coder-32b-instruct"
    echo "  deepseek/deepseek-chat-v3.1"
    echo "  moonshotai/kimi-k2-0905"
    echo "  google/gemini-2.5-pro"
    echo "  anthropic/claude-sonnet-4.5"
    echo "  openai/gpt-5-mini"
    echo "  openai/o4-mini"
    echo ""
    echo "Examples:"
    echo "  bash $0 --framework verl --model qwen/qwen-2.5-coder-32b-instruct"
    echo "  bash $0 --framework verl --model deepseek/deepseek-chat-v3.1 --test-example prime"
    echo ""
    echo "After generation, run Docker eval + metrics separately:"
    echo "  bash run_docker_eval_and_aggregate.sh --framework verl --model qwen/qwen-2.5-coder-32b-instruct"
}

# Parse args & validate
parse_common_args "$@"

NUM_COMPLETIONS="${NUM_COMPLETIONS:-1}"
TEST_EXAMPLE="${TEST_EXAMPLE:-}"

validate_required_params

# Model directory name: strip provider prefix (qwen/xxx -> xxx)
MODEL_DIR_NAME="$(basename "${MODEL_NAME}")"

# Banner
echo "============================================================"
echo "LLM Code Generation (Steps 1-3, OpenRouter API)"
echo "============================================================"
echo "Framework:  ${FRAMEWORK}"
echo "Model:      ${MODEL_NAME}"
if [ -n "$TEST_EXAMPLE" ]; then
    echo "Test example: ${TEST_EXAMPLE}"
else
    echo "Test example: all"
fi
echo "Completions: ${NUM_COMPLETIONS}"
echo "============================================================"
echo ""

# Step 1: Parse algorithm methods
echo ">>> Step 1/3: Parse algorithm methods"
bash "$SCRIPTS_DIR/run_parse_algorithm_methods.sh" \
    --framework "$FRAMEWORK" \
    ${TEST_EXAMPLE:+--test-example "$TEST_EXAMPLE"} || {
    echo ""; echo "❌ Step 1 failed, aborting."; exit 1
}

# Step 2: Construct prompts
echo ">>> Step 2/3: Construct prompts"
bash "$SCRIPTS_DIR/run_prompts_construction.sh" \
    --framework "$FRAMEWORK" \
    ${TEST_EXAMPLE:+--test-example "$TEST_EXAMPLE"} || {
    echo ""; echo "❌ Step 2 failed, aborting."; exit 1
}

# Step 3: Generate code via OpenRouter API
echo ">>> Step 3/3: Generate code via OpenRouter API"
bash "$SCRIPTS_DIR/apicall/run_openrouter.sh" \
    --framework "$FRAMEWORK" \
    --model "$MODEL_NAME" \
    --num-completions "$NUM_COMPLETIONS" \
    ${TEST_EXAMPLE:+--test-example "$TEST_EXAMPLE"} || {
    echo ""; echo "❌ Step 3 failed, aborting."; exit 1
}

# Done
echo ""
echo "============================================================"
echo "All 3 steps completed successfully!"
echo "============================================================"
echo "Framework:  ${FRAMEWORK}"
echo "Model:      ${MODEL_NAME}"
echo "  1. Parse algorithm methods    ✅"
echo "  2. Construct prompts          ✅"
echo "  3. Generate code (OpenRouter) ✅"
echo ""
echo "Output files: ${SCRIPTS_DIR}/data/${FRAMEWORK}/${MODEL_DIR_NAME}/"
echo ""
echo "Next steps — run Docker eval + aggregate metrics:"
echo "  bash ${SCRIPTS_DIR}/run_docker_eval_and_aggregate.sh \\"
echo "    --framework ${FRAMEWORK} --model ${MODEL_NAME}"
echo "============================================================"
exit 0
