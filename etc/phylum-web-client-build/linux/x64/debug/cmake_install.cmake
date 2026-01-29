# Install script for directory: /home/mannchri/work/git/phylum/client/linux

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/nix/store/yng1lcnccgq66i68g4xg8y5qrk30y9s0-clang-wrapper-21.1.7/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/")
  
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum"
         RPATH "$ORIGIN/lib")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle" TYPE EXECUTABLE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/intermediates_do_not_run/phylum")
  if(EXISTS "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum"
         OLD_RPATH "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/irondash_engine_context:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/open_file_linux:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/printing:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/sqlite3_flutter_libs:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/super_native_extensions:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/url_launcher_linux:/home/mannchri/work/git/phylum/client/linux/flutter/ephemeral:/nix/store/b8z05hhv5mk77n0d93hx14fnr1yraz6h-gtk+3-3.24.51/lib:/nix/store/6l6an18i0n18i1q1rq02yvkdf27p6a9h-pango-1.57.0/lib:/nix/store/84p91jrj1730rc4pl891zxhjh6k4r13n-harfbuzz-12.1.0/lib:/nix/store/hrwlrhq2wr6041fnd8cvzll8rxssn1lr-at-spi2-core-2.58.2/lib:/nix/store/3vkggl8hz76g9651mbr4svhmz1005jmk-cairo-1.18.4/lib:/nix/store/gglqszzvj84pk39z7aivj8cg825lwq71-gdk-pixbuf-2.44.4/lib:/nix/store/ikfv93xddmds911pnd4g03j2xgm5iv5m-glib-2.86.3/lib:/home/mannchri/work/git/phylum/client/build/linux/x64/debug/pdfium-src/lib:"
         NEW_RPATH "$ORIGIN/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/nix/store/yng1lcnccgq66i68g4xg8y5qrk30y9s0-clang-wrapper-21.1.7/bin/strip" "$ENV{DESTDIR}/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/phylum")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/data/icudtl.dat")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/data" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/linux/flutter/ephemeral/icudtl.dat")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libflutter_linux_gtk.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/linux/flutter/ephemeral/libflutter_linux_gtk.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libirondash_engine_context_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/irondash_engine_context/libirondash_engine_context_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libopen_file_linux_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/open_file_linux/libopen_file_linux_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libprinting_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/printing/libprinting_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libpdfium.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/pdfium-src/lib/libpdfium.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libsqlite3_flutter_libs_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/sqlite3_flutter_libs/libsqlite3_flutter_libs_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libsuper_native_extensions_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/super_native_extensions/libsuper_native_extensions_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/libsuper_native_extensions.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/super_native_extensions/libsuper_native_extensions.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/liburl_launcher_linux_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE FILE FILES "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/url_launcher_linux/liburl_launcher_linux_plugin.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/lib" TYPE DIRECTORY FILES "/home/mannchri/work/git/phylum/client/build/native_assets/linux/")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  
  file(REMOVE_RECURSE "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/data/flutter_assets")
  
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/data/flutter_assets")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/bundle/data" TYPE DIRECTORY FILES "/home/mannchri/work/git/phylum/client/build//flutter_assets")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/flutter/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/irondash_engine_context/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/open_file_linux/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/printing/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/sqlite3_flutter_libs/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/super_native_extensions/cmake_install.cmake")
  include("/home/mannchri/work/git/phylum/client/build/linux/x64/debug/plugins/url_launcher_linux/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/mannchri/work/git/phylum/client/build/linux/x64/debug/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
