#!/Applications/FontForge.app/Contents/MacOS/FFPython

# Uses FontForge to remove the ligature tables from Fira Code

import os
import sys

import fontforge

BASE_FONT_NAME = "FiraCode"
MODDED_NAME = "FiraMod"
FONT_DIR = os.path.expanduser("~/Library/Fonts")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "resources", MODDED_NAME)

swaps = [
    (BASE_FONT_NAME, MODDED_NAME),
    ("Fira Code", "Fira Mod")
]

base_fonts = [f for f in os.listdir(FONT_DIR) if f.startswith(BASE_FONT_NAME)]

for base in base_fonts:
    bf = fontforge.open(os.path.join(FONT_DIR, base))

    for lookup in bf.gsub_lookups:
        bf.removeLookup(lookup)

    for attr_name in ["familyname", "fullname", "fontname"]:
        attr = getattr(bf, attr_name)
        modattr = attr
        for s in swaps:
            modattr = modattr.replace(s[0], s[1])
        setattr(bf, attr_name, modattr)

    new_names = []
    for entry in bf.sfnt_names:
        if "Copyright" in entry[1]:
            continue
        mod_entry_str = entry[2]
        for s in swaps:
            mod_entry_str = mod_entry_str.replace(s[0], s[1])

        new_names.append((entry[0], entry[1], mod_entry_str))

    # FontForge seems to mess up certain fields if pulling direct from ttf
    #    https://github.com/fontforge/fontforge/issues/3130
    bf.generate(os.path.join(OUTPUT_DIR, base.replace(".ttf", ".sfd")))
    bf.close()
    bf = fontforge.open(os.path.join(OUTPUT_DIR, base.replace(".ttf", ".sfd")))
    os.remove(os.path.join(OUTPUT_DIR, base.replace(".ttf", ".sfd")))
    os.remove(os.path.join(OUTPUT_DIR, base.replace(".ttf", ".afm")))

    for n in new_names:
        # "append" will also replace an entry
        bf.appendSFNTName(*n)

    bf.generate(os.path.join(OUTPUT_DIR, base.replace(BASE_FONT_NAME, MODDED_NAME)))
    bf.close()
