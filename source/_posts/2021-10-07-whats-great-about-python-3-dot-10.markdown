---
layout: post
title: "What's great about Python 3.10?"
date: 2021-10-08 08:30:30 -0700
comments: true
twitter_image: https://treyhunner.com/images/idle3.10.png
categories: python
---

What changed in Python 3.10 and which of those changes matter for you?

I've spent this week playing with Python 3.10.
I've primarily been working on solutions to Python Morsels exercises that embrace new Python 3.10 features.
I'd like to share what I've found.


## Easier troubleshooting with improved error messages

The biggest Python 3.10 improvements by far are all related improved error messages.
I make typos all the time.
Error messages that help me quickly figure out what's wrong are *really* important.

I've already grown accustom to the process of deciphering many of Python's more cryptic error messages.
So while improved error messages *are* great for me, this change is *especially* big for new Python learners.

When I teach an introduction to Python course, some of the most common errors I help folks debug are:

1. Missing colons at the end of a block of code
2. Missing indentation or incorrect indentation in a block of code
3. Misspelled variable names
4. Brackets and braces that were never closed

Python 3.10 makes all of these errors (and more) much clearer for Python learners.

New Python users often forget to put a `:` to begin their code blocks.
In Python 3.9 users would see this cryptic error message:

```bash
$ python3.9 temp.py 70
  File "/home/trey/temp.py", line 4
    if temperature < 65
                       ^
SyntaxError: invalid syntax

```

Python 3.10 makes this much clearer:

```bash
$ python3.10 temp.py 70
  File "/home/trey/temp.py", line 4
    if temperature < 65
                       ^
SyntaxError: expected ':'
```

Indentation errors are clearer too (that `after 'if' statement on line 4` is new):

```bash
$ python3.10 temp.py 70
  File "/home/trey/temp.py", line 5
    print("Too cold")
    ^
IndentationError: expected an indented block after 'if' statement on line 4
```

And incorrect variable and attribute names now show a suggestion:

```bash
$ python3.10 temp.py 70
Traceback (most recent call last):
  File "/home/trey/temp.py", line 4, in <module>
    if temparature < 65:
NameError: name 'temparature' is not defined. Did you mean: 'temperature'?
```

I'm really excited about that one because I make typos in variable names pretty much daily.

The error message shown for unclosed brackets, braces, and parentheses is also *much* more helpful.

Python used to show us the *next* line of code after an unclosed brace:

```bash
$ python3.9 temp.py 70
  File "/home/trey/temp.py", line 6
    elif temperature > 80:
    ^
SyntaxError: invalid syntax
```

Now it instead points to the opening brace that was left unclosed:

```bash
$ python3.10 temp.py 70
  File "/home/trey/temp.py", line 5
    print("Too cold"
         ^
SyntaxError: '(' was never closed
```

You can find more details on these improved error messages in the [better error messages][] section of the "What's new in Python 3.10" documentation.

While Python 3.10 does include other changes (read on if you're interested), these improved error messages are the one 3.10 improvement that **all Python users will notice**.


## IDLE is more visually consistent

Here's another feature that affects new Python users: the look of IDLE [improved a bit][idle].
IDLE now uses spaces for indentation instead of tabs (unlike the built-in REPL) and the familiar `...` in front of REPL continuation lines is now present in IDLE within a sidebar.

Before IDLE looked like this:

{% img /images/idle3.9.png An IDLE Shell window with an if-else block that has no ... prefixes and uses tabs for indentation %}

Now IDLE looks like this:

{% img /images/idle3.10.png An IDLE Shell window with an if-else block that has ... prefixes and uses 4 spaces for indentation %}

Looks a lot more like the Python REPL on the command-prompt, right?


## Length-checking for the zip function

There's a Python Morsels exercise called `strict_zip`.
It's now become a "re-implement this already built-in functionality" exercise.
Still useful for the sake of learning how `zip` is implemented, but no longer useful day-to-day code.

Why isn't it useful?
Because `zip` now accepts a `strict` argument!
So if you're working with iterables that *might* be different lengths but *shouldn't* be, passing `strict=True` is now [recommended when using zip][strict=True].


## Structural pattern matching

The big Python 3.10 feature everyone is talking about is structural pattern matching.
This feature is very powerful but probably not very relevant for most Python users.

One important note about this feature: `match` and `case` are still allowable variable names so all your existing code should keep working (they're [soft keywords][]).


### Matching the shape and contents of an iterable

You could look at the new `match`/`case` statement as **like tuple unpacking with a lot more than just length-checking**.

Compare this snippet of code [from a Django template tag][do_get_language_info]:

```python
    args = token.split_contents()
    if len(args) != 5 or args[1] != 'for' or args[3] != 'as':
        raise TemplateSyntaxError("'%s' requires 'for string as variable' (got %r)" % (args[0], args[1:]))
    return GetLanguageInfoNode(parser.compile_filter(args[2]), args[4])
```

To the same snippet refactored to use structural pattern matching:

```python
    match token.split_contents():
        case [name, "for", code, "as", info]:
            return GetLanguageInfoNode(parser.compile_filter(code), info)
        case [name, *rest]:
            raise TemplateSyntaxError(f"'{name}' requires 'for string as variable' (got {rest!r})")
```

Notice that the second approach allows us to describe both the number of variables we're unpacking our data into and the names to unpack into (just like tuple unpacking) while also matching the second and third values against the strings `for` and `as`.
If those strings don't show up in the expected positions, we raise an appropriate exception.

Structural pattern matching is *really* handy for implementing simple parsers, like Django's template language.
I'm looking forward to seeing Django's refactored template code in 2025 (after Python 3.9 support ends).


### Complex type checking

Structural pattern matching also excels at type checking.
Strong type checking is usually discouraged in Python, but it does come crop up from time to time.

The most common place I see `isinstance` checks is in operator overloading dunder methods (`__eq__`, `__lt__`, `__add__`, `__sub__`, etc).
I've already upgraded some Python Morsels solutions to compare and contrast `match`-`case` and `isinstance` and I'm finding it more verbose in some cases but also occasionally somewhat clearer.

For example this code snippet (again [from Django][localize]):

```python
    if isinstance(value, str):  # Handle strings first for performance reasons.
        return value
    elif isinstance(value, bool):  # Make sure booleans don't get treated as numbers
        return str(value)
    elif isinstance(value, (decimal.Decimal, float, int)):
        if use_l10n is False:
            return str(value)
        return number_format(value, use_l10n=use_l10n)
    elif isinstance(value, datetime.datetime):
        return date_format(value, 'DATETIME_FORMAT', use_l10n=use_l10n)
    elif isinstance(value, datetime.date):
        return date_format(value, use_l10n=use_l10n)
    elif isinstance(value, datetime.time):
        return time_format(value, 'TIME_FORMAT', use_l10n=use_l10n)
    return value
```

Can be replaced by this code snippet instead:

```python
    match value:
        case str():  # Handle strings first for performance reasons.
            return value
        case bool():  # Make sure booleans don't get treated as numbers
            return str(value)
        case decimal.Decimal() | float() | int():
            if use_l10n is False:
                return str(value)
            return number_format(value, use_l10n=use_l10n)
        case datetime.datetime():
            return date_format(value, 'DATETIME_FORMAT', use_l10n=use_l10n)
        case datetime.date():
            return date_format(value, use_l10n=use_l10n)
        case datetime.time():
            return time_format(value, 'TIME_FORMAT', use_l10n=use_l10n)
        case _:
            return value
```

Note how much shorter each condition is.
That `case` syntax definitely takes some getting used to, but I do find it a bit easier to read in long `isinstance` chains like this.


## Bisecting with a key

Python's `bisect` module is really handy for quickly finding an item within a sorted list.

For me, the `bisect` module is mostly a reminder of how infrequently I need to care about the [binary search][] algorithms I learned in Computer Science classes.
But for those times you do need to find an item in a sorted list, `bisect` is great.

As of Python 3.10, all the binary search helpers in the `bisect` module now accept a `key` argument.
So you can now quickly search within a case insensitively-sorted list of strings for the string you're looking for.

```pycon
>>> fruits = sorted(['Watermelon','loquat', 'Apple', 'jujube'], key=str.lower)
>>> fruits
['Apple', 'jujube', 'loquat', 'Watermelon']
>>> import bisect
>>> bisect.insort(fruits, 'Lemon', key=str.lower)
>>> fruits
['Apple', 'jujube', 'Lemon', 'loquat', 'Watermelon']
>>> i = bisect.bisect(fruits, 'lime', key=str.lower)
>>> fruits[i] == 'lime'
False
>>> fruits[i]
'loquat'
```

Doing a search that involved a `key` function was [surprisingly tricky][bisect without key] before Python 3.10.


## Slots for data classes

Have a data class (especially a frozen one) and want to make it more memory-efficient?
You can add a `__slots__` attribute but you'll need to type all the field names out yourself.

```python
from dataclasses import dataclass

@dataclass
class Point:
    __slots__ = ('x', 'y')
    x: float
    y: float
```

In Python 3.10 you can now use `slots=True` instead:

```python
from dataclasses import dataclass

@dataclass(slots=True)
class Point:
    x: float
    y: float
```

This feature was actually included in the original dataclass implementation but [removed][slots removal] before Python 3.7's release (Guido suggested including it in a later Python version if users expressed interest and we did).

Creating a dataclass with `__slots__` added manually [won't allow for default field values][slots defaults], which is why `slots=True` is so handy.
There's a very smaller quirk with `slots=True` though: `super` calls break when `slots=True` is used because this causes a *new* class object to be created which breaks the [magic of super][].
But unless you're using calling `super().__setattr__` in the `__post_init__` method of a frozen dataclass [instead of][object.__setattr__] calling `object.__setattr__`, this quirk likely won't affect you.


### Type annotation improvements

If you use type annotations, [type unions][] are even easier now using the `|` operator (in addition to `typing.Union`).
Other big additions in type annotation land include [parameter specification variables][], [type aliases][], and [user-defined type guards][].
I still don't use type annotations often, but these features are a pretty big deal for Python devs who do.

Also if you're introspecting annotations, calling the `inspect.get_annotations` function is [recommended][annotations best practices] over accessing `__annotations__` directly or calling the `typing.get_type_hints` function.


### Checking for default file encoding issues

You can also now ask Python to emit warnings when you fail to specify an explicit file encoding (this is *very* relevant when writing cross operating system compatible code).

Just run Python with `-X warn_default_encoding` and you'll see a loud error message if you're not specifying encodings everywhere you open files up:

```bash
$ python3.10 -X warn_default_encoding count_lines.py declaration-of-independence.txt
/home/trey/count_lines.py:3: EncodingWarning: 'encoding' argument not specified
  with open(sys.argv[1]) as f:
67
```


## Plus lots more

The changes above are the main ones I've found useful when updating Python Morsels exercises over the last week.
There are many more changes in Python 3.10 though.

Here are a few more things I looked into, and plan to play with later:

- [keyword-only][] dataclass fields
- The `fileinput.input` (handy for handling standard input *or* a file) function [now accepts][fileinput] an `encoding` argument
- `importlib` [deprecations][]: some of my dynamic module importing code was using features that are now deprecated in Python 3.10 (you'll notice obvious deprecation warnings if your code needs updating too)
- [Dictionary views][] have a `mapping` attribute now: if you're making your own dictionary-like objects, you should probably add a `mapping` attribute to your `keys`/`values`/`items` views as well (this will definitely crop up in Python Morsels exercises in the future)
- When using multiple context managers in a single `with` block, parentheses can now be used to wrap them onto the next line (this was actually added in Python 3.9 [but unofficially][context managers])
- The names of [standard library modules](https://docs.python.org/3.10/library/sys.html#sys.stdlib_module_names) and built-in modules are now included in `sys.stdlib_module_names` and `sys.builtin_module_names`: I've occasionally needed to distinguish between third party and standard library modules dynamically and this makes that a lot easier
- `sys.orig_argv` includes the [full list of command-line arguments][orig_argv] (including the Python interpreter and all arguments passed to it) which could be useful when inspecting how your Python process was launched or when re-launching your Python process with the same arguments


## Summary

Structural pattern matching is great and the various other syntax, standard library, and builtins improvements are lovely too.
But the biggest improvement by far are the new error messages.

And you know what's even better news than the new errors in Python 3.10?
[Python 3.11 will include even better error messages][3.11]!


## Get practice with Python 3.10

Want to try out Python 3.10?
Try out the [Python 3.10 exercise path][] on Python Morsels.
It's free for [Python Morsels][] subscribers and $17 for non-subscribers.

Python Morsels currently includes **170 Python exercises** and **80 Python screencasts** with a new short screencast/article hybrid added each week.
This service is all about hands-on skill building (we learn and grow through doing, not just reading/watching).

I'd love for you to [come learn Python (3.10) with me][python 3.10 exercise path]! 💖


[better error messages]: https://docs.python.org/3.10/whatsnew/3.10.html#better-error-messages
[strict=True]: https://docs.python.org/3.10/library/functions.html#zip
[type unions]: https://docs.python.org/3.10/whatsnew/3.10.html#pep-604-new-type-union-operator
[parameter specification variables]: https://docs.python.org/3.10/whatsnew/3.10.html#pep-612-parameter-specification-variables
[type aliases]: https://docs.python.org/3.10/whatsnew/3.10.html#pep-613-typealias
[user-defined type guards]: https://docs.python.org/3.10/whatsnew/3.10.html#pep-647-user-defined-type-guards
[binary search]: https://en.wikipedia.org/wiki/Binary_search_algorithm
[slots removal]: https://github.com/ericvsmith/dataclasses/issues/28
[slots defaults]: https://stackoverflow.com/questions/50180735/how-can-dataclasses-be-made-to-work-better-with-slots
[magic of super]: https://stackoverflow.com/questions/19608134/why-is-python-3-xs-super-magic/19609168#19609168
[object.__setattr__]: https://stackoverflow.com/a/54119384/98187
[annotations best practices]: https://docs.python.org/3/howto/annotations.html#accessing-the-annotations-dict-of-an-object-in-python-3-10-and-newer
[idle]: https://twitter.com/sjoerdjob/status/1446172628922867712
[bisect without key]: https://stackoverflow.com/a/55007379/98187
[fileinput]: https://docs.python.org/3.10/whatsnew/3.10.html#fileinput
[keyword-only]: https://docs.python.org/3.10/whatsnew/3.10.html#keyword-only-fields
[deprecations]: https://docs.python.org/3.10/whatsnew/3.10.html#deprecated
[dictionary views]: https://docs.python.org/3.10/library/stdtypes.html#dict-views
[localize]: https://github.com/django/django/blob/3.2/django/utils/formats.py#L195..L209
[do_get_language_info]: https://github.com/django/django/blob/main/django/templatetags/i18n.py#L243..L246
[soft keywords]: https://www.python.org/dev/peps/pep-0622/#the-match-statement
[orig_argv]: https://docs.python.org/3.10/library/sys.html#sys.orig_argv
[3.11]: https://docs.python.org/3.11/whatsnew/3.11.html#enhanced-error-locations-in-tracebacks
[python morsels]: https://www.pythonmorsels.com/
[context managers]: https://bugs.python.org/issue12782
[python 3.10 exercise path]: https://www.pythonmorsels.com/exercises/paths/#path-14
