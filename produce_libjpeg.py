import os,sys
from pathlib import Path

prefix = str(Path.cwd()) + "/out"

data=f"""
prefix={prefix}
exec_prefix={prefix}
libdir={prefix}/lib
includedir={prefix}/include

Name: libjpeg
Description: A SIMD-accelerated JPEG codec that provides the libjpeg API
Version: 3.0.3
Libs: -L${{libdir}} -ljpeg
Cflags: -I${{includedir}}
""".strip()

sys.stdout.write(data)
