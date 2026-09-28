.PHONY: all test clean

all:
	cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
	cmake --build build -j

test:
	./scripts/run_tests.sh

clean:
	rm -rf build
