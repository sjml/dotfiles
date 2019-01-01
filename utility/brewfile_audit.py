#!/usr/bin/env python2

import os
import sys
import re
import json
import subprocess

os.chdir(os.path.dirname(os.path.abspath(__file__)))

DEEP_DEP_INTERROGATE = False
if ("--deep-deps" in sys.argv):
    DEEP_DEP_INTERROGATE = True

packages = {}
casks = []
brewData = open("../install_lists/Brewfile", "r").readlines()
for command in brewData:
    if (len(command.strip()) == 0):
        continue
    if (command.strip()[0] == "#"):
        continue
    if (command.strip().startswith("brew '")):
        pkg = re.match(r"brew '([^']*)'", command)
        pkgName = pkg.group(1)
        packages[pkgName] = []
        args = re.search(r"args: \[([^\]]*)", command)
        if args:
            opts = args.group(1).split(",")
            opts = map(lambda x: x.replace('"', "").strip(), opts)
            packages[pkgName].extend(opts)
    elif (command.strip().startswith("cask '")):
        cask = re.match(r"cask '([^']*)'", command)
        casks.append(cask.group(1))

erred = False

badDeps = json.load(open("./bad-brew-dependencies.json"))

if (DEEP_DEP_INTERROGATE):
    for badDep in badDeps:
        for pkg in packages.keys():
            pkgDeps = subprocess.check_output(["/usr/local/bin/brew", "deps", pkg]).split("\n")
            if (any([x in pkgDeps for x in badDep["brewDeps"]])):
                sys.stderr.write("WARNING: package %s will result in Homebrew %s\n" % (pkg, badDep["name"]))
else:
    deps = subprocess.check_output(["/usr/local/bin/brew", "deps", "--union"] + packages.keys()).split("\n")
    deps += packages.keys()

    for dep in deps:
        for badDep in badDeps:
            if dep in badDep["brewDeps"]:
                sys.stderr.write("WARNING: this Brewfile will result in Homebrew %s.\n" % badDep["name"])
                erred = True

FNULL = open(os.devnull, "w")
for pkg, args in packages.iteritems():
    try:
        infoStatus = subprocess.check_output(["/usr/local/bin/brew", "info", "--json=v1", pkg])
        if len(args) > 0:
            jinfo = json.loads(infoStatus)
            opts = {x["option"]:x["description"] for x in jinfo[0]["options"]}
            for a in args:
                if "--" + a not in opts.keys():
                    sys.stderr.write("WARNING: invalid option %s for %s\n" % (a, pkg))
                    erred = True
    except subprocess.CalledProcessError as e:
        sys.stderr.write("ERROR: problematic package: %s\n" % pkg)
        erred = True

for cask in casks:
    infoStatus = subprocess.call(["/usr/local/bin/brew", "cask", "info", cask], stdout=FNULL, stderr=FNULL)
    if (infoStatus != 0):
        sys.stderr.write("ERROR: problematic cask: %s\n" % cask)
        erred = True
    else:
        rawCask = subprocess.check_output(["/usr/local/bin/brew", "cask", "cat", cask])
        if "installer manual:" in rawCask:
            sys.stdout.write("INFO: %s cask requires a manual installation step.\n" % cask)

if (erred):
    sys.exit(1)
