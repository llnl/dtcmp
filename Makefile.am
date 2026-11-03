ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src
EXTRA_DIST = \
	CMakeLists.txt \
	src/CMakeLists.txt \
	cmake/FindLWGRP.cmake \
	cmake/dtcmpConfig.cmake.in

dist_pkgdata_DATA = README.md LICENSE.TXT

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libdtcmp.pc
