---
layout: post
title: "Why you should be using pathlib"
date: 2018-12-20 09:00:00 -0800
comments: true
categories: 
---

When I discovered Python's new `pathlib` module a few years ago, I initially wrote it off as being a slightly more awkward and unnecessarily object-oriented version of the `os.path` module.
I was wrong.
Python's `pathlib` module is actually [wonderful][]!

In this article I'm going to try to sell you on `pathlib`.
I hope that this article will inspire you to use Python's `pathlib` module pretty much anytime you need to work with files in Python.

## os.path is clunky

The `os.path` module has always been what we reached for to work with paths in Python.
It's got pretty much all you need, but it can be very clunky sometimes.

Should you import it like this?

```python
import os.path

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATES_DIR = os.path.join(BASE_DIR, 'templates')
```

Or like this?

```python
from os.path import abspath, dirname, join

BASE_DIR = dirname(dirname(abspath(__file__)))
TEMPLATES_DIR = join(BASE_DIR, 'templates')
```

Or maybe that `join` function is too generically named... so we could do this instead:

```python
from os.path import abspath, dirname, join as joinpath

BASE_DIR = dirname(dirname(abspath(__file__)))
TEMPLATES_DIR = joinpath(BASE_DIR, 'templates')
```

I find all of these a bit awkward.
We're passing strings into functions that return strings which we then pass into other functions that return strings.
All of these strings happen to represent paths, but they're still just strings.

The string-in-string-out functions in `os.path` are really awkward when nested because the code has to be read from the inside out.
Wouldn't it be nice if we could take these nested function calls and turn them into chained method calls instead?

With the `pathlib` module we can!

```python
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = BASE_DIR.joinpath('templates')
```

The `os.path` module requires function nesting, but the `pathlib` modules' `Path` class allows us to chain methods and attributes on `Path` objects to get an equivalent path representation.

I know what you're thinking: wait these `Path` objects aren't the same thing: they're objects, not path strings!
I'll address that later (hint: these can pretty much be used interchangeably with path strings).


## The os module is crowded

Python's classic `os.path` module is just for working with paths.
Once you want to actually *do* something with a path (e.g. create a directory) you'll need to reach for another Python module, often the `os` module.

The `os` module has lots of utilities for working with files and directories: `mkdir`, `getcwd`, `chmod`, `stat`, `remove`, `rename`, and `rmdir`.
Also `chdir`, `link`, `walk`, `listdir`, `makedirs`, `renames`, `removedirs`, `unlink` (same as `remove`), and `symlink`.
And a bunch of other stuff that isn't related to the filesystems at all: `fork`, `getenv`, `putenv`, `environ`, `getlogin`, and `system`.
Plus dozens of things I didn't mention in this paragraph.

Python's `os` module does a little bit of everything; it's sort of a junk drawer for system-related stuff.
There's a lot of lovely stuff in the `os` module, but it can be hard to find what you're looking for sometimes.
So if you're looking for path-related or filesystem-related things in the `os` module, you'll need to do a bit of digging.

The `pathlib` module replaces many of these filesystem-related `os` utilities with methods on the `Path` object.

Here's some code that makes a `src/__pypackages__` directory and renames our `.editorconfig` file to `src/.editorconfig`:

```python
import os
import os.path

os.makedirs(os.path.join('src', '__pypackages__'), exist_ok=True)
os.rename('.editorconfig', os.path.join('src', '.editorconfig'))
```

This code does the same thing using `Path` objects:

```python
from pathlib import Path

Path('src/__pypackages__').mkdir(parents=True, exist_ok=True)
Path('.editorconfig').rename('src/.editorconfig')
```

Notice that the `pathlib` code puts the path first because of method chaining!

As the Zen of Python says, "namespaces are one honking great idea, let's do more of those".
The `os` module is a very large namespace with a bunch of stuff in it.
The `pathlib.Path` class is a much smaller namespace with a much smaller number things, all of which fall under a slightly more specific category.
Plus the methods in this `Path` namespace return `Path` objects, which allows for method chaining instead of nested function string-iful function calls.


## Don't forget about the glob module!

The `os` and `os.path` modules aren't the only filepath/filesystem-related utilities in the Python standard library.
The `glob` module is another handy path-related module.

We can use the `glob.glob` function for finding files that match a certain pattern:

```python
from glob import glob

top_level_csv_files = glob('*.csv')
all_csv_files = glob('**/*.csv', recursive=True)
```

The new `pathlib` module includes glob-like utilities as well.

```python
from pathlib import Path

top_level_csv_files = Path.cwd().glob('*.csv')
all_csv_files = Path.cwd().rglob('*.csv')
```

After you've started using `pathlib` more heavily, you can pretty much forget about the `glob` module entirely: you've got all the glob functionality you need with `Path` objects.


## pathlib makes the simple cases simpler

The `pathlib` module makes a number of complex cases somewhat simpler, but **it also makes some of the simple cases even simpler**.

Need to read all the text in one or more files?

You could open the file, read its contents and close the file using a `with` block:

```python
from glob import glob

file_contents = []
for filename in glob('**/*.py', recursive=True):
    with open(filename) as python_file:
        file_contents.append(python_file.read())
```

Or you could use the `read_text` method on `Path` objects and a list comprehension to read the file contents into a new list all in one line:

```python
from pathlib import Path

file_contents = [
    path.read_text()
    for path in Path.cwd().rglob('*.py')
]
```

What if you reed to write to a file?

You could use the `open` context manager again:

```python
with open('.editorconfig') as config:
    config.write('# config goes here')
```

Or you could use the `write_text` method:

```python
Path('.editorconfig').write_text('# config goes here')
```

If you just need to "touch" a file (creating an empty file only if it doesn't exist already):

```python
from os import utime

filename = '.editorconfig'
try:
    utime(filename, None)
except OSError:
    open(filename, mode='ab').close()
```

Or you could use the `touch` method on your `Path` object:

```python
from pathlib import Path

Path('.editorconfig').touch()
```

If you prefer using `open`, whether as a context manager or otherwise, you could instead use the `open` method on your `Path` object:

```python
from pathlib import Path

path = Path('.editorconfig')
with path.open(mode='wt') as config:
    config.write('# config goes here')
```

Or, as of Python 3.6, you can even pass your `Path` object to the built-in `open` function:

```python
from pathlib import Path

path = Path('.editorconfig')
with open(path, mode='wt') as config:
    config.write('# config goes here')
```


## Path objects make your code more explicit

What do the following 3 variables point to?
What do their values represent?

```python
person = '{"name": "Trey Hunner", "location": "San Diego"}'
pycon_2019 = "2019-05-01"
home_directory = '/home/trey'
```

Each of those variables points to a string.

Those strings represent different things: one is a JSON blob, one is a date, and one is a file path.

These are a little bit more useful representations for these objects:

```python
from datetime import date
from pathlib import Path

person = {"name": "Trey Hunner", "location": "San Diego"}
pycon_2019 = date(2019, 5, 1)
home_directory = Path('/home/trey')
```

JSON objects deserialize to dictionaries, dates are represented natively using `datetime.date` objects, and filesystem paths can now be generically represented using `pathlib.Path` objects.

**Using `Path` objects makes your code more explicit**.
If you're trying to represent a date, you can use a `date` object.
If you're trying to represent a filepath, you can use a `Path` object.


## Path objects are a useful abstraction

I'm not a strong advocate of object-oriented programming.
Classes add another layer of abstraction and abstractions can sometimes add more complexity than simplicity.
But the `pathlib.Path` class is a good example of when you *should* use a class.

Working with filesystem paths involves state (the path string) and functionality (the operations we can do with a path).
That's exactly when a class can come in handy.
These `Path` objects are meant to be immutable just as strings are, so their methods return new paths which allows for nicely chainable code.

So while classes aren't always wonderful, **the `pathlib.Path` class is a useful abstraction**.


## Path objects are accepted all over now

Not only is this `Path` class a useful abstraction, it's also quickly becoming a universally recognized abstraction.

Thanks to [PEP 519][], file path objects are now becoming the standard for working with paths.
As of Python 3.6, the built-in `open` function and the various functions in the `os`, `shutil`, and `os.path` modules all work properly with `pathlib.Path` objects.

Third party libraries are also expected to start working appropriately with `Path` objects.
Most libraries will likely continue to return string-based paths, but `Path` objects being accepted by Python itself means that many of the path-related utilities that these libraries include will sometimes just accept `Path` objects with minimal changes or without any changes at all.


## Path-like objects: a new protocol

In Python we don't usually use strict typing checking.
Instead we tend to practice [duck typing][]: if it walks like a duck and quacks like a duck, it's a duck.

Instead of caring whether something is a list or a dictionary, we care whether it's a *sequence* or a *mapping*.
Instead of caring whether we're working with a function or a generator, we care whether we've been given a *callable* or an *iterable*.
We embrace duck typing so much that we don't even distinguish between actual files and fake files: the Python glossary lists [file-like object as a synonym for file object][file object].

In Python we call these abstract types protocols  (like informal interfaces because we don't have actual interfaces).  We have an iterator protocol, context manager protocol, and a buffer protocol among others.
Now we also have a path-like protocol, which [path-like objects][] should adhere to.

A path-like object should either be a string (as paths were up until now) or it should have a `__fspath__` method, which `pathlib.Path` objects have.
If we wanted to invent our own path-like object, we could inherit from `os.PathLike` or just make a class with a `__fspath__` method.

If you have a path-like object (regardless of whether it's a string or an object with `__fspath__`):

```python
from pathlib import Path

path1 = '/home/trey'
path2 = Path('/home/trey')
```

You can normalize it to a string by calling `os.fspath` on it:

```pycon
>>> from os import fspath
>>> fspath(path1)
'/home/trey'
>>> fspath(path2)
'/home/trey'
```

Or you can normalize it to a `pathlib.Path` object by passing it to `pathlib.Path`:

```pycon
>>> Path(path1)
PosixPath('/home/trey')
>>> Path(path2)
PosixPath('/home/trey')
```

We now have a fairly nice abstraction specifically for representing file paths in Python!


## Some pathlib'd code examples

Let's take a look at a couple examples of code that's been converted to embrace `pathlib`.

This program accepts a string representing a directory and prints the contents of the `.gitignore` file in that directory if one exists:


```python
import os.path
import sys


directory = sys.argv[1]
ignore_filename = os.path.join(directory, '.gitignore')
if os.path.isfile(ignore_filename):
    with open(ignore_filename, mode='rt') as ignore_file:
        print(ignore_file.read(), end='')
```


This is the same code using `pathlib.Path`:

```python
from pathlib import Path
import sys


directory = Path(sys.argv[1])
ignore_path = directory / '.gitignore'
if ignore_path.is_file():
    print(ignore_path.read_text(), end='')
```

Instead of using `os.path.join`, we're using the `/` operator which `Path` objects have overridden in a neat way.
Instead of using `os.path.isfile` we're relying on the `is_file` method on our `Path` object.
Instead of using the built-in `open` to read all contents of the file, we just use the `read_text` method.

Here's another example:

```python
from collections import defaultdict
from hashlib import md5
from os import cwd, walk
import os.path


def find_files(filepath):
    for root, directories, filenames in walk(filepath):
        for filename in filenames:
            yield os.path.join(root, filename)


file_hashes = defaultdict(list)
for path in find_files(cwd()):
    with open(path, mode='rb') as my_file:
        file_hash = md5(my_file.read()).hexdigest()
        file_hashes[file_hash].append(path)

for paths in file_hashes.values():
    if len(paths) > 1:
        print("Duplicate files found:")
        print(*paths, sep='\n')
```

The above code prints all groups of files in and below the current working directory which are duplicates (judged by a hash of their file contents).

This is the same code that uses `pathlib.Path` instead:

```python
from collections import defaultdict
from hashlib import md5
from pathlib import Path


def find_files(filepath):
    for path in Path(filepath).rglob('*'):
        if path.is_file():
            yield path


file_hashes = defaultdict(list)
for path in find_files(Path.cwd()):
    file_hash = md5(path.read_bytes()).hexdigest()
    file_hashes[file_hash].append(path)

for paths in file_hashes.values():
    if len(paths) > 1:
        print("Duplicate files found:")
        print(*paths, sep='\n')
```

I tend to find that using `pathlib` often makes my code more readable at a glance.
My code still might not be pretty, but it's often *prettier* with `pathlib`.


## What's missing from pathlib?

While `pathlib` is great, it's not all-encompassing.
There are definitely a few missing features I've stumbled upon that I wish the `pathlib` included.

The first gap I've noticed is the lack of `shutil` equivalents within the `pathlib.Path` methods.

While you can pass `Path` objects (and path-like objects) to the higher-level `shutil` functions for copying/deleting/moving files and directories, there's no equivalent to these functions on `Path` objects.

So to copy a file you still have to do something like this:

```python
from pathlib import Path
from shutil import copyfile

source = Path('old_file.txt')
destination = Path('new_file.txt')
copyfile(source, destination)
```

There's also no `pathlib` equivalent of `os.chdir`.

This just means you'll need to import `chdir` if you ever need to change the current working directory:

```python
from pathlib import Path
from os import chdir

parent = Path('..')
chdir(parent)
```

The `os.walk` function has no `pathlib` equivalent either.
Though, as you can see from the duplicate-file finding example above, you can make your own `walk`-like functions using `pathlib` fairly easily.

Here's something that's somewhat similar to `os.walk`:

```python
def walk(directory):
    for path in directory.iterdir():
        if path.is_dir():
            yield from walk(path)
        else:
            yield path
```

My hope is that `pathlib.Path` objects might eventually include methods for some of these missing operations.
But even with these missing features, **I still find it much more manageable to use "`pathlib` and friends" than "`os.path` and friends"**.


## Should you use pathlib?

I think you should use `pathlib`.

If you're on Python 3.6 or above, `pathlib.Path` objects work pretty much everywhere you're already using path strings.
I see no reason *not* to use `pathlib` if you're at least on Python 3.6.

If you're on an earlier version of Python 3, you can always wrap your `Path` object in a `str` call to get a string out of it when you need an escape hatch back to string land.
It's awkward but it works:

```python
from os import chdir
from pathlib import Path

chdir(Path('/home/trey'))  # Works on Python 3.6+
chdir(str(Path('/home/trey')))  # Works on earlier versions also
```

Regardless of which version of Python 3 you're on, I would recommend using `pathlib`.

And if you're stuck on Python 2 still (the clock is ticking!) the third-party [pathlib2][] module on PyPI is a backport so you can use `pathlib` on any version of Python.

I find that using `pathlib` often makes my code more readable.
If you can use `pathlib`, you should.


[wonderful]: https://jefftriplett.com/2017/pathlib-is-wonderful/
[duck typing]: https://en.wikipedia.org/wiki/Duck_typing
[pep 519]: https://www.python.org/dev/peps/pep-0519/#standard-library-changes
[file object]: https://docs.python.org/3/glossary.html#term-file-object
[path-like objects]: https://docs.python.org/3/glossary.html#term-path-like-object
[pathlib2]: https://github.com/mcmtroffaes/pathlib2
