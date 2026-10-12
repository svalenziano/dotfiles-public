# Copy all fonts to install em on Ubuntu

cp * ~/.local/share/fonts

# clear font cache
fc-cache -f

# Check for correct install.  Todo: more robust check
fc-match Excalifont
fc-match "Comic Shanns"
fc-match "Lilita One"