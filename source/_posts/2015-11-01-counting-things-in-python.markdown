---
layout: post
title: "Counting things in Python: a history"
date: 2015-11-01 01:56:53 -0700
comments: true
categories: python
---

Let's take a look at different ways to count the number of times things appear in a list.  The "Pythonic" way to do this has changed as Python has changed so we also discuss a bit of Python history to put these methods in context.

## If Statement

It's January 1, 1997 and we're using Python 1.4.  We have a list of colors and we'd love to know how many times each color occurs in this list.  Let's do it!

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = {}
for c in colors:
    if color_counts.has_key(c):
        color_counts[c] += 1
    else:
        color_counts[c] = 1
```

**Note:** we're not using the ``c in color_counts`` idiom because that won't be invented until Python 2.2!

After running this we'll see that our ``color_counts`` dictionary now contains the counts of each color in our list:

```pycon
>>> color_counts
{'Brown': 3, 'Yellow': 2, 'Green': 1, 'Black': 1, 'White': 1, 'Red': 1}
```

That was pretty simple.  We just looped through each color, checked if it was in the dictionary, added the color if it wasn't, and incremented the count if it was.

We could also write this as:

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = {}
for c in colors:
    if not color_counts.has_key(c):
        color_counts[c] = 1
    color_counts[c] += 1
```

This might be a little slower on sparse lists (lists with lots of non-repeating colors) because it does two statements instead of one, but we're not worried about performance, we're worried about what is Pythonic.  I would argue this is slightly more Pythonic because (per the Zen of Python) "flat is better than nested".

## Try Block

It's January 2, 1997 and we're still using Python 1.4.  We woke up this morning with a sudden realization: our code is practicing "Look Before You Leap" (LBYL) when we should be practicing "Easier to Ask Forgiveness, Than Permission" (EAFP) because EAFP is more Pythonic.  Let's refactor our code to use a try-except block:

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = {}
for c in colors:
    try:
        color_counts[c] += 1
    except KeyError:
        color_counts[c] = 1
```

Now our code attempts to increment the count for each color and if the color isn't in the dictionary, a ``KeyError`` will be raised and we will instead set the color count to 1 for the color.

## get Method

It's January 1, 1998 and we've upgraded to Python 1.5.  We've decided to refactor our code to use the new ``get`` method on dictionaries:

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = {}
for c in colors:
    color_counts[c] = color_counts.get(c, 0) + 1
```

It's cool that this is all one line of code, but we're not entirely sure if this is more Pythonic.  This is flatter, but is it simpler or more complex?  More importantly, is it more readable?

We decide this might be too clever and we change our code back to use a ``try`` block.

## setdefault

It's January 1, 2001 and we're now using Python 2.0!  We've heard that dictionaries have a ``setdefault`` method now and we decide to refactor our code to use this new method:

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = {}
for c in colors:
    color_counts.setdefault(c, 0)
    color_counts[c] += 1
```

The ``setdefault`` method is being called on every loop, regardless of whether it's needed, but this does seem a little more readable.  We decide that this is more Pythonic than our previous solutions and commit our change.

## comprehension and set

It's 1, 2005 and we're using Python 2.4.  We realize that we could solve our counting problem using sets (released in Python 2.3) and list comprehensions (released in Python 2.0).  After further thought, we remember that generator expressions were just released in Python 2.4 and we decide to use one of those instead of a list comprehension:

```python
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = dict((c, colors.count(c)) for c in set(colors))
```

This works.  It's one line of code.  It's more complex (**O(n<sup>2</sup>)** instead of **O(n)**) and not necessarily more readable.  We decide to revert this change.  It was a fun experiment, but this one-line solution wasn't probably less Pythonic than what we already had.

## defaultdict

It's January 1, 2007 and we're using Python 2.5.  We've just found out that ``defaultdict`` is included in the standard library now.  This should allow us to set ``0`` as the default value in our dictionary.  Let's refactor our code to count using a ``defaultdict`` instead:

```python
from collections import defaultdict
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = defaultdict(int)
for c in colors:
    color_counts[c] += 1
```

That ``for`` loop is so simple now!  This is almost certainly more Pythonic.

We realize that our ``color_counts`` variable does act slightly differently, but it inherits from ``dict`` and has all the same behaviors.  Instead of converting this to a ``dict``, we'll assume the rest of our code practices proper duck typing and just leave this dict-like object as-is.

```pycon
>>> color_counts
defaultdict(<type 'int'>, {'Brown': 3, 'Yellow': 2, 'Green': 1, 'Black': 1, 'White': 1, 'Red': 1})
```

## Counter

It's January 1, 2011 and we're using Python 2.7.  We've been told that our ``defaultdict`` code is no longer the most Pythonic way to count colors.  A ``Counter`` class was included in the standard library in Python 2.7 and it does all of the work for us!

```python
from collections import Counter
colors = ["Brown", "Red", "Green", "White", "Yellow", "Yellow", "Brown", "Brown", "Black"]
color_counts = Counter(colors)
```

Could this get any simpler?  This must be the most Pythonic way.

Like ``defaultdict``, this returns a dict-like object (a ``dict`` subclass actually), which should be good enough for our purposes, so we'll stick with it.

```pycon
>>> color_counts
Counter({'Brown': 3, 'Yellow': 2, 'White': 1, 'Green': 1, 'Black': 1, 'Red': 1})
```
