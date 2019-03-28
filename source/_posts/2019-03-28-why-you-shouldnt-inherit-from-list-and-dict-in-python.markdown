---
layout: post
title: "Why you shouldn't inherit from dict and list in Python"
date: 2019-03-28 06:10:34 -0700
comments: true
categories: python
---

## A custom dictionary

We'd like to make a dictionary that's bi-directional.
When a key-value pair is added, the key maps to the value but the value also maps to the key.

So there will always be an even number of elements in this dictionary.
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

We're ensuring that:

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
    def update(self, items):
        if isinstance(items, dict):
            items = items.items()
        for key, value in items:
            self[key] = value
```

And calling the initializer doesn't work:

```python
>>> d = TwoWayDict({9: 7, 8: 2})
>>> d
{9: 7, 8: 2}
```

```python
class TwoWayDict(dict):
    def __init__(self, items=()):
        self.update(items)
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
    def update(self, items):
        if isinstance(items, dict):
            items = items.items()
        for key, value in items:
            self[key] = value
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

TODO Liskov something OOP terminology for what's being broken here (first responsibility or something?)


```python
DEFAULT = object()

class TwoWayDict(dict):
    def __init__(self, items=()):
        self.update(items)
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
    def update(self, items):
        if isinstance(items, dict):
            items = items.items()
        for key, value in items:
            self[key] = value
    def pop(self, key, default=DEFAULT):
        if key in self or default is DEFAULT:
            return self[key]
        else:
            return default
    def setdefault(self, key, value):
        if key not in self:
            self[key] = value
```


## TODO Cut this section

We'd have the same problem with a custom dictionary that overrides `__getitem__` but not `get` or `pop`:

```python
class MyDefaultDict(dict):
    def __init__(self, default):
        self.default = default
        super().__init__(self)
    def __getitem__(self, key):
        if key not in self:
            self[key] = self.default
        return super().__getitem__(key)
```

The behavior of `get` hasn't changed:

```python
>>> d = MyDefaultDict(0)
>>> d.get('snakes')
>>> d
{}
>>> d['snakes']
0
>>> d
{'snakes': 0}
```

## A custom list

Let's make a custom list that inherits from the `list` constructor.

```python
class HoleList(list):
    def __delitem__(self, key):
        self[key] = None
    def no_holes(self):
        return [
            item
            for item in self
            if item is not None
        ]
    def __eq__(self, other):
        if isinstance(other, HoleList):
            return self.no_holes() == other.no_holes()
        else:
            return super().__eq__(other)
```

```python
>>> x = HoleList([2, 1, 3, 4])
>>> y = HoleList([1, 2, 3, 5])
>>> del x[0]
>>> del y[1]
>>> del x[-1]
>>> del y[-1]
>>> x
[None, 1, 3, None]
>>> y
[1, None, 3, None]
```

```python
>>> x == y
True
>>> x
[None, 1, 3, None]
>>> y
[1, None, 3, None]
>>> y[1] = 4
>>> x == y
False
x = HoleList([None, 1, 3, None])
y = HoleList([1, 4, 3, None])
```

```python
>>> x == y
False
>>> y.remove(4)
>>> y
[1, 3, None]
>>> y.pop(2)
>>> y
[1, 3]
>>> x == y
True
>>> x != y
True
```


```python
class HoleList(list):
    def __delitem__(self, key):
        self[key] = None
    def no_holes(self):
        return [
            item
            for item in self
            if item is not None
        ]
    def __eq__(self, other):
        if isinstance(other, HoleList):
            return self.no_holes() == other.no_holes()
        else:
            return super().__eq__(other)
    def __ne__(self, other):
        return not self.__eq__(other)
    def remove(self, value):
        index = self.index(value)
        del self[index]
    def pop(self, index=-1):
        value = self[index]
        del self[index]
        return value
```


## Instead


```python
from collections.abc import MutableMapping


class TwoWayDict(MutableMapping):
    def __init__(self, data=()):
        self.mapping = {}
        self.update(data)
    def __getitem__(self, key):
        return self.mapping[key]
    def __setitem__(self, key, value):
        if key in self:
            del self[self[key]]
        if value in self:
            del self[value]
        self.mapping[key] = value
        self.mapping[value] = key
    def __delitem__(self, key):
        value = self[key]
        del self.mapping[key]
        self.pop(value, None)
    def __iter__(self):
        return iter(self.mapping)
    def __len__(self):
        return len(self.mapping)
    def __repr__(self):
        return repr(self.mapping)
```


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
