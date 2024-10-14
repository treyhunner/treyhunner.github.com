---
layout: post
title: "Django and the new Python 3.13 REPL"
date: 2024-10-13 21:03:32 -0700
comments: true
categories: python django
---

Your new Django project uses Python 3.13.

You're really looking forward to using the new REPL... but `python manage.py shell` just shows the same old Python REPL.
What gives?

Well, Django's management shell uses Python's `code` module to launch a custom REPL, but the `code` module doesn't ([yet](https://github.com/python/cpython/issues/119512)) use the new Python REPL.

So you're out of luck... or are you?


## How stable do you need your `shell` command to be?

The new Python REPL's code lives in a `_pyrepl` package.
Surely there must be some way to launch the new REPL using that `_pyrepl` package!

First, note the `_` before that package name.
It's `_pyrepl`, not `pyrepl`.

Any solution that relies on this module may break in future Python releases.

So... should we give up on looking for a solution, if we can't get a "stable" one?

I don't think so.

My `shell` command doesn't usually *need* to be stable in more than one version of Python at a time.
So I'm fine with a solution that *attempts* to use the new REPL and then falls back to the old REPL if it fails.


## A working solution

So, let's look at a working solution.

Stick this code in a `management/commands/shell.py` file within one of your Django apps:

```python
"""Python 3.13 REPL support using the unsupported _pyrepl module."""
from django.core.management.commands.shell import Command as BaseShellCommand


class Command(BaseShellCommand):
    shells = ["ipython", "bpython", "pyrepl", "python"]

    def pyrepl(self, options):
        from _pyrepl.main import interactive_console
        interactive_console()
```


## How it works

Django's `shell` command has made it very simple to add support for your favorite REPL of choice.

[The code for the `shell` command](https://github.com/django/django/blob/5.1.2/django/core/management/commands/shell.py) loops through the `shells` list and attempts to run a method with that name on its own class.
If an `ImportError` is raised then it attempts the next command, stopping once no exception occurs.

Our new command will try to use IPython and bpython if they're installed and then it will try the new Python 3.13 REPL followed by the old Python REPL.

If Python 3.14 breaks our import by moving the `interactive_console` function, then an `ImportError` will be raised, causing us to fall back to the old REPL after we upgrade to Python 3.14 one day.
If instead, the `interactive_console` function's usage changes (maybe it will require arguments) then our `shell` command will completely break and we'll need to manually fix it when we upgrade to Python 3.14.


## What's so great about the new REPL?

If you're already using IPython or BPython as your REPL and you're enjoying them, I would stick with them.

Third-party libraries move faster than Python itself and they're often more feature-rich.
IPython has about 20 years worth of feature development and it has features that the built-in Python REPL will likely never have.

If you're using the default Python REPL though, this new REPL is a *huge* upgrade.
I've been using it as my default REPL since May and I *love* it.
See [my screencast on Python 3.13](https://pym.dev/python-313-whats-new/) for my favorite features in the new REPL.
