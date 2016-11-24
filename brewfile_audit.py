import sys
import re
import subprocess

packages = []
brewData = open("Brewfile", "r").readlines()
for command in brewData:
    if (len(command.strip()) == 0):
        continue
    if (command.strip()[0] == "#"):
        continue
    if (command.strip().startswith("brew '")):
        pkg = re.match(r"brew '([^']*)'", command)
        packages.append(pkg.group(1))


deps = subprocess.check_output(["/usr/local/bin/brew", "deps", "--union"] + packages)

for dep in deps.split("\n"):
    if dep == "python":
        sys.stderr.write("WARNING: this Brewfile will result in Homebrew Python.\n")
        sys.exit(1)
