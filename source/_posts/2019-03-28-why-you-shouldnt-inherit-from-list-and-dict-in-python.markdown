---
layout: post
title: "Why you shouldn't inherit from dict and list in Python"
date: 2019-03-28 06:10:34 -0700
comments: true
categories: python
---

I've created dozens of [Python Morsels][] since I started it last year.
At this point at least 10 of these exercises involve making a custom collection: often a dict-like, list-like or set-like class.

Since each Python Morsels solutions email involves a walk-through of many ways to solve the same problem, I've solved each of these in many ways.
I've solved these manually with `__dunder__` methods, I've solved them the abstract base classes in [`collections.abc`][], I've solved them with [`collections.UserDict`][] and [`collections.UserList`][], and I've solved them by inheriting from `list`, `dict`, and `set` directly.

While creating and solving many exercises involving custom collections, I've realized that inheriting from `list`, `dict`, and `set` is often subtlety painful.
I'm writing this article to explain why I often don't recommend inheriting from the built-in `list`, `dict`, and `set` classes in Python.
My examples will focus on `list` and `dict` since those are likely more commonly sub-classed.


## Making a custom dictionary

We'd like to make a dictionary that's bi-directional.
When a key-value pair is added, the key maps to the value but the value also maps to the key.

There will always be an even number of elements in this dictionary.
And if `d[k] == v` is `True` then `d[v] == k` will always be `True` also.

We could try to implement this by customizing deletion and setting of key-value pairs.

```python
class TwoWayDict(dict):
    def __delitem__(self, key):
        value = super().pop(key)
        super().pop(value, None)
    def __setitem__(self, key, value):
        if key in self:
            del self[self[key]]
        if value in self:
            del self[value]
        super().__setitem__(key, value)
        super().__setitem__(value, key)
```

Here we're ensuring that:

- deleting keys will delete their corresponding values as well
- whenever we set a new value for `k` that any existing value will be removed properly
- whenever we set a key-value pair, that the corresponding value-key pair will be set too

Setting and deleting items from this bi-directional dictionary seems to work as we'd expect:

```python
>>> d = TwoWayDict()
>>> d[4] = 3
>>> d
{4: 3, 3: 4}
>>> d[3] = 8
>>> d
{3: 8, 8: 3}
>>> d[7] = 6
>>> d
{3: 8, 8: 3, 7: 6, 6: 7}
```

But calling the `update` method on this dictionary leads to odd behavior:

```python
>>> d
{3: 8, 8: 3, 7: 6, 6: 7}
>>> d.update({9: 7, 8: 2})
>>> d
{3: 8, 8: 2, 7: 6, 6: 7, 9: 7}
```

We could fix this with a custom `update` method:

```python
    def update(self, items):
        if isinstance(items, dict):
            items = items.items()
        for key, value in items:
            self[key] = value
```

But calling the initializer doesn't work either:

```python
>>> d = TwoWayDict({9: 7, 8: 2})
>>> d
{9: 7, 8: 2}
```

So we'll make a custom initializer that calls `update`:

```python
    def __init__(self, items=()):
        self.update(items)
```

But `pop` doesn't work:

```python
>>> d = TwoWayDict()
>>> d[9] = 7
>>> d
{9: 7, 7: 9}
>>> d.pop(9)
7
>>> d
{7: 9}
```

And neither does `setdefault`:

```python
>>> d = TwoWayDict()
>>> d.setdefault(4, 2)
2
>>> d
{4: 2}
```

The problem is the `pop` method doesn't actually call `__delitem__` and the `setdefault` method doesn't actually call `__setitem__`.

If we wanted to fix this problem, we have to completely re-implement `pop` and `setdefault`:


```python
DEFAULT = object()

class TwoWayDict(dict):
    # ...
    def pop(self, key, default=DEFAULT):
        if key in self or default is DEFAULT:
            return self[key]
        else:
            return default
    def setdefault(self, key, value):
        if key not in self:
            self[key] = value
```

This is all very tedious though.
When inheriting from `dict` to create a custom dictionary, we'd expect `update` and `__init__` would call `__setitem__` and `pop` and `setdefault` would call `__delitem__`.
But they don't!

Likewise, `get` and `pop` don't call `__getitem__`, as you might expect they would.

I'm not an aficionado of object-oriented programming, but the `dict` class seems to be violating at least one of the [SOLID][] principles (maybe the open-close principle?).


## Lists and sets have the same problem

The `list` and `set` classes have similar problems to the `dict` class.
Let's take a look at an example.

We'll make a custom list that inherits from the `list` constructor and overrides the behavior of `__delitem__`, `__iter__`, and `__eq__`.
This list will customize `__delitem__` to not actually *delete* an item but to instead leave a "hole" where that item used to be.
The `__iter__` and `__eq__` methods will skip over this hole when comparing two `HoleList` classes as "equal".

This class is a bit nonsensical (no it's not a Python Morsels exercise fortunately), but we're focused less on the class itself and more on the issue with inheriting from `list`:

```python
class HoleList(list):

    EMPTY = object()

    def __delitem__(self, index):
        self[index] = self.EMPTY

    def __iter__(self):
        return (
            item
            for item in self
            if item is not self.EMPTY
        )

    def __eq__(self, other):
        if isinstance(other, HoleList):
            return all(
                x == y
                for x, y in zip(self, other)
            )
        return super().__eq__(other)
```

If we make two `HoleList` objects and delete items from them such that they have the same non-hole items:

```python
>>> x = HoleList([2, 1, 3, 4])
>>> y = HoleList([1, 2, 3, 5])
>>> del x[0]
>>> del y[1]
>>> del x[-1]
>>> del y[-1]
```

We'll see that they're equal:

```python
>>> x == y
True
>>> list(x), list(y)
([1, 3], [1, 3])
>>> x
[<object object at 0x7fed214640f0>, 1, 3, <object object at 0x7fed214640f0>]
>>> y
[1, <object object at 0x7fed214640f0>, 3, <object object at 0x7fed214640f0>]
```

But if we then ask them whether they're *not equal* we'll see that they're both *equal* and *not equal*:

```python
>>> x == y
True
>>> x != y
True
>>> list(x), list(y)
([1, 3], [1, 3])
>>> x
[<object object at 0x7fed214640f0>, 1, 3, <object object at 0x7fed214640f0>]
>>> y
[1, <object object at 0x7fed214640f0>, 3, <object object at 0x7fed214640f0>]
```

Normally in Python 3, overriding `__eq__` would customize the behavior of both equality (`==`) and inequality (`!=`) checks.
But not for `list` or `dict`: they define both `__eq__` and `__ne__` methods which means we need to override both.

```python
    def __ne__(self, other):
        return not (self == other)
```

Dictionaries suffer from this same problem: `__ne__` exists which means we need to be careful to override both `__eq__` and `__ne__` when inheriting from them.

Also like dictionaries, the `remove` and `pop` methods on lists don't call `__delitem__`:

```python
>>> y
[1, <object object at 0x7fed214640f0>, 3, <object object at 0x7fed214640f0>]
>>> y.remove(1)
>>> y
[<object object at 0x7fed214640f0>, 3, <object object at 0x7fed214640f0>]
>>> y.pop(0)
<object object at 0x7fed214640f0>
>>> y
[3, <object object at 0x7fed214640f0>]
```

We could again fix these issues by re-implementing the `remove` and `pop` methods:

```python
    def remove(self, value):
        index = self.index(value)
        del self[index]
    def pop(self, index=-1):
        value = self[index]
        del self[index]
        return value
```

But this is a pain.
And who knows whether we're done?

Every time we customize a bit of core functionality on a `list` or `dict` subclass, we'll need to make sure we customize other methods that also include exactly the same functionality (but which don't delegate to the method we overrode).


## What's the alternative to inheriting from list and dict?

So what's a better way to do this?
How can we make a `list`-like object or a `dict`-like object that *doesn't* inherit from `list` or `dict`?

There are a few answers to this question:

1. Manually create all the methods we need: we'll need to re-implement *all* methods, so this might be very tedious
2. Inherit from an abstract base class that implements *some* of these higher-level methods for us: implementing `append` should give us `extend` for free
3. Inherit from a full re-implementation of `list` or `dict` that is more extensible and more easily customizable

We're not going to re-implement everything ourselves.
We'll take a look at the other two approaches though.


## Abstract base classes

We'll take a look at the abstract base class approach first.

Here's a re-implementation of `TwoWayDict` using the `MutableMapping` abstract base class.


```python
from collections.abc import MutableMapping


class TwoWayDict(MutableMapping):
    def __init__(self, data=()):
        self.mapping = {}
        self.update(data)
    def __getitem__(self, key):
        return self.mapping[key]
    def __delitem__(self, key):
        value = self[key]
        del self.mapping[key]
        self.pop(value, None)
    def __setitem__(self, key, value):
        if key in self:
            del self[self[key]]
        if value in self:
            del self[value]
        self.mapping[key] = value
        self.mapping[value] = key
    def __iter__(self):
        return iter(self.mapping)
    def __len__(self):
        return len(self.mapping)
    def __repr__(self):
        return repr(self.mapping)
```

The `MutableMapping` class requires us to implement `__getitem__`, `__delitem__`, `__setitem__`, `__iter__`, and `__len__`.

That might seem like quite a bit, but we get very reasonable default implementations of `update`, `pop`, `setdefault`, and `clear` for free.

Unlike `dict`, these `update` and `setdefault` methods will call our `__setitem__` method and the `pop` and `clear` methods will call our `__delitem__` method.

We could do the same thing with our `HoleList` class, inheriting from `MutableSequence` instead of `MutableMapping`:

```python
from collections.abc import MutableSequence


class HoleList(MutableSequence):

    EMPTY = object()

    def __init__(self, iterable):
        self.data = list(iterable)

    def __getitem__(self, index):
        return self.data[index]

    def __setitem__(self, index, value):
        self.data[index] = value

    def __delitem__(self, index):
        self.data[index] = self.EMPTY

    def __len__(self):
        return len(self.data)

    def insert(self, index, value):
        return self.data.insert(index, value)

    def __iter__(self):
        return (
            item
            for item in self.data
            if item is not self.EMPTY
        )

    def __eq__(self, other):
        if isinstance(other, HoleList):
            return all(
                x == y
                for x, y in zip(self, other)
            )
        return super().__eq__(other)
```

The `MutableSequence` class requires us to implement `__getitem__`, `__setitem__`, `__delitem__`, `__len__`, and `insert` and gives us `append`, `reverse`, `extend`, `pop`, `remove`, and `__iadd__` for free.


## Nice wrappers around list and dict

```python
from collections import UserDict


class TwoWayDict(UserDict):
    def __delitem__(self, key):
        value = self[key]
        super().__delitem__(key)
        self.pop(value, None)
    def __setitem__(self, key, value):
        if key in self:
            del self[self[key]]
        if value in self:
            del self[value]
        super().__setitem__(key, value)
        super().__setitem__(value, key)
```

[python morsels]: https://www.pythonmorsels.com/
[`collections.abc`]: TODO
[`collections.UserDict`]: TODO
[`collections.UserList`]: TODO
[solid]: TODO
