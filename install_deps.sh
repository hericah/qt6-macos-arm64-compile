#!/bin/bash

set -e
prefix="`pwd`/out"
THREADS=8

# install/activate venv
bash ensure_python.sh
source venv/bin/activate

export PKG_CONFIG_PATH="$prefix/lib/pkgconfig/"

mkdir -p $prefix/lib
mkdir -p $prefix/bin
mkdir -p $prefix/include

sudo chmod -R 774 $prefix || true

### openssl

if [ ! -d "openssl-3.3.2" ]; then
  wget https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz -O openssl-3.3.2.tar.gz
  tar xvf openssl-3.3.2.tar.gz
  pushd openssl-3.3.2
  ./config no-shared no-dso --prefix="$prefix"
  make -j$THREADS
  make -j$THREADS install_sw
  popd
fi

### lcms2

if [ ! -d "Little-CMS" ]; then
  git clone --depth 1 --branch lcms2.16 https://github.com/mm2/Little-CMS.git
  pushd Little-CMS
  ./configure --prefix="$prefix" --enable-static --disable-shared
  make install -j8
  popd
fi

### jpeg-turbo

if [ ! -d "libjpeg-turbo" ]; then
  git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git --branch 3.0.3 --depth 1
  pushd libjpeg-turbo
  cmake -Bbuild -DENABLE_SHARED=OFF -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" -DCMAKE_POLICY_VERSION_MINIMUM=3.5  .
  make -Cbuild -j8
  make -Cbuild install
  popd
fi

### expat

if [ ! -d "expat-2.6.3" ]; then
  wget https://github.com/libexpat/libexpat/releases/download/R_2_6_3/expat-2.6.3.tar.lz -O expat-2.6.3.tar.lz
  tar xvf expat-2.6.3.tar.lz
  pushd expat-2.6.3

  autoreconf -fiv
  ./configure --prefix="$prefix" --disable-shared --enable-static
  make install
  popd
fi

### icu

if [ ! -d "icu" ]; then
  git clone -b release-74-2 --depth 1 https://github.com/unicode-org/icu
  pushd icu/icu4c/source 
  ./configure --prefix="$prefix" --disable-shared --enable-static --disable-tests --disable-samples
  make -j8
  make -j8 install
  popd
fi

if [ ! -d "double-conversion" ]; then
  git clone -b v3.3.0 --depth 1 https://github.com/google/double-conversion.git
  pushd double-conversion
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" -Blolbuild . 
  make -Clolbuild -j8 
  make -Clolbuild -j8 install
  popd
fi

if [ ! -d "brotli" ]; then
  git clone -b 1.1.0 --depth 1 https://github.com/kroketio/brotli.git
  pushd brotli
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DBROTLI_DISABLE_TESTS=ON -DBROTLI_BUNDLED_MODE=OFF -DCMAKE_PREFIX_PATH="$prefix" -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX="$prefix" -Blolbuild .
  make -Clolbuild -j8
  make -Clolbuild -j8 install
  popd
fi

if [ ! -d "libpng" ]; then
  git clone -b v1.6.43 https://github.com/glennrp/libpng.git
  pushd libpng 
  ./configure --disable-shared --enable-static --prefix=$prefix --disable-dependency-tracking --disable-silent-rules
  make -j$THREADS
  make -j$THREADS install
  popd
fi
#fix pkgconfig, add -lz 
sudo cp patches/libpng16.pc $prefix/lib/pkgconfig/libpng16.pc

# https://stackoverflow.com/questions/41767193/how-do-i-build-cairo-harfbuzz
if [ ! -d "freetype-2.13.3" ]; then
  wget https://download.savannah.gnu.org/releases/freetype/freetype-2.13.3.tar.xz 
  tar xvf freetype-2.13.3.tar.xz
  pushd freetype-2.13.3
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Bbuild -DFT_DISABLE_HARFBUZZ=TRUE -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" -DBUILD_SHARED_LIBS=OFF .
  # ./configure --prefix=$prefix --enable-freetype-config --disable-shared --enable-static --without-harfbuzz
  make -Cbuild -j$THREADS
  make -Cbuild -j$THREADS install
  popd
fi

### pcre2

if [ ! -d "pcre2" ]; then
  git clone https://github.com/PCRE2Project/pcre2.git --recursive --branch pcre2-10.44 --depth 1
  pushd pcre2

  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Bbuild -DBUILD_SHARED_LIBS=OFF -DPCRE2_SUPPORT_LIBBZ2=OFF -DPCRE2_BUILD_PCRE2_8=ON -DPCRE2_BUILD_PCRE2_32=ON -DPCRE2_BUILD_PCRE2_16=ON -DPCRE2_SUPPORT_JIT=ON -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" .
  make -Cbuild -j8
  make -Cbuild -j8 install
  popd
fi

### graphite2

if [ ! -d "graphite2-1.3.14" ]; then
  wget https://github.com/silnrsi/graphite/releases/download/1.3.14/graphite2-1.3.14.tgz -O graphite2-1.3.14.tgz
  tar xvf graphite2-1.3.14.tgz
  pushd graphite2-1.3.14
  cp ../patches/graphite2.patch src/CMakeLists.txt
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_PREFIX_PATH="$prefix" -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX="$prefix" -Bbuild .
  make -Cbuild -j8
  make -Cbuild -j8 install
  popd
fi

### harfbuzz
if [ ! -d "harfbuzz-9.0.0" ]; then
  wget https://github.com/harfbuzz/harfbuzz/archive/refs/tags/9.0.0.tar.gz -O 9.0.0.tar.gz
  tar xvf 9.0.0.tar.gz
  pushd harfbuzz-9.0.0
  CMAKE_CONFIG_PATH="$prefix/lib/cmake" PKG_CONFIG_PATH="$prefix/lib/pkgconfig" meson setup build --default-library=static -Dcairo=disabled -Dcoretext=enabled -Dfreetype=enabled -Dglib=disabled -Dgobject=disabled -Dgraphite=enabled -Dicu=enabled -Dintrospection=disabled -Dtests=disabled --prefix="$prefix"
  meson compile -Cbuild --verbose
  meson install -Cbuild
  popd
fi


### fontconfig
if [ ! -d "fontconfig-2.15.0" ]; then
  wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz -O fontconfig-2.15.0.tar.xz
  tar xvf fontconfig-2.15.0.tar.xz

  pushd fontconfig-2.15.0
  PKG_CONFIG_PATH="$prefix/lib/pkgconfig/" ./configure --prefix="$prefix" --disable-silent-rules --disable-docs --disable-shared --enable-static --with-add-fonts='/System/Library/Fonts,/Library/Fonts,~/Library/Fonts,/System/Library/AssetsV2/com_apple_MobileAsset_Font7' --localstatedir="$prefix/var/" --sysconfdir="$prefix/etc/"
  make install RUN_FC_CACHE_TEST=false -j8
  ./fc-cache/fc-cache -frv
  popd
fi
# fix pc
sudo cp patches/fontconfig.pc $prefix/lib/pkgconfig/fontconfig.pc

### freetype, again
pushd freetype-2.13.3
rm -rf build
cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Bbuild -DFT_DISABLE_HARFBUZZ=OFF -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" -DBUILD_SHARED_LIBS=OFF .
# ./configure --prefix=$prefix --enable-freetype-config --disable-shared --enable-static --without-harfbuzz
make -Cbuild -j$THREADS
make -Cbuild -j$THREADS install
popd


### cairo
if [ ! -d "cairo-1.18.2" ]; then
wget https://cairographics.org/releases/cairo-1.18.2.tar.xz -O cairo-1.18.2.tar.xz
tar xvf cairo-1.18.2.tar.xz
pushd cairo-1.18.2

  CMAKE_CONFIG_PATH="$prefix/lib/cmake" PKG_CONFIG_PATH="$prefix/lib/pkgconfig" meson setup build --default-library=static -Dfontconfig=enabled -Dfreetype=enabled -Dpng=enabled -Dxcb=disabled -Dxlib=disabled -Dzlib=enabled -Dglib=disabled --prefix="$prefix"
  meson compile -Cbuild --verbose
  meson install -Cbuild

popd
fi

### libb2
if [ ! -d "libb2-0.98.1" ]; then
  wget https://github.com/BLAKE2/libb2/releases/download/v0.98.1/libb2-0.98.1.tar.gz -O libb2-0.98.1.tar.gz 
  tar xvf libb2-0.98.1.tar.gz
  pushd libb2-0.98.1
  ./configure --disable-shared --enable-static --disable-dependency-tracking --disable-silent-rules --prefix=$prefix
  make -j$THREADS &&
  make -j$THREADS install
  popd
fi

### zstd

if [ ! -d "zstd-1.5.6" ]; then
  wget https://github.com/facebook/zstd/archive/refs/tags/v1.5.6.tar.gz -O v1.5.6.tar.gz
  tar xvf v1.5.6.tar.gz

  pushd zstd-1.5.6
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_PREFIX_PATH="$prefix" -Bbuild -S build/cmake -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_PROGRAMS_LINK_SHARED=OFF -DZSTD_BUILD_CONTRIB=ON -DZSTD_LEGACY_SUPPORT=ON -DZSTD_ZLIB_SUPPORT=ON -DZSTD_LZMA_SUPPORT=ON -DZSTD_LZ4_SUPPORT=ON -DCMAKE_CXX_STANDARD=11 -DCMAKE_INSTALL_PREFIX="$prefix"
  make -Cbuild -j8
  make -Cbuild install
  popd
fi

### tiff

if [ ! -d "libtiff" ]; then
  git clone https://github.com/kroketio/libtiff.git --recursive
  pushd libtiff
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Bbuild2 -DCMAKE_PREFIX_PATH="$prefix" -Dzstd=ON -Dwebp=OFF -Dlzma=ON -Djpeg=ON -Dtiff-docs=OFF -Dtiff-tests=OFF -Dtiff-tools-unsupported=OFF -Dtiff-tools=OFF -Dtiff-docs=OFF -Dtiff-tests=OFF -Dtiff-tools-unsupported=OFF -Dtiff-tools=OFF -DCMAKE_INSTALL_PREFIX="$prefix" .
  make -Cbuild2 -j8 .
  make -Cbuild2 -j8 install
  popd
fi

### libwebp

if [ ! -d "libwebp-1.4.0" ]; then
  wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.4.0.tar.gz -O libwebp-1.4.0.tar.gz
  tar xvf libwebp-1.4.0.tar.gz
  pushd libwebp-1.4.0

  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_PREFIX_PATH="$prefix" -DCMAKE_INSTALL_PREFIX="$prefix" -Bbuild -DBUILD_SHARED_LIBS=OFF -DCMAKE_PREFIX_PATH="$prefix" .
  make -Cbuild -j8
  make -Cbuild -j8 install
  popd
fi

# yeah well, whatever
sudo chmod -R 774 $prefix

### fontconfig
if [ ! -d "fontconfig-2.15.0" ]; then
  wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz -O fontconfig-2.15.0.tar.xz
  tar xvf fontconfig-2.15.0.tar.xz

  pushd fontconfig-2.15.0
  PKG_CONFIG_PATH="$prefix/lib/pkgconfig/" ./configure --prefix="$prefix" --disable-silent-rules --disable-docs --disable-shared --enable-static --with-add-fonts='/System/Library/Fonts,/Library/Fonts,~/Library/Fonts,/System/Library/AssetsV2/com_apple_MobileAsset_Font7' --localstatedir="$prefix/var/" --sysconfdir="$prefix/etc/"
  make install RUN_FC_CACHE_TEST=false -j8
  ./fc-cache/fc-cache -frv
  popd
fi

### md4c
if [ ! -d "md4c-release-0.5.2" ]; then
  wget https://github.com/mity/md4c/archive/refs/tags/release-0.5.2.tar.gz -O release-0.5.2.tar.gz
  tar xvf release-0.5.2.tar.gz
  pushd md4c-release-0.5.2
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_PREFIX_PATH="$prefix" -Bbuild -DCMAKE_INSTALL_PREFIX="$prefix" -DBUILD_SHARED_LIBS=OFF .
  make -Cbuild -j8
  make -Cbuild -j8 install
  popd
fi

### ====== libmng
if [ ! -d "libmng-2.0.3" ]; then
  wget https://downloads.sourceforge.net/project/libmng/libmng-devel/2.0.3/libmng-2.0.3.tar.gz
  tar xvf libmng-2.0.3.tar.gz
  pushd libmng-2.0.3
  cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -Bbuild -DMNG_INSTALL_LIB_DIR=lib -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH="$HOME/static/out" -DCMAKE_INSTALL_PREFIX="$HOME/static/out" .
  make -Cbuild -j8
  make -Cbuild -j8 install
  popd
fi
cp patches/libmng.pc.patch "$prefix/lib/pkgconfig/libmng.pc"

### libevent
if [ ! -d "libevent" ]; then
  wget https://github.com/libevent/libevent/archive/refs/tags/release-2.1.12-stable.tar.gz -O release-2.1.12-stable.tar.gz
  tar xvf release-2.1.12-stable.tar.gz
  pushd libevent-release-2.1.12-stable
  ./autogen.sh
  ./configure --disable-dependency-tracking --disable-debug-mode --prefix="$prefix" --enable-static --disable-shared
  make install -j8
  popd
fi

sudo chmod -R 774 out/ || true
python3 fix_pkgconfigs.py


# git clone https://github.com/protocolbuffers/protobuf --branch v28.0 --depth 1 --recursive
# patch to enforce c++17
# cp ../patches/protobuf_cmake.patch CMakeLists.txt
# cmake -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH="$HOME/static/out" -DCMAKE_INSTALL_PREFIX="$HOME/static/out" -Dprotobuf_BUILD_TESTS=OFF -Bbuild .
# make -Cbuild -j8
# make -Cbuild -j8 install

# wget https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz -O gettext-0.22.5.tar.gz
# tar xvf gettext-0.22.5.tar.gz
# pushd gettext-0.22.5
# ./configure --prefix="$HOME/static/out" --disable-shared --enable-static --disable-silent-rules --disable-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --disable-java --with-included-gettext --disable-csharp --without-git --without-cvs --without-xz
# make -j8
# make install
# popd
