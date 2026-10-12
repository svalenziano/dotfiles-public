#!/usr/bin/env bash
#
# convert-basecamp.sh — Convert Basecamp HTML export files to clean Markdown.
#
# Recursively finds every *.html file under the target directory, lists them,
# warns that they will be converted and the originals DELETED, and (on
# confirmation) writes a sibling *.md for each and removes the *.html.
#
# Relative attachment references (e.g. ./../../Attachments/foo.png) are
# preserved, so the .md files keep working in place of the .html files.
#
# Conversion pipeline:
#   sed 's#<h1 class="title">...</h1>##'
#                    strips Basecamp's redundant page-title heading (the
#                    class is lost in Markdown, so it must be removed here).
#   pandoc -t gfm-raw_html
#                    drops Basecamp's <div class="wrapper/formatted_content">
#                    and <a class="autolinked"> wrappers instead of leaving
#                    them as raw HTML, and emits real Markdown links/images.
#   sed 's/\\$//'    removes trailing "\" hard-break artifacts (and the stray
#                    "\" lines left by empty <br> spacer divs).
#   sed '/./,$!d'    trims leading blank lines so files start at content.
#   cat -s           collapses runs of blank lines.
#
# Usage:
#   ./convert-basecamp.sh [TARGET_DIR]
#
# TARGET_DIR defaults to the current directory.

set -euo pipefail

target="${1:-.}"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc is not installed (e.g. 'sudo apt install pandoc')." >&2
  exit 1
fi

if [ ! -d "$target" ]; then
  echo "Error: '$target' is not a directory." >&2
  exit 1
fi

# Collect the HTML files that will be converted.
files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find "$target" -type f -name '*.html' -print0)

if [ "${#files[@]}" -eq 0 ]; then
  echo "No .html files found under '$target'. Nothing to do."
  exit 0
fi

# (1) List the files that will be converted.
echo "The following ${#files[@]} HTML file(s) will be converted:"
for f in "${files[@]}"; do
  echo "  $f"
done

# (2) Warn the user.
echo
echo "Each file above will be converted from HTML to Markdown (.md)."
echo "Any existing .md file will be overwritten. The original .html files are kept."
echo

# (3) Require explicit confirmation.
read -r -p "Continue? [y/N] " reply
if [ "$reply" != "y" ] && [ "$reply" != "Y" ]; then
  echo "Aborted. No files were changed."
  exit 0
fi

count=0
for f in "${files[@]}"; do
  # Strip the redundant <h1 class="title"> before converting, then clean up.
  sed 's#<h1 class="title">[^<]*</h1>##' "$f" \
    | pandoc -f html -t gfm-raw_html --wrap=none \
    | sed 's/[[:space:]]*\\$//' \
    | sed '/./,$!d' \
    | cat -s > "${f%.html}.md"
  echo "  converted: ${f%.html}.md"
  count=$((count + 1))
done

echo "Done. Converted $count file(s). Original .html files were kept."
echo
echo "To delete the .html originals when you're ready:"
echo "  fd -e html . \"$target\" -X rm     # list them first with: fd -e html . \"$target\""
echo "  # no fd? use: find \"$target\" -name '*.html' -delete"
