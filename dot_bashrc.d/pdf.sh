# Rebuild PDF so that Boox will open it
fixpdf() {
  for f in "$@"; do
    ghostscript -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
      -dEmbedAllFonts=true \
      -dDownsampleColorImages=false \
      -dDownsampleGrayImages=false \
      -dDownsampleMonoImages=false \
      -sOutputFile="${f%.pdf}_fixed.pdf" "$f"
  done
  echo 'Done!'
  echo 'Do `fixpdf_clean` to overwrite original files with *_fixed.pdf files.'
}

checkpdf() {
  for f in *_fixed.pdf; do
    orig="${f%_fixed.pdf}.pdf"

    orig_pages=$(qpdf --show-npages "$orig")
    fixed_pages=$(qpdf --show-npages "$f")
    if [ "$orig_pages" = "$fixed_pages" ]; then
      echo "✓ $orig — page count matches ($orig_pages pages)"
    else
      echo "✗ $orig — page count MISMATCH! original=$orig_pages fixed=$fixed_pages"
    fi

    if diff-pdf "$orig" "$f" 2>/dev/null; then
      echo "✓ $orig — visual diff identical"
    else
      echo "⚠  $orig — visual differences detected, review manually"
      diff-pdf --output-diff="${f%_fixed.pdf}_diff.pdf" "$orig" "$f"
      echo "  Diff saved to ${f%_fixed.pdf}_diff.pdf"
    fi
    echo ""
  done
}

fixpdf_clean() {
  echo 'Preview replacement:'
  for f in *_fixed.pdf; do
    echo "  mv $f -> ${f%_fixed.pdf}.pdf"
  done
  
  read -p "Proceed? (y/n) " answer
  
  if [ "$answer" = "y" ]; then
    for f in *_fixed.pdf; do
      mv "$f" "${f%_fixed.pdf}.pdf"
    done
    echo 'Done!'
  else
    echo 'Cancelled.'
  fi
}







