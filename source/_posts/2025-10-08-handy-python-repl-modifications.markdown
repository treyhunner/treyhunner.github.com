---
layout: post
title: "Handy Python REPL Modifications"
date: 2025-10-08 19:59:20 -0700
comments: true
categories: python repl
---

I find myself in the Python REPL *a lot*.

I open up the REPL to play with an idea, to use Python as a calculator or quick and dirty text parsing tool, to record a screencast, to come up with a code example for an article, and (most importantly for me) to teach Python.
My Python courses and workshops are based largely around writing code together to guess how something works, try it out, and repeat.
If you spend time in the Python REPL and wish it behaved a little more **like your favorite editor**, these tricks might help.

As I've written about before, you can [add custom keyboard shortcuts][shortcuts] to the new Python REPL (since 3.13) and [customize the REPL syntax highlighting][colors] (since 3.14).

I have added **custom keyboard shortcuts** to my REPL and other modifications to help me **more quickly write and edit code in my REPL**.
I'd like to share some of the modifications that I've found helpful in my own Python REPL.


## Creating a PYTHONSTARTUP file

If you want to run Python code every time an interactive prompt starts, you can make a PYTHONSTARTUP file.

When Python launches an interactive prompt, it checks for `PYTHONSTARTUP` environment variable.
If it finds one, it treats it as a filename that contains Python code and it **runs all the code in that file**, as if you had copy-pasted the code into the REPL.

So all of the modifications I have made to my Python REPL rely on this `PYTHONSTARTUP` variable in my `~/.zshenv` file:

```sh
export PYTHONSTARTUP=$HOME/.startup.py
```

If you use bash, you'll put that in your `~/.bashrc` file.
If you're on Windows [you'll need to set an environment variable the Windows way](https://gist.github.com/mitchmindtree/92c8e37fa80c8dddee5b94fc88d1288b).

With that variable set, I can now create a `~/.startup.py` file that has Python code in it.
That code will automatically run every time I launch a new Python REPL, whether within a virtual environment or outside of one.


## My REPL keyboard shortcuts

The quick summary of my *current* modifications are:

- Pressing **Home** moves to the **first character in the code block**
- Pressing **End** moves to the **last character in the code block**
- Pressing **Alt+M** moves to the **first character** on the current line
- Pressing **Shift+Tab** removes **common indentation** from the code block
- Pressing **Alt+Up** swaps the current line with **the line above it**
- Pressing **Alt+Down** swaps the current line with **the line below it**
- Pressing **Ctrl+N** inserts **a specific list of numbers**
- Pressing **Ctrl+F** inserts **a specific list of strings**

If you've read [my Python REPL shortcuts][repl shortcuts] article, you know that we can already use **Ctrl+A** to move to the beginning of the line and **Ctrl+E** to move to the end of the line.
I already use those instead of the Home and End keys, so I decided to rebind Home and End to do something different.

The **Shift+Tab** functionality is basically a fancy wrapper around [using `textwrap.dedent`][dedent]: it dedents the current code block while keeping the cursor over the same character it was at before.

In addition to the above changes, I also modify my color scheme to work nicely with my Solarized Light color scheme in Vim.
        

## I created a pyrepl-hacks library for this

My PYTHONSTARTUP file became so messy that I ended up creating a [pyrepl-hacks library][] to help me with these modifications.

[My PYTHONSTARTUP file][my pythonstartup] now looks pretty much like this:

```python
import pathlib as _pathlib, sys as _sys
_sys.path.append(str(_pathlib.Path.home() / ".pyhacks"))

try:
    import pyrepl_hacks as _repl
except ImportError:
    pass  # We're on Python 3.12 or below
else:
    _repl.bind("Home", "home")
    _repl.bind("End", "end")
    _repl.bind("Alt+M", "move-to-indentation")
    _repl.bind("Shift+Tab", "dedent")
    _repl.bind("Alt+Down", "move-line-down")
    _repl.bind("Alt+Up", "move-line-up")
    _repl.bind_to_insert("Ctrl+N", "[2, 1, 3, 4, 7, 11, 18, 29]")
    _repl.bind_to_insert(
        "Ctrl+F",
        '["apples", "oranges", "bananas", "strawberries", "pears"]',
    )

    try:
        # Solarized Light theme to match vim
        _repl.update_theme(
            keyword="green",
            builtin="blue",
            comment="intense blue",
            string="cyan",
            number="cyan",
            definition="blue",
            soft_keyword="bold green",
            op="intense green",
            reset="reset, intense green",
        )
    except ImportError:
        pass  # We're on Python 3.13 or below

    del _repl, _pathlib, _sys  # Avoid global REPL namespace pollution
```

That's pretty short!

But wait... won't this fail unless pyrepl-hacks is installed in every virtual environment *and* installed globally for every Python version on my machine?

That's where that `sys.path.append` trick comes in handy...


## Wait... let's acknowledge the dragons 🐲

At this point I'd like to pause to note that all of this relies on using an implementation detail of Python that is deliberately undocumented because it *is not designed* to be used by end users.

The above code all relies on the `_pyrepl` module that was added in Python 3.13 (and optionally the `_colorize` module that was added in Python 3.14).

When we upgrade to a newer Python (for example Python 3.15) this solution may break.
I'm willing to take that risk, as I know that I can always unset my shell's `PYTHONSTARTUP` variable or clear out my startup file.


## Monkey patching `sys.path` to allow importing `pyrepl_hacks`

I didn't install pyrepl-hacks *the usual way*.
Instead, I installed in a very specific location.

I created a `~/.pyhacks` directory and then installed `pyrepl-hacks` *into* that directory:

```bash
$ mkdir -p ~/.pyhacks
$ python -m pip install pyrepl-hacks --target ~/.pyhacks
```

In order for the `pyrepl_hacks` Python package to work, it needs to available within every Python REPL I might launch.
Normally that would mean that it needs to be installed in every virtual environment that Python runs within.

When Python tries to import a module, it iterates through the `sys.path` directory list.
Any Python packages found *within* any of the `sys.path` directories may be imported.

So monkey patching `sys.path` within my PYTHONSTARTUP file allows `pyrepl_hacks` to be imported in every Python interpreter I launch:

```python
from pathlib import Path
import sys
sys.path.append(str(Path.home() / ".pyhacks"))
```

With those 3 lines (or something like them) placed in my PYTHONSTARTUP file, all interactive Python interpreters I launch will be able to import modules that are located in my `~/.pyhacks` directory.


## Creating your own custom REPL commands

That's pretty neat.
But what if you want to invent your own REPL commands?

Well, the `bind` utility within the `pyrepl_hacks` module can be used as a decorator for that.

This will make Ctrl+X followed by Ctrl+R insert `import subprocess` followed by `subprocess.run("", shell=True)` with the cursor positioned in between the double quotes after it's all inserted:

```python
import pyrepl_hacks as _repl

@_repl.bind(r"Ctrl+X Ctrl+R", with_event=True)
def subprocess_run(reader, event_name, event):
    """Ctrl+X followed by Ctrl+R will insert a subprocess.run command."""
    reader.insert("import subprocess\n")
    code = 'subprocess.run("", shell=True)'
    reader.insert(code)
    for _ in range(len(code) - code.index('""') - 1):
        _repl.commands.left(reader, event_name, event)
```

You can read more about the package [in the readme file][readme].


## pyrepl-hacks is just a fancy wrapper

The pyrepl-hacks package is really just a fancy wrapper around Python's `_pyrepl` and `_colorize` modules.

Why did I make a whole package and then modify my `sys.path` to use it, when I could have just used `_pyrepl` directly?

Three reasons:

1. To hide the hairiness of the solution
2. To make creating new commands *a bit* easier (functions can be used instead of classes)
3. To make the key bindings look a bit nicer (I prefer `"Ctrl+M"` over `r"\C-M")

Want to see the original code?

Read on...


## My original PYTHONSTARTUP file (without pyrepl-hacks)

Without pyrepl-hacks, [here's](https://pym.dev/p/35q9e/) what my PYTHONSTARTUP file looked pretty much like:

```python
try:
    from _pyrepl.simple_interact import _get_reader
    from _pyrepl.commands import EditCommand, MotionCommand
except ImportError:
    pass  # Python 3.12 and below
else:
    class move_to_indentation(MotionCommand):
        """Move to the start of indentation for the current line."""
        def do(self):
            import re
            x, y = self.reader.pos2xy()
            lines = self.reader.get_unicode().splitlines(keepends=True)
            line = lines[y]
            if match := re.search(r"^\s+", line):
                index = match.end()
            else:
                index = 0
            self.reader.pos = self.reader.bol() + index

    class dedent_block(EditCommand):
        """Dedent the current code block."""
        def do(self):
            import textwrap
            r = self.reader
            x, y = self.reader.pos2xy()
            original_text = r.get_unicode()
            dedented_text = textwrap.dedent(original_text)

            # Dedent buffer and invalidate cache
            r.buffer[:] = list(dedented_text)
            r.last_refresh_cache.invalidated = True
            r.dirty = True

            # Reposition cursor correctly
            original_lines = original_text.splitlines()
            dedented_lines = dedented_text.splitlines()
            removed_characters = sum(
                len(old) - len(new)
                for old, new in zip(original_lines[:y+1], dedented_lines)
            )
            r.pos -= removed_characters

    class move_line_down(EditCommand):
        """Move the current line down."""
        def do(self):
            r = self.reader
            x, y = r.pos2xy()
            lines = r.get_unicode().splitlines(keepends=True)

            # Can't move down if we're on the last line
            if y >= len(lines) - 1:
                return

            # Swap current line with next line
            lines[y], lines[y+1] = lines[y+1], lines[y]

            if not lines[y].endswith("\n"):
                lines[y] += "\n"

            # Update buffer with swapped lines
            r.buffer[:] = list("".join(lines))
            r.last_refresh_cache.invalidated = True
            r.dirty = True

            # Move cursor to same column in the moved line (one line up)
            r.pos += len(lines[y])

    class move_line_up(EditCommand):
        """Move the current line up."""
        def do(self):
            r = self.reader
            x, y = r.pos2xy()
            lines = r.get_unicode().splitlines(keepends=True)

            # Can't move up if we're on the first line
            if y <= 0:
                return

            # Swap current line with previous line
            lines[y-1], lines[y] = lines[y], lines[y-1]

            # Update buffer with swapped lines
            r.buffer[:] = list("".join(lines))
            r.last_refresh_cache.invalidated = True
            r.dirty = True

            # Move cursor to same column in the moved line (one line up)
            r.pos -= len(lines[y])

    class number_list(EditCommand):
        def do(self):
            self.reader.insert("[2, 1, 3, 4, 7, 11, 18, 29]")

    class fruits_list(EditCommand):
        def do(self):
            self.reader.insert('["apples", "oranges", "bananas", "strawberries", "pears"]')

    reader = _get_reader()
    reader.commands["move-to-indentation"] = move_to_indentation
    reader.commands["dedent-block"] = dedent_block
    reader.commands["move-line-down"] = move_line_down
    reader.commands["move-line-up"] = move_line_up
    reader.commands["number-list"] = number_list
    reader.commands["fruits-list"] = fruits_list

    reader.bind(r"\<home>", "home")  # "home" command is already in _pyrepl
    reader.bind(r"\<end>", "end")  # "end" command is already in _pyrepl
    reader.bind(r"\M-m", "move-to-indentation")  # Alt+M
    reader.bind(r"\e[Z", "dedent-block")  # Shift+Tab
    reader.bind(r"\e[1;3B", "move-line-down")  # Alt+Down
    reader.bind(r"\e[1;3A", "move-line-up")  # Alt+Up
    reader.bind(r"\C-n", "number-list")  # Ctrl+N
    reader.bind(r"\C-f", "fruits-list")  # Ctrl+F

    del (
        reader, _get_reader, EditCommand, MotionCommand, move_to_indentation,
        dedent_block, move_line_down, move_line_up, number_list, fruits_list
    )

try:
    import _colorize
except ImportError:
    pass  # Python 3.13 and below
else:
    # Solarized Light theme to match vim
    ANSIColors = _colorize.ANSIColors
    solarized_light_theme = _colorize.default_theme.copy_with(
        syntax=_colorize.Syntax(
            keyword=ANSIColors.GREEN,
            builtin=ANSIColors.BLUE,
            comment=ANSIColors.INTENSE_BLUE,
            string=ANSIColors.CYAN,
            number=ANSIColors.CYAN,
            definition=ANSIColors.BLUE,
            soft_keyword=ANSIColors.BOLD_GREEN,
            op=ANSIColors.INTENSE_GREEN,
            reset=ANSIColors.RESET + ANSIColors.INTENSE_GREEN,
        ),
    )
    _colorize.set_theme(solarized_light_theme)

    del _colorize, ANSIColors
```

Compare this *long* PYTHONSTARTUP file to the shorter one from before that uses `pyrepl_hacks`.

This longer one is over 100 lines longer!


## Try pyrepl-hacks and leave feedback

My hope is that the [pyrepl-hacks][] library will be obsolete one day.
Eventually the `_pyrepl` module might be renamed to `pyrepl` (or maybe just `repl`?) and it will have a well-documented friendly-ish public interface.

In the meantime, I plan to maintain pyrepl-hacks.
As Python 3.15 is developed, I'll make sure it continues to work.
And I may add more useful commands if I think of any.

If you hack your own REPL, I'd love to hear what modifications you come up with.
And if you have thoughts on how to improve pyrepl-hacks, please open an issue or get in touch.

Contributions and ideas welcome!


[shortcuts]: https://treyhunner.com/2024/10/adding-keyboard-shortcuts-to-the-python-repl/
[colors]: https://treyhunner.com/2025/09/customizing-your-python-repl-color-scheme/
[my pythonstartup]: https://github.com/treyhunner/dotfiles/commits/main/startup.py
[pyrepl-hacks]: https://github.com/treyhunner/pyrepl-hacks
[repl shortcuts]: https://www.pythonmorsels.com/repl-features/
[dedent]: https://www.pythonmorsels.com/dedent/
[readme]: https://github.com/treyhunner/pyrepl-hacks#readme
