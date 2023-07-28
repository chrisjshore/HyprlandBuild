# README

Automated build of a Hyprland VM based on Fedora Sway.

## Dependencies

1. VirtualBox
2. Vagrant
3. Git (optional)

## Building

Clone repo (or download as zip) and change into directory.  Run ``` vagrant up ``` and wait for build to complete, roughly 30 minutes.

## Customizations
I have only included a minimal amount of customizations in order to keep it as close to out-of-the-box as possible.  The two biggest changes are key bindings for closing a window and logging out.  They are more sensible and ergonomic for the user (me).  To revert back to the default behavior, swap the commented lines for *killactive* and *exit* in configs/hypr/hyprland.conf prior to build, or in the VM ~/.config/hypr/hyprland.conf after building.

| From                           | To                                  |
| ------------------------------ | ----------------------------------- |
| bind = $mainMod, C, killactive | bind = $mainMod, Delete, killactive |
| bind = $mainMod, M, exit       | bind = $mainMod_SHIFT, L, exit      |

Also, in hyprland.conf I had to force the monitor resolution to match the VagrantFile resolution.

## Considerations

If you want to rely on (dodgy) DNS, comment out the *echo*'s into /etc/hosts and the *for* loop at the bottom of the provision script.  Expect the build to take twice as long due to timeouts.

If you get an error stating the guest machine entered an invalid state while waiting for it to boot, run ```vagrant provision``` to continue with the build.  If you get a translation missing error at the end of the build, run ```vagrant halt``` then ```vagrant up```.  However, I've had mixed results with this so it is cleaner to run ```vagrant destroy``` to remove the unstable VM then run ```vagrant up``` to build it over again.

