#!/bin/bash

version="0.1"
# In subversion:
export REVISION="$(svnversion --no-newline)"
# In a release:
#export REVISION="tag or 'exported'?"

# Don't use the -debug flag.  That would make the comparison between
# ParaFEM and PETSc unfair.

if [[ $# == 1 && $1 == 'xx' ]]; then
    export build=xx log=xx.log
elif [[ $# == 1 && $1 == 'modules' ]]; then
    export build=modules log=modules.log
elif [[ $# == 1 && $1 == 'clean' ]]; then
    export build=clean log=clean.log
elif [[ $# == 1 && $1 == 'xxclean' ]]; then
    export build=xxclean log=xxclean.log
else
    echo 'Usage:
build.bash clean to clean everything
build.bash modules to re-build the ParaFEM modules and p12meshgen
build.bash xx to build xx15 and xx18 only
build.bash xxclean to clean xx15 and xx18 only'
    exit 2 # incorrect usage
fi

mkdir -p $HOME/modulefiles/parafem
export modulefile=$HOME/modulefiles/parafem/$version

# When the default modules are up to date, then only this line is
# needed.
#module load cray-petsc-64
module unload modules
module load modules/3.2.10.5
source $MODULESHOME/init/bash
module load cdt/16.09 &> /dev/null
module unload cray-petsc-64
module unload cray-tpsl-64
module load cray-tpsl-64/16.07.1
module load cray-petsc-64/3.7.2.1

## CrayPat
#module unload perftools
#module unload perftools-base
#module load perftools-base/6.4.2
#module load perftools/6.4.2

module list -t 2>&1 | head -n 1 > $log
module list -t 2>&1 | tail -n +2 | LC_ALL=POSIX sort >> $log
echo >> $log

# There is clock skew between TDS and /home so sleeps are needed.

(
    export PARAFEM_HOME=$(readlink --canonicalize $PWD)
    if [[ $build == 'xx' ]]; then
	sleep 1 # TDS and /home are sleepy
	./make-parafem MACHINE=xc30 --no-libs --no-tools -mpi -parafem_petsc --install-mpi-parafem_petsc-only -xx >> $log 2>&1
	sleep 1 # TDS and /home are sleepy
	cat > $modulefile <<EOF
#%Module
#
# Module parafem
#

set PARAFEM_DIR $PARAFEM_HOME
setenv PARAFEM_DIR \$PARAFEM_DIR

proc ModulesHelp { } {
    puts stderr "xx15 and xx18: ParaFEM with PETSc"
    puts stderr {=================================

Maintained by: Mark Filipiak, EPCC
}
}
prepend-path PATH \$PARAFEM_DIR/bin

module-whatis "xx15 and xx18: ParaFEM with PETSc"

EOF
	sleep 1 # TDS and /home are sleepy
    elif [[ $build == 'modules' ]]; then
	sleep 1 # TDS and /home are sleepy
	./make-parafem MACHINE=xc30 --no-libs --no-tools -mpi -parafem_petsc --install-mpi-parafem_petsc-only --only-modules >> $log 2>&1
	sleep 1 # TDS and /home are sleepy
	./make-parafem MACHINE=xc30 --no-libs -mpi -parafem_petsc --install-mpi-parafem_petsc-only --only-tools -preproc >> $log 2>&1
	sleep 1 # TDS and /home are sleepy
    elif [[ $build == 'clean' ]]; then
	sleep 1 # TDS and /home are sleepy
	./make-parafem MACHINE=xc30 clean execlean >> $log 2>&1
	rm -f $modulefile
	sleep 1 # TDS and /home are sleepy
    elif [[ $build == 'xxclean' ]]; then
	sleep 1 # TDS and /home are sleepy
	./make-parafem MACHINE=xc30 --only-programs -xx clean execlean >> $log 2>&1
	rm -f $modulefile
	sleep 1 # TDS and /home are sleepy
    fi
)
