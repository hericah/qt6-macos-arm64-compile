import os,sys,glob,re
from pathlib import Path

prefix = str(Path.cwd()) + "/out"
d = prefix + "/lib/pkgconfig/"

def write_file(path, data):
    f = open(path, "w")
    f.write(data)
    f.close()

def read_file(path):
    f = open(path, "r")
    data = f.read()
    f.close()
    return data

def _replace(inp: str):
    global prefix
    if inp.endswith("/lib"):
        return prefix + "/lib"
    return prefix

for fn in glob.glob(d + "/*.pc"):
    data = read_file(fn)
    res = re.findall(r"(\/opt\/homebrew\/.*)\n", data)
    if not res:
        continue

    for r in res:
        _r = _replace(r)
        data = data.replace(r, _r)

    write_file(fn, data)
    print("fixed pkgconfig: " + fn)
