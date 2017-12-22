---
layout: post
title: "Python 3's range: better than Python 2's xrange"
date: 2017-12-22 08:23:24 -0800
comments: true
categories: 
---

If you're switching between Python 2 and Python 3, you might think that Python 2's `xrange` objects are pretty much the identical to Python 3's `range` object.  It seems like they probably just renamed `xrange` to `range`, right?

Wrong.

Python 2's `xrange` object are somewhat more limited than Python 3's `range` objects.  In this article we're going to take a look at how `xrange` in Python 2 differs from `range` in Python 3.


## Similarities

Before we take a look at differences between `xrange` and `range` objects, let's take a look at some of the similarities.

The ``xrange`` object can be looped over (it's an iterable):

```python
>>> for n in xrange(0, 10, 4):
...     print n
...
0
4
8
```

And the ``range`` object is also an iterable:

```python
>>> for n in range(0, 10, 3):
...     print(n)
...
0
3
6
9
```

The ``xrange`` object has a start, stop, and step.  Step is optional and so is start:

```python
>>> xrange(0, 5, 1)
xrange(5)
>>> xrange(0, 5)
xrange(5)
>>> xrange(5)
xrange(5)
```

So does the range object:

```python
>>> range(0, 5, 1)
range(0, 5)
>>> range(0, 5)
range(0, 5)
>>> range(5)
range(0, 5)
```

Both have a length and both can be indexed in forward or reverse order:

```python
>>> len(xrange(5))
5
>>> xrange(0, 5)[3]
3
>>> xrange(0, 5)[-1]
4
```

Much of the basic functionality is the same between `xrange` and `range`.  Let's talk about the differences.


## Dunder Methods

The first difference we'll look at is the documentation for Python 2's `xrange` and Python 3's `range`.o

If we use the `help` function to ask `xrange` for documentation, we'll get see a number of dunder methods.  Dunder methods are Python uses to implement a operators and functionality which are shared between a number of Python objects.

Here are the core dunder methods implemented on Python 2's `xrange` objects:

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


And here are the core dunder methods implemented on Python 3's `range` objects:

     |  __contains__(self, key, /)
     |      Return key in self.
     |
     |  __eq__(self, value, /)
     |      Return self==value.
     |
     |  __ge__(self, value, /)
     |      Return self>=value.
     |
     |  __getitem__(self, key, /)
     |      Return self[key].
     |
     |  __gt__(self, value, /)
     |      Return self>value.
     |
     |  __hash__(self, /)
     |      Return hash(self).
     |
     |  __iter__(self, /)
     |      Implement iter(self).
     |
     |  __le__(self, value, /)
     |      Return self<=value.
     |
     |  __len__(self, /)
     |      Return len(self).
     |
     |  __lt__(self, value, /)
     |      Return self<value.
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

Notice that `range` objects support many more operations than `xrange` does.  Let's take a look at some of them


## Comparability

Python 3's `range` support equality checks:

    >>> range(4) == range(5)
    False
    >>> range(5) == range(5)
    True

Python 2's `xrange` objects may seem like they support equality:

    >>> xrange(4) == xrange(5)
    False

But they're actually falling back to Python's default identity check:

    >>> xrange(5) == xrange(5)
    False

Two `xrange` objects will not be seen as equal unless they are actually the same exact object.


## Sliceabiltiy

Python 3's `range` object also supports slicing:

    >>> range(10)[3:8:-1]
    range(3, 8, -1)

But `xrange` doesn't:

	>>> xrange(10)[3:8:-1]
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	TypeError: sequence index must be integer, not 'slice'

## Containment

Both `range` and `xrange` support containment checks:

    >>> 5 in xrange(10)
    True

But this support is a little deceptive with `xrange`.

Python 2's `xrange` objects don't actually implement the `__contains__` method.  This means we can ask whether something is contained in an `xrange` object but Python will have to loop over the object to find the number we're looking for.

This takes about 20 seconds to run on my computer in Python 2.7.12:

    >>> 1000000000 in xrange(1000000000)
    False

In Python 3 this returns an answer immediately:

    >>> 1000000000 in range(1000000000)
    False

## Start, stop, and step

TODO
