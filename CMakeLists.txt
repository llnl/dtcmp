cmake_minimum_required(VERSION 3.30)

project(DTCMP
    VERSION 1.1.5
    DESCRIPTION "Datatype Comparison Library"
    HOMEPAGE_URL "https://github.com/hpc/dtcmp"
    LANGUAGES C
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

list(PREPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

option(BUILD_SHARED_LIBS "Build DTCMP as a shared library" ON)
option(DTCMP_ENABLE_TESTS "Enable the build of DTCMP tests" OFF)

# dtcmp.h exports global data without explict dllexport
# no import lib would be generated, Windows must be static only
if(WIN32 AND BUILD_SHARED_LIBS)
    message(STATUS "DTCMP: shared libraries are not supported on Windows, building static")
    set(BUILD_SHARED_LIBS OFF)
endif()

if(NOT DEFINED CMAKE_INSTALL_RPATH_USE_LINK_PATH)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
endif()

find_package(MPI REQUIRED COMPONENTS C)
find_package(LWGRP REQUIRED)

if(DTCMP_ENABLE_TESTS)
    enable_testing()
endif()

add_subdirectory(src)

set(DTCMP_INSTALL_CMAKEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/dtcmp)

install(TARGETS dtcmp
    EXPORT dtcmp_targets
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(EXPORT dtcmp_targets
    FILE dtcmpTargets.cmake
    NAMESPACE dtcmp::
    DESTINATION ${DTCMP_INSTALL_CMAKEDIR}
)
configure_package_config_file(cmake/dtcmpConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/dtcmpConfig.cmake
    INSTALL_DESTINATION ${DTCMP_INSTALL_CMAKEDIR}
)
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/dtcmpConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/dtcmpConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/dtcmpConfigVersion.cmake
              cmake/FindLWGRP.cmake
        DESTINATION ${DTCMP_INSTALL_CMAKEDIR}
)

# pkg-config file, using the same variables autoconf substitutes into libdtcmp.pc.in
set(prefix ${CMAKE_INSTALL_PREFIX})
set(exec_prefix "\${prefix}")
set(libdir "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
set(includedir "\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
set(PACKAGE_NAME ${PROJECT_DESCRIPTION})
set(PACKAGE_VERSION ${PROJECT_VERSION})
set(PACKAGE_URL ${PROJECT_HOMEPAGE_URL})
configure_file(libdtcmp.pc.in ${CMAKE_CURRENT_BINARY_DIR}/libdtcmp.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libdtcmp.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

install(FILES README.md LICENSE.TXT
        DESTINATION ${CMAKE_INSTALL_DATADIR}/dtcmp
)
