---
layout: post
title: "How to flatten a list in Python"
date: 2021-11-01 08:00:00 -0700
comments: true
categories: python
---

You've somehow ended up with lists nested inside of lists, possibly like this one:

```pycon
>>> groups = [["Hong", "Ryan"], ["Anthony", "Wilhelmina"], ["Margaret", "Adrian"]]
```

But you *want* just a single list (without the nesting) like this:

```pycon
>>> expected_output = ["Hong", "Ryan", "Anthony", "Wilhelmina", "Margaret", "Adrian"]
```

You need to flatten your list-of-lists.


### We're looking for a "shallow" flatten

We can think of this as a **shallow flatten** operation, meaning we're flattening this list by one level.
A **deep flatten** operation would handle lists-of-lists-of-lists-of-lists (and so on) and that's a bit more than we need for our use case.

The flattening strategy we come up with should work on lists-of-lists as well as any other type of [iterable][]-of-iterables.
For example lists of tuples should be flattenable:

```pycon
>>> groups = [("Hong", "Ryan"), ("Anthony", "Wilhelmina"), ("Margaret", "Adrian")]
```

And even an odd type like a `dict_items` object (which we get from asking a dictionary for its items) should be flattenable:

```pycon
>>> fruit_counts = {"apple": 3, "lime": 2, "watermelon": 1, "mandarin": 4}
>>> fruit_counts.items()
dict_items([('apple', 3), ('lime', 2), ('watermelon', 1), ('mandarin', 4)])
>>> flattened_counts = ['apple', 3, 'lime', 2, 'watermelon', 1, 'mandarin', 4]
```


### Flattening iterables-of-iterables with a `for` loop

One way to flatten an iterable-of-iterables is with a `for` loop.
We can loop one level deep to get each of the inner iterables.

```python
for group in groups:
    ...
```

And then we loop a second level deep to get each item from each inner iterable.

```python
for group in groups:
    for name in group:
        ...
```

And then append each item to a new list:

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

Or we could use the `+=` operator to concatenate each list to our new list:

```python
names = []
for group in groups:
    names += group
```

You can think of `+=` on lists as calling the `extend` method.
With lists these two operations (`+=` and `extend`) are equivalent.


### Flattening iterables-of-iterables with a comprehension

This nested `for` loop with an `append` call might look familiar:

```python
names = []
for group in groups:
    for name in group:
        names.append(name)
```

The structure of this code looks like something we could [copy-paste into a list comprehension][comprehension].

Inside our square brackets we'd copy the thing we're appending first, and then the logic for our first loop, and then the logic for our second loop:

```python
names = [
    name
    for group in groups
    for name in group
]
```

This comprehension loops two levels deep, just like our nested `for` loops did.
Note that the order of the `for` clauses in the comprehension **must remain the same as the order of the `for` loops**.

The (sometimes confusing) order of those `for` clauses is partly why I recommend [copy-pasting into a comprehension][comprehension].
When turning a `for` loop into a comprehension, the `for` and `if` clauses remain in the same relative place, but the thing you're appending moves from the end to the beginning.


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

This feature was specifically excluded from [PEP 448][], the Python Enhancement Proposal that added this `*`-in-list-literal syntax to Python due to readability concerns.


### Can't we use `sum`?

Here's another list flattening trick I've seen a few times:

```pycon
>>> names = sum(groups, start=[])
```

This *does* work:

```pycon
>>> names
['Hong', 'Ryan', 'Anthony', 'Wilhelmina', 'Margaret', 'Adrian']
```

But I find this technique pretty unintuitive.

We use the `+` operator in Python for both adding numbers and concatenating sequences and the `sum` function happens to work with anything that supports the `+` operator (thanks to [duck typing][]).
But in my mind, the word "sum" implies arithmetic: **summing adds numbers together**.

I find it confusing to "sum" lists, so **I don't recommend this approach**.


### What about `itertools.chain`?

There is one more tool that's often used for flattening: the `chain` utility in the `itertools` module.

`chain` accepts any number arguments and it returns an [iterator][]:

```pycon
>>> from itertools import chain
>>> chain(*groups)
<itertools.chain object at 0x7fc1b2d65bb0>
```

We can loop over that iterator or turn it into another iterable, like a list:

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


### Recap: comparing list flattening techniques

If you want to flatten an iterable-of-iterables lazily, I would use `itertools.chain.from_iterable`:

```pycon
>>> from itertools import chain
>>> flattened = chain.from_iterable(groups)
```

This will return an [iterator][], meaning no work will be done until the returned iterable is looped over:

```pycon
>>> list(flattened)
['Hong', 'Ryan', 'Anthony', 'Wilhelmina', 'Margaret', 'Adrian']
```

And it will be consumed as we loop, so looping twice will result in an empty iterable:

```pycon
>>> list(flattened)
[]
```

If you find `itertools.chain` a bit too cryptic, you might prefer a `for` loop that calls the `extend` method on a new list to repeatedly extend the values in each iterable:

```python
names = []
for group in groups:
    names.extend(group)
```

Or a `for` loop that uses the `+=` operator on our new list:

```python
names = []
for group in groups:
    names += group
```

Unlike `chain.from_iterable`, both of these `for` loops build up new list rather than a lazy iterator object.

If you find list comprehensions readable (I love them for signaling "look we're building up a list") then you might prefer a comprehension instead:

```python
names = [
    name
    for group in groups
    for name in group
]
```

And if you *do* want laziness (an iterator) but you don't like `itertools.chain` you could make a [generator expression][] that does tha same thing as `itertools.chain.from_iterable`:

```python
names = (
    name
    for group in groups
    for name in group
)
```

Happy list flattening!


[comprehension]: https://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[generator expression]: https://www.pythonmorsels.com/topics/how-write-generator-expression/
[asterisks]: https://treyhunner.com/2018/10/asterisks-in-python-what-they-are-and-how-to-use-them/
[pep 448]: https://www.python.org/dev/peps/pep-0448/#variations
[iterator]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[iterable]: https://www.pythonmorsels.com/topics/iterable/
[duck typing]: https://www.pythonmorsels.com/topics/duck-typing/
