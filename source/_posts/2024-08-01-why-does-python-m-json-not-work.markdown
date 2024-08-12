---
layout: post
title: Why does "python -m json" not work? Why is it "json.tool"?
date: 2024-08-01 14:00:00 -0700
comments: true
categories: python
---

**Update**: upon the encouragement of a few CPython core team members, I [opened a pull request](https://github.com/python/cpython/pull/122884) to add this to Python 3.14.

Have you ever used Python's `json.tool` command-line interface?

You can run `python -m json.tool` against a JSON file and Python will print a nicely formatted version of the file.

```bash
python -m json.tool example.json
[
    1,
    2,
    3,
    4
]
```

Why do we need to run `json.tool` instead of `json`?


## The history of `python -m`

Python 3.5 added the ability to run a module as a command-line script using the `-m` argument (see [PEP 338](https://peps.python.org/pep-0338/)) which was implemented in Python 2.5.
While that feature was being an additional feature/bug was accidentally added, alowing packages to be run with the `-m` flag as well.
When a package was run with the `-m` flag, the package's `__init__.py` file would be run, with the `__name__` variable set to `__main__`.

This accidental feature/bug was [removed in Python 2.6](https://github.com/python/cpython/issues/47000).

It wasn't until Python 2.7 that the ability to run `python -m package` was re-added (see below).


## The history of the `json` module

The `json` module was [added in Python 2.6](https://docs.python.org/3/whatsnew/2.6.html#the-json-module-javascript-object-notation).
It was based on the third-party `simplejson` library.

That library originally relied on the fact that Python packages could be run with the `-m` flag to run the package's `__init__.py` file with `__name__` set to `__main__` (see [this code from version 1.8.1](https://github.com/simplejson/simplejson/blob/v1.8.1/simplejson/__init__.py#L368)).

When `simplejson` was added to Python as the `json` module in Python 2.6, this bug/feature could no longer be relied upon as it was fixed in Python 2.6.
To continue allowing for a nice command-line interface, it was decided that running a `tool` submodule would be the way to add a command-line interface to the `json` package ([discussion here](https://github.com/simplejson/simplejson/commit/74d9c5c4c4339db47dfa86bf37858cae80ed3776)).

Python 2.7 [added the ability to run any package as a command-line tool](https://docs.python.org/2.7/using/cmdline.html?highlight=__main__#cmdoption-m).
The package would simply need a `__main__.py` file within it, which Python would run as the entry point to the package.

At this point, `json.tool` had already been added in Python 2.6 and no attempt was made (as far as I can tell) to allow `python -m json` to work instead.
Once you've added a feature, removing or changing it can be painful.


## Could we make `python -m json` work today?

We could.
We would just need to [rename `tool.py` to `__main__.py`](https://github.com/treyhunner/cpython/commit/1226315e2df0d4229558734d5f0d50f1386a025e).
To allow `json.tool` to still work *also*, would could [make a new `tool.py` module](https://github.com/python/cpython/commit/7ce95d21886c7ad5278c07c1a20cda5bebab4731) that simply imports `json.__main__`.

We could even go so far as to [deprecate `json.tool`](https://github.com/treyhunner/cpython/commit/ae4ca62346c690e1c6aaf1ccfed37069984b5d67) if we wanted to.

Should we do this though? 🤔


## Should we make `python -m json` work?

I don't know about you, but I would rather type `python -m json` than `python -m json.tool`.
It's more memorable *and* easier to guess, if you're not someone who has memorized [all the command-line tools hiding in Python](https://www.pythonmorsels.com/cli-tools/).

But would this actually be used?
I mean, don't people just use the [jq](https://jqlang.github.io/jq/) tool instead?

Well, a `sqlite3` shell was [added to Python 3.12](https://docs.python.org/3/library/sqlite3.html#command-line-interface) despite the fact that third-party interactive sqlite prompts are fairly common.

It is pretty handy to have a access to a tool within an unfamiliar environment where installing yet-another-tool might pose a problem.
Think Docker, a locked-down Windows machine, or any computer without network or with network restrictions.

Personally, I'd like to see `python3 -m json` work.
I can't think of any big downsides.
Can you?

**Update**: [pull request opened](https://github.com/python/cpython/pull/122884).


## Too long; didn't read

The "too long didn't read version":

- Python 2.5 added support for the `-m` argument for *modules*, but not *packages*
- A third-party `simplejson` app existed with a nice CLI that relied on a `-m` implementation bug allowing packages to be run using `-m`
- Python 2.6 fixed that implementation quirk and broke the previous ability to run `python -m simplejson`
- Python 2.6 also added the `json` module, which was based on this third-party `simplejson` package
- Since `python -m json` couldn't work anymore, the ability to run `python -m json.tool` was added
- Python 2.7 added official support for `python -m some_package` by running a `__main__` submodule
- The `json.tool` module already existed in Python 2.6 and the ability to run `python -m json` was (as far as I can tell) never seriously considered


## All thanks to git history and issue trackers

I discovered this by noting [the first commit](https://github.com/simplejson/simplejson/commit/74d9c5c4c4339db47dfa86bf37858cae80ed3776) that added the `tool` submodule to `simplejson`, which notes the fact that this was for consistency with the new `json` standard library module.

Thank you git history.
And thank you to the folks who brought us the `simplejson` library, the `json` module, and the ability to use `-m` on both a module and a package!

Also, thank you to Alyssa Coghlan, Hugo van Kemenade, and Adam Turner for reviewing my pull request to add this feature to Python 3.14. 💖
