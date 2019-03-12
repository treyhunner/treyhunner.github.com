---
layout: post
title: "Initial, unique, empty, and sentinel values in Python"
date: 2019-03-12 06:24:45 -0700
comments: true
categories: python
---

Occasionally in Python (and in programming in general), you'll need an object which can be uniquely identified.
Sometimes this unique object represents a **stop value** or a **skip value** and sometimes it's an **initial value** or **default value**.
But in each of these cases you want your object to stand out from the other objects you're working with.

In this article we'll take a look at a few different ways to create these unique values that stand out from the rest and we'll wander through a few different uses for these unique values along the way.


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

This behavior is somewhat similar to the built-in `min` function, except **this code is buggy**!
There are actually two bugs here.

An iterable containing a single `None` value will be treated as if it was an empty iterable:

```python
>>> min([None], default=0)
0
>>> min([None])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 8, in min
ValueError: Empty iterable
```

Also if we specify our `default` value as `None` this `min` function won't accept it:

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

The first bug is related to the initial value for `minimum` and the second is related to the default value for our `default` argument.
In both cases, **we're using `None` to represent an *unspecified* or *un-initialized* value**.
This is a problem because `None` is a valid default value and it's a valid value in our iterable.

Python's `None` value is useful for representing emptiness, but it isn't magical, at least not any more magical than any other valid value.

When `None` isn't a valid input for your function, it's perfectly fine to use it to represent a unique default or initial state.
But `None` is often valid data, which means **`None` is sometimes a poor choice for a unique initial state**.

We can fix both of these bugs by creating a truly unique value to check our code with.

Here we've created an `initial` variable which points to a unique object which we check instead of `None`:

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

But it doesn't fix the second.

To fix the second bug we need to use a different default our `default` argument to a value other than `None`:

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

Every class in Python has a base class of `object` (in Python 3, things were a bit weirder in Python 2).

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
>>> str()
''
>>> bytearray()
bytearray(b'')
>>> zip()
<zip object at 0x7fa1f3e24c88>
>>> frozenset()
frozenset()
>>> property()
<property object at 0x7fa1f3e2a0e8>
>>> bool()
False
```

So we're creating an instance of `object`.
But... why?

Well, in an instance of `object` shouldn't be seen as equal to any other object:

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

This works because Python's `==` operator does an *identity check* by default.
Meaning unless two variables point to the exact some object in memory, `==` will return `False`:

```python
>>> x = object()
>>> y = object()
>>> z = x
>>> id(x)
140079600030336
>>> id(y)
140079600030400
>>> id(z)
140079600030336
>>> x == x
True
>>> x == y
False
>>> x == z
True
```

This is true *by default*... but many objects in Python overload the `==` operator to do much more useful things.
Numbers and strings are "equal" whenever you'd intuitively expect them to be:

```python
>>> x = 0
>>> y = 0.0
>>> id(x)
94548887873248
>>> id(y)
140079600424136
>>> x == y
True
```

And lists, tuples, dictionaries, and other data structures tend to be "equal" when they contain the same values:

```python
>>> [1, 2, 3] == [1, 2, 3]
True
>>> (1, 2) == (1, 3)
False
>>> {} == {}
True
```

So the `object` class is just using the *default* implementation for `==` which means `object` instances are only equal to themselves.
Which is handy.

We could have made our own class and used an instance of it the same way, but we have `object` already so there's no need.


## Equality is a problem

You might have noticed that in our `min` function code where we used `object()`, we didn't actually use `==` to compare with our unique `INITIAL` object.
Instead we used the `is` operator.

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

We used `is` instead of `==` and `is not` instead of `!=` above.

Let's say we changed our code to use equality and inequality instead:

```python
INITIAL = object()


def min(iterable, default=INITIAL):
    """Imperfect re-implementation of Python's built-in min function."""
    minimum = INITIAL
    for item in iterable:
        if minimum == INITIAL or item < minimum:
            minimum = item
    if minimum != INITIAL:
        return minimum
    elif default != INITIAL:
        return default
    else:
        raise ValueError("Empty iterable")
```

If someone made a class like this:

```python
class AlwaysEqual:
    def __eq__(self, other):
        return True
```

And then called the `min` function using this class in an iterable, our `min` function would think the iterable was empty:

```python
>>> min([AlwaysEqual()], default=0)
0
>>> min([AlwaysEqual()])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 12, in min
ValueError: Empty iterable
```

Our code breaks for this weird case because when we ask `minimum == INITIAL` or `minimum != INITIAL` we're delegating work to the `minimum` object, which has decided to override its `==` and `!=` operators in a strange and unhelpful way.

This might seem like a strange example (and it is) but my point is that we're asking the wrong question here.
We don't care whether the object we've found **is equal to** our `INITIAL` value, we care **whether it is** our `INITIAL` value.

Python's `is` operator asks about the **identity** of an object: are the two objects on either side of the `is` operator actually the same exact object.
In other words, are they stored in exactly the same place in memory and therefore are the same object:

```python
>>> x = object()
>>> y = AlwaysEqual()
>>> z = x
>>> x is y
False
>>> x is z
True
>>> id(x)
140079600030400
>>> id(y)
140079561403808
>>> id(z)
140079600030400
>>> x
<object object at 0x7f66d2ccd2c0>
>>> y
<__main__.AlwaysEqual object at 0x7f66d07f6da0>
>>> z
<object object at 0x7f66d2ccd2c0>
```

The `is` operator, unlike `==`, is not overloadable.
Unlike `==`, there's no way to control or change what happens when you say `x is y`.
The `is` operator will always tell you whether those two objects are one in the same.

If you've never seen `is`, [here's an article on `==` vs `is`][identity vs equality]


## Sentinel values

That `INITIAL` value we made above is sort of like a [sentinel value][].
A sentinel value is a "stop value": when you see a sentinel value it's a signal that the loop or algorithm that you're in should terminate.

Like a sentinel value, our `INITIAL` object we made should be completely unique: it shouldn't ever be seen in any arbitrary input that may be given to our function.

We could use other sentinel values besides `object()`.
For example we could have created our own class and made an instance of it:

```python
class DummyClass:
    """Class that doesn't do anything."""

INITIAL = DummyClass()
```

Or we could have even created an instance of `list`, `set`, or `dict`:

```python
>>> INITIAL = []
```

That `DummyClass` and a new `list` instance might be *equal* to another object, but they won't be *identical* to anything but themselves:

```python
>>> INITIAL = []
>>> INITIAL == []
True
>>> INITIAL is []
False
```

So why didn't we use an empty list?
Everyone knows what `[]` means, but `object()` is mysterious, so wouldn't an empty list have been less confusing?

I'd argue that an empty list would actually be *more* confusing because when we see an empty list we expect it to be used *as a list*.  But we don't care about the list object at all here: **we only care about its uniqueness**.

This may have been more obvious:

```python
>>> INITIAL = ['completely unique value']
```

But I find this just as obvious:

```python
>>> INITIAL = object()  # completely unique value
```

Plus if a confused developer Googles "what is `object()`?" you might end up with [an explanation][explanation].


## Equality instead of identity

There's another reason to use `object()` instead of a list: we might not always check for identity.

Take this function:

```python
from itertools import zip_longest

SENTINEL = ['completely unique value']

def strict_zip(*iterables):
    """Variation of ``zip`` which requires equal-length iterables."""
    for values in zip_longest(*iterables, fillvalue=SENTINEL):
        if SENTINEL in values:
            raise ValueError("Given iterables must have the same length.")
        yield values
```

This function *zips* together given iterables, but raises an exception if they have a different number of items:

```python
>>> list(strict_zip([1, 2], ['a', 'b']))
[(1, 'a'), (2, 'b')]
>>> list(strict_zip([1, 2], ['a', 'b', 'c']))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 6, in strict_zip
ValueError: Given iterables must have the same length.
```

It works as expected, unless we pass in a list matching `['completely unique value']` as one of our values:

```python
>>> list(strict_zip([1, 2], ['a', ['completely unique value']]))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 6, in strict_zip
ValueError: Given iterables must have the same length.
```

This happens because we're relying on equality instead of identity.
There aren't any `==` signs in our function, but there's an implicit equality check: `if SENTINEL in values`.
When we use the `in` operator we're looping over `values` and checking if any of those values are equal to `SENTINEL` (which is our special list).

We're essentially using a [magic string][] here (really a magic list in this case).

This case might be very unlikely (after all, when is anyone going to pass in such a value).
I'd argue that someone passing in an object which returns `True` when equal to every other object (like that `AlwaysEqual` object from earlier) is even less likely.

So let's use `object()` instead:

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

Now the only thing we can pass in that would be "equal" to our sentinel value is something odd like `AlwaysEqual`:

```python
class AlwaysEqual:
    def __eq__(self, other): return True
```

```python
>>> list(strict_zip([1, 2], ['a', 'b']))
[(1, 'a'), (2, 'b')]
>>> list(strict_zip([1, 2], ['a', ['completely unique value']]))
[(1, 'a'), (2, ['completely unique value'])]
>>> class AlwaysEqual:
...     def __eq__(self, other): return True
...
>>> list(strict_zip([1, 2], ['a', AlwaysEqual()]))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 5, in strict_zip
ValueError: Given iterables must have the same length.
```

Which is unlikely, but still possible.


## Rely on identity checks for unique values

Using `object()` is a good practice because:

1. It isn't *equal* to anything else (except for odd things like `AlwaysEqual`).
2. It stands out more than some other random value would.  Its sole purpose is just to make a sentinel value (besides serving as the base class very every other object).

But when you're writing code that uses a sentinel value, it's wise to rely on identity rather than equality if you can.
Identity checks are often faster than equality checks (`==` has to call the `__eq__` method, but `is` is a hard-coded memory check).
But also they're just a bit more *correct*: if it's uniqueness we care about, a unique memory location is the ultimate uniqueness check.

So when possible try to rely on identity.
Sometimes it's a bit awkward, as in our `strip_zip` function before.

Instead of `if SENTINEL in values` we'd need to loop over `values` and ask `v is SENTINEL` for each.
Fortunately Python's `any` function and a generator expression would make this a bit easier:

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

That's not as straightforward as simply `SENTINEL in values`, but the readability isn't so much worse in this case.
I'd be fine with either function personally, as long as we're using 


## This is what `is` was made for

If we care about *equality* we use `==`, if we care about *identity* we use `is`.

If you search my Python code for " is " you'll pretty much only find the following things:

1. `x is None` (this is the most common thing you'll see)
2. `x is True` or `x is False` (sometimes my tests get picky about `True` vs truthiness)
3. `iter(x) is x` ([iterators][] are a different Python rabbit hole)
4. `x is some_sentinel`

Those first two are checking for a [singleton][singletons] value (as [recommended by PEP 8][pep8]).
The third one is checking if we've seen **the same object twice** (an iterator in this case).
And the fourth one is our sentinel value check we've been discussing.

The `is` operator checks whether two objects are exactly the same object in memory.

You never want to use the `is` operator *except* with unique values: sentinel values, [singletons][] (like `None`, `True`, and `False`), and checking for the same object again.


## So when would use use `object()`?

When would we practically use `object()` for a uniqueness check in our own code?

I can think of a few cases:

1. **Unique default values**: a passed-in value that must be unique by default
1. **Unique initial values**: a starting value that should be distinguished from values seen later
2. **Unique stop values**: a value whose presence tells us to stop looping/processing (a true sentinel value)
2. **Unique skip values**: a value whose presence should be treated as an empty value to be skipped over


[sentinel value]: https://en.wikipedia.org/wiki/Sentinel_value
[explanation]: https://stackoverflow.com/questions/28306371/what-is-object-good-for
[magic string]: https://en.wikipedia.org/wiki/Magic_string
[singletons]: https://en.wikipedia.org/wiki/Singleton_pattern
[pep8]: https://pep8.org/#programming-recommendations
[iterators]: https://treyhunner.com/2016/12/python-iterator-protocol-how-for-loops-work/
[identity vs equality]: https://www.blog.pythonlibrary.org/2017/02/28/python-101-equality-vs-identity/
