#!/usr/bin/python

import os
import sys
import re
import subprocess

packages = []
casks = []
brewData = open("Brewfile", "r").readlines()
for command in brewData:
    if (len(command.strip()) == 0):
        continue
    if (command.strip()[0] == "#"):
        continue
    if (command.strip().startswith("brew '")):
        pkg = re.match(r"brew '([^']*)'", command)
        packages.append(pkg.group(1))
    elif (command.strip().startswith("cask '")):
        cask = re.match(r"cask '([^']*)'", command)
        casks.append(cask.group(1))


deps = subprocess.check_output(["/usr/local/bin/brew", "deps", "--union"] + packages)

erred = False
for dep in deps.split("\n"):
    if dep == "python":
        sys.stderr.write("WARNING: this Brewfile will result in Homebrew Python.\n")
        erred = True

FNULL = open(os.devnull, "w")
for pkg in packages:
    infoStatus = subprocess.call(["brew", "info", pkg], stdout=FNULL, stderr=FNULL)
    if (infoStatus != 0):
        sys.stderr.write("WARNING: problematic package: %s\n" % pkg)
        erred = True
for cask in casks:
    infoStatus = subprocess.call(["brew", "cask", "info", cask], stdout=FNULL, stderr=FNULL)
    if (infoStatus != 0):
        sys.stderr.write("WARNING: problematic cask: %s\n" % cask)
        erred = True

if (erred):
    sys.exit(1)

