all: build test

#We define some targets at the most abstract level, these are the targets which will be available to the user/CI system.
build: build/renv build/renv.lock build/build.log
test: build/test-results.out
clean:
	rm -rf build

#Nice isolated environment that we can build in.
build/renv:
	mkdir -p build
	cd build && Rscript -e "renv::init(bare = TRUE, force = TRUE)"
	cd build && Rscript -e "renv::activate()"
	cd build && Rscript -e "install.packages('devtools')"

build/renv.lock: DESCRIPTION build/renv
	cd build && Rscript -e "devtools::install_deps('../', dependencies = TRUE)"
	cd build && Rscript -e "renv::snapshot(project = '../', lockfile = 'renv.lock')"

#Build the R package into a source package if there is any changes to R package files (we ignore all other files)
build/build.log: build/renv.lock $(shell find . -path ./.Rproj.user -prune -o -path ./.git -prune -o -path ./build -prune -o -path ./Makefile -prune -o -path ./.Rhistory -prune -o -path ./.gitignore -prune -o -print)
	cd build && Rscript -e "devtools::build('../', path = '.')" > build.log

#When the built package has changed on disk, we should re-run it's tests.
build/test-results.out: build
	cd build && Rscript -e "testthat::test_local(pkg = '../$(shell find build/*.tar.gz -type f)')" > test-results.out
