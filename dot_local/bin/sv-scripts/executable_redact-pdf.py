#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pymupdf",
#     "rich",
# ]
# ///

import re
from pathlib import Path
import sys

import pymupdf
from rich import print

import private_redact_config

in_dir = Path(private_redact_config.IN_DIR).expanduser()
out_dir = Path(private_redact_config.OUT_DIR).expanduser()

for d in (in_dir, out_dir):                                             
    if not d.is_dir():                                                    
        sys.exit(f"Directory not found: {d}") 

words_to_redact = private_redact_config.WORDS_TO_REDACT


regexes_to_redact = private_redact_config.REGEXES_TO_REDACT

pdf_files = list(in_dir.glob("*.pdf"))

print(f"[green]{len(pdf_files)} files found in {in_dir}[/green]")  
for fname in pdf_files:
    print(f"> '{fname}'")



for file in pdf_files:
    count = 0
    doc = pymupdf.Document(file)
    doc_words = words_to_redact.copy()

    for item in regexes_to_redact:
        for page in doc:
            for line in page.get_text("text").split('\n'):
                m = re.search(item, line, re.IGNORECASE)
                if m:
                    doc_words.append(m.group(0))

    # redaction method - search for each word within each page by document
    for page in doc:
        for word in doc_words:
            found = page.search_for(word)
            for f in found:
                page.add_redact_annot(f, fill=(0, 0, 0))
                count += 1
        page.apply_redactions()

    print(f"👍 Redacted {count} items from " + file.name)

    doc.save(out_dir / file.name, incremental=False, garbage=4, deflate=True)
    doc.scrub()
    doc.close()

print("\nSuccessfully redacted " + str(len(pdf_files)) + " files")