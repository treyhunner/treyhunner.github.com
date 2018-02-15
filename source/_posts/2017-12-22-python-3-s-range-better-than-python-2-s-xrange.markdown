---
layout: post
title: "Python 3's range is more powerful than Python 2's xrange"
date: 2018-02-15 08:00:00 -0800
comments: true
categories: python
---

If you're switching between Python 2 and Python 3, you might think that Python 2's `xrange` objects are pretty much the identical to Python 3's `range` object.  It seems like they probably just renamed `xrange` to `range`, right?

Not quite.

Python 2's `xrange` is somewhat more limited than Python 3's `range`.  In this article we're going to take a look at how `xrange` in Python 2 differs from `range` in Python 3.


## Python 2 vs Python 3: range

The first thing I need to address is how `range` works in Python 2 and Python 3.

In Python 2, the `range` function returned a list of numbers:

```pycon
>>> range(5)
[0, 1, 2, 3, 4]
```

And the `xrange` class represented an iterable that provided the same thing when looped over, but it was lazy:

```pycon
>>> xrange(5)
xrange(5)
```

This laziness was really embraced in Python 3.  In Python 3, they removed the original `range` function and renamed `xrange` to `range`:

```pycon
>>> range(5)
range(0, 5)
```

So if you wanted the Python 2 behavior for `range` in Python 3, you could always convert the `range` object to a list:

```pycon
>>> list(range(5))
[0, 1, 2, 3, 4]
```

Okay now let's compare Python 2's `xrange` class to Python 3's `range` class.


## Similarities

Before we take a look at differences between `xrange` and `range` objects, let's take a look at some of the similarities.

Python 2's `xrange` has a fairly descriptive string representation:

```pycon
>>> xrange(10)
xrange(10)
```

And so does Python 3's `range` object:

```pycon
>>> range(10)
range(0, 10)
```

The `xrange` object in Python 2 is an iterable (anything you can loop over is an iterable):

```pycon
>>> for n in xrange(3):
...     print n
...
0
1
2
```

And the `range` object in Python 3 is also an iterable:

```pycon
>>> for n in range(3):
...     print(n)
...
0
1
2
```

The `xrange` object has a start, stop, and step.  Step is optional and so is start:

```pycon
>>> xrange(0, 5, 1)
xrange(5)
>>> xrange(0, 5)
xrange(5)
>>> xrange(5)
xrange(5)
>>> list(xrange(0, 10, 3))
[0, 3, 6, 9]
```

So does the `range` object:

```pycon
>>> range(0, 5, 1)
range(0, 5)
>>> range(0, 5)
range(0, 5)
>>> range(5)
range(0, 5)
>>> list(range(0, 10, 3))
[0, 3, 6, 9]
```

Both have a length and both can be indexed in forward or reverse order:

```pycon
>>> len(xrange(5))
5
>>> xrange(0, 5)[3]
3
>>> xrange(0, 5)[-1]
4
```

Python considers both `range` and `xrange` to be sequences:

```pycon
>>> from collections import Sequence
>>> isinstance(xrange(10), Sequence)
True
```

So much of the basic functionality is the same between `xrange` and `range`.  Let's talk about the differences.


## Dunder Methods

The first difference we'll look at is the built-in documentation that exists for Python 2's `xrange` and Python 3's `range`.

If we use the `help` function to ask `xrange` for documentation, we'll see a number of dunder methods.  Dunder methods are what Python uses when you use many operators on objects (like `+` or `*`) as well as other features shared between different objects (like the `len` and `str` functions).

Here are the core dunder methods which Python 2's `xrange` objects fully implement:

     |  __getitem__(...)
     |      x.__getitem__(y) <==> x[y]
     |
     |  __iter__(...)
     |      x.__iter__() <==> iter(x)
     |
     |  __len__(...)
     |      x.__len__() <==> len(x)
     |
     |  __reduce__(...)
     |
     |  __repr__(...)
     |      x.__repr__() <==> repr(x)
     |
     |  __reversed__(...)
     |      Returns a reverse iterator.


And here are the core dunder methods which Python 3's `range` objects fully implement:

     |  __contains__(self, key, /)
     |      Return key in self.
     |
     |  __eq__(self, value, /)
     |      Return self==value.
     |
     |  __getitem__(self, key, /)
     |      Return self[key].
     |
     |  __iter__(self, /)
     |      Implement iter(self).
     |
     |  __len__(self, /)
     |      Return len(self).
     |
     |  __ne__(self, value, /)
     |      Return self!=value.
     |
     |  __repr__(self, /)
     |      Return repr(self).
     |
     |  __reversed__(...)
     |      Return a reverse iterator.
     |
     |  count(...)
     |      rangeobject.count(value) -> integer -- return number of occurrences of value
     |
     |  index(...)
     |      rangeobject.index(value, [start, [stop]]) -> integer -- return index of value.
     |      Raise ValueError if the value is not present.

Notice that `range` objects support many more operations than `xrange` does.  Let's take a look at some of them.


## Comparability

Python 3's `range` support equality checks:

```pycon
>>> range(4) == range(5)
False
>>> range(5) == range(5)
True
```

Python 2's `xrange` objects may seem like they support equality:

```pycon
>>> xrange(4) == xrange(5)
False
```

But they're actually falling back to Python's default identity check:

```pycon
>>> xrange(5) == xrange(5)
False
```

Two `xrange` objects will not be seen as equal unless they are actually the same exact object:

```pycon
>>> a = xrange(5)
>>> b = xrange(5)
>>> a == a
True
>>> a == b
False
```

Whereas a comparison between two `range` objects in Python 3 actually checks whether the start, stop, and step of each object is equal:

```pycon
>>> a = range(1, 10, 2)
>>> b = range(1, 10, 2)
>>> a == a
True
>>> a == b
True
```


## Sliceabiltiy

We already saw that both Python 2's `xrange` and Python 3's `range` support indexing:

```pycon
>>> range(10)[3]
3
>>> range(10)[-1]
9
```

Python 3's `range` object also supports slicing:

```pycon
>>> range(10)[2:]
range(2, 10)
>>> range(10)[3:8:-1]
range(3, 8, -1)
```

But `xrange` doesn't:

```pycon
>>> xrange(10)[2:]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: sequence index must be integer, not 'slice'
```

## Containment

Both `range` and `xrange` support containment checks:

```pycon
>>> 5 in xrange(10)
True
```

But this support is a little deceptive with `xrange`.  Python 2's `xrange` objects don't actually implement the `__contains__` method that is used to implement Python's `in` operator.

So while we can ask whether an `xrange` object contains a number, in order to answer our question Python will have to manually loop over the `xrange` object until it finds a match.

This takes about 20 seconds to run on my computer in Python 2.7.12:

```pycon
>>> -1 in xrange(1000000000)
False
```

But in Python 3 this returns an answer immediately:

```pycon
>>> -1 in range(1000000000)
False
```

Python 3 is able to return an answer immediately for `range` objects because it can compute an answer based off the start, stop, and step we provided.

## Start, stop, and step

In Python 3, `range` objects have a start, stop, and step:

```pycon
>>> numbers = range(10)
>>> numbers.start
0
>>> numbers.stop
10
>>> numbers.step
1
```

These can be useful when playing with or extending the capability of `range`.

We might for example wish that `range` objects could be negated to get a mirrored `range` on the opposite side of the number line:

```pycon
>>> numbers = range(5, 20)
>>> -numbers
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: bad operand type for unary -: 'range'
```

While `range` objects don't support this feature, we could implement something similar by negating the start, stop, and step ourselves and making a new `range`:

```pycon
>>> numbers = range(5, 20)
>>> range(-numbers.start, -numbers.stop, -numbers.step)
range(-5, -20, -1)
```

While you can provide start, stop, and step as arguments to Python 2's `xrange` objects, they don't have these start, stop, and step **attributes** at all:

```pycon
>>> numbers = xrange(10)
>>> numbers.start
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'xrange' object has no attribute 'start'
```

If you wanted to get start, stop, and step from an `xrange` object, you would need to calculate them manually.  Something like this might work:

```pycon
>>> numbers = xrange(10)
>>> start, stop, step = numbers[0], numbers[-1]+1, numbers[1]-numbers[0]
>>> start
0
>>> stop
10
>>> step
1
```


## Is any of this important to know?

Most of the time you use either Python 2's `xrange` objects or Python 3's `range` objects, you'll probably just be creating them and looping over them immediately:

```pycon
>>> for n in range(0, 10, 3):
...     print(n)
...
0
3
6
9
```

So the missing `xrange` features I noted above don't matter most of the time.

However, there are times when it's useful to have a sequence of consecutive numbers that supports features like slicing, fast containment checks, or equality.  In those cases, Python 2 users will be tempted to fall back to the Python 2 `range` function which returns a list.  In Python 3 though, you'll pretty much always find what you're looking for in the `range` class.  For pretty much every operation you'll want to perform, **Python 3's `range` is fast, memory-efficient, and powerful**.

Python 3 put a lot of work into making sure its built-ins are memory efficient and fast.  Many built-in functions (e.g. `zip`, `map`, `filter`) now return iterators and lazy objects instead of lists.

At the same time, Python 3 made common functions and classes, like `range`, more featureful.

There are many big improvements that Python 3 made over Python 2, but there are **many many more tiny benefits to upgrading to Python 3**.  If you haven't already, I'd strongly consider whether it makes sense for you to upgrade your code to Python 3.
