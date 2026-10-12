# This script created based on these install instructions:
# https://espanso.org/docs/install/linux/#find-the-right-version

# check to see if X11 or Wayland
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
  echo "espanso install script only works for x11, not Wayland"
  exit 1
fi

cd "$(mktemp -d)" || exit 1

wget https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb
sudo apt install ./espanso-debian-x11-amd64.deb

# verify correct install
espanso --version

# Register espanso as a systemd service (required only once)
espanso service register

# Start espanso
espanso start
