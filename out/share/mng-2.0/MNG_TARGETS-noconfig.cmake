#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "mng" for configuration ""
set_property(TARGET mng APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(mng PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "C"
  IMPORTED_LINK_INTERFACE_LIBRARIES_NOCONFIG "/Users/dsc/static/out/lib/libjpeg.a;/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.5.sdk/usr/lib/libz.tbd;/Users/dsc/static/out/lib/liblcms2.a;m"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libmng.a"
  )

list(APPEND _cmake_import_check_targets mng )
list(APPEND _cmake_import_check_files_for_mng "${_IMPORT_PREFIX}/lib/libmng.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
