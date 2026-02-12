# KOCO-BENCH: Benchmarking Domain Specialization for Large Language Models in Software Development

<div align="center">
</div>

[![Arxiv](https://img.shields.io/badge/Arxiv-B31B1B?style=for-the-badge&logo=arxiv&logoColor=white)](https://www.arxiv.org/abs/2601.13240)
[![HuggingFace](https://img.shields.io/badge/HuggingFace-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)](https://huggingface.co/datasets/xueniki/KOCO-bench)


## 📋 Overview

**KOCO-bench** is a novel benchmark designed to evaluate domain specialization methods for Large Language Models (LLMs) in real-world software development scenarios. Unlike existing benchmarks that focus on assessing *what* knowledge LLMs possess, KOCO-bench evaluates *how* LLMs acquire and apply new domain knowledge.

### Key Highlights

- 🌐 **6 Emerging Domains**: Covering diverse areas of modern software development
- 🔧 **11 Software Frameworks**: Real-world frameworks with active development
- 📦 **25 Projects**: Comprehensive projects with production-level code
- 📚 **Curated Knowledge Corpora**: Explicit domain knowledge sources for specialization methods
- 🎯 **Multi-Granularity Evaluation**: From function-level to project-level code generation
- ✅ **Rigorous Test Suites**: Automated evaluation with comprehensive test coverage
- 💡 **Knowledge Understanding**: Multiple-choice Q&A for domain comprehension

## 🔍 Problem Statement

Large language models excel at general programming tasks but struggle with domain-specific software development. KOCO-bench addresses this gap by providing:

1. **Explicit Knowledge Corpora**: Structured domain knowledge (APIs, rules, constraints, etc.) for developing and testing specialization methods
2. **Realistic Evaluation**: Tasks require acquiring and applying domain knowledge, mimicking real-world development workflows
3. **Challenging Scenarios**: Current state-of-the-art LLMs show limited performance, highlighting the need for better domain specialization methods

## 🎯 Evaluation Tasks

### Task 1: Domain Code Generation

Multi-granularity code generation tasks with automated evaluation:

- **Function-Level**: Generate individual functions based on specifications
- **Module-Level**: Implement multiple related functions
- **Project-Level**: Complete end-to-end project implementations

Each task includes:
- 📝 Detailed requirements and specifications from algorithm documentation
- 🧪 Comprehensive test suites for automatic evaluation
- 📊 Multiple evaluation metrics (pass@k, avg_pass_ratio, etc.)

### Task 2: Domain Knowledge Understanding

Multiple-choice Q&A tasks to assess domain comprehension across **6 frameworks**:

| Dataset | Description |
|---------|-------------|
| **ascend-transformer-boost** | Ascend NPU transformer optimization |
| **cosmos-rl** |  Cosmos RL framework concepts |
| **robocasa** | Robot manipulation and simulation |
| **trackerLab** |   Visual object tracking |
| **triton-ascend** |  Triton compiler for Ascend |
| **VSLAM-LAB** | Visual SLAM algorithms |

Each question assesses:
- ✅ API usage comprehension
- ✅ Framework design patterns
- ✅ Domain-specific constraints
- ✅ Best practices and conventions
- ✅ Architectural decisions

## 🔧 Setup

### 1. Build Docker Eval Images

Code evaluation (Task 1, Step 4) runs inside Docker containers. Each framework maps to a slim, purpose-built image:

| Framework | Docker Image | Dockerfile |
|-----------|-------------|------------|
| `verl`, `open-r1` | `koco-eval-verl` | `Dockerfile.eval.verl` |
| `raganything`, `smolagents` | `koco-eval-rag` | `Dockerfile.eval.rag` |
| `tensorrt_model_optimizer` | `koco-eval-trt` | `Dockerfile.eval.trt` |

```bash
cd KOCO-bench/Build-Env/Docker
make all                    # build all eval images
# or build only what you need:
make FRAMEWORK=verl         # builds koco-eval-verl
make eval-rag               # builds koco-eval-rag
```

> The evaluation script automatically selects the correct image based on `--framework`. Build at least the image for the framework you plan to evaluate.

### 2. Configure Environment

We use the OpenRouter API for code generation or knowledge understanding evaluation, set your API key:

```bash
cp KOCO-bench-en/domain_code_generation/scripts/.env.example \
   KOCO-bench-en/domain_code_generation/scripts/.env
# then edit .env with your key
```

## 🚀 Usage

### Task 1: Domain Code Generation Evaluation

#### Option 1: Full Pipeline (Step 1-5)

Runs the complete pipeline end-to-end: parse algorithm methods, construct prompts, generate code via OpenRouter, execute evaluation in Docker, and aggregate metrics.

```bash
bash KOCO-bench-en/domain_code_generation/scripts/LLM_eval_openrouter.sh \
  --framework <FRAMEWORK> \
  --model <MODEL>
```

**Required parameters:**

| Parameter | Description | Available values |
|-----------|-------------|------------------|
| `--framework` | Target framework to evaluate | `verl`, `raganything`, `smolagents`, `open-r1`, `tensorrt_model_optimizer` |
| `--model` | OpenRouter model identifier | e.g. `qwen/qwen-2.5-coder-32b-instruct`, `deepseek/deepseek-chat-v3.1`, `openai/gpt-5-mini` |

**Examples:**

```bash
# Evaluate Qwen on the verl framework
bash KOCO-bench-en/domain_code_generation/scripts/LLM_eval_openrouter.sh \
  --framework verl \
  --model qwen/qwen-2.5-coder-32b-instruct
```

#### Option 2: Evaluate & Aggregate Only (Steps 4-5)

If you already have generated code (`_output.jsonl` files), use this to run only Docker execution evaluation and metrics aggregation:

```bash
bash KOCO-bench-en/domain_code_generation/scripts/run_docker_eval_and_aggregate.sh \
  --framework <FRAMEWORK> \
  --model <MODEL>
```

Takes the same `--framework`, `--model`, and `--test-example` parameters as above.

**Examples:**

```bash
# Evaluate and aggregate for already-generated results
bash KOCO-bench-en/domain_code_generation/scripts/run_docker_eval_and_aggregate.sh \
  --framework verl \
  --model qwen/qwen-2.5-coder-32b-instruct
```

#### Option 3: Training Custom Models

```bash
cd KOCO-bench-en/domain_code_generation/scripts

# SFT Training
bash sft/run_finetuning.sh

# LoRA Training (parameter-efficient)
bash lora/run_finetuning_lora.sh

# Inference with trained model
bash inference/start_inference_server.sh
bash inference/run_batch_code_generation_with_server.sh
```

### Task 2: Domain Knowledge Understanding Evaluation

#### Option 1: One-Click Evaluation (All Datasets)

```bash
cd KOCO-bench-en/domain_knowledge_understanding/scripts

# Evaluate all datasets with default model
bash run_evaluation_openrouter.sh

# Or specify a different model
MODEL="qwen/qwen-2.5-coder-32b-instruct" bash run_evaluation_openrouter.sh
```

#### Option 2: Evaluate Single Dataset

```bash
cd KOCO-bench-en/domain_knowledge_understanding/scripts

# Evaluate only one dataset
DATASET="cosmos-rl" bash run_evaluation_openrouter.sh

# With custom model
MODEL="anthropic/claude-sonnet-4.5" DATASET="robocasa" bash run_evaluation_openrouter.sh
```

#### Option 3: Using Python Script Directly

```bash
cd KOCO-bench-en/domain_knowledge_understanding/scripts

python3 evaluation_openrouter.py \
    --model "qwen/qwen2.5-coder-7b-instruct" \
    --input ../problems/problems_cosmos-rl_EN.json \
    --output ../results/qwen2.5-coder-7b-instruct/results_cosmos-rl.json \
    --temperature 0.0 \
    --max_tokens 4096
```

#### Option 4: Local Model Evaluation

```bash
cd KOCO-bench-en/domain_knowledge_understanding/scripts

# Start inference server
bash start_inference_server.sh

# Run evaluation
bash run_evaluation_local.sh

# Stop server
bash stop_inference_server.sh
```


## 🏗️ Benchmark Structure

<details>
<summary>Click to expand full directory tree</summary>

```
KOCO-bench/
├── KOCO-bench-en/                      # English version
│   ├── domain_code_generation/         # Code generation tasks
│   │   ├── {framework}/                # Framework-specific directories
│   │   │   ├── knowledge_corpus/       # Curated domain knowledge
│   │   │   │   ├── {framework}-main/   # Source code repository
│   │   │   │   └── metadata.json       # Framework metadata
│   │   │   ├── test_examples/          # Test projects
│   │   │   │   └── {example}/          # Individual test cases
│   │   │   │       ├── code/           # Project code
│   │   │   │       │   └── tests/      # Test suites
│   │   │   │       └── requirements/   # Task specifications
│   │   │   └── README.md
│   │   └── scripts/                    # Evaluation scripts
│   │       ├── README.md               # Detailed documentation
│   │       ├── QUICK_START_AGGREGATE.md
│   │       ├── parse_algorithm_methods.py
│   │       ├── prompts_construction.py
│   │       ├── execution_evaluation_pure.py
│   │       ├── aggregate_metrics.py
│   │       ├── LLM_eval_openrouter.sh  # One-click evaluation
│   │       ├── agent/                  # agent inference
│   │       ├── apicall/                # OpenRouter API integration
│   │       ├── sft/                    # Supervised fine-tuning
│   │       ├── lora/                   # LoRA training & inference
│   │       └── inference/              # Local model inference
│   └── domain_knowledge_understanding/ # Knowledge understanding tasks
│       ├── problems/                   # Multiple-choice Q&A datasets
│       │   ├── problems_ascend-transformer-boost_EN.json
│       │   ├── problems_cosmos-rl_EN.json
│       │   ├── problems_robocasa_EN.json
│       │   ├── problems_trackerLab_EN.json
│       │   ├── problems_triton-ascend_EN.json
│       │   └── problems_VSLAM-LAB_EN.json
│       ├── repositories/               # Full source code repositories
│       │   ├── ascend-transformer-boost/
│       │   ├── cosmos-rl/
│       │   ├── robocasa/
│       │   ├── trackerLab/
│       │   ├── triton-ascend/
│       │   └── VSLAM-LAB/
│       ├── results/                    # Evaluation results
│       └── scripts/                    # Evaluation scripts
│           ├── README.md
│           ├── evaluation_openrouter.py
│           ├── run_evaluation_openrouter.sh
│           └── evaluation_local.py
└── KOCO-bench-ch/                      # Chinese version
```

</details>

## 📖 Documentation

### Code Generation Documentation
- **[Code Generation Scripts README](KOCO-bench-en/domain_code_generation/scripts/README.md)**: Comprehensive guide for code generation evaluation workflow
- **[Quick Start: Aggregating Metrics](KOCO-bench-en/domain_code_generation/scripts/QUICK_START_AGGREGATE.md)**: Guide for metrics aggregation and comparison
- **[LoRA Training Guide](KOCO-bench-en/domain_code_generation/scripts/lora/README.md)**: LoRA fine-tuning documentation
- **[Inference Server Guide](KOCO-bench-en/domain_code_generation/scripts/inference/INFERENCE_SERVER_README.md)**: Local model serving
- **[Agent Guide](KOCO-bench-en/domain_code_generation/scripts/agent/README.md)**: Agent documentation

### Knowledge Understanding Documentation
- **[Knowledge Understanding Scripts README](KOCO-bench-en/domain_knowledge_understanding/scripts/README.md)**: Guide for running MCQ evaluation
- **[Local Inference Guide](KOCO-bench-en/domain_knowledge_understanding/scripts/LOCAL_INFERENCE_GUIDE.md)**: Using local models for knowledge understanding



## 🙏 Acknowledgments

We thank the open-source communities of all frameworks included in KOCO-bench for their excellent work and contributions to the field.

