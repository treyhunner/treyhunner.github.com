---
layout: post
title: "The Secret Lives of Iterators"
date: 2016-12-31 13:42:58 -0800
comments: true
categories: 
---

## TODO Random stuff to delete

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



That means we can pass iterators to `iter` to get an iterator.

Okay that's a little odd.  This might make a little more sense if we compare `iterator` and `iterator2`:

```pycon
>>> iterator is iterator2
True
```

These objects occupy exactly the same place in memory, meaning the iterator of our iterator is *itself*.

Iterators are iterables.  You can get iterators for every iterable.  Asking an iterator for an iterator always give you itself.

It's iterators all the way down... in fact it's the same iterator all the way down.

```pycon
>>> numbers = [1, 2, 3]
>>> i1 = iter(numbers)
>>> i2 = iter(i1)
>>> i3 = iter(i2)
>>> i1 is i2 is i3
True
```



## Iterators are single-use lazy iterables

You can think of iterators as single-use iterables.

```python
from itertools import count
multiples_of_five = count(step=5)
```

