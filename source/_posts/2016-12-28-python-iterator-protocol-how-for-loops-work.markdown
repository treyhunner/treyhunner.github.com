---
layout: post
title: "The Iterator Protocol: How \"For Loops\" Work in Python"
date: 2016-12-28 11:00:00 -0800
comments: true
categories: python favorite
---

We're interviewing for a job and our interviewer has asked us to remove all `for` loops from a block of code.  They then mentioned something about iterators and cackled maniacally while rapping their fingers on the table.  We're nervous and frustrated about being assigned this ridiculous task, but we'll try our best.

To understand how to loop without a `for` loop, we'll need to discover what makes `for` loops tick.

We're about to learn how `for` loops work in Python.  Along the way we'll need to learn about iterables, iterators, and the iterator protocol.  Let's loop. ➿

<ul data-toc=".entry-content"></ul>


## Looping with indexes: a failed attempt

We might initially try to remove our `for` loops by using a traditional looping idiom from the world of C: [looping with indexes][loop with indexes].

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

This approach only works on [sequences][], which are data types that have indexes from `0` to one less than their length.  Lists, strings, and tuples are sequences.  Dictionaries, sets, and many other *iterables* are not *sequences*.

We've been instructed to implement a looping construct that works on *all iterables*, not just sequences.


## Iterables: what are they?

In the Python world, an **iterable** is any object that **you can loop over with a for loop**.

[Iterables][] are not always indexable, they don't always have lengths, and they're not always finite.

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

So iterables can be infinitely long: which means that we can't always convert an iterable to a `list` (or any other sequence) before we loop over it.  We need to somehow ask our iterable for each item of our iterable individually, the same way our `for` loop works.


## Iterables & Iterators

Okay we've defined *iterable*, but how do iterables actually work in Python?

All [iterables][] can be passed to the built-in `iter` function to get an **iterator** from them.

```pycon
>>> iter(['some', 'list'])
<list_iterator object at 0x7f227ad51128>
>>> iter({'some', 'set'})
<set_iterator object at 0x7f227ad32b40>
>>> iter('some string')
<str_iterator object at 0x7f227ad51240>
```

That's an interesting fact but... what's an *iterator*?

Iterators have exactly one job: return the "next" item in our iterable.  They're sort of like [tally counters][], but they don't have a reset button and instead of giving the next number they give the next item in our iterable.

You can get an iterator from *any* iterable:

```pycon
>>> iterator = iter('hi')
```

And iterators can be passed to ``next`` to get their next item:

```pycon
>>> next(iterator)
'h'
>>> next(iterator)
'i'
>>> next(iterator)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

So [iterators][] can be passed to the built-in `next` function to get the next item from them and if there is no next item (because we reached the end), a `StopIteration` exception will be raised.


## Iterators are also iterables

So calling `iter` on an *iterable* gives us an iterator.  And calling `next` on an *iterator* gives us the next item or raises a `StopIteration` exception if there aren't any more items.

There's actually a bit more to it than that though.  You can pass iterators to the built-in `iter` function to get themselves back.  That means that iterators are also iterables.

```pycon
>>> iterator = iter('hi')
>>> iterator2 = iter(iterator)
>>> iterator is iterator2
True
```

That fact leads to some interesting consequences that we don't have time to go into right now.  We'll save that discussion for a future learning adventure...


## The Iterator Protocol

The **iterator protocol** is a fancy term meaning "how iterables actually work in Python".

Let's redefine iterables from Python's perspective.

Iterables:

1. Can be passed to the `iter` function to get an iterator for them.
2. There is no 2.  That's *really* all that's needed to be an iterable.

Iterators:

1. Can be passed to the `next` function which gives their next item or raises `StopIteration`
2. Return themselves when passed to the `iter` function.

The inverse of these statements should also hold true.  Which means:

1. Anything that can be passed to `iter` without an error is an iterable.
2. Anything that can be passed to `next` without an error (except for `StopIteration`) is an iterator.
3. Anything that returns itself when passed to `iter` is an iterator.


## Looping with iterators

With what we've learned about iterables and iterators, we should now be able to recreate a `for` loop without actually using a `for` loop.

This `while` loop manually loops over some `iterable`, printing out each item as it goes:

```python
def print_each(iterable):
    iterator = iter(iterable)
    while True:
        try:
            item = next(iterator)
        except StopIteration:
            break  # Iterator exhausted: stop the loop
        else:
            print(item)
```

We can call this function with any iterable and it will loop over it:

```pycon
>>> print_each({1, 2, 3})
1
2
3
```

The above function is essentially the same as this one which uses a `for` loop:

```python
def print_each(iterable):
    for item in iterable:
        print(item)
```

This `for` loop is automatically doing what we were doing manually: calling `iter` to get an iterator and then calling `next` over and over until a `StopIteration` exception is raised.

The iterator protocol is used by `for` loops, tuple unpacking, and all built-in functions that work on generic iterables.  Using the iterator protocol (either manually or automatically) is the only universal way to loop over any iterable in Python.


## For loops: more complex than they seem

We're now ready to complete the very silly task our interviewer assigned to us.  We'll remove all `for` loops from our code by manually using `iter` and `next` to loop over iterables.  What did we learn in exploring this task?

Everything you can loop over is an **iterable**.  Looping over iterables works via getting an **iterator** from an iterable and then repeatedly asking the iterator for the next item.

The way iterators and iterables work is called the **iterator protocol**.  List comprehensions, tuple unpacking, `for` loops, and all other forms of iteration rely on the iterator protocol.

I'll explore iterators more in future articles.  For now know that iterators are hiding behind the scenes of all iteration in Python.


## Even more on iterators

If you'd like to dive a bit deeper into this topic, you might want to check out my [Loop Better talk][] or my [article of the same name][].

If you're interested in making your own iterators, I've also written an article on [how to make an iterator in Python][].

If you want an excuse to practice making iterators, consider giving [Python Morsels][] a try.
The first few exercises include an excuse to create your own Python iterator.


## Practice working with iterators

You don't learn new Python skills by reading, you learn them by writing code.

If you'd like to practice working with iterators, you can sign up for [Python Morsels][] using the form below.
The first exercise I send you will involve both working with and creating iterators.

<form method="post" action="https://www.pythonmorsels.com/accounts/signup/">
  <input type="email" name="email" placeholder="Your email" class="subscribe-email form-big" required>
  <input type="hidden" name="exercise_track" value="iterators">
  <input type="hidden" name="form_id" value="how for loops work">
  <button type="submit" class="subscribe-btn form-big">Get my iterator practice exercise</button>
<br>

<small>
  I won't share you info with others (see the <a href="https://www.pythonmorsels.com/privacy/">Python Morsels Privacy Policy</a> for details).<br>
  This form is reCAPTCHA protected (Google <a href="https://policies.google.com/privacy">Privacy Policy</a> &amp; <a href="https://policies.google.com/terms">TOS</a>)
</small>

</form>


[loop with indexes]: http://treyhunner.com/2016/04/how-to-loop-with-indexes-in-python/
[sequences]: https://docs.python.org/3/glossary.html#term-sequence
[iterables]: https://docs.python.org/3/glossary.html#term-iterable
[iterators]: https://docs.python.org/3/glossary.html#term-iterator
[tally counters]: https://en.wikipedia.org/wiki/Tally_counter
[loop better talk]: https://youtu.be/V2PkkMS2Ack?t=25s
[article of the same name]: https://opensource.com/article/18/3/loop-better-deeper-look-iteration-python
[how to make an iterator in Python]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[python morsels]: https://www.pythonmorsels.com/
