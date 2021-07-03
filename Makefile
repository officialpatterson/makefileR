#init build creates a new build directory and initialises it with a new renv environment to use.
initBuild:
	mkdir -p build
	cd build && Rscript -e "renv::init(bare = FALSE)"

#Install dependencies installs all the package dependencies into the renv environment

#Build target creates a new built package from sources
build: R/hello.R initBuild
	Rscript -e "devtools::build('.', path = 'build/package.tar.gz')"
#
