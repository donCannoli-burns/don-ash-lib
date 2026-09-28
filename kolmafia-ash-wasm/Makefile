CLANG ?= clang
WASM_LD ?= wasm-ld
CFLAGS := --target=wasm32 -O2 -nostdlib -fno-builtin -Wall -Wextra -Werror
LDFLAGS := -Wl,--no-entry -Wl,--export-memory -Wl,--initial-memory=1048576 -Wl,--max-memory=16777216 \
	-Wl,--export=ash_version_major -Wl,--export=ash_version_minor -Wl,--export=ash_version_patch \
	-Wl,--export=ash_reset_arena -Wl,--export=ash_alloc -Wl,--export=ash_out_ptr -Wl,--export=ash_out_len \
	-Wl,--export=ash_error_ptr -Wl,--export=ash_error_len -Wl,--export=ash_policy_clear -Wl,--export=ash_policy_set \
	-Wl,--export=ash_policy_allowed -Wl,--export=ash_build_enum_string -Wl,--export=ash_build_enum_number \
	-Wl,--export=ash_build_function -Wl,--export=ash_build_batch

.PHONY: all test clean
all: dist/kolmafia_ash.wasm

dist/kolmafia_ash.wasm: src/ash_wasm.c
	mkdir -p dist
	$(CLANG) $(CFLAGS) $(LDFLAGS) -o $@ $<

test: all
	npm test

clean:
	rm -f dist/kolmafia_ash.wasm dist/generated-ash.js
