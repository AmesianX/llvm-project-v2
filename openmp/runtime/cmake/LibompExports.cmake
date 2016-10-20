#
#//===----------------------------------------------------------------------===//
#//
#//                     The LLVM Compiler Infrastructure
#//
#// This file is dual licensed under the MIT and the University of Illinois Open
#// Source Licenses. See LICENSE.txt for details.
#//
#//===----------------------------------------------------------------------===//
#

# LibompExports.cmake
#   Copy library and header files into the exports/ subdirectory after library build

# Create the suffix for the export directory
# - Only add to suffix when not a default value
# - Example suffix: .deb.30.s1
#   final export directory: exports/lin_32e.deb.30.s1/lib
# - These suffixes imply the build is a Debug, OpenMP 3.0, Stats-Gathering version of the library
set(libomp_suffix)
libomp_append(libomp_suffix .deb DEBUG_BUILD)
libomp_append(libomp_suffix .dia RELWITHDEBINFO_BUILD)
libomp_append(libomp_suffix .min MINSIZEREL_BUILD)
if(NOT "${LIBOMP_OMP_VERSION}" STREQUAL "45")
  libomp_append(libomp_suffix .${LIBOMP_OMP_VERSION})
endif()
libomp_append(libomp_suffix .s1 LIBOMP_STATS)
libomp_append(libomp_suffix .ompt LIBOMP_OMPT_SUPPORT)
if(${LIBOMP_OMPT_SUPPORT})
  libomp_append(libomp_suffix .no-ompt-blame IF_FALSE LIBOMP_OMPT_BLAME)
  libomp_append(libomp_suffix .no-ompt-trace IF_FALSE LIBOMP_OMPT_TRACE)
endif()
string(REPLACE ";" "" libomp_suffix "${libomp_suffix}")

# Set exports locations
if(${MIC})
  set(libomp_platform "${LIBOMP_PERL_SCRIPT_OS}_${LIBOMP_MIC_ARCH}") # e.g., lin_knf, lin_knc
else()
  if(${IA32})
    set(libomp_platform "${LIBOMP_PERL_SCRIPT_OS}_32")
  elseif(${INTEL64})
    set(libomp_platform "${LIBOMP_PERL_SCRIPT_OS}_32e")
  else()
    set(libomp_platform "${LIBOMP_PERL_SCRIPT_OS}_${LIBOMP_ARCH}") # e.g., lin_arm, lin_ppc64
  endif()
endif()
set(LIBOMP_EXPORTS_DIR "${LIBOMP_BASE_DIR}/exports")
set(LIBOMP_EXPORTS_PLATFORM_DIR "${LIBOMP_EXPORTS_DIR}/${libomp_platform}${libomp_suffix}")
set(LIBOMP_EXPORTS_CMN_DIR "${LIBOMP_EXPORTS_DIR}/common${libomp_suffix}/include")
set(LIBOMP_EXPORTS_INC_DIR "${LIBOMP_EXPORTS_PLATFORM_DIR}/include")
set(LIBOMP_EXPORTS_MOD_DIR "${LIBOMP_EXPORTS_PLATFORM_DIR}/include_compat")
set(LIBOMP_EXPORTS_LIB_DIR "${LIBOMP_EXPORTS_DIR}/${libomp_platform}${libomp_suffix}/lib")

# Put headers in exports/ directory post build
add_custom_command(TARGET omp POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBOMP_EXPORTS_CMN_DIR}
  COMMAND ${CMAKE_COMMAND} -E copy omp.h ${LIBOMP_EXPORTS_CMN_DIR}
)
if(${LIBOMP_OMPT_SUPPORT})
  add_custom_command(TARGET omp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy ompt.h ${LIBOMP_EXPORTS_CMN_DIR}
  )
endif()
if(${LIBOMP_FORTRAN_MODULES})
  add_custom_command(TARGET libomp-mod POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBOMP_EXPORTS_MOD_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy omp_lib.mod ${LIBOMP_EXPORTS_MOD_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy omp_lib_kinds.mod ${LIBOMP_EXPORTS_MOD_DIR}
  )
  add_custom_command(TARGET omp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy omp_lib.h ${LIBOMP_EXPORTS_CMN_DIR}
  )
endif()

# Copy OpenMP library into exports/ directory post build
if(WIN32)
  get_target_property(LIBOMP_OUTPUT_DIRECTORY omp RUNTIME_OUTPUT_DIRECTORY)
else()
  get_target_property(LIBOMP_OUTPUT_DIRECTORY omp LIBRARY_OUTPUT_DIRECTORY)
endif()
if(NOT LIBOMP_OUTPUT_DIRECTORY)
  set(LIBOMP_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endif()
add_custom_command(TARGET omp POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBOMP_EXPORTS_LIB_DIR}
  COMMAND ${CMAKE_COMMAND} -E copy ${LIBOMP_OUTPUT_DIRECTORY}/${LIBOMP_LIB_FILE} ${LIBOMP_EXPORTS_LIB_DIR}
)

# Copy Windows import library into exports/ directory post build
if(WIN32)
  get_target_property(LIBOMPIMP_OUTPUT_DIRECTORY ompimp ARCHIVE_OUTPUT_DIRECTORY)
  if(NOT LIBOMPIMP_OUTPUT_DIRECTORY)
    set(LIBOMPIMP_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  add_custom_command(TARGET ompimp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBOMP_EXPORTS_LIB_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${LIBOMPIMP_OUTPUT_DIRECTORY}/${LIBOMP_IMP_LIB_FILE} ${LIBOMP_EXPORTS_LIB_DIR}
  )
endif()

