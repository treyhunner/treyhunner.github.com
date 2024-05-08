---
layout: post
title: "My favorite Python 3.13 feature"
date: 2024-05-08 13:30:00 -0700
comments: true
categories: python
twitter_image: https://treyhunner.com/images/new-repl-demo.gif
---

Python 3.13 just hit feature freeze with [the first beta release today](https://www.python.org/downloads/release/python-3130b1/).

Just before the feature freeze, a shiny new feature was added: **a brand new Python REPL**. ✨

This new Python REPL is will likely be my favorite thing about 3.13.
It's definitely the feature I'm most looking forward to using while teaching after 3.13.0 final is released later this year.

I'd like to share what's so great about this new REPL and what additional improvements I'm hoping we might see in future Python releases.


## Little niceties

The first thing you'll notice when you launch the new REPL is the colored prompt.

{% img /images/new-repl-intro.gif %}

You may also notice that as you type a block of code, after the first indented line, the next line will be auto-indented!
Additionally, hitting the Tab key inserts 4 spaces now, which means there's no more need to ever hit `Space Space Space Space` to indent ever again.

At this point you might be thinking, "wait did I accidentally launch ptpython or some other alternate REPL?"
But it gets even better!


## You can "exit" now

Have you ever typed `exit` at the Python REPL?
If so, you've seen a message like this:

```pycon
>>> exit
Use exit() or Ctrl-D (i.e. EOF) to exit
```

That feels a bit silly, doesn't it?
Well, typing `exit` will exit immediately.

{% img /images/new-repl-exit.gif %}

Typing `help` also enters help mode now (previously you needed to call `help()` as a function).


## Block-level history

The feature that will make the biggest different in my own usage of the Python REPL is block-level history.

{% img /images/new-repl-block.gif %}

I make typos all the time while teaching.
I also often want to re-run a specific block of code with a couple small changes.

The old-style Python REPL stores history line-by-line.
So editing a block of code in the old REPL required hitting the up arrow many times, hitting Enter, hitting the up arrow many more times, hitting Enter, etc. until each line in a block was chosen.
At the same time you also needed to make sure to edit your changes along the way... or you'll end up re-running the same block with the same typo as before!

The ability to edit a previously typed *block* of code is huge for me.
For certain sections of my Python curriculum, I hop into [ptpython][] or [IPython][] specifically for this feature.
Now I'll be able to use the default Python REPL instead.


## Pasting code *just works*

The next big feature for me is the ability to paste code.

Check this out:

{% img /images/new-repl-paste.gif %}

Not impressed?
Well, watch what happens when we paste that same block of code into the old Python REPL:

{% img /images/old-repl-paste.gif %}

The old REPL treated pasted text the same as manually typed text.
When two consecutive newlines were encountered in the old REPL, it would end the current block of code because it assumed the Enter key had been pressed twice.

The new REPL supports [bracketed paste][], which is was invented in 2002 and has since been adopted by all modern terminal emulators.


## No Windows support? Curses!

Unfortunately, this new REPL doesn't currently work on Windows.
This new REPL relies on the `curses` and `readline` modules, neither of which are available on Windows.
I'm hoping that this new REPL might encourage the addition of `curses` support on Windows (there are [multiple issues](https://github.com/python/cpython/issues/85796) discussing this).

The [in-browser Python REPL](https://pym.dev/repl) on Python Morsels also won't be able to use the new REPL because readline and curses aren't available in the WebAssembly Python build.


## Beta test Python 3.13 to try out the new REPL 💖

The new Python REPL coming in 3.13 is a major improvement over the old REPL.
While the lack of Windows support is disappointing, but I'm hopeful that a motivated Windows user will help add support eventually!

Want to try out this new REPL?
Download and install [Python 3.13.0 beta 1](https://www.python.org/downloads/release/python-3130b1/)!

Beta testing new Python releases helps the Python core team ensure the final release of 3.13.0 is as stable and functional as possible.
If you notice a bug, [check the issue tracker](https://github.com/python/cpython/issues) to see if it's been reported yet and if not report it!


[ptpython]: https://github.com/prompt-toolkit/ptpython
[ipython]: https://github.com/ipython/ipython
[bracketed paste]: https://en.wikipedia.org/wiki/Bracketed-paste
