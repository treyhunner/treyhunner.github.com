---
layout: post
title: tmuxstart
type: post
published: true
comments: true
---

I've been using a helper script to manage all of my tmux sessions for the last
few months (nearly since the time I switched from screen to tmux).

### A tmuxinator alternative

I use a separate session for each project I work on and I wanted a way to
easily connect to project sessions with the same default windows and
environment variables each time.  I tried using [tmuxinator][], but I found it
to be too complicated for my needs.  I had trouble working within the
limitations of the yaml files and I found the installation to be overly
complicated (especially when working on a new server that didn't have ruby
installed).  After I realized how simple it would be to solve my own problem I
made the tmuxstart script.


### Now available on Github

While updating my [dotfiles][] repository I realized I hadn't yet incorporated
my tmuxstart workflow into my `.tmux.conf` file.  Yesterday I decided to make
README and LICENSE files for my script and put it under version control.  I
also added some helper functions to make the script even easier to use.  It's
now available in my [tmuxstart][] repository on Github.


### Example usage

Below is an example of how to use tmuxstart.

1. Add the following line to your `~/.tmux.conf` file:
```
    bind S command-prompt -p "Make/attach session:" "new-window 'tmuxstart \'%%\''"
```

2. Create a `~/.tmuxstart` directory:
```
    mkdir ~/.tmuxstart
```

3. Create a file `~/.tmuxstart/main` with the following contents:
```
    new_session htop
    new_window
```

Now you can create a tmux session called "main" with [htop][] in the first
window and a shell in the second window by executing:

    tmuxstart main

Or from an existing tmux server type `<PREFIX> S` (``<PREFIX>`` is Ctrl-B by
default), type ``main`` and hit Enter.

When using either of these methods if a session called "main" already exists
the existing session will be used instead.


### How I use this

I have a separate tmuxstart session file for each of my Django projects and
some of my open source projects also.  I use a "main" session file similar to
the one above and I have Gnome Terminal set to start with the custom command
"tmuxstart main" instead of a shell.

[tmuxstart]: https://github.com/treyhunner/tmuxstart
[dotfiles]: https://github.com/treyhunner/dotfiles
[tmuxinator]: https://github.com/aziz/tmuxinator
[htop]: http://htop.sourceforge.net/
