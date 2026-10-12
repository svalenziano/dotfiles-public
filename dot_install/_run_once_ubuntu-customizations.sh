
# 'nautilus' (files explorer) shortcut to copy the path of the selected file
mkdir -p ~/.local/share/nautilus/scripts
echo '#!/bin/bash
echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | xclip -selection clipboard' \
> ~/.local/share/nautilus/scripts/copy-path
chmod +x ~/.local/share/nautilus/scripts/copy-path

# disable middle-click paste
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste false

# disable hover-to-focus                          
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'

# adjust two-finger scroll
# sounds difficult - every solution sounds a bit hacky
    # imwheel
    # libinput quirks file
    # GNOME extension