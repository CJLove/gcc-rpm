# gcc-rpm

This script will take a gcc source tarball (e.g. gcc-6.5.0.tar.gz),
download associated dependencies, build gcc from source, and build an
`alt-gccX` rpm for it.  The rpm will install gcc into /opt/gccxyz.

The motivation for this is to be able to have alternate gcc/g++ versions 
available in parallel with the "system" compiler, and to facilitate easy installation into Docker images

Disclaimers: 
- These rpms are *not* for production use
- I have run into issues trying to build gcc 5.x or 4.9 on Fedora 29 (which uses gcc 8.3.1), so there may need to be support for using a _moderately_ older toolchain in these cases.  Unclear whether the resulting toolchain would be self-contained or depend on libraries from the version used to built it.

## Usage
```bash
$ ./build.sh -source=gcc-w.x.y.tar.gz [-buildonly][-rpmonly][-release=X]
$ sudo rpm -ivh alt-gccw-*.rpm
```