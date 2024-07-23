#!/usr/bin/env bash

# Takes the Fira Mod files (built from the CI process of https://github.com/sjml/FiraCode)
#   and patches them with the Nerd Font glyphs (https://github.com/ryanoasis/nerd-fonts)


cd "$(dirname "$0")"

OUTPUT_DIR=patched
PATCHER_ZIP=FontPatcher.zip
PATCHER_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${PATCHER_ZIP}"
PATCHER_DIR=patcher
FONTFORGE_EXE=/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge
FONTFORGE_PY=/Applications/FontForge.app/Contents/MacOS/FFPython

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

rm -rf $PATCHER_DIR $PATCHER_ZIP
wget $PATCHER_URL
unzip $PATCHER_ZIP -d $PATCHER_DIR

for ff in *.ttf; do
  $FONTFORGE_EXE -script $PATCHER_DIR/font-patcher $ff \
    --outputdir $OUTPUT_DIR \
    --complete \
    --makegroups 4
done

# working around https://github.com/ryanoasis/nerd-fonts/issues/1679
#  (also renaming from NerdFont -> NF)
for bf in $(ls $OUTPUT_DIR/*.ttf); do
  $FONTFORGE_PY -c "import fontforge; bf = fontforge.open('${bf}'); bf.appendSFNTName('English (US)', 'Preferred Family', 'FiraMod NF'); bf.generate('${bf/NerdFont/NF}'); bf.close()"
done
rm $OUTPUT_DIR/*NerdFont*.ttf

rm -rf $PATCHER_DIR $PATCHER_ZIP
