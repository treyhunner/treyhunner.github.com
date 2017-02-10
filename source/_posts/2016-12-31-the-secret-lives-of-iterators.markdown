---
layout: post
title: "The Secret Lives of Iterators"
date: 2016-12-31 13:42:58 -0800
comments: true
categories: 
---

I've written about [the iterator protocol][]: we talked about iterators, iterables, and how `for` loops work.

Even if you're familiar with the iterator protocol, you may not really understand how iterators behave at an intuitive level.  As children, we form our intuitions about the world through play.  We can do the same thing as adults.

Let's play with iterators!


## Iterators are single-use

You can think of iterators as single-use iterables.

```python
from itertools import count
multiples_of_five = count(step=5)
```


## Iterators & zip

What happens when we zip iterators together?

```pycon
>>> numbers = [1, 2, 3, 4, 5]
>>> a = iter(numbers)
>>> b = iter(numbers)
>>> c = zip(a, b)
>>> list(c)
[(1, 1), (2, 2), (3, 3), (4, 4), (5, 5)]
```

When we zip iterators together, we get a list of tuples of the elements in each iterator.  That's pretty much the same thing that happens when we zip any two iterables together (if you're unfamiliar with zip, see the article I wrote on [looping with indexes][]).

What would happen if we zipped an iterator to itself?

```pycon
>>> numbers = [1, 2, 3, 4, 5]
>>> i = iter(numbers)
>>> z = zip(i, i)
>>> list(z)
[(1, 2), (3, 4)]
```

That's weird... it grouped items in two-tuples.  What's going on here?

Remember that as we loop over iterators, we consume items from them.

You can think of the `zip` function like this:

```python
def zip(*iterables):
    iterators = [iter(it) for it in iterables]
    while iterators:
        try:
            yield tuple([next(it) for it in iterators])
        except StopIteration:
            return
```

So `zip`:

1. Gets iterators for each given iterable
2. Calls `next` on each iterator repeatedly until one is exhausted

Remember that iterators are their own iterator.  So calling `iter` on an iterator will always return itself.

```pycon
>>> numbers = [1, 2, 3, 4, 5]
>>> a = iter(numbers)
>>> b = iter(numbers)
>>> a is b
False
>>> iter(a) is a
True
```

Because calling `iter` on an iterator will always return itself, calling `next` on each of the iterators in `zip` will consume each item from the same iterator.  This is an implementation detail of the way `zip` works.

This isn't a bug in `zip` though.  The `zip` function is simply relying on the iterator protocol.  There's not really any other way `zip` could work!


## Iterators and containment

reverse iterator and ask about containment


## Iterators and equality

ask two iterators whether they're equal to each other


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


## Iterators are lazy

TODO


[the iterator protocol]: http://localhost:9000/2016/12/python-iterator-protocol-how-for-loops-work/
[looping with indexes]: http://localhost:9000/2016/04/how-to-loop-with-indexes-in-python/
