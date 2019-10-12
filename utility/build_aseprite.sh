#!/bin/bash

# Aseprite costs money, but you can compile it for free. I am poor, so I compile it.
# To get it to work well on the Mac, you need to download the trial version and copy
# the compiled executable into it. This script automates all of that except for the
# download itself. It also requires cmake and ninja to already be installed.

APP_PATH="/Applications/Aseprite.app"
VERSION="1.2.15"
GIT_COMMIT="2c9fe857487c940a8d08adc7de5c62fde3d49a24"

if [ ! -d "$APP_PATH" ]; then
  echo "First, install the trial version of Aseprite. https://www.aseprite.org/trial/."
  echo "(If it's not 1.2.15, this might need to be updated.)"
  exit 1
fi

hash cmake 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Need cmake."
  exit 1
fi
hash ninja 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Need ninja."
  exit 1
fi


mkdir -p temp-aseprite
cd temp-aseprite

git clone --recursive https://github.com/aseprite/aseprite.git
cd aseprite
git checkout $GIT_COMMIT
mkdir deps
cd deps
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
git clone -b aseprite-m71 https://github.com/aseprite/skia.git
export PATH="${PWD}/depot_tools:${PATH}"
cd skia
python tools/git-sync-deps
gn gen out/Release --args="is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_libjpeg_turbo=false skia_use_system_libpng=false skia_use_libwebp=false skia_use_system_zlib=false extra_cflags_cc=[\"-frtti\"]"
ninja -C out/Release skia

cd ../..
mkdir build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -DLAF_OS_BACKEND=skia \
  -DSKIA_DIR="${PWD}/../deps/skia" \
  -DSKIA_OUT_DIR="${PWD}/../deps/skia/out/Release" \
  -G Ninja \
  ..
ninja aseprite

cp bin/aseprite "$APP_PATH/Contents/MacOS"
cp -R bin/data "$APP_PATH/Contents/Resources"

cd ../../..
rm -rf temp-aseprite

echo
echo "The .app bundle in /Applications has been patched."
