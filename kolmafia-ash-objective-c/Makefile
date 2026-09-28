CLANG ?= clang
CFLAGS ?= -fobjc-arc -Wall -Wextra -Wpedantic -Iinclude
FRAMEWORKS = -framework Foundation
BUILD = build

.PHONY: all clean test source-check

all: $(BUILD)/kmash-smoke

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/kmash-smoke: src/KMAsh.m examples/smoke.m include/KMAsh.h | $(BUILD)
	$(CLANG) $(CFLAGS) src/KMAsh.m examples/smoke.m $(FRAMEWORKS) -o $@

source-check:
	python3 tests/source_checks.py

test: source-check all
	@echo "Build passed. Live smoke test requires KoLmafia + KOLMAFIA_PWD:"
	@echo "  KOLMAFIA_PWD='<pwd hash>' ./$(BUILD)/kmash-smoke"

clean:
	rm -rf $(BUILD)
