# https://sw.kovidgoyal.net/kitty/binary/
set -e  # abort immediately if an error occurs

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# Add kitty and kitten to PATH (assumes ~/.local/bin is in your system-wide PATH)
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/

# Desktop integration
# https://sw.kovidgoyal.net/kitty/binary/#desktop-integration-on-linux
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

# Fix icon and executable paths in desktop files
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

# Set kitty as the default terminal for desktop environments that support xdg-terminal-exec
echo 'kitty.desktop' > ~/.config/xdg-terminals.list

echo "Kitty successfully installed!"