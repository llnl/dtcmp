#[=======================================================================[.rst:
FindLWGRP
---------

Find the LWGRP library (https://github.com/llnl/lwgrp).

An installed LWGRP CMake package config (``lwgrpConfig.cmake``) is preferred,
falling back to searching for the header and library directly.

Set ``LWGRP_ROOT`` to the LWGRP install prefix if it is not in a default
search location.

Imported Targets
^^^^^^^^^^^^^^^^

``LWGRP::LWGRP``
  The LWGRP library. lwgrp.h includes mpi.h, so this target links
  ``MPI::MPI_C`` when that target exists.

Result Variables
^^^^^^^^^^^^^^^^

``LWGRP_FOUND``
``LWGRP_INCLUDE_DIR``
  Only set when falling back to the header and library search.
``LWGRP_LIBRARY``
  Only set when falling back to the header and library search.
#]=======================================================================]

include(FindPackageHandleStandardArgs)

find_package(LWGRP CONFIG QUIET NAMES lwgrp LWGRP)
# wrap the package's target so dependents, including the dtcmp export, only
# ever reference LWGRP::LWGRP regardless of how lwgrp was found
if(LWGRP_FOUND AND NOT TARGET LWGRP::LWGRP AND TARGET lwgrp::lwgrp)
    add_library(LWGRP::LWGRP INTERFACE IMPORTED)
    target_link_libraries(LWGRP::LWGRP INTERFACE lwgrp::lwgrp)
endif()
if(TARGET LWGRP::LWGRP)
    find_package_handle_standard_args(LWGRP CONFIG_MODE)
    return()
endif()

find_path(LWGRP_INCLUDE_DIR NAMES lwgrp.h)
find_library(LWGRP_LIBRARY NAMES lwgrp liblwgrp)

find_package_handle_standard_args(LWGRP
    REQUIRED_VARS LWGRP_LIBRARY LWGRP_INCLUDE_DIR
)

if(LWGRP_FOUND AND NOT TARGET LWGRP::LWGRP)
    add_library(LWGRP::LWGRP UNKNOWN IMPORTED)
    set_target_properties(LWGRP::LWGRP PROPERTIES
        IMPORTED_LOCATION "${LWGRP_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${LWGRP_INCLUDE_DIR}"
    )
    if(TARGET MPI::MPI_C)
        set_property(TARGET LWGRP::LWGRP APPEND PROPERTY INTERFACE_LINK_LIBRARIES MPI::MPI_C)
    endif()
endif()

mark_as_advanced(LWGRP_INCLUDE_DIR LWGRP_LIBRARY)
