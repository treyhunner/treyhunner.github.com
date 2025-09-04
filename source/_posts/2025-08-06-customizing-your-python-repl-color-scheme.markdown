---
layout: post
title: "Customizing your Python REPL's color scheme (Python 3.14+)"
date: 2025-09-04 14:00:00 -0700
comments: true
categories: python repl
twitter_image: https://treyhunner.com/images/python3.14-repl-syntax-highlighting.png
---

Did you know that Python 3.14 will include [syntax highlighting](https://docs.python.org/3.14/whatsnew/3.14.html#whatsnew314-pyrepl-highlighting) in the REPL?

Python 3.14 is due to be [officially released](https://peps.python.org/pep-0745/) in about a month.
I recommended tweaking your Python setup now so you'll have your ideal color scheme on release day.

{% img /images/python3.14-repl-syntax-highlighting.png Python 3.14 REPL with syntax highlighting using custom color scheme %}

But... what if the default syntax colors don't match the colors that your text editor uses?

Well, fortunately you can customize your color scheme!

**Warning**: I am recommending using an undocumented private module (it has an `_`-prefixed name) which may change in future Python versions.
Do not use this module in production code.


## Installing Python 3.14

Don't have Python 3.14 installed yet?

If you have [uv](https://docs.astral.sh/uv/) installed, you can run this command to launch Python 3.14:

```bash
$ uv run --python 3.14 python
```

That will automatically install 3.14 (if you don't have it yet) and run it.


## Setting a theme

I have my terminal colors set to the Solarized Light color palette and I have Vim use a Solarized Light color scheme as well.

The REPL doesn't *quite* match my text editor by default:

{% img /images/python3.14-repl-default-color-scheme.png Python 3.14 REPL with default syntax highlighting %}

The numbers, comments, strings, and keywords are all different colors than my text editor.

This code makes the Python REPL use *nearly* the same syntax highlighting as my text editor:

```python
from _colorize import set_theme, default_theme, Syntax, ANSIColors

set_theme(default_theme.copy_with(
    syntax=Syntax(
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
))
```

Check it out:

{% img /images/python3.14-repl-syntax-highlighting.png Python 3.14 REPL with syntax highlighting using custom color scheme %}

Neat, right?

But... I want this to be enabled by default!


## Using a `PYTHONSTARTUP` file

You can use a `PYTHONSTARTUP` file to run code every time a new Python process starts.

If Python sees a `PYTHONSTARTUP` environment variable when it starts up, it will open that file and evaluate the code within it.

I have this in my `~/.zshrc` file to set the `PYTHONSTARTUP` environment variable to `~/.startup.py`:

```bash
# Setup python-launcher to use startup file
export PYTHONSTARTUP=$HOME/.startup.py
```

In my `~/.startup.py` file, I have this code:

```python
def _main():
    """Everything's in a function to avoid polluting the global scope."""
    try:
        from _colorize import set_theme, default_theme, Syntax, ANSIColors
    except ImportError:
        pass  # Python 3.13 and below
    else:
        # Define Solarized Light colors
        solarized_light_theme = default_theme.copy_with(
            syntax=Syntax(
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
        set_theme(solarized_light_theme)

_main()  # _main avoids name collision, in case python -i is used
del _main  # Delete _main from global scope
```

Note that:

1. I put all relevant code within a `_main` function so that the variables I set don't remain in the global scope of the Python REPL (they will by default)
2. I call the `_main` function and then delete the function afterward, again so the `_main` variable doesn't stay floating around in my REPL
3. I use `try`-`except`-`else` to ensure errors don't occur on Python 3.13 and below

Also note that the syntax highlighting in the new REPL is [not as fine-grained](https://github.com/python/cpython/issues/134953) as many other syntax highlighting tools.
I suspect that it may become a bit more granular over time, **which may break the above code**.

The `_colorize` module is currently an internal implementation detail and is deliberately undocumented.
Its API may change at any time, so **the above code may break in Python 3.15**.
If that happens, I'll just update my `PYTHONSTARTUP` file at that point.


## Packaging themes

I've stuck all of the above code in a `~/.startup.py` file and I set the `PYTHONSTARTUP` environment variable on my system to point to this file.

Instead of manually updating a startup file, is there any way to make these themes *installable*?

Well, if a `.pth` file is included in Python's `site-packages` directory, that file (which must be a single line) will be run whenever Python starts up.
In theory, a package could use such a file to import a module and then call a function that would set the color scheme for the REPL.
My [dramatic](https://github.com/treyhunner/dramatic) package uses (*cough* abuses *cough*) `.pth` files in this way.

This sounds like a somewhat bad idea, but maybe not a *horrible* idea.

If you do this, let me know.


## What's your theme?

Have you played with setting a theme in your own Python REPL?

What theme are you using?
