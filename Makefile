#init build creates a new build directory and initialises it with a new renv environment to use.
SHELL := /bin/bash
all: test build

#high level target, most abstract functions, this is the external interface to our build scripts
build: build/build.log
test: build/test-results.out
clean:
	rm -rf build

build/renv:
	mkdir -p build
	cd build && Rscript -e "renv::init(bare = TRUE, force = TRUE)"
	cd build && Rscript -e "renv::activate()"
	cd build && Rscript -e "install.packages('devtools')"

build/renv.lock: DESCRIPTION build/renv
	cd build && Rscript -e "devtools::install_deps('../', dependencies = TRUE)"
	cd build && Rscript -e "renv::snapshot(project = '../', lockfile = 'renv.lock')"

#Build target creates a new built package from sources
build/build.log: build/renv.lock $(shell find R -type f) $(shell find tests -type f)
	cd build && Rscript -e "devtools::build('../', path = '.')" > build.log

build/test-results.out: build
	cd build && Rscript -e "testthat::test_local(pkg = '../$(shell find build/*.tar.gz -type f)')" > test-results.out
