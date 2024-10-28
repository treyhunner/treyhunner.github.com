---
layout: post
title: "Adding keyboard shortcuts to the Python REPL"
date: 2024-10-28 07:15:00 -0700
comments: true
categories: python
---

I talked about the new Python 3.13 REPL [a few months ago][3.13 repl] and [after 3.13 was released][3.13 features].
I think it's **awesome**.

I'd like to share a secret feature within the Python 3.13 REPL which I've been finding useful recently: **adding custom keyboard shortcuts**.

This feature involves a `PYTHONSTARTUP` file, use of an unsupported Python module, and dynamically evaluating code.

In short, we may be getting ourselves into trouble.
But the result is *very* neat!


## The goal: keyboard shortcuts in the REPL

First, I'd like to explain the end result.

Let's say I'm in the Python REPL on my machine and I've typed `numbers = `:

```pycon
>>> numbers =
```

I can now hit `Ctrl-N` to enter a list of numbers I often use while teaching ([Lucas numbers][]):

```pycon
numbers = [2, 1, 3, 4, 7, 11, 18, 29]
```

That saved me some typing!


## Getting a prototype working

First, let's try out an example command.

Copy-paste this into your Python 3.13 REPL:

```python
from _pyrepl.simple_interact import _get_reader
from _pyrepl.commands import Command

class Lucas(Command):

    def do(self):
        self.reader.insert("[2, 1, 3, 4, 7, 11, 18, 29]")

reader = _get_reader()
reader.commands["lucas"] = Lucas
reader.bind(r"\C-n", "lucas")
```

Now hit `Ctrl-N`.

If all worked as planned, you should see that list of numbers entered into the REPL.

Cool!
Now let's generalize this trick and make Python run our code whenever it starts.

But first... a disclaimer.


## Here be dragons 🐉

Notice that `_` prefix in the `_pyrepl` module that we're importing from?
That means this module is officially unsupported.

The `_pyrepl` module is an implementation detail and its implementation may change at any time in future Python versions.

In other words: `_pyrepl` is designed to be used by *Python's standard library modules* and not anyone else.
That means that we should assume this code will break in a future Python version.

Will that stop us from playing with this module for the fun of it?

It won't.


## Creating a `PYTHONSTARTUP` file

So we've made *one* custom key combination for ourselves.
How can we setup this command automatically whenever the Python REPL starts?

We need a `PYTHONSTARTUP` file.

When Python launches, if it sees a `PYTHONSTARTUP` environment variable it will treat that environment variable as a Python file to run on startup.

I've made a `/home/trey/.python_startup.py` file and I've set this environment variable in my shell's configuration file (`~/.zshrc`):

```bash
export PYTHONSTARTUP=$HOME/.python_startup.py
```

To start, we could put our single custom command in this file:

```python
try:
    from _pyrepl.simple_interact import _get_reader
    from _pyrepl.commands import Command
except ImportError:
    pass  # Not in the new pyrepl OR _pyrepl implementation changed
else:
    class Lucas(Command):
        def do(self):
            self.reader.insert("[2, 1, 3, 4, 7, 11, 18, 29]")

    reader = _get_reader()
    reader.commands["lucas"] = Lucas
    reader.bind(r"\C-n", "lucas")
```

Note that I've stuck our code in a `try`-`except` block.
Our code *only* runs if those `_pyrepl` imports succeed.

Note that this *might* still raise an exception when Python starts *if* the reader object's `command` attribute or `bind` method change in a way that breaks our code.

Personally, I'd like to see those breaking changes occur print out a traceback the next time I upgrade Python.
So I'm going to leave those last few lines *without* their own catch-all exception handler.


## Generalizing the code

Here's a `PYTHONSTARTUP` file with a more generalized solution:

```python
try:
    from _pyrepl.simple_interact import _get_reader
    from _pyrepl.commands import Command
except ImportError:
    pass
else:
    # Hack the new Python 3.13 REPL!
    cmds = {
        r"\C-n": "[2, 1, 3, 4, 7, 11, 18, 29]",
        r"\C-f": '["apples", "oranges", "bananas", "strawberries", "pears"]',
    }
    from textwrap import dedent
    reader = _get_reader()
    for n, (key, text) in enumerate(cmds.items(), start=1):
        name = f"CustomCommand{n}"
        exec(dedent(f"""
            class _cmds:
                class {name}(Command):
                    def do(self):
                        self.reader.insert({text!r})
                reader.commands[{name!r}] = {name}
                reader.bind({key!r}, {name!r})
        """))
    # Clean up all the new variables
    del _get_reader, Command, dedent, reader, cmds, text, key, name, _cmds, n
```

This version uses a dictionary to map keyboard shortcuts to the text they should insert.

Note that we're repeatedly building up a string of `Command` subclasses for each shortcut, using `exec` to execute the code for that custom `Command` subclass, and then binding the keyboard shortcut to that new command class.

At the end we then delete all the variables we've made so our REPL will start the clean global environment we normally expect it to have:

```pycon
Python 3.13.0 (main, Oct  8 2024, 10:37:56) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> dir()
['__annotations__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__spec__']
```

Is this messy?

Yes.

Is that a needless use of a dictionary that could have been a list of 2-item tuples instead?

Yes.

Does this work?

Yes.


## Doing more interesting and risky stuff

Note that there are many keyboard shortcuts that may cause weird behaviors if you bind them.

For example, if you bind `Ctrl-i`, your binding may trigger every time you try to indent.
And if you try to bind `Ctrl-m`, your binding may be ignored because this is equivalent to hitting the `Enter` key.

So be sure to test your REPL carefully after each new binding you try to invent.

If you want to do something more interesting, you could poke around in the `_pyrepl` package to see what existing code you can use/abuse.

For example, here's a very hacky way of making a binding to `Ctrl-x` followed by `Ctrl-r` to make this import `subprocess`, type in a `subprocess.run` line, and move your cursor between the empty string within the `run` call:

```python
    class _cmds:
        class Run(Command):
            def do(self):
                from _pyrepl.commands import backward_kill_word, left
                backward_kill_word(self.reader, self.event_name, self.event).do()
                self.reader.insert("import subprocess\n")
                code = 'subprocess.run("", shell=True)'
                self.reader.insert(code)
                for _ in range(len(code) - code.index('""') - 1):
                    left(self.reader, self.event_name, self.event).do()
    reader.commands["subprocess_run"] = _cmds.Run
    reader.bind(r"\C-x\C-r", "subprocess_run")
```


## What keyboard shortcuts are available?

As you play with customizing keyboard shortcuts, you'll likely notice that many key combinations result in strange and undesirable behavior when overridden.

For example, overriding `Ctrl-J` will also override the `Enter` key... at least it does in my terminal.

I'll list the key combinations that seem unproblematic on my setup with Gnome Terminal in Ubuntu Linux.

Here are `Control` key shortcuts that seem to be complete unused in the Python REPL:

- `Ctrl-N`
- `Ctrl-O`
- `Ctrl-P`
- `Ctrl-Q`
- `Ctrl-S`
- `Ctrl-V`

Note that overriding `Ctrl-H` is often an alternative to the backspace key

Here are `Alt`/`Meta` key shortcuts that appear unused on my machine:

- `Alt-A`
- `Alt-E`
- `Alt-G`
- `Alt-H`
- `Alt-I`
- `Alt-J`
- `Alt-K`
- `Alt-M`
- `Alt-N`
- `Alt-O`
- `Alt-P`
- `Alt-Q`
- `Alt-S`
- `Alt-V`
- `Alt-W`
- `Alt-X`
- `Alt-Z`

You can add an `Alt` shortcut by using `\M` (for "meta").
So `r"\M-a"` would capture `Alt-A` just as `r"\C-a"` would capture `Ctrl-A`.

Here are keyboard shortcuts that *can* be customized but you might want to consider whether the current default behavior is worth losing:

- `Alt-B`: backward word (same as `Ctrl-Left`)
- `Alt-C`: capitalize word (does nothing on my machine...)
- `Alt-D`: kill word (delete to end of word)
- `Alt-F`: forward word (same as `Ctrl-Right`)
- `Alt-L`: downcase word (does nothing on my machine...)
- `Alt-U`: upcase word (does nothing on my machine...)
- `Alt-Y`: yank pop
- `Ctrl-A`: beginning of line (like the `Home` key)
- `Ctrl-B`: left (like the `Left` key)
- `Ctrl-E`: end of line (like the `End` key)
- `Ctrl-F`: right (like the `Right` key)
- `Ctrl-G`: cancel
- `Ctrl-H`: backspace (same as the `Backspace` key)
- `Ctrl-K`: kill line (delete to end of line)
- `Ctrl-T`: transpose characters
- `Ctrl-U`: line discard (delete to beginning of line)
- `Ctrl-W`: word discard (delete to beginning of word)
- `Ctrl-Y`: yank
- `Alt-R`: restore history (within history mode)


## What fun have you found in `_pyrepl`?

Find something fun while playing with the `_pyrepl` package's inner-workings?

I'd love to hear about it!
Comment below to share what you found.


[3.13 repl]: https://treyhunner.com/2024/05/my-favorite-python-3-dot-13-feature/
[3.13 features]: https://www.pythonmorsels.com/python-313-whats-new/
[lucas numbers]: https://en.wikipedia.org/wiki/Lucas_number
