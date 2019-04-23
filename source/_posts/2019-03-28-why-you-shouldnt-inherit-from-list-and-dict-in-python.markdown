---
layout: post
title: "The problem with inheriting from dict and list in Python"
date: 2019-04-09 07:00:00 -0700
comments: true
categories: python
---

I've created dozens of [Python Morsels][] since I started it last year.
At this point at least 10 of these exercises involve making a custom collection: often a dict-like, list-like or set-like class.

Since each Python Morsels solutions email involves a walk-through of many ways to solve the same problem, I've solved each of these in many ways.

I've solved these:

- manually with `__dunder__` methods
- with the abstract base classes in [collections.abc][]
- with [collections.UserDict][UserDict] and [collections.UserList][UserList]
- by inheriting from `list`, `dict`, and `set` directly

While creating and solving many exercises involving custom collections, I've realized that inheriting from `list`, `dict`, and `set` is often subtly painful.
I'm writing this article to explain why I often don't recommend inheriting from these built-in classes in Python.

My examples will focus on `dict` and `list` since those are likely more commonly sub-classed.

<ul data-toc=".entry-content"></ul>


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
    def __repr__(self):
        return f"{type(self).__name__}({super().__repr__()})"
```

Here we're ensuring that:

- deleting keys will delete their corresponding values as well
- whenever we set a new value for `k`, that any existing value will be removed properly
- whenever we set a key-value pair, that the corresponding value-key pair will be set too

Setting and deleting items from this bi-directional dictionary seems to work as we'd expect:

```python
>>> d = TwoWayDict()
>>> d[3] = 8
>>> d
TwoWayDict({3: 8, 8: 3})
>>> d[7] = 6
>>> d
TwoWayDict({3: 8, 8: 3, 7: 6, 6: 7})

```

But calling the `update` method on this dictionary leads to odd behavior:

```python
>>> d
TwoWayDict({3: 8, 8: 3, 7: 6, 6: 7})
>>> d.update({9: 7, 8: 2})
>>> d
TwoWayDict({3: 8, 8: 2, 7: 6, 6: 7, 9: 7})
```

Adding `9: 7` should have removed `7: 6` and `6: 7` and adding `8: 2` should have removed `3: 8` and `8: 3`.

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
TwoWayDict({9: 7, 8: 2})
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
TwoWayDict({9: 7, 7: 9})
>>> d.pop(9)
7
>>> d
TwoWayDict({7: 9}
```

And neither does `setdefault`:

```python
>>> d = TwoWayDict()
>>> d.setdefault(4, 2)
2
>>> d
TwoWayDict({4: 2})
```

The problem is the `pop` method doesn't actually call `__delitem__` and the `setdefault` method doesn't actually call `__setitem__`.

If we wanted to fix this problem, we have to completely re-implement `pop` and `setdefault`:


```python
DEFAULT = object()

class TwoWayDict(dict):
    # ...
    def pop(self, key, default=DEFAULT):
        if key in self or default is DEFAULT:
            value = self[key]
            del self[key]
            return value
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


## Lists and sets have the same problem

The `list` and `set` classes have similar problems to the `dict` class.
Let's take a look at an example.

We'll make a custom list that inherits from the `list` constructor and overrides the behavior of `__delitem__`, `__iter__`, and `__eq__`.
This list will customize `__delitem__` to not actually *delete* an item but to instead leave a "hole" where that item used to be.
The `__iter__` and `__eq__` methods will skip over this hole when comparing two `HoleList` classes as "equal".

This class is a bit nonsensical (no it's not a Python Morsels exercise fortunately), but we're focused less on the class itself and more on the issue with inheriting from `list`:

```python
class HoleList(list):

    HOLE = object()

    def __delitem__(self, index):
        self[index] = self.HOLE

    def __iter__(self):
        return (
            item
            for item in super().__iter__()
            if item is not self.HOLE
        )

    def __eq__(self, other):
        if isinstance(other, HoleList):
            return all(
                x == y
                for x, y in zip(self, other)
            )
        return super().__eq__(other)

    def __repr__(self):
        return f"{type(self).__name__}({super().__repr__()})"
```

Unrelated Aside: if you're curious about that `object()` thing, I explain why it's useful in [my article about sentinel values in Python][sentinel values].

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
HoleList([<object object at 0x7f56bdf38120>, 1, 3, <object object at 0x7f56bdf38120>])
>>> y
HoleList([1, <object object at 0x7f56bdf38120>, 3, <object object at 0x7f56bdf38120>])
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
HoleList([<object object at 0x7f56bdf38120>, 1, 3, <object object at 0x7f56bdf38120>])
>>> y
HoleList([1, <object object at 0x7f56bdf38120>, 3, <object object at 0x7f56bdf38120>])
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
HoleList([1, <object object at 0x7f56bdf38120>, 3, <object object at 0x7f56bdf38120>])
>>> y.remove(1)
>>> y
HoleList([<object object at 0x7f56bdf38120>, 3, <object object at 0x7f56bdf38120>])
>>> y.pop(0)
<object object at 0x7f56bdf38120>
>>> y
HoleList([3, <object object at 0x7f56bdf38120>])
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


## Why did the Python developers do this?

From my understanding, the built-in `list`, `dict`, and `set` types have in-lined a lot of code for performance.
Essentially, they've copy-pasted the same code between many different functions to avoid extra function calls and make things a tiny bit faster.

I haven't found a reference online that explains why this decision was made and what the consequences of the alternatives to this choice were.
But I mostly trust that this was done for my benefit as a Python developer.
If `dict` and `list` weren't faster this way, why would the core developers have chosen this odd implementation?


## What's the alternative to inheriting from list and dict?

So inheriting from `list` to make a custom list was painful and inheriting from `dict` to create a custom dictionary was painful.
What's the alternative?

How can we create a custom dictionary-like object that *doesn't* inherit from the built-in `dict`?

There are a few ways to create custom dictionaries:

1. Fully embrace duck typing: figure out everything you need for your data structure to be `dict`-like and create a completely custom class (that walks and quacks like a `dict`)
2. Inherit from a helper class that'll point us in the right direction and tell us which methods our object needs to be `dict`-like
3. Find a more extensible re-implementation of `dict` and inherit from it instead

We're going to skip over the first approach: reimplementing everything from scratch will take a while and Python has some helpers that'll make things easier.
We're going to take a look at those helpers, first the ones that point us in the right direction (2 above) and then the ones that act as full `dict`-replacements (3 above).


### Abstract base classes: they'll help you quack like a duck

Python's [collections.abc][] module includes **abstract base classes** that can help us implement some of the common protocols (*interfaces* as Java calls them) seen in Python.

We're trying to make a dictionary-like object.
Dictionaries are **mutable mappings**.
A dictionary-like object is a mapping.
That word "mapping" comes from "hash map", which is what many other programming languages call this kind of data structure.

So we want to make a mutable mapping.
The `collections.abc` module provides an abstract base class for that: `MutableMapping`!

If we inherit from this abstract base class, we'll see that we're required to implement certain methods for it to work:

```python
>>> from collections.abc import MutableMapping
>>> class TwoWayDict(MutableMapping):
...     pass
...
>>> d = TwoWayDict()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: Can't instantiate abstract class TwoWayDict with abstract methods __delitem__, __getitem__, __iter__, __len__, __setitem__
```

The `MutableMapping` class requires us to say how getting, deleting, and setting items works, how iterating works, and how we get the length of our dictionary.
But once we do that, we'll get the `pop`, `clear`, `update`, and `setdefault` methods for free!

Here's a re-implementation of `TwoWayDict` using the `MutableMapping` abstract base class:

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
        return f"{type(self).__name__}({self.mapping})"
```

Unlike `dict`, these `update` and `setdefault` methods will call our `__setitem__` method and the `pop` and `clear` methods will call our `__delitem__` method.

Abstract base classes might make you think we're leaving the wonderful land of Python duck typing behind for some sort of strongly-typed [OOP][] land.
But abstract base classes actually enhance duck typing.
**Inheriting from abstract base classes helps us be better ducks**.
We don't have to worry about whether we've implemented all the behaviors that make a mutable mapping because the abstract base class will yell at us if we forgot to specify some essential behavior.

The `HoleList` class we made before would need to inherit from the `MutableSequence` abstract base class.
A custom set-like class would probably inherit from the `MutableSet` abstract base class.


### UserList/UserDict: lists and dictionaries that are actually extensible

When using the collection ABCs, `Mapping`, `Sequence`, `Set` (and their mutable children) you'll often find yourself creating a wrapper around an existing data structure.
If you're implementing a dictionary-like object, using a dictionary under the hood makes things easier: the same applies for lists and sets.

Python actually includes two even higher level helpers for creating list-like and dictionary-like classes which **wrap around `list` and `dict` objects**.
These two classes live in the [collections][] module as [UserList][] and [UserDict][].

Here's a re-implementation of `TwoWayDict` that inherits from `UserDict`:

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
    def __repr__(self):
        return f"{type(self).__name__}({self.data})"
```

You may notice something interesting about the above code.

That code looks extremely similar to the code we originally wrote (the first version that had lots of bugs) when attempting to inherit from `dict`:

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
    def __repr__(self):
        return f"{type(self).__name__}({super().__repr__()})"
```

The `__setitem__` method is identical, but the `__delitem__` method has some small differences.

It might seem from these two code blocks that `UserDict` just a better `dict`.
That's not quite right though: `UserDict` isn't a `dict` replacement so much as a `dict` wrapper.

The `UserDict` class implements the *interface* that dictionaries are supposed to have, but it wraps around an actual `dict` object under-the-hood.

Here's another way we could have written the above `UserDict` code, without any `super` calls:

```python
from collections import UserDict


class TwoWayDict(UserDict):
    def __delitem__(self, key):
        value = self.data.pop(key)
        self.data.pop(value, None)
    def __setitem__(self, key, value):
        if key in self:
            del self[self[key]]
        if value in self:
            del self[value]
        self.data[key] = value
        self.data[value] = key
```

Both of these methods reference `self.data`, which we didn't define.

The `UserDict` class initializer makes a dictionary which it stores in `self.data`.
All of the methods on this dictionary-like `UserDict` class wrap around this `self.data` dictionary.
`UserList` works the same way, except its `data` attribute wraps around a `list` object.
If we want to customize one of the `dict` or `list` methods of these classes, we can just override it and change what it does.

You can think of `UserDict` and `UserList` as **wrapper classes**.
When we inherit from these classes, we're wrapping around a `data` attribute which we proxy all our method lookups to.

In fancy OOP speak, we might consider `UserDict` and `UserList` to be [adapter classes][].


### So should I use abstract base classes or UserDict and UserList?

The `UserList` and `UserDict` classes were originally created long before the abstract base classes in `collections.abc`.
`UserList` and `UserDict` have been around (in some form at least) since before Python 2.0 was even released, but the `collections.abc` abstract base classes have only been around since Python 2.6.

The `UserList` and `UserDict` classes are for when you want something that acts almost identically to a list or a dictionary but you want to customize just a little bit of functionality.

The abstract base classes in `collections.abc` are useful when you want something that's a *sequence* or a *mapping* but is different enough from a list or a dictionary that you really should be making your own custom class.


## Does inheriting from list and dict ever make sense?

Inheriting from `list` and `dict` isn't always bad.

For example, here's a perfectly functional version of a `DefaultDict` (which acts a little differently from `collections.defaultdict`):

```python
class DefaultDict(dict):
    def __init__(self, *args, default=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.default = default
    def __missing__(self, key):
        return self.default
```

This `DefaultDict` uses the `__missing__` method to act as you'd expect:

```python
>>> d = DefaultDict({'a': 8})
>>> d['a']
8
>>> d['b']
>>> d
{'a': 8}
>>> e = DefaultDict({'a': 8}, default=4)
>>> e['a']
8
>>> e['b']
4
>>> e
{'a': 8}
```

There's no problem with inheriting from `dict` here because we're not overriding functionality that lives in many different places.

If you're changing functionality that's limited to a single method or adding your own custom method, it's probably worth inheriting from `list` or `dict` directly.
But if your change will require duplicating the same functionality in multiple places (as is often the case), consider reaching for one of the alternatives.


## When making a custom list or dictionary, remember you have options

When creating your own set-like, list-like, or dictionary-like object, think carefully about how you need your object to work.

If you need to change some core functionality, inheriting from `list`, `dict`, or `set` will be painful and I'd recommend against it.

If you're making a variation of `list` or `dict` and need to customize just a little bit of core functionality, consider inheriting from `collections.UserList` or `collections.UserDict`.

In general, if you're making something custom, you'll often want to reach for the abstract base classes in `collections.abc`.
For example if you're making a slightly more custom sequence or mapping (think `collections.deque`, `range`, and maybe `collections.Counter`) you'll want `MutableSequence` or `MutableMapping`.
And if you're making a custom set-like object, your only options are `collections.abc.Set` or `collections.abc.MutableSet` (there is no `UserSet`).

We don't need to create our own data structures very often in Python.
When you do need to create your own custom collections, wrapping around a data structure is a great idea.
Remember the `collections` and `collections.abc` modules when you need them!


## You don't learn by putting information into your head

You don't learn by putting information into your head, you learn by trying to retrieve information *from* your head.
This knowledge about inheriting from `list` and `dict` and the `collections.abc` classes and `collections.UserList` and `collections.UserDict` isn't going to stick unless you try to apply it!

If you use the below form to sign up for Python Morsels, the first exercise you see when you sign up will involve creating your own custom mapping or sequence (it'll be a surprise which one).
After that first exercise, I'll send you one exercise every week for the next month.
By default they'll be **intermediate-level** exercises, though you can change your skill level after you sign up.

<form method="post" action="https://www.pythonmorsels.com/signup/">
    <input type="email" name="email" placeholder="Your email" class="subscribe-email form-big" required>
    <input type="hidden" name="exercise_track" value="custom collection">
    <input type="hidden" name="form_id" value="inheriting from builtins">
    <button type="submit" class="subscribe-btn form-big">Get my Python Morsels exercise</button>
    <br>
    <small>
    You can <a href="https://www.pythonmorsels.com/privacy/">find the Privacy Policy for Python Morsels here</a>.
    </small>
</form>

If you'd rather get more beginner-friendly exercises, use the Python Morsels sign up form on the right side of this page instead.


[python morsels]: https://www.pythonmorsels.com/
[collections.abc]: https://docs.python.org/3/library/collections.abc.html
[UserDict]: https://docs.python.org/3/library/collections.html#collections.UserDict
[UserList]: https://docs.python.org/3/library/collections.html#collections.UserList
[solid]: https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)
[oop]: https://en.wikipedia.org/wiki/Object-oriented_programming
[collections]: https://docs.python.org/3/library/collections.html
[sentinel values]: https://treyhunner.com/2019/03/unique-and-sentinel-values-in-python/
[adapter classes]: https://en.wikipedia.org/wiki/Adapter_pattern
