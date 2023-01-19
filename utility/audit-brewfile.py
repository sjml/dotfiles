# processes the brewfile and checks it against the public Homebrew API
#   to see if any of the formulae have been dropped.


import os
import sys
import json
import http.client
import re

os.chdir(os.path.dirname(os.path.abspath(__file__)))

brewfile_contents = open("../install_lists/Brewfile", "r").read()

# patterns for things to allow if they're not found in the list (for taps and things)
#   could get fancy and try to follow the taps and see if they're there, but ain't
#   nobody got time for that and I only use a few non-standard taps
allow = [
    r"^font-*",
    r"^sjml/sjml/*",
]

brews = []
casks = []
mapps = []

for line in brewfile_contents.splitlines():
    line = line.strip()
    if len(line) == 0 or line[0] == "#":
        continue
    elements = line.split()
    if elements[0] == "brew":
        brews.append(elements[1][1:-1])
    elif elements[0] == "cask":
        casks.append(elements[1][1:-1])
    elif elements[0] == "mas":
        id = elements[-1]
        app_name = re.findall(r"^mas\s'([^']*)'", line)[0]
        mapps.append([app_name, id])
    else:
        pass
        # print("skipping", elements[0])


def get_url(server, url):
    hc = http.client.HTTPSConnection(server)
    hc.request("GET", url)
    resp = hc.getresponse()
    code = resp.getcode()
    if code != 200:
        raise RuntimeError(f"Could not load remote URL: {url}, status code {code}")
    return resp.read().decode("utf-8")

if not os.path.exists("./formula.json"):
    formulae_json = get_url("formulae.brew.sh", "/api/formula.json")
    with open("./formula.json", "w") as fout:
        fout.write(formulae_json)
else:
    with open("./formula.json", "r") as fin:
        formulae_json = fin.read()

if not os.path.exists("./cask.json"):
    cask_json = get_url("formulae.brew.sh", "/api/cask.json")
    with open("./cask.json", "w") as fout:
        fout.write(cask_json)
else:
    with open("./cask.json", "r") as fin:
        cask_json = fin.read()

formula_list = [f['name'] for f in json.loads(formulae_json)]
cask_list = [c['token'] for c in json.loads(cask_json)]

print(f"🕵️  Checking Brewfile with {len(brews)} formulae and {len(casks)} casks...")

errs = []

def check_allowed(string):
    for r in allow:
        if re.match(r, string):
            return True
    return False

for b in brews:
    if b not in formula_list and not check_allowed(b):
        errs.append(["brew", b])
for c in casks:
    if c not in cask_list and not check_allowed(c):
        errs.append(["cask", c])

print(f"🕵️  Checking {len(mapps)} app listings against the Mac App Store...")
for a in mapps:
    results_json = get_url("itunes.apple.com", f"/lookup?id={a[1]}")
    results = json.loads(results_json)
    if results['resultCount'] == 0:
        errs.append(["mas", a[0]])

print()
if len(errs) == 0:
    print("🎉  Brewfile is legit!")
else:
    print("🙈  Brewfile's got issues.")
    for e in errs:
        print(f"❌  {e[0]} {e[1]}")
    sys.exit(len(errs))
