---
layout: post
title: "Python without for loops: how iteration works"
date: 2016-10-18 15:02:12 -0700
comments: true
categories: python
---

Let's pretend for a moment that we've been asked to remove all `for` loops from our Python code.

Maybe we're about to embark on a journey to a parallel universe where `for` loops were removed from Python.  Maybe we've decided that `for` loops make programming too easy.  Maybe we're interviewing for a job and our interviewer assigned us the ridiculous task of removing `for` loops from our code.

Whatever the reason: we're going to remove all `for` loops from our code.  How do we do it?

Let's try a few strategies and see if we can find one that works in all cases.


## Take 1: Loop with Indexes

We first try to remove our `for` loops by using a traditional looping idiom from the world of C: [looping with indexes][loop with indexes].

```python
colors = ["red", "green", "blue", "purple"]
i = 0
while i < len(colors):
    print(colors[i])
    i += 1
```

This works on lists, but it fails on sets:

```pycon
>>> colors = {"red", "green", "blue", "purple"}
>>> i = 0
>>> while i < len(colors):
...     print(colors[i])
...     i += 1
...
Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
TypeError: 'set' object does not support indexing
```

This approach only works on [sequences][], which are data types that have indexes from `0` to one less than their length.  So lists, strings, and tuples are sequences while dictionaries and sets are not.


## Take 2: Convert to a List

We could try to get around this problem by converting our non-sequences to sequences: in other words we could make a list out of everything before we loop over it.

```python
colors = {"red", "green", "blue", "purple"}
colors_list = list(colors)
i = 0
while i < len(colors_list):
    print(colors[i])
    i += 1
```

This works for sets and dictionaries, but it doesn't work for everything we can loop over.

Lists, sets, tuples, strings, sets, and dictionaries are all finite collections: they're all data types that act as containers holding a finite amount of data.  When we iterate over each item in these containers, we know our loop will end at some point.

This isn't always true though: it's possible to loop over infinite things.


## Manually Looping Over Iterables

We've so far failed to define an important word in the Python looping world: iterable.

**Iterable** is the generic term for **anything you can loop over with a for loop**.

Iterables are not always indexable, they don't always have lengths, and they're not always finite.

Here's an *infinite* iterable which provides every multiple of 5 as you loop over it:

```python
from itertools import count
multiples_of_five = count(step=5)
```

When we were using `for` loops, we could have looped over the beginning of this iterable like this:

```python
for n in multiples_of_five:
    if n > 100:
        break
    print(n)
```

If we removed the `break` condition from that `for` loop, it would go on printing forever.

So iterables can be infinitely long: which means that we can't always convert an iterable to a list/sequence before we loop over it.  We need to somehow ask our iterable for each item manually, the same way our `for` loop is.


## Take 3: Next

The key to looping over our `multiples_of_five` iterable is `next`:

```python
from itertools import count

multiples_of_five = count(step=5)

while True:
    n = next(multiples_of_five)
    if n > 100:
        break
    print(n)
```

This infinitely long iterable can be passed to the `next` function to repeatedly get the next value from it.

That's neat, but does `next` work on lists, sets, and other iterables?  Let's try it:

```pycon
>>> colors = {'green', 'red', 'blue', 'purple'}
>>> while True:
...     color = next(colors)
...     print(color)
...
Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
TypeError: 'set' object is not an iterator
```

Nope.  We did get an interesting error message though: `'set' object is not an iterator`.

But what's an iterator?


## Iterator Protocol

When I defined iterable before, I didn't mention how iterables work.

All [iterables][] can be passed to the built-in `iter` function to get an iterator from them.

```pycon
>>> iter(['some', 'list'])
<list_iterator object at 0x7f227ad51128>
>>> iter({'some', 'set'})
<set_iterator object at 0x7f227ad32b40>
>>> iter('some string')
<str_iterator object at 0x7f227ad51240>
```

Neat... but what's an iterator?

[Iterators][] can be passed to the built-in `next` function to get the next item from them.  If there is no next item, a `StopIteration` exception will be raised.

There's actually a bit more to it than that: iterators are also iterables.

But you can get an iterator from every iterable... so what happens if you ask an iterator for an iterator?  You get itself!  Iterators are their own iterators.

```pycon
>>> i = iter('some string')
>>> i is iter(i)
True
```

So iterators:

1. Can be passed to the built-in `next` function to get the next item from them.
2. Return themselves when passed to the built-in `iter` function.

## Take 3: Looping With Iterators

So if we have a `for` loop like this:

```python
for n in colors:
    print(n)
```

We can create an equivalent loop that manually uses the iterator protocol like this:

```python
while True:
    iterator = iter(colors)
    try:
        n = next(iterator)
    except StopIteration:
        break
    else:
        print(n)
```


[loop with indexes]: http://treyhunner.com/2016/04/how-to-loop-with-indexes-in-python/
[sequences]: https://docs.python.org/3/glossary.html#term-sequence
[iterables]: https://docs.python.org/3/glossary.html#term-iterable
[iterators]: https://docs.python.org/3/glossary.html#term-iterator
