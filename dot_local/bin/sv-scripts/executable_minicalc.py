#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "rich",
# ]
# ///
"""minicalc - a calculator that ignores words. Run with -h for the help page."""

import ast
import operator
import os
import re
import shutil
import subprocess
import sys

from rich.console import Console

# Everything minicalc says is blue; the only plain text is what the user types.
# Markup is off because we echo user input back, and highlight is off so rich
# doesn't recolor the numbers.
console = Console(highlight=False, markup=False, soft_wrap=True)
errs = Console(stderr=True, highlight=False, markup=False, soft_wrap=True)


def out(text="", console=console):
    console.print(text, style="blue")


HELP = """CAUTION: WRITTEN BY CLAUDE, NOT YET PROOFED / BATTLE-TESTED

minicalc - a calculator that ignores words.

Type math with units, labels, or currency mixed in. Anything that isn't a
number or an operator is discarded, then the arithmetic is evaluated.

    > 100 liters / 5 containers
    100 liters / 5 containers = 20
    > $79.8k - $18.9k
    $79.8k - $18.9k = 60.9

Usage
    minicalc.py                        interactive prompt
    minicalc.py "100 liters / 5 jars"  one-shot
    cat notes.md | minicalc.py         annotate math lines, pass the rest through
    minicalc.py -h, --help             this page

At the prompt
    /c, /copy       copy the last result line to the clipboard
    ans, prev, _    the previous answer
    ?, help         this page
    q, quit, exit   leave

What counts
    operators   + - * / // % **  (or ^)  and  \u00d7 \u00f7 \u2212
    numbers     1200, 1,200 and $1,200 all read as 1200
    comments    everything after  #  or  //  is ignored
    words       discarded, k/M/B included -- "79.8k" is just 79.8

Not supported
    A % touching a digit ("20%"). Percentages are ambiguous, so minicalc
    refuses rather than guessing. For modulo, put spaces around it:  7 % 3"""

OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.Pow: operator.pow,
    ast.Mod: operator.mod,
    ast.FloorDiv: operator.floordiv,
    ast.USub: operator.neg,
    ast.UAdd: operator.pos,
}


class Unsupported(Exception):
    """Syntax minicalc refuses outright rather than quietly mis-reading."""


def strip_comments(s):
    return re.split(r"\s+//|\s+#(?!\d)", s, maxsplit=1)[0]


def normalize(line, last=None):
    s = strip_comments(line)

    # Previous answer.
    if last is not None:
        s = re.sub(
            r"\b(ans|prev)\b|(?<![\w.])_(?![\w.])", repr(last), s, flags=re.IGNORECASE
        )

    # Currency and thousands separators.
    s = re.sub(r"[$€£¥₹]", " ", s)
    s = re.sub(r"(?<=\d),(?=\d{3}\b)", "", s)

    # Words carry no arithmetic meaning -- drop them.
    s = re.sub(r"[A-Za-z_]+", " ", s)

    # Unicode operators and caret exponentiation.
    s = s.replace("×", "*").replace("÷", "/").replace("−", "-")
    s = s.replace("**", "^")

    s = re.sub(r"\s+", " ", s).strip()

    # Drop leading/trailing binary operators, e.g. "total = 5 + 3 +".
    s = re.sub(r"^\s*[*/%^]\s*", "", s)
    s = re.sub(r"\s*[-+*/%^]\s*$", "", s)
    return s.strip().replace("^", "**")


def evaluate(node):
    if isinstance(node, ast.Expression):
        return evaluate(node.body)
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in OPS:
        return OPS[type(node.op)](evaluate(node.left), evaluate(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in OPS:
        return OPS[type(node.op)](evaluate(node.operand))
    raise ValueError("unsupported expression")


def fmt(n):
    if isinstance(n, float):
        if n.is_integer() and abs(n) < 1e15:
            n = int(n)
        else:
            n = round(n, 10)
    return f"{n:,}"


def copy(text):
    """Put text on the system clipboard. False if no clipboard tool exists."""
    if os.environ.get("WAYLAND_DISPLAY") and shutil.which("wl-copy"):
        cmd = ["wl-copy"]
    elif shutil.which("xclip"):
        cmd = ["xclip", "-selection", "clipboard"]
    else:
        return False
    subprocess.run(cmd, input=text.encode(), check=False)
    return True


def calc(line, last=None):
    """Return the result, or None if the line isn't arithmetic.

    Raises Unsupported when the line uses syntax we refuse to guess at.
    """
    # "20%" would otherwise be read as modulo and answer something plausible
    # but wrong. A % with space on both sides is an honest modulo, so allow it.
    if re.search(r"\d%|%\d", strip_comments(line)):
        raise Unsupported(
            "`%` signs are not supported. If you meant 'modulo', "
            "separate the `%` character from the digits."
        )
    expr = normalize(line, last)
    if not expr or not re.search(r"\d", expr):
        return None
    try:
        return evaluate(ast.parse(expr, mode="eval"))
    except (
        SyntaxError,
        ValueError,
        TypeError,
        ZeroDivisionError,
        OverflowError,
        RecursionError,
    ):
        return None


def main():
    args = sys.argv[1:]

    if args and args[0] in ("-h", "--help", "help", "?"):
        out(HELP)
        return

    if args:
        try:
            result = calc(" ".join(args))
        except Unsupported as e:
            out(str(e), errs)
            sys.exit(1)
        if result is None:
            out("couldn't parse that", errs)
            sys.exit(1)
        out(f"{' '.join(args)} = {fmt(result)}")
        return

    if not sys.stdin.isatty():
        last = None
        for line in sys.stdin:
            line = line.rstrip("\n")
            try:
                result = calc(line, last)
            except Unsupported:
                result = None
            if result is None:
                out(line)
            else:
                last = result
                out(f"{line} = {fmt(result)}")
        return

    last = None
    last_line = None
    while True:
        try:
            line = console.input("[blue]> [/blue]").strip()
        except (EOFError, KeyboardInterrupt):
            out()
            return
        if line in ("exit", "quit", "q"):
            return
        if not line:
            continue
        if line in ("?", "help", "/h", "/help"):
            out(HELP)
            continue
        if line in ("/c", "/copy"):
            if last_line is None:
                out("  nothing to copy")
            elif copy(last_line):
                out("  copied")
            else:
                out("  no clipboard tool (install xclip or wl-clipboard)")
            continue
        try:
            result = calc(line, last)
        except Unsupported as e:
            out(f"  {e}")
            continue
        if result is None:
            out("  ?")
            continue
        last = result
        last_line = f"{line} = {fmt(result)}"
        out(last_line)


if __name__ == "__main__":
    main()
