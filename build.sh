#!/bin/bash

PARAM_SOURCE=gcc-4.8.5.tar.gz
PARAM_BUILD=true
PARAM_RPM=true
PARAM_RELEASE=0


function ShowUsage()
{
cat << EOT
Usage:
    $(basename $0) options
		[-source=<sourceTarball>]
		[-buildonly] - build and install source only
		[-release=X] - release # for rpm (default=0)
		[-rpmonly] - build rpms only
EOT
return 0
}

while test $# -gt 0; do
        param="$1"
        if test "${1::1}" = "-"; then
                if test ${#1} -gt 2 -a "${1::2}" = "--" ; then
                        param="${1:2}"
                else
                        param="${1:1}"
                fi
        else
                break
        fi

        shift

	case $param in
	source=*)
		PARAM_SOURCE=$(echo $param|cut -f2 -d'=')
		;;
	release=*)
		PARAM_RELEASE=$(echo $param|cut -f2 -d'=')
		;;
	buildonly)
		PARAM_BUILD=true
		PARAM_RPM=false
		;;
	rpmonly)
		PARAM_BUILD=false
		PARAM_RPM=true
		;;
        help|h|?|-?)
                ShowUsage
                exit 0
                ;;
        *)
                echo "Error: Unknown parameter: $param"
                ShowUsage
                exit 2
                ;;
        esac
done

# Validate that source tarball exists
if [ ! -f "$PARAM_SOURCE" ]; then
	echo "Error: source tarball $PARAM_SOURCE doesn't exist"
	exit 1
fi

# Determine version from the tarball filename
pre=${PARAM_SOURCE#gcc-}
version=${pre%.tar.gz}
major=$(echo $version | cut -f1 -d'.')
compactVersion=${version//.}
sourceDir=${PARAM_SOURCE%.tar.gz}
prefix=/opt/gcc${compactVersion}
release=${PARAM_RELEASE}
arch=x86_64

gcc_fullname=alt-gcc$major-$version-$release.$arch
gcc_rpm=$gcc_fullname.rpm
gcc_tarball=$gcc_fullname.tar.gz

echo "Build GCC version $version for installation in ${prefix}"

if [ "$PARAM_BUILD" = "true" ]; then
	echo "Building GCC $version from source"
	rm -rf $sourceDir build
	tar zxf $PARAM_SOURCE
	[ ! -d $sourceDir ] && { echo "Error: $sourceDir doesn't exist"; exit 1; }
	cd $sourceDir
	[ ! -x contrib/download_prerequisites ] && { echo "Eror: ./contrib/download_prerequisites doesn't exist"; exit 1; }
	./contrib/download_prerequisites
	cd ..
	mkdir build
	cd build
	../$sourceDir/configure --prefix=$prefix --disable-multilib --enable-languages=c,c++
	[ $? -ne 0 ] && { echo "Error: configure failed"; exit 1; }
	make -j 12
	[ $? -ne 0 ] && { echo "Error: make failed"; exit 1; }
	sudo make install
	[ $? -ne 0 ] && { echo "Error: make install failed"; exit 1; }

	cd ..

	rm -rf build $sourceDir
fi

if [ "$PARAM_RPM" = "true" ]; then
	echo "Building GCC $version rpms"

	rm -rf install

	mkdir -p install/$gcc_fullname/opt/

	cp -r /opt/gcc${compactVersion} install/$gcc_fullname/opt/

	cd install
	tar czf ../$gcc_tarball $gcc_fullname
	cd ..

	[ ! -f $gcc_tarball ] && { echo "Error: tarball $gcc_fullname.tar not found"; exit 1; }

	rm -f alt-gcc${compactVersion}.spec
	sed "s/VERSION/${version}/g" alt-gcc.spec > alt-gcc${compactVersion}.spec
	sed -i "s/MAJOR/${major}/g" alt-gcc${compactVersion}.spec
	sed -i "s/RELEASE/${release}/g" alt-gcc${compactVersion}.spec
	sed -i "s/COMPACT/${compactVersion}/g" alt-gcc${compactVersion}.spec

	rpmdev-setuptree

	cp $gcc_tarball $HOME/rpmbuild/SOURCES

	QA_RPATHS=$(( 0x0020 )) rpmbuild -bb alt-gcc${compactVersion}.spec
	[ $? -ne 0 ] && { echo "Error: rpmbuild failed"; exit 1; }

	echo "Cleaning up"
	rm -rf install $gcc_tarball alt-gcc${compactVersion}.spec

	sudo rm -rf $prefix

	cp $HOME/rpmbuild/RPMS/$arch/$gcc_rpm .
	echo "Resulting rpm is $gcc_rpm"

fi
