---
layout: post
title: "Unique sentinel values, identity checks, and when to use object() instead of None"
date: 2019-03-20 07:30:00 -0700
comments: true
categories: python
---

Occasionally in Python (and in programming in general), you'll need an object which can be uniquely identified.
Sometimes this unique object represents a **stop value** or a **skip value** and sometimes it's an **initial value**.
But in each of these cases you want your object to stand out from the other objects you're working with.

When you need a unique value (a **sentinel value** maybe) `None` is often the value to reach for.
But sometimes `None` isn't enough: sometimes `None` is ambiguous.

In this article we'll talk about when `None` isn't enough, I'll show you how I create unique values when `None` doesn't cut it, and we'll see a few different uses for this technique.


## Initial values and default values

Let's re-implement a version of Python's built-in `min` function.

```python
def min(iterable, default=None):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = None
    for item in iterable:
        if minimum is None or item < minimum:
            minimum = item
    if minimum is not None:
        return minimum
    elif default is not None:
        return default
    else:
        raise ValueError("Empty iterable")
```

This `min` function, like the built-in one, returns the minimum value in the given iterable or raises an exception when an empty iterable is given unless a default value is specified (in which case the default is returned).

```python
>>> min([4, 3, 8, 7])
3
>>> min([9])
9
>>> min([])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 12, in min
ValueError: Empty iterable
>>> min([], default=9)
9
>>> min([4, 3, 8, 7], default=9)
3
```

This behavior is somewhat similar to the built-in `min` function, except **our code is buggy**!

There are two bugs here.

First, an iterable containing a single `None` value will be treated as if it was an empty iterable:

```python
>>> min([None], default=0)
0
>>> min([None])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 8, in min
ValueError: Empty iterable
```

Second, if we specify our `default` value as `None` this `min` function won't accept it:

```python
>>> min([], default='')
''
>>> min([], default=None)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 12, in min
ValueError: Empty iterable
```

Why is this happening?

It's all about `None`.


## Why is `None` a problem?

The first bug in our code is related to the initial value for `minimum` and the second is related to the default value for our `default` argument.
In both cases, **we're using `None` to represent an *unspecified* or *un-initialized* value**.

```python
def min(iterable, default=None):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = None
    for item in iterable:
        if minimum is None or item < minimum:
            minimum = item
    if minimum is not None:
        return minimum
    elif default is not None:
        return default
    else:
        raise ValueError("Empty iterable")
```

Using `None` is a problem in both cases because `None` is both a valid value for `default` and a valid value in our iterable.

Python's `None` value is useful for representing emptiness, but it isn't magical, at least not any more magical than any other valid value.

If we need a truly unique value for our default state, we need to invent our own.

When `None` isn't a valid input for your function, it's perfectly fine to use it to represent a unique default or initial state.
But `None` is often valid data, which means **`None` is sometimes a poor choice for a unique initial state**.

We'll fix both of our bugs by using `object()`: a somewhat common convention for creating a truly unique value in Python.

First we'll set `minimum` to a unique object:

```python
def min(iterable, default=None):
    """Imperfect re-implementation of Python's built-in min function."""
    initial = object()
    minimum = initial
    for item in iterable:
        if minimum is initial or item < minimum:
            minimum = item
    if minimum is not initial:
        return minimum
    elif default is not None:
        return default
    else:
        raise ValueError("Empty iterable")
```

That `initial` variable holds our unique value so we can check for its presence later.

This fixes the first bug:

```python
>>> min([None], default=0)
>>> min([None])
>>> min([])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 13, in min
ValueError: Empty iterable
```

But not the second.

To fix the second bug we need to use a different default value for our `default` argument (other than `None`).

To do this, we'll make a global "constant" (by convention) variable, `INITIAL`, outside our function:

```python
INITIAL = object()


def min(iterable, default=INITIAL):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = INITIAL
    for item in iterable:
        if minimum is INITIAL or item < minimum:
            minimum = item
    if minimum is not INITIAL:
        return minimum
    elif default is not INITIAL:
        return default
    else:
        raise ValueError("Empty iterable")
```

Now our code works exactly how we'd hope it would:

```python
>>> min([None], default=0)
>>> min([None])
>>> min([], default=None)
>>> min([], default='')
''
>>> min([4, 3, 7, 8])
3
>>> min([4, 3, 7, 8], default=0)
3
>>> min([])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 12, in min
ValueError: Empty iterable
```

That's lovely... but what is this magical `object()` thing?
Why does it work, how does it work, and when should we use it?


## What is `object()`?

Every class in Python has a base class of `object` (in Python 3 that is... things were a bit weirder in Python 2).

So `object` is a class:

```python
>>> object
<class 'object'>
>>> type(object)
<class 'type'>
```

When we call `object` we're creating an "instance" of the object class, just as calling any other class (when given the correct arguments) will create instances of them:

```python
>>> set()
set()
>>> bytearray()
bytearray(b'')
>>> frozenset()
frozenset()
```

So we're creating an instance of `object`.
But... why?

Well, an instance of `object` shouldn't be seen as equal to any other object:

```python
>>> x = object()
>>> y = object()
>>> x == y
False
>>> x == 4
False
>>> x == None
False
>>> x == []
False
```

Except itself:

```python
>>> x = object()
>>> z = x
>>> x == z
True
```

Python's `None` is similar, except that *anyone* can get access to this unique `None` object anywhere in their code by just typing `None`.

```python
>>> x = None
>>> y = None
>>> x == y
True
>>> x = object()
>>> y = object()
>>> x == y
False
```

We needed a placeholder value in our code.
`None` is a lovely placeholder as long as **we don't need to worry about distinguishing between *our* `None` from *their* `None`**.

If `None` is valid *data*, it's no longer just a placeholder.
At that point, we need to start reaching for `object()` instead.


## Equality vs identity

I noted that `object()` isn't *equal* to anything else.
But we weren't actually checking for equality (using `==` or `!=`) in our function:

Instead of `==` and `!=`, we used `is` and `is not`.

```python
INITIAL = object()


def min(iterable, default=INITIAL):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = INITIAL
    for item in iterable:
        if minimum is INITIAL or item < minimum:
            minimum = item
    if minimum is not INITIAL:
        return minimum
    elif default is not INITIAL:
        return default
    else:
        raise ValueError("Empty iterable")
```

While `==` and `!=` are equality operators, `is` and `is not` are **identity operators**.

Python's `is` operator asks about the **identity** of an object: are the two objects on either side of the `is` operator actually the same exact object.

We're not just asking *are they equal*, but are they stored in *the same place in memory* and in fact refer to the same exact object.

Two of the variables below (`x` and `z`) point to the same object:

```python
>>> x = object()
>>> y = object()
>>> z = x
```

So while `y` has a unique ID in memory, `x` and `z` do not:

```python
>>> id(x)
140079600030400
>>> id(y)
140079561403808
>>> id(z)
140079600030400
```

Which means `x` is *identical* to `z`:

```python
>>> x is y
False
>>> x is z
True
```

By default, Python's `==` operator delegates to `is`.
Meaning unless two variables point to the exact some object in memory, `==` will return `False`:

```python
>>> x = object()
>>> y = object()
>>> z = x
>>> x == x
True
>>> x == y
False
>>> x == z
True
```

This is true *by default*... but many objects in Python overload the `==` operator to do much more useful things when we ask about equality.

```python
>>> 0 == 0.0
True
>>> [1, 2, 3] == [1, 2, 3]
True
>>> (1, 2) == (1, 3)
False
>>> {} == {}
True
```

Each object can **customize the behavior of `==`** to answer whatever question they'd like.

Which means someone could make a class like this:

```python
>>> class AlwaysEqual:
...     def __eq__(self, other):
...         return True
...
```

And suddenly our assumption about `==` with `object()` (or any other value) will fail us:

```python
>>> x = object()
>>> y = AlwaysEqual()
>>> x is y
False
>>> x == y
True
```


## Use identity to compare unique objects

The `is` operator, unlike `==`, is not overloadable.
**Unlike with `==`, there's no way to control or change what happens when you say `x is y`.**

There's a `__eq__` method, but there's no such thing as a `__is__` method.
Which means the `is` operator will never lie to you: it will always tell you whether two objects are one in the same.

If we use `is` instead of `==`, we could actually use any unique object to represent our unique `INITIAL` value.

Even an empty list:

```python
INITIAL = []


def min(iterable, default=INITIAL):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = INITIAL
    for item in iterable:
        if minimum is INITIAL or item < minimum:
            minimum = item
    if minimum is not INITIAL:
        return minimum
    elif default is not INITIAL:
        return default
    else:
        raise ValueError("Empty iterable")
```

An empty list might seem problematic in the same way as `None` was: but they're actually quite different.

We don't have any of the same issues as we did with `None` before:

```python
>>> min([[]], default=0)
[]
>>> min([[]])
[]
>>> min([], default=[])
[]
```

The reason is that `None` is a [singleton value][singletons].
That means that every time you say `None` in your Python code, you're referencing the exact same `None` object every time.

```python
>>> x = None
>>> y = None
>>> x is y
True
>>> id(x), id(y)
(94548887510464, 94548887510464)
```

Whereas every empty list we make creates a brand new list object:

```python
>>> x = []
>>> y = []
>>> x is y
False
>>> id(x), id(y)
(140079561624776, 140079598927432)
```

So while two independent empty lists may be *equal*, they aren't the same object:

```python
>>> x = []
>>> y = []
>>> x == y
True
>>> x is y
False
```

The objects that those `x` and `y` variables point to have **the same value** but are **not actually the same object**.


## None is a placeholder value

Python's `None` is lovely.
`None` is a universal placeholder value.
Need a placeholder?
Great!
Python has a great placeholder value and it's called `None`!

There are lots of places where Python itself actually uses `None` as a placeholder value also.

If you pass no arguments to the string `split` method, that's the same as passing a separator value of `None`:

```python
>>> s = "hello world"
>>> s.split()
['hello', 'world']
>>> s.split(None)
['hello', 'world']
```

If you pass in a `key` function of `None` to the `sorted` builtin, that's the same as passing in no `key` function at all:

```python
>>> sorted(s, key=None)
[' ', 'd', 'e', 'h', 'l', 'l', 'l', 'o', 'o', 'r', 'w']
>>> sorted(s)
[' ', 'd', 'e', 'h', 'l', 'l', 'l', 'o', 'o', 'r', 'w']
```

Python loves using `None` as a placeholder because it's often a pretty great placeholder value.

The issue with `None` only appears **if someone else could reasonably be using `None` as a non-placeholder input to our function**.
This is often the case when the caller of a function has a placeholder values (often `None`) in their inputs and the author of that function (that's us) needs a separate unique placeholder.

Using `None` to represent two different things at once is like having two identical-looking bookmarks in the same book: it's confusing!


## Creating unique non-None placeholders: why `object()`?

When we made that `INITIAL` value before, we were sort of inventing our own `None`-like object: an object that we could uniquely reference by using the `is` operator.

That `INITIAL` object we made should be completely unique: it shouldn't ever be seen in any arbitrary input that may be given to our function (unless someone made the strange decision to import `INITIAL` and reference it specifically).

Why `object()` though?
After all we could have used any unique object by creating an instance of pretty much any class:

```python
>>> INITIAL = []
>>> INITIAL == []
True
>>> INITIAL is []
False
```

Though it might have been even more clear to create our own class just for this purpose:

```python
class DummyClass:
    """Class that just creates unique objects."""

INITIAL = DummyClass()
```

But I'd argue that `object()` is the "right" thing to use here.

Everyone knows what `[]` means, but `object()` is mysterious, which is actually the reason I think it's a good choice in this case.

When we see an empty list we expect that list to be used *as a list* and when we see a class instance, we expect that class to *do something*.
But we don't actually want this object to *do* anything: **we only care about the uniqueness of this new object**.

We could have done this:

```python
>>> INITIAL = ['completely unique value']
```

But I find using `object()` less confusing than this because it's clear: readers won't have a chance to be confused by the listy-ness of a list.

```python
>>> INITIAL = object()  # completely unique value
```

Also if a confused developer Googles "what is `object()` in Python?" they might end up with [some sort of explanation][explanation].


## Other cases for non-None placeholders

There's a word I've been avoiding using up to this point.
I've only been avoiding it because I think I typically misuse it (or rather overuse it).
The word is [sentinel value][].

I suspect I overuse this word because I use it to mean any unique placeholder value, such as the `INITIAL` object we made before.
But most definitions I've seen use "sentinel value" to specifically mean a value which indicates the end of a list, a loop, or an algorithm.

Sentinel values are a thing that, when seen, indicate that something has finished.
I think of this as a **stop value**: when you see a sentinel value it's a signal that the loop or algorithm that you're in should terminate.

Before we weren't using a stop value so much as an **initial value**.

Here's an example of a stop value, a true sentinel value:

```python
from itertools import zip_longest

SENTINEL = object()

def strict_zip(*iterables):
    """Variation of ``zip`` which requires equal-length iterables."""
    for values in zip_longest(*iterables, fillvalue=SENTINEL):
        if SENTINEL in values:
            raise ValueError("Given iterables must have the same length.")
        yield values
```

We're using the unique `SENTINEL` value above to signal that we need to stop looping and raise an exception.
The presence of this value indicates that one of our iterables was a different length than the others and we need to handle this error case.


## Rely on identity checks for unique values

Note that we're implicitly relying on `==` above because we're saying `if SENTINEL in values` which actually loops over `values` looking for a value that is equal to `SENTINEL`.

If we wanted to be more strict (and possibly more efficient) we could rely on `is`, but we'd need to do some looping ourselves.
Fortunately Python's `any` function and a generator expression would make that a bit easier:

```python
from itertools import zip_longest

SENTINEL = object()

def strict_zip(*iterables):
    """Variation of ``zip`` which requires equal-length iterables."""
    for values in zip_longest(*iterables, fillvalue=SENTINEL):
        if any(v is SENTINEL for v in values):
            raise ValueError("Given iterables must have the same length.")
        yield values
```

I'm fine with either of these functions.  The first is a bit more readable even though this one is arguably a bit more correct.

Identity checks are often faster than equality checks (`==` has to call the `__eq__` method, but `is` does a straight memory ID check).
But identity checks are also a bit more *correct*: if it's uniqueness we care about, **a unique memory location is the ultimate uniqueness check**.

When writing code that uses **a unique object**, it's wise to **rely on identity rather than equality** if you can.


## This is what `is` was made for

If we care about *equality* (the value of an object) we use `==`, if we care about *identity* (the memory location) we use `is`.

If you search my Python code for ` is ` you'll pretty much only find the following things:

1. `x is None` (this is the most common thing you'll see)
2. `x is True` or `x is False` (sometimes my tests get picky about `True` vs truthiness)
3. `iter(x) is x` ([iterators][] are a different Python rabbit hole)
4. `x is some_unique_object`

Those first two are checking for a [singleton][singletons] value (as [recommended by PEP 8][pep8]).
The third one is checking if we've seen **the same object twice** (an iterator in this case).
And the fourth one is checking for the presence of these unique values we've been discussing.

The `is` operator checks whether two objects are exactly the same object in memory.
**You never want to use the `is` operator *except* for true identity checks**: [singletons][] (like `None`, `True`, and `False`), and checking for the same object again, and checking for our own unique values (sentinels, as I usually call them).


## So when would we use `object()`?

Oftentimes `None` is both the easy answer and the right answer for a unique placeholder value in Python, but sometimes you just need to invent your own unique placeholder value.
In those cases `object()` is a great tool to have in your Python toolbox.

When would we actually use `object()` for a uniqueness check in our own code?

I can think of a few cases:

2. **Unique initial values**: a starting value that should be distinguished from values seen later (`default` and `initial` in our `min` function)
3. **Unique stop values**: a value whose presence tells us to stop looping/processing (a true sentinel value, as in `strict_zip`)
4. **Unique skip values**: a value whose presence should be treated as an empty value to be skipped over (we didn't see this, but it comes up with utilities like `itertools.zip_longest` sometimes)

I hope this meandering through unique values has given you something (some non-`None` things) to think about.

May your `None` values be unambiguous and your identity checks be truly unique.


[sentinel value]: https://en.wikipedia.org/wiki/Sentinel_value
[explanation]: https://stackoverflow.com/questions/28306371/what-is-object-good-for
[magic string]: https://en.wikipedia.org/wiki/Magic_string
[singletons]: https://en.wikipedia.org/wiki/Singleton_pattern
[pep8]: https://pep8.org/#programming-recommendations
[iterators]: https://treyhunner.com/2016/12/python-iterator-protocol-how-for-loops-work/
