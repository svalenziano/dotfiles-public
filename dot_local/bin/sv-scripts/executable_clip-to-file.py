#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pillow",
# ]
# ///
"""

PasteImg: save the clipboard image to a file.

Usage examples

```
# IF RASTER is in clipboard: auto-saves png to ~/Downloads
# IF SVG is in clipboard: auto-saves an svg to ~/Downloads
clip-to-file.py  
```

```
# specify directory AND filename
clip-to-file.py --svg ./cool-picture.svg
```
"""

import argparse
import os
import random
import re
import shutil
import subprocess
import sys

from PIL import Image, ImageGrab

# Removed 'ico' from set until size error can be caught
IMG_TYPES = {"png", "bmp", "jpg", "jpeg", "tiff"}

SAVE_PATH = "~/Downloads"

# Dark Reader (browser extension) injects these when SVG is copied from the DOM
DARKREADER_ATTR = re.compile(r'\s*data-darkreader-[\w-]*="[^"]*"')
DARKREADER_DECL = re.compile(r'\s*--darkreader-[^;"]*;?')
EMPTY_STYLE = re.compile(r'\s*style="\s*"')


def _xclip(target):
    """Return the clipboard contents for an X selection target, or b''."""
    result = subprocess.run(
        ["xclip", "-selection", "clipboard", "-t", target, "-o"],
        capture_output=True,
    )
    return result.stdout if result.returncode == 0 else b""


def get_clipboard_svg():
    """Return cleaned SVG from the clipboard (image/svg+xml target or SVG markup
    copied as text), or None if no SVG is available. Strips Dark Reader cruft."""
    if shutil.which("xclip") is None:
        return None

    data = _xclip("image/svg+xml")
    text = data.decode("utf-8", "replace") if data else ""
    if "<svg" not in text.lower():
        text = (_xclip("UTF8_STRING") or _xclip("text/plain")).decode("utf-8", "replace")
    if "<svg" not in text.lower():
        return None

    # Trim to the SVG document, dropping stray text from a DOM copy
    starts = [i for i in (text.lower().find("<svg"), text.find("<?xml")) if i != -1]
    start = min(starts)
    end = text.lower().rfind("</svg>")
    text = text[start:end + len("</svg>")] if end != -1 else text[start:]

    # Strip Dark Reader cruft
    text = DARKREADER_ATTR.sub("", text)
    text = DARKREADER_DECL.sub("", text)
    text = EMPTY_STYLE.sub("", text)
    return text


def write_svg(filename, text):
    """Write SVG text to file."""
    print(f"Saving clipboard image to file (svg): {filename}")
    with open(filename, "w", encoding="utf-8") as f:
        f.write(text)


def grab_raster():
    """Return a clipboard bitmap as a PIL Image, or None. grabclipboard() raises
    UnidentifiedImageError on Linux when the clipboard holds non-image data."""
    try:
        img = ImageGrab.grabclipboard()
    except (OSError, ValueError):
        return None
    return img if isinstance(img, Image.Image) else None

def main():
    parser = argparse.ArgumentParser(description="PasteImg: Output clipboard to file")
    parser.add_argument("filename", nargs="?", default="", help="filename to use")
    parser.add_argument(
        "--svg",
        action="store_true",
        help="save SVG from the clipboard (image/svg+xml target, or SVG markup copied as text)",
    )
    parser.add_argument("-v", "--version", action="version", version="%(prog)s 0.5")
    args = parser.parse_args()

    filename = args.filename
    if not filename:
        name = "".join(random.choice("0123456789abcdef") for _ in range(12))
        save_dir = os.path.expanduser(SAVE_PATH)
        os.makedirs(save_dir, exist_ok=True)
        filename = os.path.join(save_dir, name)

    # Split filename suffix
    shortname, extension = os.path.splitext(filename)
    ext = extension.lstrip(".").lower()

    # SVG mode: explicit --svg flag or a .svg filename
    if args.svg or ext == "svg":
        if shutil.which("xclip") is None:
            sys.exit("Error: --svg requires 'xclip' (X11).")
        if ext == "":
            filename = f"{shortname}.svg"
        elif ext != "svg":
            sys.exit(f"Error: --svg conflicts with extension '{extension}'")
        svg = get_clipboard_svg()
        if svg is None:
            sys.exit("No SVG on the clipboard! (copy SVG markup or from Excalidraw/Inkscape)")
        write_svg(filename, svg)
        return

    img = grab_raster()

    if ext in IMG_TYPES:
        # Explicit raster extension
        if img is None:
            sys.exit("No image available!")
        # Pillow recognises 'jpeg', not 'jpg', as the format
        fmt = "jpeg" if ext == "jpg" else ext
        print(f"Saving clipboard image to file ({fmt}): {filename}")
        img.save(filename, fmt.upper())
        return

    if ext == "":
        # Auto-detect: prefer a raster bitmap, else fall back to SVG
        if img is not None:
            filename = f"{shortname}.png"
            print(f"Saving clipboard image to file (png): {filename}")
            img.save(filename, "PNG")
            return
        svg = get_clipboard_svg()
        if svg is not None:
            write_svg(f"{shortname}.svg", svg)
            return
        sys.exit("No image available!")

    sys.exit(f"Error: Unknown file extension '{extension}'")


if __name__ == "__main__":
    main()
