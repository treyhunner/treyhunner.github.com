---
layout: post
title: "Python: range is not an iterator"
date: 2018-02-28 16:00:00 -0800
comments: true
categories: python
---

After my [Loop Better talk at PyGotham 2017][loop better] someone asked me a great question: iterators are lazy iterables and `range` is a lazy iterable in Python 3, so is `range` an iterator?

Unfortunately, I don't remember the name of the person who asked me this question.  I do remember saying something along the lines of "oh I love that question!"

I love this question because `range` objects in Python 3 ([xrange in Python 2][xrange]) are lazy, but **range objects are not iterators** and this is something I see folks mix up frequently.

In the last year I've heard Python beginners, long-time Python programmers, and even other Python educators mistakenly refer to Python 3's `range` objects as iterators.  This distinction is something a lot of people get confused about.


## Yes this *is* confusing

When people talk about iterators and iterables in Python, you're likely to hear the someone repeat the misconception that `range` is an iterator.  This mistake might seem unimportant at first, but I think it's actually a pretty critical one.  If you believe that `range` objects are iterators, your mental model of how iterators work in Python *isn't clear enough yet*.  Both `range` and iterators are "lazy" in a sense, but they're lazy in fairly different ways.

With this article I'm going to explain how iterators work, how `range` works, and how the laziness of these two types of "lazy iterables" differs.

But first, I'd like to ask that you **do not use the information below as an excuse to be unkind to anyone**, whether new learners or experienced Python programmers.  Many people have used Python very happily for years without fully understanding the distinction I'm about to explain.  You can write many thousands of lines of Python code without having a strong mental model of how iterators work.


## What's an iterator?

In Python an iterable is anything that you can iterate over and an iterator is the thing that does the actual iterating.

Iter-<strong>ables</strong> are able to be iterated over.  Iter-<strong>ators</strong> are the agents that perform the iteration.

You can get an iterator from any iterable in Python by using the `iter` function:

```python
>>> iter([1, 2])
<list_iterator object at 0x7f043a081da0>
>>> iter('hello')
<str_iterator object at 0x7f043a081dd8>
```

Once you have an iterator, the only thing you can do with it is get its next item:

```python
>>> my_iterator = iter([1, 2])
>>> next(my_iterator)
1
>>> next(my_iterator)
2
```

And you'll get a stop iteration exception if you ask for the next item but there aren't anymore items:

```python
>>> next(my_iterator)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

Both conveniently and somewhat confusingly, all iterators are also iterables.  Meaning you can get an iterator from an iterator (it'll give you itself back).  Therefore you can iterate over an iterator as well:

```python
>>> my_iterator = iter([1, 2])
>>> [x**2 for x in my_iterator]
[1, 4]
```

Importantly, it should be noted that iterators are stateful.  Meaning once you've consumed an item from an iterator, it's gone.  So after you've looped over an iterator once, it'll be empty if you try to loop over it again:

```python
>>> my_iterator = iter([1, 2])
>>> [x**2 for x in my_iterator]
[1, 4]
>>> [x**2 for x in my_iterator]
[]
```

In Python 3, `enumerate`, `zip`, `reversed`, and a number of other built-in functions return iterators:

```python
>>> enumerate(numbers)
<enumerate object at 0x7f04384ff678>
>>> zip(numbers, numbers)
<zip object at 0x7f043a085cc8>
>>> reversed(numbers)
<list_reverseiterator object at 0x7f043a081f28>
```

Generators (whether from generator functions or generator expressions) are one of the simpler ways to create your own iterators:

```python
>>> numbers = [1, 2, 3, 4, 5]
>>> squares = (n**2 for n in numbers)
>>> squares
<generator object <genexpr> at 0x7f043a0832b0>
```

I often say that iterators are lazy single-use iterables.  They're "lazy" because they have the ability to only compute items as you loop over them.  And they're "single-use" because once you've "consumed" an item from an iterator, it's gone forever.  The term "exhausted" is often used for an iterator that has been fully consumed.

That was the quick summary of what iterators are.  If you haven't encountered iterators before, I'd recommend reviewing them a bit further before continuing on.  I've written [an article which explains iterators](http://treyhunner.com/2016/12/python-iterator-protocol-how-for-loops-work/) and I've given a talk, [Loop Better][] which I mentioned earlier, during which I dive a bit deeper into iterators.


## How is range different?

Okay we've reviewed iterators.  Let's talk about `range` now.

The `range` object in Python 3 (`xrange` in Python 2) can be looped over like any other iterable:

```python
>>> for n in range(3):
...     print(n)
...
0
1
2
```

And because `range` is an iterable, we can get an iterator from it:

```python
>>> iter(range(3))
<range_iterator object at 0x7f043a0a7f90>
```

But `range` objects themselves are not iterators.  We **cannot** call `next` on a `range` object:

```python
>>> next(range(3))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'range' object is not an iterator
```

And unlike an iterator, we can loop over a `range` object without consuming it:

```python
>>> numbers = range(3)
>>> tuple(numbers)
(0, 1, 2)
>>> tuple(numbers)
(0, 1, 2)
```

If we did this with an iterator, we'd get no elements the second time we looped:

```python
>>> numbers = iter(range(3))
>>> tuple(numbers)
(0, 1, 2)
>>> tuple(numbers)
()
```

Unlike `zip`, `enumerate`, or `generator` objects, `range` objects **are not iterators**.


## So what is range?

The `range` object is "lazy" in a sense because it doesn't generate every number that it "contains" when we create it.  Instead it gives those numbers to us as we need them when looping over it.

Here is a `range` object and a generator (which is a type of iterator):

```python
>>> numbers = range(1_000_000)
>>> squares = (n**2 for n in numbers)
```

Unlike iterators, `range` objects have a length:

```python
>>> len(numbers)
1000000
>>> len(squares)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: object of type 'generator' has no len()
```

And they can be indexed:

```python
>>> numbers[-2]
999998
>>> squares[-2]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'generator' object is not subscriptable
```

And unlike iterators, you can ask them whether they contain things without changing their state:

```python
>>> 0 in numbers
True
>>> 0 in numbers
True
>>> 0 in squares
True
>>> 0 in squares
False
```

If you're looking for a description for `range` objects, you could call them "lazy sequences".  They're sequences (like lists, tuples, and strings) but they don't really contain any memory under the hood and instead answer questions computationally.

```python
>>> from collections.abc import Sequence
>>> isinstance([1, 2], Sequence)
True
>>> isinstance('hello', Sequence)
True
>>> isinstance(range(3), Sequence)
True
```


## Why does this distinction matter?

It might seem like I'm nitpicking in saying that range isn't an iterator, but I really don't think I am.

If I tell you something is an iterator, you'll know that when you call `iter` on it you'll always get the same object back (by definition):

```
>>> iter(my_iterator) is my_iterator
True
```

And you'll be certain that you can call `next` on it because you can call `next` on all iterators:

```
>>> next(my_iterator)
4
>>> next(my_iterator)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

And you'll know that items will be consumed from the iterator as you loop over it.  Sometimes this feature can come in handy for processing iterators in particular ways:

```python
>>> my_iterator = iter([1, 2, 3, 4])
>>> list(zip(my_iterator, my_iterator))
[(1, 2), (3, 4)]
```

So while it may seem like the difference between "lazy iterable" and "iterator" is subtle, these terms really do mean different things.  While "lazy iterable" is a very general term without concrete meaning, the word "iterator" implies an object with a very specific set of behaviors.

## When in doubt say "iterable" or "lazy iterable"

If you know you can loop over something, it's an <strong>iterable</strong>.

If you know the thing you're looping over happens to compute things as you loop over it, it's a <strong>lazy iterable</strong>.

If you know you can pass something to the `next` function, it's an <strong>iterator</strong> (which are the most common form of lazy iterables).

If you can loop over something multiple times without "exhausting" it, it's not an iterator.  If you can't pass something to the `next` function, it's not an iterator.  Python 3's `range` object is not an iterator.  If you're teaching people about `range` objects, please don't use the word "iterator".  It's confusing and might cause others to start misusing the word "iterator" as well.

On the other hand, if you see someone else misusing the word iterator don't be mean.  You may want to point out the misuse if it seems important, but keep in mind that I've heard long-time Python programmers and experienced Python educators misuse this word by calling `range` objects iterators.  Words are important, but language is tricky.

Thanks for joining me on this brief `range` and iterator-filled adventure!


[loop better]: https://www.youtube.com/watch?v=Wd7vcuiMhxU
[xrange]: treyhunner.com/2018/02/python-3-s-range-better-than-python-2-s-xrange/
