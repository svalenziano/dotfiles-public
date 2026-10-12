# https://obsproject.com/download

flatpak install flathub com.obsproject.Studio

# v412loopback is required for Debian/Ubuntu-based distros
# not sure if this step actually worked for SV / or was necessary for my needs
sudo apt update && sudo apt install v4l2loopback-dkms