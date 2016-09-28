function(lldb_link_common_libs name targetkind)
  if (NOT LLDB_USED_LIBS)
    return()
  endif()

  if(${targetkind} MATCHES "SHARED")
    set(LINK_KEYWORD PUBLIC)
  endif()

  if(${targetkind} MATCHES "SHARED" OR ${targetkind} MATCHES "EXE")
    if (LLDB_LINKER_SUPPORTS_GROUPS)
      target_link_libraries(${name} ${LINK_KEYWORD}
                            -Wl,--start-group ${LLDB_USED_LIBS} -Wl,--end-group)
    else()
      target_link_libraries(${name} ${LINK_KEYWORD} ${LLDB_USED_LIBS})
    endif()
  endif()
endfunction(lldb_link_common_libs)

macro(add_lldb_library name)
  # only supported parameters to this macro are the optional
  # MODULE;SHARED;STATIC library type and source files
  cmake_parse_arguments(PARAM
    "MODULE;SHARED;STATIC;OBJECT"
    ""
    ""
    ${ARGN})
  llvm_process_sources(srcs ${PARAM_UNPARSED_ARGUMENTS})

  if (MSVC_IDE OR XCODE)
    string(REGEX MATCHALL "/[^/]+" split_path ${CMAKE_CURRENT_SOURCE_DIR})
    list(GET split_path -1 dir)
    file(GLOB_RECURSE headers
      ../../include/lldb${dir}/*.h)
    set(srcs ${srcs} ${headers})
  endif()
  if (PARAM_MODULE)
    set(libkind MODULE)
  elseif (PARAM_SHARED)
    set(libkind SHARED)
  elseif (PARAM_OBJECT)
    set(libkind OBJECT)
  else ()
    # PARAM_STATIC or library type unspecified. BUILD_SHARED_LIBS
    # does not control the kind of libraries created for LLDB,
    # only whether or not they link to shared/static LLVM/Clang
    # libraries.
    set(libkind STATIC)
  endif()

  #PIC not needed on Win
  if (NOT MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif()

  if (PARAM_OBJECT)
    add_library(${name} ${libkind} ${srcs})
  else()
    llvm_add_library(${name} ${libkind} DISABLE_LLVM_LINK_LLVM_DYLIB ${srcs})

    lldb_link_common_libs(${name} "${libkind}")

    if (PARAM_SHARED)
      if (LLDB_LINKER_SUPPORTS_GROUPS)
        target_link_libraries(${name} PUBLIC
                    -Wl,--start-group ${SWIFT_ALL_LIBS} -Wl,--end-group)
        target_link_libraries(${name} PUBLIC
                    -Wl,--start-group ${CLANG_ALL_LIBS} -Wl,--end-group)
        target_link_libraries(${name} PUBLIC
                    -Wl,--start-group ${LLVM_ALL_LIBS} -Wl,--end-group)
      else()
        target_link_libraries(${name} PUBLIC ${SWIFT_ALL_LIBS})
        target_link_libraries(${name} PUBLIC ${CLANG_ALL_LIBS})
        target_link_libraries(${name} PUBLIC ${LLVM_ALL_LIBS})
      endif()
    endif()
    llvm_config(${name} ${LLVM_LINK_COMPONENTS} ${LLVM_PRIVATE_LINK_COMPONENTS})

    if (${name} STREQUAL "liblldb")
      if (PARAM_SHARED)
        install(TARGETS ${name}
          RUNTIME DESTINATION bin
          LIBRARY DESTINATION lib${LLVM_LIBDIR_SUFFIX}
          ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX})
      else()
        install(TARGETS ${name}
          LIBRARY DESTINATION lib${LLVM_LIBDIR_SUFFIX}
          ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX})
      endif()
    endif()
  endif()

  # Hack: only some LLDB libraries depend on the clang autogenerated headers,
  # but it is simple enough to make all of LLDB depend on some of those
  # headers without negatively impacting much of anything.
  add_dependencies(${name} libclang)

  set_target_properties(${name} PROPERTIES FOLDER "lldb libraries")
endmacro(add_lldb_library)

macro(add_lldb_executable name)
  add_llvm_executable(${name} DISABLE_LLVM_LINK_LLVM_DYLIB ${ARGN})
  set_target_properties(${name} PROPERTIES FOLDER "lldb executables")
  # ELF and Mach-O loaders have different ways of expressing that an rpath
  # should be relative to the binary being loaded. Mach-O uses @loader_path, and
  # ELF uses $ORIGIN.
  if(APPLE)
    set(rpath_prefix "@loader_path")
  else()
    set(rpath_prefix "$ORIGIN")
  endif()
  set_target_properties(${name} PROPERTIES INSTALL_RPATH "${rpath_prefix}/../lib")
endmacro(add_lldb_executable)

# Support appending linker flags to an existing target.
# This will preserve the existing linker flags on the
# target, if there are any.
function(lldb_append_link_flags target_name new_link_flags)
  # Retrieve existing linker flags.
  get_target_property(current_link_flags ${target_name} LINK_FLAGS)

  # If we had any linker flags, include them first in the new linker flags.
  if(current_link_flags)
    set(new_link_flags "${current_link_flags} ${new_link_flags}")
  endif()

  # Now set them onto the target.
  set_target_properties(${target_name} PROPERTIES LINK_FLAGS ${new_link_flags})
endfunction()
