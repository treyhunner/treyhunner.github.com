---
layout: post
title: "Counting things in Python: a history"
date: 2015-11-09 12:30:00 -0700
comments: true
categories: python favorite
---

Sometimes the [Pythonic][] way to solve a problem changes over time.  As Python has evolved, so has the Pythonic way to count list items.

Let's look at different techniques for counting the number of times things appear in a list.  While analyzing these techniques, we will *only* be looking at code style.  We'll worry about performance later.

We will need some historical context to understand these different techniques.  Fortunately we live in the `__future__` and we have a time machine.  Let's jump in our DeLorean and head to 1997.

## if Statement

It's January 1, 1997 and we're using Python 1.4.  We have a list of colors and we'd love to know how many times each color occurs in this list.  Let's use [a dictionary][1.4]!

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = {}
for c in colors:
    if color_counts.has_key(c):
        color_counts[c] = color_counts[c] + 1
    else:
        color_counts[c] = 1
```

**Note:** we're not using `+=` because augmented assignment won't be added until [Python 2.0][pep 203] and we're not using the `c in color_counts` idiom because that won't be invented until [Python 2.2][2.2]!

After running this we'll see that our `color_counts` dictionary now contains the counts of each color in our list:

```pycon
>>> color_counts
{'brown': 3, 'yellow': 2, 'green': 1, 'black': 1, 'red': 1}
```

That was pretty simple.  We just looped through each color, checked if it was in the dictionary, added the color if it wasn't, and incremented the count if it was.

We could also write this as:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = {}
for c in colors:
    if not color_counts.has_key(c):
        color_counts[c] = 0
    color_counts[c] = color_counts[c] + 1
```

This might be a little slower on sparse lists (lists with lots of non-repeating colors) because it executes two statements instead of one, but we're not worried about performance, we're worried about code style.  After some thought, we decide to stick with this new version.

## try Block

It's January 2, 1997 and we're still using Python 1.4.  We woke up this morning with a sudden realization: our code is practicing "Look Before You Leap" ([LBYL][]) when we should be practicing "Easier to Ask Forgiveness, Than Permission" ([EAFP][]) because EAFP is more Pythonic.  Let's refactor our code to use a try-except block:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = {}
for c in colors:
    try:
        color_counts[c] = color_counts[c] + 1
    except KeyError:
        color_counts[c] = 1
```

Now our code attempts to increment the count for each color and if the color isn't in the dictionary, a `KeyError` will be raised and we will instead set the color count to 1 for the color.

## get Method

It's January 1, 1998 and we've upgraded to Python 1.5.  We've decided to refactor our code to use the [new `get` method on dictionaries][1.5]:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = {}
for c in colors:
    color_counts[c] = color_counts.get(c, 0) + 1
```

Now our code loops through each color, gets the current count for the color from the dictionary, defaulting this count to `0`, adds `1` to the count, and sets the dictionary key to this new value.

It's cool that this is all one line of code, but we're not entirely sure if this is more Pythonic.  We decide this might be too clever so we revert this change.

## setdefault

It's January 1, 2001 and we're now using Python 2.0!  We've heard that [dictionaries have a `setdefault` method now][2.0] and we decide to refactor our code to use this new method.  We also decide to use the new `+=` augmented assignment operator:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = {}
for c in colors:
    color_counts.setdefault(c, 0)
    color_counts[c] += 1
```

The `setdefault` method is being called on every loop, regardless of whether it's needed, but this does seem a little more readable.  We decide that this is more Pythonic than our previous solutions and commit our change.

## fromkeys

It's January 1, 2004 and we're using Python 2.3.  We've heard about a [new `fromkeys` class method][2.3] on dictionaries for constructing dictionaries from a list of keys.  We refactor our code to use this new method:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = dict.fromkeys(colors, 0)
for c in colors:
    color_counts[c] += 1
```

This creates a new dictionary using our colors as keys, with all values set to `0` initially.  This allows us to increment each key without worrying whether it has been set.  We've removed the need for any checking or exception handling which seems like an improvement.  We decide to keep this change.

## Comprehension and set

It's January 1, 2005 and we're using Python 2.4.  We realize that we could solve our counting problem using sets ([released in Python 2.3][2.3-sets] and made into [a built-in in 2.4][2.4]) and list comprehensions ([released in Python 2.0][pep 202]).  After further thought, we remember that [generator expressions][pep 289] were also just released in Python 2.4 and we decide to use one of those instead of a list comprehension:

```python
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = dict((c, colors.count(c)) for c in set(colors))
```

**Note**: we didn't use a dictionary comprehension because those won't be invented until [Python 2.7][pep 274].

This works.  It's one line of code.  But is it Pythonic?

We remember the [Zen of Python][], which [started in a python-list email thread][zen email] and was [snuck into Python 2.2.1][import this].  We type `import this` at our REPL:

```pycon
>>> import this
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```

Our code is *more complex* (**O(n<sup>2</sup>)** instead of **O(n)**), *less beautiful*, and *less readable*.  That change was a fun experiment, but this one-line solution is **less Pythonic** than what we already had.  We decide to revert this change.

## defaultdict

It's January 1, 2007 and we're using Python 2.5.  We've just found out that [`defaultdict` is in the standard library][2.5] now.  This should allow us to set `0` as the default value in our dictionary.  Let's refactor our code to count using a `defaultdict` instead:

```python
from collections import defaultdict
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = defaultdict(int)
for c in colors:
    color_counts[c] += 1
```

That `for` loop is so simple now!  This is almost certainly more Pythonic.

We realize that our `color_counts` variable does act differently, however it *does* inherit from `dict` and supports all the same mapping functionality.

```pycon
>>> color_counts
defaultdict(<type 'int'>, {'brown': 3, 'yellow': 2, 'green': 1, 'black': 1, 'red': 1})
```

Instead of converting `color_counts` to a `dict`, we'll assume the rest of our code practices [duck typing][] and leave this dict-like object as-is.

## Counter

It's January 1, 2011 and we're using Python 2.7.  We've been told that our `defaultdict` code is no longer the most Pythonic way to count colors.  [A `Counter` class was included in the standard library][2.7] in Python 2.7 and it does all of the work for us!

```python
from collections import Counter
colors = ["brown", "red", "green", "yellow", "yellow", "brown", "brown", "black"]
color_counts = Counter(colors)
```

Could this get any simpler?  This must be the most Pythonic way.

Like `defaultdict`, this returns a dict-like object (a `dict` subclass actually), which should be good enough for our purposes, so we'll stick with it.

```pycon
>>> color_counts
Counter({'brown': 3, 'yellow': 2, 'green': 1, 'black': 1, 'red': 1})
```

## After thought: Performance

Notice that we didn't focus on efficiency for these solutions.  Most of these solutions have the same time complexity (`O(n)` in big O notation) but runtimes could vary based on the Python implementation.

While performance isn't our main concern, [I did measure the run-times on CPython 3.5.0][performance].  It's interesting to see how each implementation changes in relative efficiency based on the density of color names in the list.

## Conclusion

Per the [Zen of Python][], "there should be one-- and preferably only one-- obvious way to do it".  This is an aspirational message.  There isn't always one obvious way to do it.  The "obvious" way can vary by time, need, and level of expertise.

**"Pythonic" is a relative term.**

### Related Resources

- [import this and the Zen of Python](http://www.wefearchange.org/2010/06/import-this-and-zen-of-python.html): Zen of Python trivia borrowed from this post
- [Permission or Forgiveness](https://www.youtube.com/watch?v=AZDWveIdqjY): Alex Martelli discusses Grace Hopper's EAFP
- [Python How To: Group and Count with Dictionaries](https://codefisher.org/catch/blog/2015/04/22/python-how-group-and-count-dictionaries/): while writing this post, I discovered this related article

### Credits

Thanks to [Brian Schrader][] and [David Lord][] for proof-reading this post and [Micah Denbraver][] for actually [testing out these solutions][tests] on the correct versions of Python.

[1.4]: https://docs.python.org/release/1.4/lib/node13.html
[1.5]: https://docs.python.org/release/1.5/lib/node13.html
[2.0]: https://docs.python.org/release/2.0/lib/typesmapping.html
[2.2]: https://docs.python.org/release/2.2/lib/typesmapping.html
[2.3]: https://docs.python.org/release/2.3/lib/typesmapping.html
[2.3-sets]: https://docs.python.org/release/2.3/lib/module-sets.html
[2.4]: https://docs.python.org/release/2.4/lib/types-set.html
[2.5]: https://docs.python.org/release/2.5/lib/defaultdict-objects.html
[2.7]: https://docs.python.org/2.7/library/collections.html#collections.Counter

[duck typing]: https://docs.python.org/2/glossary.html#term-duck-typing
[eafp]: https://docs.python.org/2/glossary.html#term-eafp
[import this]: http://svn.python.org/view/python/tags/r221/Lib/this.py?revision=25249&view=markup
[lbyl]: https://docs.python.org/2/glossary.html#term-lbyl
[pep 202]: https://www.python.org/dev/peps/pep-0202/
[pep 203]: https://www.python.org/dev/peps/pep-0203/
[pep 274]: https://www.python.org/dev/peps/pep-0274/
[pep 289]: https://www.python.org/dev/peps/pep-0289/
[performance]: https://gist.github.com/treyhunner/0987601f960a5617a1be
[pythonic]: http://nedbatchelder.com/blog/201011/pythonic.html
[tests]: https://gist.github.com/macro1/9b364612ee3907df4179
[zen email]: https://mail.python.org/pipermail/python-list/1999-June/001951.html
[zen of python]: https://www.python.org/dev/peps/pep-0020/

[brian schrader]: http://brianschrader.com/
[david lord]: http://stackoverflow.com/users/400617/davidism
[micah denbraver]: http://micah.bigprob.net/
