#!/usr/bin/env python3
"""Export Lucas Chess app icon PNGs from embedded Iconos.bin for .icns generation."""

import argparse
import os
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description="Export app icon PNG sizes for macOS .icns")
    parser.add_argument("output_dir", help="Directory to write icon_*.png files")
    args = parser.parse_args()

    bin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    os.chdir(bin_dir)
    sys.argv[0] = os.path.join(bin_dir, "LucasR.py")
    sys.path.insert(0, bin_dir)

    import Code  # noqa: F401
    from PySide6 import QtGui, QtWidgets
    from Code.QT import Iconos, IconosBase

    _app = QtWidgets.QApplication([])
    IconosBase.icons.reset(IconosBase.icons.NORMAL)
    pm = Iconos.pmAplicacion64()
    if pm.isNull():
        print("Failed to load Aplicacion64 icon", file=sys.stderr)
        return 1

    os.makedirs(args.output_dir, exist_ok=True)
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    for size in sizes:
        scaled = pm.scaled(size, size)
        path = os.path.join(args.output_dir, f"icon_{size}x{size}.png")
        if not scaled.save(path, "PNG"):
            print(f"Failed to write {path}", file=sys.stderr)
            return 1
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
