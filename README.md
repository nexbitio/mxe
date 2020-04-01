
Introduction

MXE (M cross environment) is a Makefile that compiles a cross compiler and cross compiles many free libraries such as SDL and Qt. Thus, it provides a nice cross compiling environment for various target platforms, which

    is designed to run on any Unix system
    is easy to adapt and to extend
    builds many free libraries in addition to the cross compiler
    can also build just a subset of the packages, and automatically builds their dependencies
    downloads all needed packages and verifies them by their checksums
    is able to update the version numbers of all packages automatically
    directly uses source packages, thus ensuring the whole build mechanism is transparent
    allows inter-package and intra-package parallel builds whenever possible
    integrates well with autotools, cmake, qmake, and hand-written makefiles.
    has been in continuous development since 2007 and is used by several projects

Supported Toolchains
Runtime 	Host Triplet 	Packages
Static 	Shared*
MinGW-w64 	i686-w64-mingw32 	99% (339/341) 	62% (211/341)
x86_64-w64-mingw32 	91% (311/341) 	61% (209/341)

These numbers were last updated on October 13, 2014. You can see the current status by executing make build-matrix.html in the MXE directory.

* Shared support in MXE was just added in early February, 2014. These numbers are expected to rise significantly.
Screenshots

Cross compiling 4tH:
4th-compile

and running it:
4th-run
Tutorial
Step 1: Requirements and Download

First, you should ensure that your system meets MXE's requirements. You will almost certainly have to install some stuff.

When everything is fine, download the current version:

git clone https://github.com/mxe/mxe.git

If you don't mind installing it in your home directory, just skip the following step and go straight to step 3.

MXE builds and installs everything under the same top-level directory and is not relocatable after the first packages are built.

Due to limitations of GNU Make, the path of MXE is not allowed to contain any whitespace characters.
Step 2: System-wide Installation (optional)

Now you should save any previous installation of the MXE. Assuming you've installed it under /opt/mxe (any other directory will do as well), you should execute the following commands:

su
mv /opt/mxe /opt/mxe.old
exit

Then you need to transfer the entire directory to its definitive location. We will assume again you use /opt/mxe, but feel free to use any other directory if you like.

su
mv mxe /opt/mxe
exit

We're almost done. Just change to your newly created directory and get going:

cd /opt/mxe

Step 3: Build MXE

Enter the directory where you've downloaded MXE. Now it depends on what you actually want – or need.

If you choose to enter:

make

you're in for a long wait, because it compiles a lot of packages. On the other hand it doesn't require any intervention, so you're free to do whatever you like – like watch a movie or go for a night on the town. When it's done you'll find that you've installed a very capable Win32 cross compiler onto your system.

If you only need the most basic tools you can also use:

make gcc

and add any additional packages you need later on. You can also supply a host of packages on the command line, e.g.:

make gtk lua libidn

Targets can also be specified on the command line. By default, only i686-w64-mingw32.static is built, but you can build your toolchain(s) of choice with:

make MXE_TARGETS='x86_64-w64-mingw32.static i686-w64-mingw32.static'

or by adjusting the MXE_TARGETS variable in settings.mk.

You'll always end up with a consistent cross compiling environment.

If you have trouble here, please feel free to contact the mxe team through the issue tracker or mailing list.

After you're done it just needs a little post-installation.
Step 4: Environment Variables

Edit your .bashrc script in order to change $PATH:

export PATH=/where MXE is installed/usr/bin:$PATH

You may be tempted to also add $(TARGET)/bin to your path. You never want to do this, the executables and scripts in there will cause conflicts with your native toolchain.

In case you are using custom $PKG_CONFIG_PATH entries, you can add separate entries for cross builds:

export PKG_CONFIG_PATH="entries for native builds"

export PKG_CONFIG_PATH_i686_w64_mingw32_static="entries for MXE builds"

Remember to use i686-w64-mingw32.static-pkg-config instead of pkg-config for cross builds. The Autotools do that automatically for you.

Note that any other compiler related environment variables (like $CC, $LDFLAGS, etc.) may spoil your compiling pleasure, so be sure to delete or disable those.

For the most isolated and repeatable environment, use a white-list approach:

unset `env | \
    grep -vi '^EDITOR=\|^HOME=\|^LANG=\|MXE\|^PATH=' | \
    grep -vi 'PKG_CONFIG\|PROXY\|^PS1=\|^TERM=' | \
    cut -d '=' -f1 | tr '\n' ' '`

Congratulations! You're ready to cross compile anything you like.
Step 5a: Cross compile your Project (Autotools)

If you use the Autotools, all you have to do is:

./configure --host=i686-w64-mingw32.static
make

If you build a library, you might also want to enforce a static build:

./configure --host=i686-w64-mingw32.static --enable-static --disable-shared
make

Don't worry about a warning like this:

configure: WARNING: If you wanted to set the --build type, don't use --host.
If a cross compiler is detected then cross compile mode will be used.

Everything will be just fine.
Step 5b: Cross compile your Project (CMake)

If you have a CMake project, you can use the provided toolchain file:

cmake ... -DCMAKE_TOOLCHAIN_FILE=/where MXE is installed/usr/i686-w64-mingw32.static/share/cmake/mxe-conf.cmake

Step 5c: Cross compile your Project (Qt)

If you have a Qt application, all you have to do is:

/where MXE is installed/usr/i686-w64-mingw32.static/qt/bin/qmake
make

Note that Qt 4 is in the "qt" subdirectory. Qt 5 is in the "qt5" subdirectory and its qmake can be invoked similarly.

If you are using Qt plugins such as the svg or ico image handlers, you should also have a look at the Qt documentation about static plugins.

Note the sql drivers (-qt-sql-*) and the image handlers for jpeg, tiff, gif and mng are built-in, not plugins.
Step 5d: Cross compile your Project (Makefile)

If you have a handwritten Makefile, you probably will have to make a few adjustments to it:

CC=$(CROSS)gcc
LD=$(CROSS)ld
AR=$(CROSS)ar
PKG_CONFIG=$(CROSS)pkg-config

You may have to add a few others, depending on your project.

Then, all you have to do is:

make CROSS=i686-w64-mingw32.static-

That's it!
Step 5e: Cross compile your Project (OSG)

Using static OpenSceneGraph libraries requires a few changes to your source. The graphics subsystem and all plugins required by your application must be referenced explicitly. Use a code block like the following:

#ifdef OSG_LIBRARY_STATIC
USE_GRAPHICSWINDOW()
USE_OSGPLUGIN(<plugin1>)
USE_OSGPLUGIN(<plugin2>)
...
#endif

Look at examples/osgstaticviewer/osgstaticviewer.cpp in the OpenSceneGraph source distribution for an example. This example can be compiled with the following command:

i686-w64-mingw32.static-g++ \
    -o osgstaticviewer.exe examples/osgstaticviewer/osgstaticviewer.cpp \
    `i686-w64-mingw32.static-pkg-config --cflags openscenegraph-osgViewer openscenegraph-osgPlugins` \
    `i686-w64-mingw32.static-pkg-config --libs openscenegraph-osgViewer openscenegraph-osgPlugins`

The i686-w64-mingw32.static-pkg-config command from MXE will automatically add -DOSG_LIBRARY_STATIC to your compiler flags.
Further Steps

If you need further assistance, feel free to join the mailing list where you'll get in touch with the MXE developers and other users.
Download

To obtain the current version, run:

git clone https://github.com/mxe/mxe.git

To retrieve updates, run:

git pull

You can also browse the web repository.

In addition, feel free to join the mailing list and to propose new packages.
Requirements

MXE requires a recent Unix system where all components as stated in the table below are installed. It also needs roughly 2 GiB of RAM to link gcc and at least 700 MB of disk space per target (counted with only gcc built).

Detailed instructions are available for:

    Debian
    Fedora
    FreeBSD
    Frugalware
    Gentoo
    Mac OS X
    openSUSE

Autoconf 	≥ 2.67
Automake 	≥ 1.11.3
Bash 	
Bison 	
Bzip2 	
CMake 	≥ 2.8.0
Flex 	≥ 2.5.31
GCC (gcc, g++) 	
Git 	≥ 1.7
GNU Coreutils 	
GNU Gettext 	
GNU gperf 	
GNU Make 	≥ 3.81
GNU Sed 	
Intltool 	≥ 0.40
LibC for 32-bit 	
libffi 	≥ 3.0.0
Libtool 	≥ 2.2
OpenSSL-dev 	
p7zip (7-Zip) 	
Patch 	
Perl 	
Perl XML::Parser 	
Pkg-config 	≥ 0.16
Python 	
Ruby 	
SCons 	≥ 0.98
UnZip 	
Wget 	
XZ Utils 	
Debian and derivatives

apt-get install \
    autoconf automake autopoint bash bison bzip2 cmake flex \
    gettext git g++ gperf intltool libffi-dev libtool \
    libltdl-dev libssl-dev libxml-parser-perl make openssl \
    p7zip-full patch perl pkg-config python ruby scons sed \
    unzip wget xz-utils

On 64-bit Debian, install also:

apt-get install g++-multilib libc6-dev-i386

On Debian Jessie (8) or Ubuntu Utopic (14.10) or later, install also:

apt-get install libtool-bin

Only the latest Debian stable series is supported.
Fedora

yum install \
    autoconf automake bash bison bzip2 cmake flex gcc-c++ \
    gettext git gperf intltool make sed libffi-devel \
    libtool openssl-devel p7zip patch perl pkgconfig \
    python ruby scons unzip wget xz

On 64-bit Fedora, there are issues without a 32-bit compiler.
FreeBSD

pkg_add -r \
    automake autoconf bash bison cmake coreutils flex \
    gettext git glib20 gmake gperf gsed intltool libffi \
    libtool openssl p5-XML-Parser p7zip patch perl \
    pkgconf python ruby scons unzip wget

Ensure that /usr/local/bin precedes /usr/bin in your $PATH:

For C style shells, edit .cshrc

setenv PATH /usr/local/bin:$PATH

For Bourne shells, edit .profile

export PATH = /usr/local/bin:$PATH

On 64-bit FreeBSD, there are issues without a 32-bit compiler.

N.B. FreeBSD is no longer fully supported

to build the remainder of MXE, run:

gmake EXCLUDE_PKGS='gtksourceviewmm2 ocaml% openexr pcl qtbase'

to see a list of all dependent downstream packages that will be excluded, run:

gmake show-downstream-deps-'gtksourceviewmm2 ocaml% openexr \
                            pcl qtbase'

Frugalware

pacman-g2 -S \
    autoconf automake bash bzip2 bison cmake flex gcc \
    gettext git gperf intltool make sed libffi libtool \
    openssl patch perl perl-xml-parser pkgconfig python \
    ruby scons unzip wget xz xz-lzma

On 64-bit Frugalware, there are issues without a 32-bit compiler.
Gentoo

emerge \
    sys-devel/autoconf sys-devel/automake app-shells/bash \
    sys-devel/bison app-arch/bzip2 dev-util/cmake \
    sys-devel/flex sys-devel/gcc sys-devel/gettext \
    dev-vcs/git dev-util/gperf dev-util/intltool \
    sys-devel/make sys-apps/sed dev-libs/libffi \
    sys-devel/libtool dev-libs/openssl app-arch/p7zip \
    sys-devel/patch dev-lang/perl dev-perl/XML-Parser \
    dev-util/pkgconfig dev-lang/python dev-lang/ruby \
    dev-util/scons app-arch/unzip net-misc/wget \
    app-arch/xz-utils

Mac OS X

Install Xcode 5
Step 1
Method 1 - MacPorts

Install MacPorts, then run:

sudo port install \
    glib2 intltool p5-xml-parser p7zip gpatch scons wget xz

Method 2 - Rudix

Install Rudix you can make it with following command

curl -s https://raw.githubusercontent.com/rudix-mac/rpm/2014.6/rudix.py \
    | sudo python - install rudix

then run:

sudo rudix install glib pkg-config scons wget xz

Step 2

After installing pre-requirement run from within the mxe directory:

make build-requirements

You may be prompted to install a java runtime - this is not required.

Mac OS X versions ≤ 10.7 are no longer supported.
openSUSE

zypper install -R \
    autoconf automake bash bison bzip2 cmake flex gcc-c++ \
    gettext-tools git gperf intltool libffi-devel libtool \
    make openssl libopenssl-devel p7zip patch perl \
    perl-XML-Parser pkg-config python ruby scons sed unzip \
    wget xz

On 64-bit openSUSE, install also:

zypper install -R \
    gcc-32bit glibc-devel-32bit libgcc46-32bit \
    libgomp46-32bit libstdc++46-devel-32bit

Issues without a 32-bit compiler

Certain packages contain native tools that are currently 32-bit only. In order to build these on a 64-bit system, multi-lib support must be enabled in the compiler toolchain. However, not all operating systems support this.

To build the remainder of MXE, specify the affected packages to exclude:

make EXCLUDE_PKGS='ocaml%'

Usage

All build commands also download the packages if necessary.

In a BSD userland, substitute "make" with "gmake" as all commands are based on GNU Make.

make
    build all packages, non-parallel 
make gcc
    build a minimal useful set of packages, i.e. the cross compilers and the most basic packages, non-parallel 
make foo bar
    build packages "foo", "bar" and their dependencies, non-parallel 
    the package list can also be set in settings.mk

    LOCAL_PKG_LIST := foo bar
    .DEFAULT local-pkg-list:
    local-pkg-list: $(LOCAL_PKG_LIST)

    so a call to make will only build those packages (and their dependencies, of course) 
make foo bar --touch
    mark packages "foo" and "bar" as up-to-date after a trivial change in one of their dependencies (short option "-t") 
make foo bar --jobs=4 JOBS=2
    build packages "foo", "bar" and their dependencies, where up to 4 packages are built in parallel (short option "-j 4"), each with up to 2 compiler processes running in parallel 
    the JOBS variable can also be defined in settings.mk and defaults to the number of CPUs up to a max of 6 to prevent runaway system load with diminishing returns - see the GNU Make manual for more details on parallel execution 
make --jobs=4 --keep-going
    build all packages with 4 inter-package parallel jobs and continue as much as possible after an error (short option "-j 4 -k") 
make EXCLUDE_PKGS='foo bar'
    build all packages excluding foo, bar, and all downstream packages that depend on them - mostly used when there are known issues 
make check-requirements
    check most of the requirements if necessary – executed automatically before building packages 
make download
    download all packages, non-parallel, such that subsequent builds work without internet access 
make download-foo download-bar
    download packages "foo", "bar" and their dependencies, non-parallel 
make download-foo download-bar -j 4
    download packages "foo", "bar" and their dependencies, where up to 4 packages are downloaded in parallel 
make download-only-foo download-only-bar
    download packages "foo", "bar", without their dependencies, non-parallel 
make clean
    remove all package builds – use with caution! 
make clean-junk
    remove all unused files, including unused package files, temporary folders, and logs 
make clean-pkg
    remove all unused package files, handy after a successful update 
make show-deps-foo
    print a list of upstream dependencies and downstream dependents 
make show-downstream-deps-foo
    print a list of downstream dependents suitable for usage in shell scripts 
make show-upstream-deps-foo
    print a list of upstream dependencies suitable for usage in shell scripts 
make build-matrix.html
    generate a report of what packages are supported on what targets to build-matrix.html 
make update
    for internal use only! – update the version numbers of all packages, download the new versions and note their checksums 
make update UPDATE_DRYRUN=true
    for internal use only! – show list of update candidates without downloading 
make update-package-foo
    for internal use only! – update the version numbers of package foo, download the new version and note its checksum 
make update-checksum-foo
    for internal use only! – download package foo and update its checksum 
make cleanup-style
    for internal use only! – cleanup coding style 

List of Packages

See something missing? Feel free to create a new package.
a52dec 	a52dec (aka. liba52)
agg 	Anti-Grain Geometry
alure 	alure
apr 	APR
apr-util 	APR-util
armadillo 	Armadillo C++ linear algebra library
aspell 	Aspell
assimp 	Assimp Open Asset Import Library
atk 	ATK
atkmm 	ATKmm
aubio 	aubio
autoconf 	autoconf
automake 	automake
bfd 	Binary File Descriptor library
binutils 	GNU Binutils
bison 	bison
blas 	blas
boost 	Boost C++ Library
box2d 	Box2D
bullet 	Bullet physics, version 2
bzip2 	bzip2
cairo 	cairo
cairomm 	cairomm
cblas 	cblas
ccfits 	CCfits
cegui 	Crazy Eddie’s GUI System (CEGUI)
cfitsio 	cfitsio
cgal 	cgal
check 	check
chipmunk 	Chipmunk Physics
chromaprint 	Chromaprint
cmake 	cmake
cminpack 	cminpack
coreutils 	GNU Core Utilities
cppunit 	CppUnit
crystalhd 	Broadcom Crystal HD Headers
cunit 	cunit
curl 	cURL
dbus 	dbus
dcmtk 	DCMTK
devil 	DevIL
dlfcn-win32 	POSIX dlfcn wrapper for Windows
eigen 	eigen
exiv2 	Exiv2
expat 	Expat XML Parser
faad2 	faad2
fdk-aac 	FDK-AAC
ffmpeg 	ffmpeg
fftw 	fftw
file 	file
flac 	FLAC
flann 	FLANN
flex 	flex
fltk 	FLTK
fontconfig 	fontconfig
freeglut 	freeglut
freeimage 	FreeImage
freetds 	FreeTDS
freetype 	freetype
freetype-bootstrap 	freetype (without harfbuzz)
fribidi 	FriBidi
ftgl 	ftgl
gc 	gc
gcc 	GCC
gcc-gmp 	GMP for GCC
gcc-isl 	ISL for GCC
gcc-mpc 	MPC for GCC
gcc-mpfr 	MPFR for GCC
gd 	GD (without support for xpm)
gdal 	GDAL
gdb 	gdb
gdk-pixbuf 	GDK-pixbuf
gendef 	gendef
geos 	GEOS
gettext 	gettext
giflib 	giflib
glew 	GLEW
glfw2 	GLFW 2.x
glfw3 	GLFW 3.x
glib 	GLib
glibmm 	GLibmm
gmp 	GMP
gnutls 	GnuTLS
gperf 	GNU gperf
graphicsmagick 	GraphicsMagick
gsl 	GSL
gsoap 	gSOAP
gst-plugins-base 	gst-plugins-base
gst-plugins-good 	gst-plugins-good
gstreamer 	gstreamer
gta 	gta
gtk2 	GTK+
gtkglarea 	GtkGLArea
gtkglext 	GtkGLExt
gtkglextmm 	GtkGLExtmm
gtkimageview 	GtkImageView
gtkmm2 	GTKMM
gtksourceview 	GTKSourceView
gtksourceviewmm2 	GtkSourceViewmm
guile 	GNU Guile
harfbuzz 	HarfBuzz
hdf4 	HDF4
hdf5 	HDF5
hunspell 	Hunspell
icu4c 	ICU4C
id3lib 	id3lib
ilmbase 	IlmBase
imagemagick 	ImageMagick
intltool 	Intltool
isl 	Integer Set Library
itk 	Insight Segmentation and Registration Toolkit (ITK)
jack 	JACK Audio Connection Kit
jansson 	Jansson
jasper 	JasPer
jpeg 	jpeg
json-c 	json-c
json_spirit 	json_spirit
jsoncpp 	jsoncpp
lame 	lame
lapack 	lapack
lcms 	lcms
lcms1 	lcms1
lensfun 	lensfun
levmar 	levmar
libaacs 	libaacs
libarchive 	Libarchive
libass 	libass
libbluray 	libbluray
libbs2b 	Bauer Stereophonic-to-Binaural library
libcaca 	libcaca
libcdio 	Libcdio
libcdio-paranoia 	Libcdio-paranoia
libcomm14cux 	libcomm14cux
libcroco 	Libcroco
libdca 	libdca (formerly libdts)
libdnet 	libdnet
libdvbpsi 	libdvbpsi
libdvdcss 	libdvdcss
libdvdnav 	libdvdnav
libdvdread 	libdvdread
libepoxy 	libepoxy
libevent 	libevent
libf2c 	libf2c
libffi 	libffi
libftdi 	LibFTDI
libftdi1 	LibFTDI1
libgcrypt 	libgcrypt
libgda 	libgda
libgdamm 	libgdamm
libgee 	libgee
libgeotiff 	GeoTiff
libglade 	glade
libgnurx 	libgnurx
libgomp 	GCC-libgomp
libgpg_error 	libgpg-error
libgsasl 	Libgsasl
libgsf 	libgsf
libharu 	libharu
libiberty 	libiberty
libical 	libical
libiconv 	libiconv
libidn 	Libidn
libircclient 	libircclient
libjpeg-turbo 	libjpeg-turbo
liblaxjson 	liblaxjson
liblo 	liblo
liblqr-1 	liblqr-1
libltdl 	GNU Libtool Library (libltdl)
libmad 	libmad
libmicrohttpd 	GNU Libmicrohttpd
libmikmod 	libMikMod
libmng 	libmng
libmodplug 	libmodplug
libmpcdec 	libmpcdec
libntlm 	Libntlm
liboauth 	liboauth
libodbc++ 	libodbc++
liboil 	liboil
libpano13 	libpano13
libpaper 	libpaper
libplist 	libplist
libpng 	libpng
librsvg 	librsvg
librtmp 	librtmp
libsamplerate 	libsamplerate
libshout 	libshout
libsigc++ 	libsigc++
libsndfile 	libsndfile
libssh2 	libssh2
libsvm 	libsvm
libtool 	GNU Libtool
libunistring 	libunistring
libusb 	LibUsb
libusb1 	LibUsb-1.0
libvpx 	vpx
libwebp 	libwebp
libwebsockets 	libwebsockets
libxml++ 	libxml2
libxml2 	libxml2
libxslt 	libxslt
libzip 	libzip
llvm 	llvm
log4cxx 	log4cxx
lua 	Lua
luabind 	Luabind
luajit 	LuaJIT
lzo 	lzo
m4 	GNU M4
make 	GNU Make
matio 	matio
mdbtools 	mdbtools
minizip 	minizip
mingw-w64 	MinGW-w64 Runtime
mman-win32 	MMA-Win32
mpc 	GNU MPC
mpfr 	mpfr
mpg123 	mpg123
muparser 	muParser
mxml 	Mini-XML
ncurses 	Ncurses
netcdf 	NetCDF
netpbm 	Netpbm
nettle 	nettle
nlopt 	NLopt
nsis 	NSIS
ocaml-cairo 	cairo-ocaml
ocaml-camlimages 	camlimages
ocaml-core 	ocaml
ocaml-findlib 	findlib
ocaml-flexdll 	flexdll
ocaml-lablgl 	lablgl
ocaml-lablgtk2 	lablgtk2
ocaml-native 	ocaml
ocaml-xml-light 	xml-light
oce 	Open CASCADE Community Edition
ogg 	OGG
old 	old
openal 	openal
openblas 	OpenBLAS
opencore-amr 	opencore-amr
opencsg 	opencsg
opencv 	OpenCV
openexr 	OpenEXR
openjpeg 	OpenJPEG
openmp-validation 	OpenMP Validation Suite
openscenegraph 	OpenSceneGraph
openssl 	openssl
opus 	opus
opusfile 	opusfile
pango 	Pango
pangomm 	Pangomm
pcl 	PCL (Point Cloud Library)
pcre 	PCRE
pdcurses 	PDcurses
pdflib_lite 	PDFlib Lite
pfstools 	pfstools
physfs 	physfs
picomodel 	picomodel
pire 	PIRE
pixman 	pixman
pkgconf 	pkgconf
plib 	Plib
plibc 	Plibc
plotmm 	PlotMM
plotutils 	plotutils
poco 	POCO C++ Libraries
polarssl 	Polar SSL Library
poppler 	poppler
popt 	popt
portablexdr 	PortableXDR
portaudio 	portaudio
portmidi 	portmidi
postgresql 	PostgreSQL
primesieve 	Primesieve
proj 	proj
protobuf 	protobuf
pthreads 	POSIX Threads
qdbm 	QDBM
qhttpengine 	qhttpengine
qjson 	QJson
qscintilla2 	QScintilla2
qt 	Qt
qt3d 	Qt
qt5 	Qt
qtactiveqt 	Qt
qtbase 	Qt
qtconnectivity 	Qt
qtdeclarative 	Qt
qtenginio 	Qt
qtgraphicaleffects 	Qt
qtimageformats 	Qt
qtlocation 	Qt
qtmultimedia 	Qt
qtquick1 	Qt
qtquickcontrols 	Qt
qtscript 	Qt
qtsensors 	Qt
qtserialport 	Qt
qtserialport_qt4 	Qt
qtservice 	Qt Solutions
qtsvg 	Qt
qtsystems 	Qt
qttools 	Qt
qttranslations 	Qt
qtwebchannel 	Qt
qtwebengine 	Qt
qtwebkit 	Qt
qtwebsockets 	Qt
qtwinextras 	Qt
qtxlsxwriter 	QtXlsxWriter
qtxmlpatterns 	Qt
qwt 	Qwt
qwt_qt4 	Qwt-qt4
qwtplot3d 	QwtPlot3D
readline 	Readline
rubberband 	Rubberband
rucksack 	rucksack
sdl 	SDL
sdl_gfx 	SDL_gfx
sdl_image 	SDL_image
sdl_mixer 	SDL_mixer
sdl_net 	SDL_net
sdl_pango 	SDL_Pango
sdl_rwhttp 	SDL_rwhttp
sdl_sound 	SDL_sound
sdl_ttf 	SDL_ttf
sdl2 	SDL2
sdl2_gfx 	SDL2_gfx
sdl2_image 	SDL2_image
sdl2_mixer 	SDL2_mixer
sdl2_net 	sdl2_net
sdl2_ttf 	SDL2_ttf
sed 	GNU sed
sfml 	SFML
smpeg 	smpeg
smpeg2 	smpeg
sox 	SoX
speex 	Speex
sqlite 	SQLite
suitesparse 	SuiteSparse
t4k_common 	t4k_common
taglib 	TagLib
tclap 	tclap
teem 	Teem
termcap 	Termcap
theora 	Theora
tiff 	LibTIFF
tinyxml 	tinyxml
tinyxml2 	tinyxml2
tre 	TRE
twolame 	TwoLAME
vamp-plugin-sdk 	Vamp Plugins SDK
vcdimager 	vcdimager
vidstab 	vid.stab video stablizer
vigra 	vigra
vmime 	VMime
vo-aacenc 	VO-AACENC
vo-amrwbenc 	VO-AMRWBENC
vorbis 	Vorbis
vtk 	vtk
vtk6 	VTK6
wavpack 	WavPack
wget 	wget
widl 	Wine IDL Compiler
winpcap 	WinPcap
winpthreads 	MinGW w64 pthreads
wt 	Wt
wxwidgets 	wxWidgets
x264 	x264
xapian-core 	Xapian-Core
xerces 	Xerces-C++
xine-lib 	xine-lib
xmlrpc-c 	xmlrpc-c
xmlwrapp 	xmlwrapp
xorg-macros 	X.org utility macros
xvidcore 	xvidcore
xz 	XZ
yasm 	Yasm
zlib 	zlib
zziplib 	ZZIPlib
Guidelines for Creating Packages

    The package should be a free software library that is really used by one of your applications. Please also review our legal notes.

    BTW, we're always curious about the applications people are porting. We maintain a list of projects which use MXE. No matter whether your project is free or proprietary – as long as it has its own website, we'd be happy to link to it.

    Also, feel free to link to us. :-)

    Grep through the src/*.mk files to find a project that is most similar to yours. (Really, grep is your friend here.)

    For instance, when adding a GNU library, you should take a package like gettext.mk or libiconv.mk as the base of your work. When using a SourceForge project, you could start with a copy of xmlwrapp.mk. And so on.

    The GNU Make Standard Library is also available (though it should be unnecessary for most packages).

    Adjust the comments, fill in the $(PKG)_* fields.

    To fill the $(PKG)_CHECKSUM field, use a command such as (for file gettext.mk):

    make update-checksum-gettext

    or:

    openssl sha1 pkg/gettext-x.y.z.tar.gz

    if you have already downloaded the package

    Be especially careful with the $(PKG)_DEPS section. The easiest way to get the dependencies right is to start with a minimal setup. That is, initialize MXE with make gcc only, then check whether your package builds successfully.

    Always list the dependency on gcc explicitly:

    $(PKG)_DEPS     := gcc ...

    Add your package to the list of packages.

    Each package gets its own table row element with table cells specifying your package name, official name and website:

    <tr>
        <td class="package">gettext</td>
        <td class="website"><a href="https://www.gnu.org/software/gettext/">gettext</a></td>
    </tr>

    Always look for the SSL version of a website, that is, prefer https:// URLs over http:// URLs.

    Write your $(PKG)_BUILD. If your library has a ./configure script, enable/disable all dependency libraries explicitly via "--enable-*" and "--disable-*" options.

    You might also have to provide a patch for it. In that case, have a look at other patches such as sdl2-2-libtool.patch. In particular, each patch file should be named as:

    PACKAGE-PATCHNUMBER-DESCRIPTION.patch

    and should start with:

    This file is part of MXE.
    See index.html for further information.

    This patch has been taken from:
    https://...

    where the URL points to the bugtracker entry, mailing list entry or website you took the patch from.

    If you created the patch yourself, please offer it to the upstream project first, and point to that URL, using the same wording: "This patch has been taken from:".

    Depending on the feedback you get from the upstream project, you might want to improve your patch.

    If you find some time, please provide a minimal test program for it. It should be simple, stand alone and should work unmodified for many (all?) future versions of the library. Test programs are named as:

    PACKAGE-test.c

    or

    PACKAGE-test.cpp

    depending on whether it is a C or C++ library. To get a clue, please have a look at existing test programs such as sdl-test.c.

    At the very end of your *.mk file you should build the test program in a generic way, using strict compiler flags. The last few lines of sdl.mk will give you a clue.

    You could also try to provide a $(PKG)_UPDATE section. However, that requires some experience and "feeling" for it. So it is perfectly okay if you leave a placeholder:

    define $(PKG)_UPDATE
        echo 'TODO: write update script for $(PKG).' >&2;
        echo $($(PKG)_VERSION)
    endef

    We'll fill that in for you. It's a funny exercise.

    Check that you don't have "dirty stuff" in your *.mk files, such as TAB characters or trailing spaces at lines endings. Run:

    make cleanup-style

    to remove these. Have a look at random *.mk files to get a feeling for the coding style.

    The same holds for your test program.

    However, patch files should always appear in the same coding style as the files they are patching.

    When patching sources with crlf line endings, the patch file itself should also have the same eol style. Use the convention of naming the file as *crlf.patch to instruct git not to normalise the line endings (defined in .gitattributes).

    Finally, in your $(PKG)_BUILD section, please check that you use our portability variables:
    bash 	→	$(SHELL)
    date 	→	$(DATE)
    install 	→	$(INSTALL)
    libtool 	→	$(LIBTOOL)
    libtoolize	→	$(LIBTOOLIZE)
    make 	→	$(MAKE)
    patch 	→	$(PATCH)
    sed 	→	$(SED)
    sort 	→	$(SORT)
    wget 	→	$(WGET)

    Check whether everything runs fine. If you have some trouble, don't hesitate to ask on the mailing list, providing your *.mk file so far.

    Issue a pull request to propose your final *.mk file to us. If you have trouble with pull requests, send your file to the mailing list instead.

    Either way, don't forget to tell us if there are some pieces in your *.mk file you feel unsure about. We'll then have a specific look at those parts, which avoids trouble for you and us in the future.

Copyright © 2007–2015

    Volker Diels-Grabsch
    Mark Brand
    Tony Theodore
    Martin Gerhardy
    Tiancheng "Timothy" Gu
    ... and many other contributors

(contact via the project mailing list)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
Legal
Disclaimer - it's all code...

Modern legal systems are like any other large, complex, and evolving body of code you're likely to encounter.

They have their own language with quirky parsers, compilers, and interpreters (though these tend to be human). Their issue trackers are a backlog of court cases. They have bugs. They have traps for the uninitiated that may potentially do more than waste your time.

We currently limit ourselves to:

--enable-languages='c,c++,objc,fortran'

so nothing mentioned here or on the mailing list should be taken as legal advice. :-)
Choosing the right compiler

The best starting point for any legal questions would be the

FTF (Freedom Task Force of the FSFE (Free Software Foundation Europe)).

They have been very helpful in the past, and maintain an extensive network of legal contacts, both within and outside Europe.

Your local jurisdiction may be a signatory to various international agreements, so be sure to mention where you are in any correspondence (much like any detailed bug report really).

Additionally, you should also do some background reading from the FSF (Free Software Foundation) and Wikipedia to familiarise yourself with some of the potential issues (and experience some context-switching overhead).
Contributions

Contributions are always welcome!

Ownership of all contributions (bug fixes, new packages, doc updates, etc.) remain with the author. All we require is a real name (no l33t handles, please), and that you release your work under our licence.

If you prefer not to be credited with a contribution, please notify the committer.
Package Licences

Each package is individually licensed under terms specified by the authors of that package. Please see the respective source tarball and/or project website for details.

Packages that are non-free or ambiguous will be removed or rejected.

The definition of free must be one of:

    The Free Software Definition
    The Debian Free Software Guidelines (DFSG)
    The Open Source Definition

Please contact the mailing list if you notice a package that doesn't meet these guidlines.
Other Considerations

In addition to the usual considerations (copyrights, patents, trademarks, export regulations etc.), building statically linked libraries for Windows exposes some edge cases that you may not have encountered before.

According to freedom 0 and our own licence, you can use mxe in countless different environments, each with it's own special legal considerations. The configuration options of certain packages (e.g ffmpeg) allow the use of non-free software and/or combinations that cause license violations.

For these packages, we will provide sensible defaults aimed at achieving the following goals:

    avoid causing inherent licensing issues with conflicting options
    make the package as feature complete as possible

Note that this does not prevent downstream violations, or affect any further obligations a licence may impose on you.
Potential Issues - Non Exhaustive List
GNU Licenses

Review the FAQ
LGPL and Static Linking

Review the Differences from the GPL section of the Wikipedia article mentioned above.
GPL and OpenSSL

See conflicting accounts from the FSF and the OpenSSL project.

A similar situation also exists for package fdk-aac.
History

2015-05-04 – Retired the stable branch

    The stable branch was retired as it did more harm than good. Everybody is using the master branch, because it is always recent and well enough tested. For historical reference, the last commit to the stable branch was 0c6cc9c, which was fully merged into master as usual.

    Added support for shared toolchains for over 50% of all the packages.

    Unfortunately, a number of factors have forced us to drop support for MinGW 3 (i.e. "MinGW.org"), in favor of the MinGW-w64 toolchain. This decision was made in a large part because of the dropping of support for MinGW by GLib and Qt5, which arguably are two of the most important packages in MXE. Other considerations have also been taken, like the lack of maintainership in MinGW and potential legal challenges that comes with using supplemental DirectX headers in MinGW in order to support Qt4. Worse yet, having to support the unsupported MinGW toolchain impedes adding or updating packages, as shown in the pull request of updating GLib.

    Please note that dropping support for MinGW DOES NOT MEAN dropping support for the 32-bit architecture. MinGW-w64 also supports 32-bit target through i686-w64-mingw32.

    To ease migration to the supported MinGW-w64 target, we have finished porting all packages that were MinGW-only to at least i686-w64-mingw32 (32-bit target of MinGW-w64). Hence your existing commands should work out-of-the-box assuming the MXE_TARGETS environmental variable is set correctly.
2013-07-27 – Release 2.23

    The stable branch was updated to the current development version after a thorough testing phase.

    Current users are strongly encouraged to start with a clean tree as the toolchain has been updated and requires a full rebuild:

    git pull && make clean && make

    Most packages were updated to their latest version.

    Many new packages are supported: alure, apr-util, apr, armadillo, cegui, cfitsio, cminpack, flann, gtkglarea, gtkimageview, harfbuzz, hdf4, hdf5, hunspell, icu4c, itk, lensfun, levmar, libf2c, libftdi, libgda, libgdamm, libglade, liblqr-1, libmodplug, librtmp, libzip, log4cxx, mdbtools, ncurses, netcdf, netpbm, ocaml-cairo, ocaml-camlimages, ocaml-core, ocaml-findlib, ocaml-flexdll, ocaml-lablgl, ocaml-lablgtk2, ocaml-native, ocaml-xml-light, opencv, opus, opusfile, pcl, picomodel, plib, plibc, poppler, portablexdr, portmidi, protobuf, qdbm, qt5, qtactiveqt, qtbase, qtdeclarative, qtgraphicaleffects, qtimageformats, qtjsbackend, qtmultimedia, qtquick1, qtquickcontrols, qtscript, qtsensors, qtserialport, qtsvg, qttools, qttranslations, qtxmlpatterns, qwt, sdl_gfx, sfml, sox, teem, twolame, vtk6, wavpack, wget, winpthreads, xapian-core, yasm

    Added support for mingw-w64 based toolchains targeting 32 & 64-bit architectures.

    With the addition of Qt5, there is no longer a prefixed version of qmake, see the Qt section of the tutorial for the new way to invoke qmake.

    FreeBSD is no longer fully supported. Qt5, ocaml*, and 8 other packages are excluded from the build.
2012-04-12 – Release 2.22

    The release tarballs have been replaced with a stable branch that conforms to the new branch concept:

        Any change of a build script goes into "master".
        Any package upgrade goes into "master".
        Any documentation upgrade that refers to a feature not present in stable goes into "master".
        Anything else that doesn't affect the build goes into "stable".
        Any non-critical improvement to the main Makefile goes into "stable".
        Any improvement in the package download URLs or package version recognition goes into "stable".
        When in doubt, "master" is used rather than "stable".
        Every change to the "stable" branch will be merged into "master".
        After a successful testing phase, the "stable" branch will be fast-forwarded to "master".

    The project has been renamed from mingw-cross-env (MinGW cross compiling environment) to MXE (M cross environment).

    Most packages were updated to their latest version.

    New packages are supported: agg, cgal, eigen, file, gta, json-c, libgnurx, libharu, libircclient, libssh2, libxml++, llvm, lzo, mpfr, nettle, opencsg, qjson, qwtplot3d, vtk, and wt.
2011-06-07 – Release 2.21

    Download | Changelog

    Minor bugfixes in several packages.

    Almost all packages are updated to their latest version.

    Packages gtkmm and gtksourceviewmm have been renamed to gtkmm2 and gtksourceviewmm2.

    New packages are supported: libass, poco, and t4k_common.
2011-04-05 – Release 2.20

    Download | Changelog

    This release fixes a download error caused by the pixman project (a sudden change of their URL scheme without proper redirects). That sort of thing should never happen!
2011-03-19 – Release 2.19

    Download | Changelog

    The download mechanisms are improved.

    A CMake toolchain file is provided to simplify cross-compiling projects which use CMake.

    Support for Debian/Lenny is dropped.

    Package gtk is renamed to gtk2.

    Almost all packages are updated to their latest version.

    New packages are supported: dbus, graphicsmagick, libical, liboauth, physfs, and vigra.

    Note for boost::filesystem users: Version 3 is a major revision and now the default in 1.46.
2010-12-15 – Release 2.18

    Download | Changelog

    This release fixes a checksum error caused by the atkmm project (a sudden change of their current source tarball). That sort of thing should never happen!
2010-12-11 – Release 2.17

    Download | Changelog

    This release provides some improvements of the build system such as an automatic check for most of the requirements.

    All packages are updated to their latest version.

    New packages are supported: bfd, blas, cblas, dcmtk, ftgl, lapack, lcms1, mingw-utils, mxml, suitesparse and tinyxml.
2010-10-27 – Release 2.16

    Download | Changelog

    This release provides lots of improvements to the build system as well as the documentation.

    Support for OpenSolaris is dropped.

    Almost all packages are updated to their latest version.

    Many new packages are supported: atkmm, cairomm, cunit, faac, faad2, ffmpeg, gdk-pixbuf, glibmm, gtkglextmm, gtkmm, gtksourceview, gtksourceviewmm, imagemagick, lame, libiberty, libsigc++, libvpx, matio, openal, opencore-amr, pangomm, pfstools, plotmm, sdl_sound and x264.
2010-06-16 – Release 2.15

    Download | Changelog

    This release fixes download errors caused by the Qt project (a sudden change of their current source tarball).

    Almost all packages are updated to their latest version.
2010-06-08 – Release 2.14

    Download | Changelog

    This release fixes download errors caused by the MinGW project (a sudden change of their URL scheme without proper redirects). That sort of thing should never happen!

    Almost all packages are updated to their latest version.

    New packages are supported: libarchive, libgee and xvidcore.
2010-05-31 – Release 2.13

    Download | Changelog

    This release switches back from TDM to the official GCC, thus supporting the current GCC 4.5.

    The set of DirectX headers is improved and more complete.

    The deadlock issues with Pthreads-w32 are fixed.

    A static build of GDB is provided, i.e. a standalone "gdb.exe" that doesn't require any extra DLLs.

    More packages are backed by test programs.

    Many "sed hacks" are replaced by proper portability patches.

    Almost all packages are updated to their latest version.

    Many new packages are supported: fribidi, gc, gdb, gmp, gsl, gst-plugins-base, gst-plugins-good, gstreamer, gtkglext, guile, libcroco, libffi, liboil, libpaper, libshout, libunistring and xine-lib.
2010-02-21 – Release 2.12

    Download | Changelog

    This release fixes some minor build issues, and contains a first small set of test programs to check the package builds.

    The build rules are simplified by calling generators like Autotools and Flex, instead of patching the generated files.

    Almost all packages are updated to their latest version.

    Many new packages are supported: aubio, devil, directx, exiv2, fftw, freeimage, gsoap, id3lib, liblo, libpano13, librsvg, libsamplerate, muparser, openscenegraph, portaudio and sdl_pango.
2010-02-20 – Release 2.11

    Download | Changelog

    This release contains a packaging bug. Please use release 2.12 instead.
2009-12-23 – Release 2.10

    Download | Changelog

    This release adds support for many new packages: flac, libmad, libsndfile, sdl_net, speex, postgresql, freetds, openssl, plotutils, taglib, lcms, freeglut, xerces and zziplib.

    Almost all packages are updated to their latest version.

    In addition to the libraries some command line tools such as psql.exe are built, too.

    The placements of logfiles, as well as many other build details, have been improved.
2009-10-24 – Release 2.9

    Download | Changelog

    This release adds support for Qt, VMime and libmng.

    The target triplet is updated to i686-pc-mingw32.

    OpenMP support is enabled in GCC.

    Almost all packages are updated to their latest version.
2009-09-11 – Release 2.8

    Download | Changelog

    This release comes with a better look & feel by providing a highlevel overview of the build process.

    The detailed build messages are stored into separate log files for each package, so parallel builds don't intermix them anymore.

    The download URLs of SourceForge packages are adjusted to ensure that the selected SourceForge mirror is really used and not circumvalented via HTTP redirects to other mirrors.

    Almost all packages are updated to their latest version.

    The whole mingw-cross-env project has moved to Savannah. So all URIs have changed, but the old URIs redirect to the new locations seamlessly.

    Everyone is invited to join the freshly created project mailing list.
2009-08-11 – Release 2.7

    Download | Changelog

    This release provides an improved version recognition for SourceForge packages. SourceForge changed their page layout in a way that makes it much harder to identify the current version of a package.

    Additionally, almost all packages are updated to their latest version.
2009-06-19 – Release 2.6

    Download | Changelog

    This release contains some portability fixes which allow it to run on a wider range of systems such as Frugalware.

    The documentation and website are completely revised.

    New packages such as CppUnit, libUsb, NSIS, Popt, SQLite and Theora are supported.

    Almost all packages are updated to their latest version.

    A new command "make download" is implemented.
2009-04-06 – Release 2.5

    Download | Changelog

    This release fixes a download error caused by the MinGW project. They suddenly changed the names of their source tarballs. That sort of thing should never happen!

    This release also contains some bugfixes which allow it to run on a wider range of systems.

    All downloaded files are now verified by their SHA-1 checksums.

    New versions of various packages are supported.
2009-03-08 – Release 2.4

    Download | Changelog

    This release provides many new libraries such as wxWidgets, GTK+ and OpenEXR.

    In addition, new versions of various packages are supported.
2009-02-09 – Release 2.3

    Download | Changelog

    This release fixes some serious build problems on FreeBSD and MacOS-X.

    The Makefile has a new target "clean-pkg" and allows to be called from a separate build directory via "make -f .../Makefile".

    Some new versions of the packages are supported, especially GCC-4.3 by switching from MinGW GCC to TDM-GCC.
2009-01-31 – Release 2.2

    Download | Changelog

    This release fixes some minor build problems.

    It also supports some new packages and some newer versions of the already supported packages.

    Parallelization is now disabled by default.
2008-12-13 – Release 2.1

    Download | Changelog

    This release fixes a download error caused by the GDAL project. They suddenly changed their download URLs. That sort of thing should never happen!

    In addition, some newer versions of various packages are supported.

    There is also a small compatibility fix for OS X.
2008-11-10 – Release 2.0

    Download | Changelog

    The shell script has been rewritten as Makefile and supports partial builds and parallel builds.

    As usual, this release also supports some new packages and some newer versions of the already supported packages.
2008-01-11 – Release 1.4

    Download | Changelog

    This release now includes a tutorial by Hans Bezemer and has improved compile options of FLTK. As usual, it supports some newer versions of the libraries.

    At the request of its author, libowfat is no longer supported from this release on.

    The script now uses a specific SourceForge mirror instead of randomly chosen ones, because the download phase often stumbled on some very slow mirrors.
2007-12-23 – Release 1.3

    Download | Changelog

    A sudden change in the download URLs of GEOS made the automatic download fail. Such changes should never happen! But it happened, and this quick release is an attempt to limit the damage.

    This release also supports some newer versions of the libraries including support for fontconfig-2.5.0.
2007-12-13 – Release 1.2

    Download | Changelog

    This release is a switch from gcc-3 to gcc-4. It also supports a new library and some newer versions of the already supported libraries.
2007-07-24 – Release 1.1

    Download | Changelog

    This release is the result of the public attention the release 1.0 got. It contains many improvements suggested by its first users, and adds support for many new libraries.

    Thanks to Rocco Rutte who contributed many code snippets.
2007-06-19 – Release 1.0

    Download | Changelog

    This first release has been created in a 7-day-sprint.
2007-06-12 – Project start

See also
This project

    Website
    Project on GitHub
    Entry on Open Hub
    Entry on Savannah
    First release anouncement and the discussion around it

Related projects

    Arch Linux mingw-w64 packages
    Win32 cross compiling packages by Arch Linux
    Debian mingw32 package
    Bare win32 cross compiler
    Fedora MinGW packages
    Win32 cross compiling packages by Fedora
    MSYS2
    Win32/64 ports of many free software packages
    GnuWin32
    Win32 ports of many free software packages
    IMCROSS
    Another project with similar goal
    MinGW cross-compiler build script
    Old script provided by the SDL project
    mxe-octave
    Fork of MXE specialized on building GNU Octave
    openSUSE MinGW packages
    Win32 cross compiling packages by openSUSE
    Win-builds
    Creates binary packages, runs on both Linux and Windows

Related articles

    Cross compilers, the new wave
    Appeared on LXer and Linux Today
    Cross Compiling for Win32
    Overview of win32 cross compiling
    MinGW cross compiler for Linux build environment
    Official tutorial of the MinGW project
    Cross-compiling under Linux for MS Windows
    Old tutorial provided by the wxWidgets project

Projects which use MXE

    Tower Toppler
    Pushover
    The 4tH Compiler
    Spring RTS
    Ube
    Marathon Aleph One
    Aorta
    msmtp
    mpop
    cvtool
    Tux Math
    Tux Typing
    GCompris
    Generic Tagged Arrays
    QTads
    UFO: Alien Invasion
    PokerTH
    TeXworks
    Bino
    Eros
    MKVToolNix
    OpenSCAD
    Warzone 2100
    Lightspark
    Hugor
    DiffPDF
    Pdfgrep
    Spek
    BioSig
    GNU FreeDink
    sigrok
    Mechanized Assault and eXploration Reloaded
    Galois
    xfemm

