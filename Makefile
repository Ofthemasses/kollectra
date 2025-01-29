REPO_URL := $(shell yq '.repositories.VexRiscv.url' config.yaml)
COMMIT_HASH := $(shell yq '.repositories.VexRiscv.commit' config.yaml)
LIB_DIR := lib
VEX_DIR := $(LIB_DIR)/bin/VexRiscv

.PHONY: init clean

init: generate_lib_dirs shallow_clone checkout

generate_lib_dirs:
	@echo "Creating lib directory..."
	mkdir -p $(LIB_DIR)/bin
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

clean:
	@echo "Removing $(LIB_DIR)..."
	rm -rf $(LIB_DIR)
	@echo "$(LIB_DIR) has been removed."
