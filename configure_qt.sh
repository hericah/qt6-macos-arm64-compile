#!/bin/bash
set -e

prefix="`pwd`/out"
path_build="`pwd`/build"

# brew install node@22 ccache cmake ninja python@3.12 virtualenv

# install/activate venv
bash ensure_python.sh
source venv/bin/activate

git clone -b v6.8.0-beta4 --depth 1 https://codereview.qt-project.org/qt/qt5 qt6 || true
pushd qt6
  ./init-repository --module-subset=qtdeclarative,qtsvg,qtlocation,qtconnectivity,qtimageformats,qtwebsockets,qthttpserver,qtbase,qtpositioning,qt5compat,qtwebsockets,qtwebchannel,qtwebengine
popd

# patch Qt6 configure error
cp patches/QtBuildInformation.cmake qt6/qtbase/cmake/QtBuildInformation.cmake

# export PATH="$HOME/static/out/bin:$PATH"
export C_INCLUDE_PATH="$HOME/static/out"
export CPLUS_INCLUDE_PATH="$HOME/static/out"

# Backport fix to allow QtWebEngine to build with ninja>=1.12.0.
# Issue ref: https://bugreports.qt.io/browse/QTBUG-124375
cp patches/qtwebpatch1_BUILD.gn qt6/qtwebengine/src/3rdparty/chromium/extensions/browser/api/declarative_net_request/BUILD.gn
cp patches/qtwebpatch2_BUILD.gn qt6/qtwebengine/src/3rdparty/chromium/content/public/browser/BUILD.gn

# GN requires clang in clangBasePath/bin
cp patches/qtwebpatch3_TOOLCHAIN.gni ./qt6/qtwebengine/src/3rdparty/chromium/build/toolchain/apple/toolchain.gni

# WARNING: CHANGE VULKANSDK TO THE CORRECT PATH
export VULKAN_SDK="$HOME/VulkanSDK/1.3.290.0/macOS"
if [ ! -d "$VULKAN_SDK" ]; then
  echo "bad VulkanSDK directory"
  exit
fi

if [ ! -d "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.sdk/usr" ]; then
  echo "bad MacOS xcode sdk thingy directory"
  exit
fi

export PATH="$VULKAN_SDK/bin:$PATH"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"
export VK_ICD_FILENAMES="$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json"
export VK_LAYER_PATH="$VULKAN_SDK/share/vulkan/explicit_layer.d"
export VK_INSTANCE_LAYERS="VK_LAYER_KHRONOS_validation"
export QT_VULKAN_LIB="$VULKAN_SDK/lib/libMoltenVK.dylib"

echo "Vulkan SDK: $VULKAN_SDK"

pushd qt6
  ./configure -release -prefix "$path_build" -extprefix "$path_build" -no-sql-mysql -no-sql-odbc -no-sql-psql -sysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk -- -Bbuild -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DCMAKE_PREFIX_PATH="$VULKAN_SDK;$prefix" -GNinja -DFEATURE_sql_mysql=OFF -DCMAKE_OSX_ARCHITECTURES="arm64" -DFEATURE_sql_odbc=OFF -DFEATURE_sql_psql=OFF -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DCMAKE_FIND_FRAMEWORK=FIRST -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=/opt/homebrew/Library/Homebrew/cmake/trap_fetchcontent_provider.cmake -Wno-dev -DBUILD_TESTING=OFF -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX14.sdk -DFEATURE_pkg_config=ON -DQT_FEATURE_clang=OFF -DFEATURE_dbus=OFF -DQT_FEATURE_relocatable=OFF -DQT_FEATURE_system_assimp=ON -DQT_FEATURE_system_protobuf=ON -DQT_FEATURE_brotli=OFF -DQT_FEATURE_system_doubleconversion=ON -DQT_FEATURE_system_freetype=ON -DQT_FEATURE_system_harfbuzz=ON -DQT_FEATURE_system_hunspell=ON -DQT_FEATURE_system_jpeg=ON -DQT_FEATURE_system_libb2=ON -DQT_FEATURE_system_pcre2=ON -DQT_ALLOW_SYMLINK_IN_PATHS=OFF -DQT_FEATURE_system_png=OFF -DQT_FEATURE_system_sqlite=ON -DQT_FEATURE_system_tiff=ON -DQT_FEATURE_system_webp=ON -DQT_FEATURE_system_zlib=ON -DQT_FEATURE_webengine_proprietary_codecs=OFF -DQT_FEATURE_webengine_kerberos=ON -DCMAKE_OSX_DEPLOYMENT_TARGET=14.0 -DQT_FEATURE_ffmpeg=OFF -DQT_FEATURE_webengine_vulkan=OFF -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_INSTALL_EXAMPLES_SOURCES=OFF -DJPEG_LIBRARY_RELEASE="$prefix/lib/libjpeg.a" -DJPEG_INCLUDE_DIRS="$prefix/include/" -DFEATURE_xcb=OFF -DFEATURE_linuxfb=OFF -DFEATURE_xcb_xlib=OFF -DQT_USE_CCACHE=ON -DFEATURE_gtk3=OFF -DFEATURE_glib=OFF -DFEATURE_kms=OFF -DFEATURE_xkbcommon=OFF -DQT_FEATURE_brotli=OFF -DFEATURE_brotli=OFF -DPCRE2_USE_STATIC_LIBS=ON

  echo "[*] detect which libraries are .dylib (and maybe need to be .a instead):"
  cat build/CMakeCache.txt| grep 'dylib$' | python3 ../print_filepaths.py

  echo "[*] detect any dylib's from brew (probably shouldnt link against homebrew stuff):"
  cat build/CMakeCache.txt | grep 'dylib' | grep -i homebrew || true

  echo "[*] also see 'summary.txt' for Qt configure output:"
  cat build/config.summary > ../summary.txt || true
  
  echo "[*] to compile, 1) activate venv 'source venv/bin/activate' 2) 'cd qt6' 3) and:"
  echo "cmake --build build --parallel 8"
  echo "or"
  echo "cmake --build build --parallel 8 --target qtdeclarative"
  echo ""
  echo "after compile, to install: $path_build"
  echo "cmake --install build"
popd
