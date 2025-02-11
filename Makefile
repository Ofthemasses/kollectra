REPO_URL := $(shell yq '.repositories.VexRiscv.url' config.yaml)
COMMIT_HASH := $(shell yq '.repositories.VexRiscv.commit' config.yaml)
SCALA_LIB_DIR := vexcores/lib
VEX_DIR := $(SCALA_LIB_DIR)/VexRiscv

.PHONY: init clean

init: build_kollectra_core

build_kollectra_core:
	cd vexcores; \
	sbt "runMain kollectra.cores.GenKollectraCore";

clean:
	@echo "Removing $(SCALA_LIB_DIR)..."
	rm -r $(SCALA_LIB_DIR)
	@echo "$(SCALA_LIB_DIR) has been removed."
