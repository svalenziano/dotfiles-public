---
keywords: keyboard shortcuts, hotkeys, Lenovo p51, ubuntu
---

This file is a placeholder.  I was unable to map p51 `Fn` key to anything, since it seems like the keyboard firmware is intercepting keypresses in a way that they can't be remapped in the OS.

Things I tried:
xev -event keyboard | grep -oE 'keysym 0x[0-9a-f]+, [A-Za-z_]+'
sudo evtest /dev/input/event3
sudo evtest /dev/input/event6

All of the above tests resulted in NO OUTPUT for Fn+Left, Fn+Right, Fn+Up, Fn+Down.
