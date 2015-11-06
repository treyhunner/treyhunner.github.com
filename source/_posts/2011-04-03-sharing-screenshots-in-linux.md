---
layout: post
title: Sharing Screenshots in Linux
type: post
published: true
comments: true
categories: linux
---
I have been using Github Issues recently and loving its simplicity.  Unfortunately, I've found that I often need to upload screenshots to demonstrate bugs and Issues does not support file uploads.  There are [Windows][screengrabber] and [Mac][cloudapp] applications that solve this problem by capturing a screenshot, uploading it, and copying a URL to access the screenshot to the clipboard.

I did not find any Linux applications that will capture/upload a screenshot and copy the URL but I discovered [a thread in the Dropbox forums][dropbox script] with a script that does just that.  I added comments to the script, changed the variable names, removed the need for a temporary file, and added a `notify-send` call as a visual cue (should work on Ubuntu).  I have the script mapped to <kbd>Ctrl-PrtScrn</kbd> in Ubuntu.

{% gist 892492 %}

[screengrabber]: http://wiki.dropbox.com/DropboxAddons/DropboxScreenGrabber
[cloudapp]: http://www.getcloudapp.com/
[dropbox script]: http://forums.dropbox.com/topic.php?id=21735
