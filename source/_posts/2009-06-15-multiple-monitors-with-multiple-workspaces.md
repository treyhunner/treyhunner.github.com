---
layout: post
title: Multiple Monitors with Multiple Workspaces
type: post
published: true
comments: true
---
In most window managers (WMs) that allow for multiple workspaces, additional monitors simply increase the size of each workspace. Since January I have been using a window manager that handles multiple monitors very differently, [xmonad][].  Instead of increasing the workspace size to fit onto two monitors, each monitor displays a separate workspace, so the number of visible workspaces is increased.

*Paradigm difference between these two WM styles:*

1. Each additional monitor extends the workspace size
    - One large workspace is visible at a time (ex: workspace 1 spans across all monitors)
    - When the workspace changes, both monitors change
    - When removing a monitor, workspaces must shrink in size, bunching windows together
2. Each additional monitor allows another workspace to be visible
    - Each monitor displays one workspace at a time (ex: monitor 1 currently showing workspace 3 and monitor 2 currently showing workspace 1)
    - When the workspace on one monitor changes the workspace on the other monitor does not need to change
    - When removing a monitor, one less workspace will be displayed

There are many times when I want to be able to keep one monitor static while changing the other monitor.  For example I may want a video to stay on one monitor while I work on the other monitor.  In most window managers this restricts me to one workspace because changing workspaces would change both monitors.  In xmonad, the workspace that contains the video can be placed on one monitor and the visible workspace on the other monitor can changed freely without interfering with the first monitor.

Since using xmonad, I have found "1 workspace per monitor" window management much more productive and comfortable.  I wish more window managers would at least make this kind of workspace/monitor handling an option.  I have had problems with xmonad recently and I have been trying to switch back to a more popular window manager with free-floating windows like Gnome, KDE, Xfce, or Openbox.

So far my biggest problem with switching to other window managers has been the lack of "1 workspace per monitor" support.  Xmonad has greatly increased my productivity with two monitors and it's hard for me to switch away from it for this reason.  Hopefully I will find out how to effectively emulate this behavior in other window managers.

[xmonad]: http://www.xmonad.org/
