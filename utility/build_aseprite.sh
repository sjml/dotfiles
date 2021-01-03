#!/bin/bash

# Aseprite costs money, but you can compile it for free. I am poor, so I compile it.
# To get it to work well on the Mac, you need to download the trial version and copy
# the compiled executable into it. This script automates all of that except for the
# download itself. It also requires cmake and ninja to already be installed.

APP_PATH="/Applications/Aseprite.app"
VERSION="1.2.25"
GIT_COMMIT="f44aad06db9d7a7efe9beb0038df37140ac9c2ba"
SKIA_BRANCH="aseprite-m81"

python --version 2>&1 | grep "Python 2"
if [ $? -ne 0 ]; then
  echo "<sigh>"
  echo "Because of reasons, you need to make sure the \"python\" command"
  echo "points to Python 2. Set your path and try again."
  exit 1
fi

if [ ! -d "$APP_PATH" ]; then
  echo "First, install the trial version of Aseprite. https://www.aseprite.org/trial/."
  echo "(If it's not version $VERSION, this script might need to be updated.)"
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

set -e

mkdir -p temp-aseprite
cd temp-aseprite

git clone --no-checkout https://github.com/aseprite/aseprite.git
cd aseprite
git checkout $GIT_COMMIT
git submodule update --init --recursive
mkdir deps
cd deps
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
git clone -b $SKIA_BRANCH https://github.com/aseprite/skia.git
export PATH="${PWD}/depot_tools:${PATH}"
cd skia
python tools/git-sync-deps
gn gen out/Release --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false target_cpu=\"x64\" extra_cflags=[\"-stdlib=libc++\", \"-mmacosx-version-min=10.9\"] extra_cflags_cc=[\"-frtti\"]"
ninja -C out/Release skia modules

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
  -DSKIA_LIBRARY_DIR="${PWD}/../deps/skia/out/Release" \
  -G Ninja \
  ..
ninja aseprite

cp bin/aseprite "$APP_PATH/Contents/MacOS"
cp -R bin/data "$APP_PATH/Contents/Resources"

cd ../../..
rm -rf temp-aseprite

# don't *need* to do this, per se
xattr -dr com.apple.quarantine $APP_PATH

echo
echo "The bundle at $APP_PATH has been patched."
