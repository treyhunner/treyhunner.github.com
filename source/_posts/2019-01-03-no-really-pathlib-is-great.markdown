---
layout: post
title: "No really, pathlib is great"
date: 2019-01-15 11:20:00 -0800
comments: true
categories: python
---

I recently [published an article about Python's pathlib module][original article] and how I think everyone should be using it.

I won some [pathlib][] converts, but some folks also brought up concerns.
Some folks noted that I seemed to be comparing `pathlib` to `os.path` in a disingenuous way.
Some people were also concerned that `pathlib` will take a very long time to be widely adopted because `os.path` is so entrenched in the Python community.
And there were also concerns expressed about performance.

In this article I'd like to acknowledge and address these concerns.
This will be both a defense of `pathlib` and a sort of love letter to [PEP 519][].

<ul data-toc=".entry-content"></ul>


## Comparing pathlib and os.path the right way

In my last article I compared this code which uses `os` and `os.path`:

```python
import os
import os.path

os.makedirs(os.path.join('src', '__pypackages__'), exist_ok=True)
os.rename('.editorconfig', os.path.join('src', '.editorconfig'))
```

To this code with uses `pathlib.Path`:

```python
from pathlib import Path

Path('src/__pypackages__').mkdir(parents=True, exist_ok=True)
Path('.editorconfig').rename('src/.editorconfig')
```

This might seem like an unfair comparison because I used `os.path.join` in the first example to ensure the correct path separator is used on all platforms but I didn't do that in the second example.
But this is in fact a fair comparison because **the Path class normalizes path separators automatically**.

We can prove this by looking at the string representation of this `Path` object on Windows:

```pycon
>>> str(Path('src/__pypackages__'))
'src\\__pypackages__'
```

No matter whether we use the `joinpath` method, a `/` in a path string, the `/` operator (which is a neat feature of `Path` objects), or separate arguments to the `Path` constructor, we get the same representation in all cases:

```pycon
>>> Path('src', '.editorconfig')
WindowsPath('src/.editorconfig')
>>> Path('src') / '.editorconfig'
WindowsPath('src/.editorconfig')
>>> Path('src').joinpath('.editorconfig')
WindowsPath('src/.editorconfig')
>>> Path('src/.editorconfig')
WindowsPath('src/.editorconfig')
```

That last expression caused some confusion from folks who assumed `pathlib` wouldn't be smart enough to convert that `/` into a `\` in the path string.
Fortunately, it is!

With `Path` objects, you never have to worry about backslashes vs forward slashes again: specify all paths using forward slashes and you'll get what you'd expect on all platforms.


## Normalizing file paths shouldn't be your concern

If you're developing on Linux or Mac, it's very easy to add bugs to your code that only affect Windows users.
Unless you're careful to use `os.path.join` to build your paths up or `os.path.normcase` to convert forward slashes to backslashes as appropriate, **you may be writing code that breaks on Windows**.

This is a Windows bug waiting to happen (we'll get mixed backslashes and forward slashes here):

```python
import sys
import os.path
directory = '.' if not sys.argv[1:] else sys.argv[1]
new_file = os.path.join(directory, 'new_package/__init__.py')
```

This just works on all systems:

```python
import sys
from pathlib import Path
directory = '.' if not sys.argv[1:] else sys.argv[1]
new_file = Path(directory, 'new_package/__init__.py')
```

It used to be the responsibility of you the Python programmer to carefully join and normalize your paths, just as it used to be your responsibility in Python 2 land to use unicode whenever it was more appropriate than bytes.
This is the case no more.
The `pathlib.Path` class is careful to fix path separator issues before they even occur.

I don't use Windows.
I don't own a Windows machine.
But a ton of the developers who use my code likely use Windows and I don't want my code to break on their machines.

**If there's a chance that your Python code will ever run on a Windows machine, you really need `pathlib`**.

**Don't stress about path normalization**: just use `pathlib.Path` whenever you need to represent a file path.


## pathlib seems great, but I depend on code that doesn't use it!

You have lots of code that works with path strings.
Why would you switch to using `pathlib` when it means you'd need to rewrite all this code?

Let's say you have a function like this:

```python
import os
import os.path

def make_editorconfig(dir_path):
    """Create .editorconfig file in given directory and return filename."""
    filename = os.path.join(dir_path, '.editorconfig')
    if not os.path.exists(filename):
        os.makedirs(dir_path, exist_ok=True)
        open(filename, mode='wt').write('')
    return filename
```

This function accepts a directory to create a `.editorconfig` file in, like this:

```pycon
>>> import os.path
>>> make_editorconfig(os.path.join('src', 'my_package'))
'src/my_package/.editorconfig'
```

But our code also works with a `Path` object:

```pycon
>>> from pathlib import Path
>>> make_editorconfig(Path('src/my_package'))
'src/my_package/.editorconfig'
```

But... how??

Well `os.path.join` accepts `Path` objects (as of Python 3.6).
And `os.makedirs` accepts `Path` objects too.

In fact the built-in `open` function accepts `Path` objects and `shutil` does and anything in the standard library that previously accepted a path string is now expected to work with both `Path` objects and path strings.

This is all thanks to [PEP 519][], which called for an `os.PathLike` abstract base class and declared that Python utilities that work with file paths should now accept either path strings or path-like objects.


## But my favorite third-party library X has a better Path object!

You might already be using a third-party library that has a `Path` object which works differently than pathlib's Path objects.
Maybe you even like it better.

For example [django-environ][], [path.py][], [plumbum][], and [visidata][] all have their own custom `Path` objects that represent file paths.
Some of these `pathlib` alternatives predate `pathlib` and chose to inherit from `str` so they could be passed to functions that expected path strings.
Thanks to PEP 519 both `pathlib` and its third-party alternatives can play nicely without needing to resort to the hack of inheriting from `str`.

Let's say you don't like `pathlib` because `Path` objects are immutable and you very much prefer using mutable `Path` objects.
Well thanks to [PEP 519][], you can create your own even-better-because-it-is-mutable `Path` and also has a `__fspath__`.
You don't *need* to use `pathlib` to benefit from it.

Any homegrown `Path` object you make or find in a third party library now has the ability to work natively with the Python built-ins and standard library modules that expect Path objects.
**Even if you don't like `pathlib`, its existence a big win for third-party `Path` objects as well**.


## But Path objects and path strings don't mix, do they?

You might be thinking: this is really wonderful, but won't this sometimes-a-string and sometimes-a-path-object situation add confusion to my code?

The answer is yes, somewhat.
But I've found that it's pretty easy to work around.

PEP 519 added a couple other things along with path-like objects: one is a way to convert all path-like objects to path strings and the other is a way to convert all path-like objects to `Path` objects.

Given either a path string or a `Path` object (or anything with a `__fspath__` method):

```python
from pathlib import Path
import os.path
p1 = os.path.join('src', 'my_package')
p2 = Path('src/my_package')
```

The `os.fspath` function will now normalize both of these types of paths to strings:

```pycon
>>> from os import fspath
>>> fspath(p1), fspath(p2)
('src/my_package', 'src/my_package')
```

And the `Path` class will now accept both of these types of paths and convert them to `Path` objects:

```pycon
>>> Path(p1), Path(p2)
(PosixPath('src/my_package'), PosixPath('src/my_package'))

```

That means you could convert the output of the `make_editorconfig` function back into a `Path` object if you wanted to:

```pycon
>>> from pathlib import Path
>>> Path(make_editorconfig(Path('src/my_package')))
PosixPath('src/my_package/.editorconfig')
```

Though of course a better long-term approach would be to rewrite the `make_editorconfig` function to use `pathlib` instead.


## pathlib is too slow

I've heard this concern come up a few times: `pathlib` is just too slow.

It's true that `pathlib` can be slow.
Creating thousands of `Path` objects can make a noticeable impact on your code.

I decided to test the performance difference between `pathlib` and the alternative on my own machine using two different programs that both look for all `.py` files below the current directory.

Here's the `os.walk` version:

```python
from os import getcwd, walk


extension = '.py'
count = 0
for root, directories, filenames in walk(getcwd()):
    for filename in filenames:
        if filename.endswith(extension):
            count += 1
print(f"{count} Python files found")
```

Here's the `Path.rglob` version:

```python
from pathlib import Path


extension = '.py'
count = 0
for filename in Path.cwd().rglob(f'*{extension}'):
    count += 1
print(f"{count} Python files found")
```

Testing runtimes for programs that rely on filesystem accesses is tricky because runtimes vary greatly, so I reran each script 10 times and compared the best runtime of each.

Both scripts found 97,507 Python files in the directory I ran them in.
The first one finished in 1.914 seconds (best out of 10 runs).
The second one finished in 3.430 seconds (best out of 10 runs).

When I set `extension = ''` these find about 600,000 files and the differences spread a little further apart.
The first runs in 1.888 seconds and the second in 7.485 seconds.

So the `pathlib` version of this program **ran twice as slow** for `.py` files and **four times as slow** for every file in my home directory.
**The `pathlib` code was indeed slower**, much slower percentage-wise.

But in my case, this speed difference doesn't matter much.
I searched for every file in my home directory and lost 6 seconds to the slower version of my code.
If I needed to scale this code to search 10 million files, I'd probably want to rewrite it.
But that's a problem I can get to if I experience it.

If you have a tight loop that could use some optimizing and `pathlib.Path` is one of the bottlenecks that's slowing that loop down, abandon `pathlib` in that part of your code.
But **don't optimize parts of your code that aren't bottlenecks**: it's a waste of time and often results in less readable code for little gain.


## Improving readability with pathlib

I'd like to wrap up these thoughts by ending with some `pathlib` refactorings.
I've taken a couple small examples of code that work with files and refactored these examples to use `pathlib` instead.
I'll mostly leave these code blocks without comment and let you be the judge of which versions you like best.

Here's the `make_editorconfig` function we saw earlier:

```python
import os
import os.path


def make_editorconfig(dir_path):
    """Create .editorconfig file in given directory and return filename."""
    filename = os.path.join(dir_path, '.editorconfig')
    if not os.path.exists(filename):
        os.makedirs(dir_path, exist_ok=True)
        open(filename, mode='wt').write('')
    return filename
```

And here's the same function using `pathlib.Path` instead:

```python
from pathlib import Path


def make_editorconfig(dir_path):
    """Create .editorconfig file in given directory and return filepath."""
    path = Path(dir_path, '.editorconfig')
    if not path.exists():
        path.parent.mkdir(exist_ok=True, parents=True)
        path.touch()
    return path
```

Here's a command-line program that accepts a string representing a directory and prints the contents of the `.gitignore` file in that directory if one exists:

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

And here's some code that prints all groups of files in and below the current directory which are duplicates:

```python
from collections import defaultdict
from hashlib import md5
from os import getcwd, walk
import os.path


def find_files(filepath):
    for root, directories, filenames in walk(filepath):
        for filename in filenames:
            yield os.path.join(root, filename)


file_hashes = defaultdict(list)
for path in find_files(getcwd()):
    with open(path, mode='rb') as my_file:
        file_hash = md5(my_file.read()).hexdigest()
        file_hashes[file_hash].append(path)

for paths in file_hashes.values():
    if len(paths) > 1:
        print("Duplicate files found:")
        print(*paths, sep='\n')
```

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

The changes here are subtle, but I think they add up.
I prefer this `pathlib`-refactored version.


## Start using pathlib.Path objects

Let's recap.

The `/` separators in `pathlib.Path` strings are automatically converted to the correct path separator based on the operating system you're on.
This is a huge feature that can make for code that is **more readable and more certain to be free of path-related bugs**.

```pycon
>>> path1 = Path('dir', 'file')
>>> path2 = Path('dir') / 'file'
>>> path3 = Path('dir/file')
>>> path3
WindowsPath('dir/file')
>>> path1 == path2 == path3
True
```

The Python standard library and built-ins (like `open`) also accept `pathlib.Path` objects now.
This means **you can start using pathlib, even if your dependencies don't**!

```python
from shutil import move

def rename_and_redirect(old_filename, new_filename):
    move(old, new)
    with open(old, mode='wt') as f:
        f.write(f'This file has moved to {new}')
```

```pycon
>>> from pathlib import Path
>>> old, new = Path('old.txt'), Path('new.txt')
>>> rename_and_redirect(old, new)
>>> old.read_text()
'This file has moved to new.txt'
```

And if you don't like `pathlib`, you can use a third-party library that provides the same path-like interface.
This is great because **even if you're not a fan of `pathlib` you'll still benefit from the new changes detailed in PEP 519**.

```pycon
>>> from plumbum import Path
>>> my_path = Path('old.txt')
>>> with open(my_path) as f:
...     print(f.read())
...
This file has moved to new.txt
```

While `pathlib` is sometimes slower than the alternative(s), the cases where this matters are somewhat rare (in my experience at least) and **you can always jump back to using path strings for parts of your code that are particularly performance sensitive**.

And in general, `pathlib` makes for more readable code.
Here's a succinct and descriptive Python script to demonstrate my point:

```python
from pathlib import Path
gitignore = Path('.gitignore')
if gitignore.is_file():
    print(gitignore.read_text(), end='')
```

The `pathlib` module is lovely: start using it!


[pathlib]: https://docs.python.org/3/library/pathlib.html
[pep 519]: https://www.python.org/dev/peps/pep-0519/#standard-library-changes
[duck typing]: https://en.wikipedia.org/wiki/Duck_typing
[path-like objects]: https://docs.python.org/3/glossary.html#term-path-like-object
[django-environ]: https://github.com/joke2k/django-environ
[path.py]: https://github.com/jaraco/path.py
[plumbum]: https://github.com/tomerfiliba/plumbum
[visidata]: https://github.com/saulpw/visidata
[original article]: https://treyhunner.com/2018/12/why-you-should-be-using-pathlib/
