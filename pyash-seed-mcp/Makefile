.PHONY: check test validate dump-tools

check: validate test

validate:
	python3 tools/validate_seed.py
	python3 -m py_compile bridge/pyash_seed_mcp.py tests/test_seed.py tools/validate_seed.py
	python3 tools/validate_pyash_vendor.py

test:
	python3 tests/test_seed.py

dump-tools:
	python3 bridge/pyash_seed_mcp.py --dump-tools
