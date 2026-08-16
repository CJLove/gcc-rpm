# gcc-rpm

This script will take a gcc source tarball (e.g. gcc-15.3.0.tar.gz),
download associated dependencies, build gcc from source, and build an
`alt-gccX` rpm for it.  The rpm will install gcc into /opt/gccxyz.

The motivation for this is to be able to have alternate gcc/g++ versions 
available in parallel with the "system" compiler, and to facilitate easy installation into Docker images

Disclaimers: 
- These rpms are *not* for production use
- `-nosan` argument added as I have observed that sanitizer support for older gcc versions can fail to build on newer Linux distributions and/or kernel versions.

## Usage
```bash
$ ./build.sh -?
Usage:
    build.sh options
		[-source=<sourceTarball>]
		[-buildonly] - build and install source only
		[-release=X] - release # for rpm (default=0)
		[-comfigOpts=X] - additional options for configure
		[-rpmonly] - build rpms only
		[-nosan] - disable sanitizer build

$ sudo rpm -ivh alt-gccw-*.rpm
```