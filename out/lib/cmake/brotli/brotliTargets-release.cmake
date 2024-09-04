#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "brotli::brotlienc" for configuration "Release"
set_property(TARGET brotli::brotlienc APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(brotli::brotlienc PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbrotlienc.a"
  )

list(APPEND _cmake_import_check_targets brotli::brotlienc )
list(APPEND _cmake_import_check_files_for_brotli::brotlienc "${_IMPORT_PREFIX}/lib/libbrotlienc.a" )

# Import target "brotli::brotlidec" for configuration "Release"
set_property(TARGET brotli::brotlidec APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(brotli::brotlidec PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbrotlidec.a"
  )

list(APPEND _cmake_import_check_targets brotli::brotlidec )
list(APPEND _cmake_import_check_files_for_brotli::brotlidec "${_IMPORT_PREFIX}/lib/libbrotlidec.a" )

# Import target "brotli::brotlicommon" for configuration "Release"
set_property(TARGET brotli::brotlicommon APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(brotli::brotlicommon PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libbrotlicommon.a"
  )

list(APPEND _cmake_import_check_targets brotli::brotlicommon )
list(APPEND _cmake_import_check_files_for_brotli::brotlicommon "${_IMPORT_PREFIX}/lib/libbrotlicommon.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
