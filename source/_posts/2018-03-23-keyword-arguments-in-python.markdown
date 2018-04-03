---
layout: post
title: "Keyword/Named Arguments in Python: How to Use Them"
date: 2018-03-23 11:23:08 -0700
comments: true
categories: python
---

Keyword arguments are one of those Python features that often seems a little odd for folks moving to Python from many other programming languages.  It doesn't help that folks learning Python often discover the various features of keyword arguments slowly over time.

When teaching Python, I've often wished I had a summary of the various keyword argument-related features that I could link learners to.  I hope that this article will accomplish that task.

In this article I'm going to explain what keyword arguments are and why they're used.  I'll then go over some more advanced uses of them that even long-time Python programmers may have overlooked because quite a few things have changed in recent versions of Python 3.  If you're already an experienced Python programmer, you might want to skip to the end.


## What are keyword arguments?

Let's take a look at what keyword arguments (also called "named arguments") are.

First let's take this Python function:

```python
from math import sqrt

def quadratic(a, b, c):
    x1 = -1 * b / (2 * a)
    x2 = sqrt(b ** 2 - 4 * a * c) / (2 * a)
    return (x1 + x2), (x1 - x2)
```

When we call this function, we can pass each of our three arguments in two different ways.

We can pass our arguments as positional arguments like this:

```pycon
>>> quadratic(31, 93, 62)
(-1.0, -2.0)
```

Or we can pass our arguments as keyword arguments like this:

```pycon
>>> quadratic(a=31, b=93, c=62)
(-1.0, -2.0)
```

The order of these arguments matters when they're passed positionally:

```pycon
>>> quadratic(31, 93, 62)
(-1.0, -2.0)
>>> quadratic(62, 93, 31)
(-0.5, -1.0)
```

But it doesn't matter when they're passed by their name:

```pycon
>>> quadratic(a=31, b=93, c=62)
(-1.0, -2.0)
>>> quadratic(c=62, b=93, a=31)
(-1.0, -2.0)
```

When we use keyword/named arguments, it's the name that matters, not the position:

```pycon
>>> quadratic(a=31, b=93, c=62)
(-1.0, -2.0)
>>> quadratic(c=31, b=93, a=62)
(-0.5, -1.0)
```

So unlike many other programming languages, Python knows the names of the arguments our function accepts.

If we ask for help on our function Python will tell us our three arguments by name:

```pycon
>>> help(quadratic)
Help on function quadratic in module __main__:

quadratic(a, b, c)
```

Note that functions can be called with a mix of positional and named arguments:

```pycon
>>> quadratic(31, 93, c=62)
(-1.0, -2.0)
```

## Why use keyword arguments?

When calling functions in Python, you'll often have the opportunity to use either keyword arguments or positional arguments.  Keyword arguments can often be used to make function calls more explicit.

Take this code:

```python
with GzipFile(None, 'wt', 9, output_file) as gzip_out:
    gzip_out.write(contents)
```

This takes a file object `output_file` and `contents` string and writes a gzipped version of the string to the output file.

This code does the same thing but it uses keyword arguments instead of positional arguments:

```python
with GzipFile(fileobj=output_file, mode='wt', compresslevel=9) as gzip_out:
    gzip_out.write(contents)
```

Notice that using this keyword argument call style made it more obvious what each of these three arguments represent.

We were also able to leave off an argument here.  The first argument that we left off represents a `filename` and already has a default value of `None`.  We don't need a `filename` here because we're supposed to pass either a file object or a filename to `GzipFile`, not both.

We're actually able to leave another argument off though.

Here's the same code again, but the compress level has been left at its default value of `9` this time:

```python
with GzipFile(fileobj=output_file, mode='wt') as gzip_out:
    gzip_out.write(contents)
```

We left out two arguments and we were able to rearrange the remaining 2 arguments in an order that made sense based on their significance (the file object is most important and the write text access mode is less important).

When we use keyword arguments:

1. We can often leave out arguments that have default values
2. We can rearrange arguments in a way that makes them most readable
3. We call arguments by their names to make it more clear what they represent


## Where you see keyword arguments

You'll likely see keyword arguments quite a bit in Python.

Python has a number of functions that take an unlimited number of positional arguments.  These functions sometimes have arguments that can be provided to customize their functionality.  Those arguments must be provided as named arguments to distinguish them from the positional arguments.

The built-in `print` function accepts the optional `sep`, `end`, `file`, and `flush` attributes this way:

```pycon
>>> print('comma', 'separated', 'words', sep=', ')
comma, separated, words
```

The `itertools.zip_longest` function accepts the optional `fillvalue` attribute this way also:

```pycon
>>> from itertools import zip_longest
>>> list(zip_longest([1, 2], [7, 8, 9], [4, 5], fillvalue=0))
[(1, 7, 4), (2, 8, 5), (0, 9, 0)]
```

Some functions in Python even force arguments to be named even when they could be specified positionally.

In Python 2, the `sorted` function accepted arguments positionally or as keyword arguments:

```pycon
>>> sorted([4, 1, 8, 2, 7], None, None, True)
[8, 7, 4, 2, 1]
>>> sorted([4, 1, 8, 2, 7], reverse=True)
[8, 7, 4, 2, 1]
```

But Python 3's `sorted` function requires all arguments after the iterable to be specified as keyword arguments:

```pycon
>>> sorted([4, 1, 8, 2, 7], None, True)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: must use keyword argument for key function
>>> sorted([4, 1, 8, 2, 7], reverse=True)
[8, 7, 4, 2, 1]
```

Python also uses supports keyword arguments in another of other places, for example the `format` method on strings:

```pycon
message = '{a}**2 + {b}**2 == {sum_of_squares}'.format(
    a=a,
    b=b,
    sum_of_squares=a**2 + b**2,
)
```


## Requiring your arguments be named

If you want to make a function that accepts any number of arguments and also accepts some keyword-only arguments, you can use a `*` operator to capture all the positional arguments and then specify optional keyword-only arguments after the `*` capture:

```python
def product(*numbers, initial=1):
    total = initial
    for n in numbers:
        total *= n
    return total
```

The initial argument in the above function must be specified as a keyword argument:

```pycon
>>> product(4, 4)
16
>>> product(4, 4, initial=1)
16
>>> product(4, 5, 2, initial=3)
120
```

Note that while `initial` has a default value, you can also specify required keyword-only arguments using this syntax:

```python
def join(*iterables, joiner):
    if not iterables:
        return
    yield from iterables[0]
    for iterable in iterables[1:]:
        yield joiner
        yield from iterable
```

The `joiner` variable here doesn't have a default value, so it must be specified when we call this function:

```pycon
>>> list(join([1, 2, 3], [4, 5], [6, 7], joiner=0))
[1, 2, 3, 0, 4, 5, 0, 6, 7]
>>> list(join([1, 2, 3], [4, 5], [6, 7], joiner='-'))
[1, 2, 3, '-', 4, 5, '-', 6, 7]
>>> list(join([1, 2, 3], [4, 5], [6, 7]))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: join() missing 1 required keyword-only argument: 'joiner'
```

Note that this syntax of putting arguments after the `*` only works in Python 3.  There's no syntactic way in Python 2 to require an argument to be named.


## Keyword-only arguments without positional arguments

What if you want to accept only keyword arguments without also accepting unlimited positional arguments?

If you want to accept keyword-only arguments and you're not using a `*` to accept any number of positional arguments, you can use a `*` without anything after it.

For example here's a modified version of Django's `django.shortcuts.render` function:

```python
def render(request, template_name, context=None, *, content_type=None, status=None, using=None):
    content = loader.render_to_string(template_name, context, request, using=using)
    return HttpResponse(content, content_type, status)
```

Unlike Django's current implementation of `render`, this version disallows calling `render` with all positional arguments.  We're only able to pass `context_type`, `status`, and `using` as keyword arguments.

Just like with unlimited positional arguments, these keyword arguments can be required.  Here's a function with four required keyword-only arguments:

```python
from random import choice, shuffle
UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LOWERCASE = UPPERCASE.lower()
DIGITS = "0123456789"
ALL = UPPERCASE + LOWERCASE + DIGITS

def random_password(*, upper, lower, digits, length):
    chars = [
        *(choice(UPPERCASE) for _ in range(upper)),
        *(choice(LOWERCASE) for _ in range(lower)),
        *(choice(DIGITS) for _ in range(digits)),
        *(choice(ALL) for _ in range(length-upper-lower-digits)),
    ]
    shuffle(chars)
    return "".join(chars)
```

This function requires all of its arguments to be specified using their name:

```pycon
>>> random_password(upper=1, lower=1, digits=1, length=8)
'oNA7rYWI'
>>> random_password(upper=1, lower=1, digits=1, length=8)
'bjonpuM6'
>>> random_password(1, 1, 1, 8)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: random_password() takes 0 positional arguments but 4 were given
```

Requiring arguments to be named can make calls to our function much more clear.

The purpose of this function call:

```python
random_password(upper=1, lower=1, digits=1, length=8)
```

Is much more obvious than this one:

```python
random_password(1, 1, 1, 8)
```

Again note that this syntax also only works in Python 3.


## Capturing arbitrary keyword arguments

What if you want to write a function that captures arbitrary of keyword arguments?

For example the string format method accepts any keyword argument you give it:

```pycon
>>> "My name is {name} and I like {color}".format(name="Trey", color="purple")
'My name is Trey and I like purple'
```

How can you write such a function?

Python allows functions to capture any keyword arguments provided to them using the `**` operator when defining a function:

```python
def format_attributes(**attributes):
    """Return a string of comma-separated key-value pairs."""
    return ", ".join(
        f"{param}: {value}"
        for param, value in attributes.items()
    )
```

That `**` operator will allow our `format_attributes` function to accept any number of keyword arguments.  The given arguments will be stored in a dictionary called `attributes`.

Here's an example use of our function:

```pycon
>>> format_attributes(name="Trey", website="http://treyhunner.com", color="purple")
'name: Trey, website: http://treyhunner.com, color: purple'
```

## Calling functions with arbitrary arguments

Just as you can define functions that take arbitrary keyword arguments, you can also call functions with arbitrary keyword arguments.

By this I mean that you can pass keyword arguments into a function based on items in a dictionary.

Here we're manually taking every key/value pair from a dictionary and passing them in as keyword arguments:

```pycon
>>> items = {'name': "Trey", 'website': "http://treyhunner.com", 'color': "purple"}
>>> format_attributes(name=items['name'], website=items['website'], color=items['color'])
'name: Trey, website: http://treyhunner.com, color: purple'
```

But this approach of hard-coding these keyword arguments requires that we have to know every key in our dictionary when we write our code.

We can do this for arbitrary keys in the dictionary by using the `**` operator to unpack our dictionary items into keyword arguments in our function call:

```pycon
>>> items = {'name': "Trey", 'website': "http://treyhunner.com", 'color': "purple"}
>>> format_attributes(**items)
'name: Trey, website: http://treyhunner.com, color: purple'
```

This ability to pass arbitrary keyword arguments into functions and to accept arbitrary keyword arguments inside functions (as we did before) is seen frequently when using inheritance:

```python
def my_method(self, *args, **kwargs):
    print('Do something interesting here')
    super().my_method(*args, **kwargs)  # Call parent method with all given arguments
```

Note we're also using the `*` operator here for doing the same kind of capturing and unpacking for positional arguments.


## Order matters

Since Python 3.6, the order of keyword arguments passed into a function is guaranteed to be preserved (see [PEP 468][]).

This means that using `**` to capture arguments passed to a function will result in a dictionary with keys in the same order the arguments were passed.  So since Python 3.6, you'll never see something like this happen:

```pycon
>>> format_attributes(name="Trey", website="http://treyhunner.com", color="purple")
'website: http://treyhunner.com, color: purple, name: Trey'
```

Instead arguments will always maintain the order they were passed in:

```pycon
>>> format_attributes(name="Trey", website="http://treyhunner.com", color="purple")
'name: Trey, website: http://treyhunner.com, color: purple'
```

## When to name your arguments

Using named arguments when calling functions be your code more readable.

An arguments position often doesn't convey as much meaning as its name.  So when calling functions, consider naming arguments that you pass in if it might make their meaning more clear.

When defining a function, also think about which arguments could be considerably more clear if specified as keyword arguments.  Consider requiring that those arguments by specified as keyword arguments by using `*`.

And remember that you can accept arbitrary keyword arguments to your function and pass arbitrary keyword arguments to functions you call.

[pep 468]: https://www.python.org/dev/peps/pep-0468/
