REPO_URL := $(shell yq '.repositories.VexRiscv.url' config.yaml)
COMMIT_HASH := $(shell yq '.repositories.VexRiscv.commit' config.yaml)
SCALA_LIB_DIR := vexcores/lib
VEX_DIR := $(SCALA_LIB_DIR)/VexRiscv

.PHONY: init build_kollectra_core clean build-docker run-docker

init: build_kollectra_core

dev: build-docker run-docker

build_kollectra_core:
	cd vexcores; \
	sbt "runMain kollectra.cores.GenKollectraCore";

clean:
	@echo "Removing $(SCALA_LIB_DIR)..."
	rm -r $(SCALA_LIB_DIR)
	@echo "$(SCALA_LIB_DIR) has been removed."

build-docker:
	docker build -t kollectra-dev .

run-docker:
	docker run -it --rm -v $(PWD):/project kollectra-dev
