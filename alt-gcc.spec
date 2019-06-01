Summary: GCC Compiler
Name: alt-gccMAJOR
Release: RELEASE
Version: VERSION
%define fullname %{name}-%{version}-%{release}.x86_64
%define debug_package %{nil}
License: GPL v2 or later
Group: Development/Libraries/C and C++

# The name of the source tar ball.
Source: %{fullname}.tar.gz

URL: http://gcc.gnu.org
Vendor: Chris Love
Packager: Chris Love

Prereq: /sbin/ldconfig

# Allows you to specify a directory as the root for building and installing the
# new package (from http://www.rpm.org/RPM-HOWTO/build.html).
BuildRoot: %{_tmppath}/%{fullname}

# Boolean that specifies if you want to automatically determine some dependencies.
AutoReqProv: no

%description
The supplemental GCC %{version} compileThe supplemental GCC %{version} compiler.

Authors:
--------
    The GCC team.

%prep

# An RPM macro that untars the source archive (defined in the source tag) and
# puts it in the build root for use by later sections.
%setup -n %{fullname}

%build

%install

# Define my destination dir for packaging (not installing).
DESTDIR=$RPM_BUILD_ROOT

%{__rm} -rf $DESTDIR
mkdir -p $DESTDIR
cp -a * $DESTDIR

%clean

%{__rm} -rf $RPM_BUILD_ROOT

%post

/sbin/ldconfig

%postun

/sbin/ldconfig

%files

%defattr(755,root,root)
%dir /opt/gccCOMPACT/
/opt/gccCOMPACT/*

