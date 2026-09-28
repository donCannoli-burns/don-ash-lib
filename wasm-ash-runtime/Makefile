.PHONY: check static-check fixture-check

check: static-check fixture-check

static-check:
	python3 tools/static_check.py

fixture-check:
	node tools/check_fixtures.mjs
