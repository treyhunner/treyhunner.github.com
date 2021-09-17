---
layout: post
title: "How to flatten a list in Python"
date: 2021-09-16 06:22:27 -0700
comments: true
categories: 
---

**TODO** intro


### What do we mean by *flatten*?

We have a list of lists of strings:

```pycon
>>> groups = [["Hong", "Ryan"], ["Anthony", "Wilhelmina"], ["Margaret", "Adrian"]]
```

We would like to take this nested list-of-lists of strings and turn into into a single list of strings:

```pycon
>>> expected_output = ["Hong", "Ryan", "Anthony", "Wilhelmina", "Margaret", "Adrian"]
```

We can think of this as a **shallow flatten** operation, meaning we're flattening this list by one level.

The flattening strategy we come up with should work on lists-of-lists as well as any other type of iterable-of-iterables.
For example lists of tuples should be flattenable:

```pycon
>>> groups = [("Hong", "Ryan"), ("Anthony", "Wilhelmina"), ("Margaret", "Adrian")]
```

And `dict_items` objects of tuples should be flattenable:

```pycon
TODO show dictionary
TODO show .items() on dictionary
TODO show expected output
```


### Flattening iterables-of-iterables with a `for` loop

One way to flatten an iterable-of-iterables is with a `for` loop.
We can loop one level deep to get each iterable.

```python
for group in groups:
    ...
```

And then we loop a second level deep to get each item in each iterable.

```python
for group in groups:
    for name in group:
        ...
```

And we append each item to a new list.

```python
names = []
for group in groups:
    for name in group:
        names.append(name)
```

There's also a list method that makes this a bit shorter, the `extend` method:

```python
names = []
for group in groups:
    names.extend(group)
```

The list `extend` method accepts an iterable and appends every item in the iterable you give to it.

Using the `+=` operator on a list does the same thing as the `extend` method:

```python
names = []
for group in groups:
    names += group
```

You can think of `+=` on lists as calling the `extend` method: the two operations are equivalennt (for lists that is).


### Flattening iterables-of-iterables with a comprehension

This nested `for` loop with an `append` call might look familiar:

```python
names = []
for group in groups:
    for name in group:
        names.append(name)
```

The structure of that code looks like something we could [copy-paste into a list comprehension][comprehension]:

```python
names = [
    name
    for group in groups
    for name in group
]
```

This comprehension looks two levels deep, just like our nested `for` loops did.
Note that the order of the `for` clauses in the comprehension must remain the same as the order of the `for` loops.


### Could we flatten with `*` in a comprehension?

But what about Python's `*` operator?
I've written about the many uses for [the prefixed asterisk symbol in Python][asterisks].

We can use `*` in Python's list literal syntax (`[`...`]`) to unpack an iterable into a new list:

```pycon
>>> numbers = [3, 4, 7]
>>> more_numbers = [2, 1, *numbers, 11, 18]
>>> more_numbers
[2, 1, 3, 4, 7, 11, 18]
```

Could we use that `*` operator to unpack an iterable within a comprehension?

```python
names = [
    *group
    for group in groups
]
```

We can't.
If we try to do this Python will specifically tell us that the `*` operator can't be used like this in a comprehension:

```pycon
>>> names = [
...     *group
...     for group in groups
... ]
  File "<stdin>", line 2
    ]
     ^
SyntaxError: iterable unpacking cannot be used in comprehension
```

This feature was specifically excluded from [PEP 448][], the Python Enhancement Proposal that added this `*`-in-list-literal syntax to Python.


### What about `itertools.chain`?

There is one more tool that's often used for flattening: the `chain` utility in the `itertools` module.

`chain` accepts any number arguments and it returns an iterator:

```pycon
>>> from itertools import chain
>>> chain(*groups)
<itertools.chain object at 0x7fc1b2d65bb0>
```

We can loop over that iterator or turn into another iterable, like a list:

```pycon
>>> list(chain(*groups))
['Hong', 'Ryan', 'Anthony', 'Wilhelmina', 'Margaret', 'Adrian']
```

There's actually a method on `chain` that's specifically for flattening a single iterable:

```pycon
>>> list(chain.from_iterable(groups))
['Hong', 'Ryan', 'Anthony', 'Wilhelmina', 'Margaret', 'Adrian']
```

Using `chain.from_iterable` is more performant than using `chain` with `*` because `*` unpacks the whole iterable immediately when `chain` is called.

**TODO** summary?


[comprehension]: https://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[asterisks]: https://treyhunner.com/2018/10/asterisks-in-python-what-they-are-and-how-to-use-them/
[pep 448]: https://www.python.org/dev/peps/pep-0448/#variations
