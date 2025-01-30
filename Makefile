REPO_URL := $(shell yq '.repositories.VexRiscv.url' config.yaml)
COMMIT_HASH := $(shell yq '.repositories.VexRiscv.commit' config.yaml)
SCALA_LIB_DIR := vexcores/lib
VEX_DIR := $(SCALA_LIB_DIR)/VexRiscv

.PHONY: init clean

init: generate_scala_lib_dirs shallow_clone checkout build_kollectra_core

generate_scala_lib_dirs:
	@echo "Creating lib directory..."
	mkdir -p $(SCALA_LIB_DIR)
	@echo "lib directory has been created."

shallow_clone:
	@if [ ! -d "$(VEX_DIR)" ]; then \
	  echo "Cloning repository from $(VEX_DIR) at specified commit into $(VEX_DIR)..."; \
	  git init $(VEX_DIR); \
	  cd $(VEX_DIR) && git remote add origin $(REPO_URL); \
	  git fetch --depth 1 origin $(COMMIT_HASH); \
	else \
	  echo "Repository already cloned at $(VEX_DIR)."; \
	fi

checkout:
	@echo "Checking out commit $(COMMIT_HASH) in $(VEX_DIR)..."
	cd $(VEX_DIR) && git checkout FETCH_HEAD
	@echo "Repository $(VEX_DIR) is now at commit $(COMMIT_HASH)."

build_kollectra_core:
	cd vexcores; \
	sbt "runMain kollectra.cores.GenKollectraCore";

clean:
	@echo "Removing $(SCALA_LIB_DIR)..."
	rm -r $(SCALA_LIB_DIR)
	@echo "$(SCALA_LIB_DIR) has been removed."
