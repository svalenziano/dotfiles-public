#!/usr/bin/env python3
"""Double the width and height of one or more SVG images, in place.

Usage:
    double-svg.py PATH [PATH ...]

Each PATH may be an SVG file, a directory (walked recursively for *.svg files),
or a shell glob (the shell expands it before this script runs). The list of
files that would change is printed first; nothing is written until you type 'y'.

Only the first <svg ...> opening tag is rewritten:
  * existing width/height attributes are doubled, preserving any unit;
  * if width/height are absent but a viewBox is present, width/height are
    derived from the viewBox's dimensions, doubled, and added.
The viewBox itself is never changed, so artwork scales up with no quality loss.

Standard library only.
"""

import os
import re
import sys
import tempfile

# number, optional unit (px, pt, em, %, ...), captured separately
_DIM_RE_TMPL = (
    r'({attr}\s*=\s*)'           # group 1: attr name + '=' (+ optional spaces)
    r'(["\']?)'                  # group 2: opening quote (may be empty)
    r'\s*([-+]?\d*\.?\d+)'       # group 3: the number
    r'([a-zA-Z%]*)'             # group 4: the unit (may be empty)
    r'\s*\2'                     # closing quote matching group 2
)


def _fmt(value):
    """Format a doubled value without a trailing '.0' for whole numbers."""
    return str(int(value)) if value == int(value) else str(value)


def _double_attr(tag, attr):
    """Double the numeric part of `attr` in `tag`. Returns (new_tag, found)."""
    found = False

    def repl(m):
        nonlocal found
        found = True
        quote = m.group(2)
        doubled = _fmt(float(m.group(3)) * 2)
        return f"{m.group(1)}{quote}{doubled}{m.group(4)}{quote}"

    new_tag = re.sub(_DIM_RE_TMPL.format(attr=attr), repl, tag, count=1)
    return new_tag, found


def rewrite_svg_tag(tag):
    """Return the <svg ...> tag with width/height doubled, or None if unchanged."""
    new_tag, has_w = _double_attr(tag, "width")
    new_tag, has_h = _double_attr(new_tag, "height")

    if has_w and has_h:
        return new_tag

    # Missing one or both dimensions: try to derive from the viewBox.
    vb = re.search(
        r'viewBox\s*=\s*["\']?\s*'
        r'[-+]?\d*\.?\d+[,\s]+[-+]?\d*\.?\d+[,\s]+'
        r'([-+]?\d*\.?\d+)[,\s]+([-+]?\d*\.?\d+)',
        tag,
    )
    if not vb:
        return new_tag if (has_w or has_h) else None

    inject = []
    if not has_w:
        inject.append(f'width="{_fmt(float(vb.group(1)) * 2)}"')
    if not has_h:
        inject.append(f'height="{_fmt(float(vb.group(2)) * 2)}"')

    # Insert the new attribute(s) right after "<svg".
    return re.sub(r'(<svg\b)', r'\1 ' + " ".join(inject), new_tag, count=1)


def transform(text):
    """Return SVG text with the first <svg> tag's dimensions doubled, or None."""
    m = re.search(r'<svg\b[^>]*>', text, re.DOTALL)
    if not m:
        return None
    new_tag = rewrite_svg_tag(m.group(0))
    if new_tag is None or new_tag == m.group(0):
        return None
    return text[:m.start()] + new_tag + text[m.end():]


def collect_files(args):
    """Expand args (files, dirs, unmatched globs) into a deduped file list."""
    files = []
    seen = set()

    def add(path):
        key = os.path.abspath(path)
        if key not in seen:
            seen.add(key)
            files.append(path)

    for arg in args:
        if os.path.isdir(arg):
            for root, _dirs, names in os.walk(arg):
                for name in sorted(names):
                    if name.lower().endswith(".svg"):
                        add(os.path.join(root, name))
        elif os.path.isfile(arg):
            add(arg)
        else:
            print(f"skip: '{arg}' is not a file or directory", file=sys.stderr)
    return files


def main(argv):
    if not argv:
        print("Usage: double-svg.py PATH [PATH ...]", file=sys.stderr)
        return 2

    candidates = collect_files(argv)

    # Keep only files that actually contain an <svg> tag.
    targets = []
    for path in candidates:
        try:
            with open(path, "r", encoding="utf-8") as fh:
                if "<svg" in fh.read():
                    targets.append(path)
                else:
                    print(f"skip: '{path}' does not look like an SVG",
                          file=sys.stderr)
        except (OSError, UnicodeDecodeError) as err:
            print(f"skip: '{path}' could not be read ({err})", file=sys.stderr)

    if not targets:
        print("No SVG files to modify.", file=sys.stderr)
        return 1

    print("The following files will be modified in place:")
    for path in targets:
        print(f"  {path}")

    try:
        answer = input("Type 'y' to proceed: ").strip()
    except EOFError:
        answer = ""
    if answer not in ("y", "Y"):
        print("Aborted.")
        return 0

    for path in targets:
        with open(path, "r", encoding="utf-8") as fh:
            text = fh.read()
        new_text = transform(text)
        if new_text is None:
            print(f"unchanged: {path} (no width/height or viewBox to double)")
            continue
        directory = os.path.dirname(os.path.abspath(path))
        fd, tmp = tempfile.mkstemp(dir=directory, suffix=".svg")
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as out:
                out.write(new_text)
            os.replace(tmp, path)
        except BaseException:
            if os.path.exists(tmp):
                os.unlink(tmp)
            raise
        print(f"updated: {path}")

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
