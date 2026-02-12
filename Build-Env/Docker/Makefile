.PHONY: all eval-rag eval-verl eval-trt clean help

# Framework → target mapping for `make FRAMEWORK=xxx`
ifdef FRAMEWORK
ifeq ($(FRAMEWORK),verl)
_TARGETS := eval-verl
else ifeq ($(FRAMEWORK),open-r1)
_TARGETS := eval-verl
else ifeq ($(FRAMEWORK),raganything)
_TARGETS := eval-rag
else ifeq ($(FRAMEWORK),smolagents)
_TARGETS := eval-rag
else ifeq ($(FRAMEWORK),tensorrt_model_optimizer)
_TARGETS := eval-trt
else
$(error Unknown FRAMEWORK "$(FRAMEWORK)". Use: verl, open-r1, raganything, smolagents, tensorrt_model_optimizer)
endif
else
_TARGETS := eval-rag eval-verl eval-trt
endif

# Default: build all (or just the FRAMEWORK target if set)
all: $(_TARGETS)

# --- Individual image targets ---

eval-rag:
	docker build -f Dockerfile.eval.rag -t koco-eval-rag .

eval-verl:
	docker build -f Dockerfile.eval.verl -t koco-eval-verl .

eval-trt:
	docker build -f Dockerfile.eval.trt -t koco-eval-trt .

# --- Cleanup ---

clean:
	-docker rmi koco-eval-rag koco-eval-verl koco-eval-trt 2>/dev/null

# --- Help ---

help:
	@echo "KOCO-bench eval Docker images"
	@echo ""
	@echo "Usage:"
	@echo "  make all                           Build all 3 eval images"
	@echo "  make eval-rag                      Build raganything + smolagents image"
	@echo "  make eval-verl                     Build verl + open-r1 image"
	@echo "  make eval-trt                      Build tensorrt_model_optimizer image"
	@echo "  make FRAMEWORK=verl                Build just the image for a framework"
	@echo "  make clean                         Remove all koco-eval images"
	@echo ""
	@echo "Framework -> Image mapping:"
	@echo "  verl, open-r1               -> koco-eval-verl"
	@echo "  raganything, smolagents      -> koco-eval-rag"
	@echo "  tensorrt_model_optimizer     -> koco-eval-trt"
