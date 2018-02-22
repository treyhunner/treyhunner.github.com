---
layout: post
title: "Loop better: a deeper look at the iterator protocol"
date: 2018-02-19 10:00:45 -0800
comments: true
categories: python
---

**TODO intro**


## Looping Problems


### Problem 1: Looping Twice

Let's say we have a list of numbers and a generator that will give us the squares of those numbers:

```pycon
>>> numbers = [1, 2, 3, 5, 7]
>>> squares = (n**2 for n in numbers)
```

We can pass our generator object to the `tuple` constructor to make a tuple out of it:

```pycon
>>> tuple(squares)
(1, 4, 9, 25, 49)
```

If we then take the same generator object and pass it to the `sum` function we might expect that we'd get the sum of these numbers, which would be 88.

Instead we'll get `0`:

```pycon
>>> sum(squares)
0
```

### Problem 2: Containment Checking

```pycon
>>> numbers = [1, 2, 3, 5, 7]
>>> squares = (n**2 for n in numbers)
>>> 9 in squares
True
>>> 9 in squares
False
```

- If we ask whether `9` is in this generator **(click)**, Python will tell us this is `True` **(click)**
- 9 *is* in this generator
- If we ask the *same question* again **(click)**, Python will tell us this time, that it's `False` **(click)**
- We asked the same question twice and Python gave us two different answers.
- That's a little weird

### Problem 3: Unpacking

```pycon
>>> counts = {'apples': 2, 'oranges': 1}
>>> x, y = counts
>>> x
'apples'
```

- This dictionary has two key-value pairs
- If we try to unpack this dictionary into two variables **(click)**, you might think we'll get an error
- But we don't **(click)**... we can unpack dictionaries
- Okay that's a little odd, but let's just go with it
- You might expect at this point that `x` and `y` at this point are tuples of key-value pairs
-  **(click)** But you'd be wrong.
- `x` and `y` are not tuples of key-value pairs... they're keys.
- That's a little weird also.  We'll come back to that at the end of this talk.


## Review: Python's for loop

**TODO**


## Python's for loops don't use indexes

How do Python's `for` loops actually work?

- You might think that under the hood, Python's `for` loops use indexes to loop
- Here we're manually looping over an iterable using a `while` loop and indexes
- This works for lists **(click)**, but it won't work everything
- In fact, this way of looping *only* works for *sequences*
- This *will not* work for all iterables
- For example, this won't work for sets

```python
numbers = [1, 2, 3, 5, 7]
i = 0
while i < len(numbers):
    print(numbers[i])
    i += 1
```

- If we try to manually loop a set using indexes, we'll get an error. **(click)**
- Because **sets are not sequences**: they don't support indexing
- At this point we could try converting this set to a list and then looping over it with indexes, but that would be cheating
- Plus that's not going to work at all for those infinitely long iterables I mentioned earlier
- We *cannot* manually loop over every iterable by using indexes: it just isn't possible sometimes
- So we can assume at this point that `for` loops in Python don't actually use indexes
- So Python's `for` loops don't use indexes to loop over iterables... but what *do* they use?

```pycon
>>> fruits = {'lemon', 'apple', 'orange', 'watermelon'}
>>> i = 0
>>> while i < len(fruits):
...     print(fruits[i])
...     i += 1
...
Traceback (most recent call last):
File "<stdin>", line 2, in <module>
TypeError: 'set' object does not support indexing
```

We cannot rely on indexes when looping in Python.


## Iterators power for loops


- Under the hood, Python's for loops rely on something called an **iterator**
- Iterators are the thing that powers `for` loops in Python
- You can get an iterator from any iterable in Python-
- And you can use an iterator to manually loop over an iterable
- Let's take a look at how that works

Iterables can give you iterators

```pycon
>>> numbers = [1, 2, 3, 5, 7]
>>> coordinates = (4, 5, 7)
>>> words = "hello there"
>>> iter(numbers)
<list_iterator object at 0x7f2b9271c860>
>>> iter(coordinates)
<tuple_iterator object at 0x7f2b9271ce80>
>>> iter(words)
<str_iterator object at 0x7f2b9271c860>
```

- We have three iterables here: a list, a tuple, and a string
- We can ask each of these for an *iterator* using Python's built-in **`iter` function** **(click)**
- Passing an iterable to the `iter` function will always give us back an iterator **(click)**, no matter what type of iterable we're working with
- Lists, strings, and tuples are all iterables **(click)**
- And every iterable will provide us with an iterator when we pass it to the built-in `iter` function

Iterators can give the next item

```pycon
>>> numbers = [1, 2, 3]
>>> iterator = iter(numbers)
>>> next(iterator)
1
>>> next(iterator)
2
>>> next(iterator)
3
>>> next(iterator)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
```

- Once we *have* an iterator, there is *only* one thing that we can do with it **(click)**: **get its next item**
- **(click)** We can use Python's built-in `next` function to get the *next* item **(click)** from *any* iterator
- And if you ask for the `next` item and there are **no more items** **(click)**, you'll get a `StopIteration` exception
- So you can get an iterator from every iterable
- And the only thing that you can do with iterators is ask them for their next item
- And if they don't have a next item you'll get an exception

**TODO**: tally-counter image (with proper attribution)

- So you can think of iterators as kind of like one-directional tally counters, with a broken reset button
- They keep track of where they are as you ask them for their next item
- But they only go in one direction
- And they cannot be reset
- Iterators are one-directional tally-counts without a reset button

**TODO**: hello kitty PEZ image (with proper attribution)

- Iterators are *also* kind of like a Hello Kitty PEZ dispenser that cannot be reloaded
- When you take a PEZ out, it's gone
- And once the dispenser is empty, it's useless
- Iterators are Hello Kitty PEZ dispensers that cannot be reloaded


## Looping without a for loop


- Now that we know about iterators, we're going to try manually looping over an iterable once again
- We'll do that, by turning this `for` loop into a `while` loop
- We've already established that we can't use *indexes* to loop over an arbitrary iterables
- But we *can* get iterators from iterables
- And we can repeatedly get the next item from an iterator to loop over that iterable
- So that's what we're going to do

```python
def funky_for_loop(iterable, action_to_do):
    for item in iterable:
        action_to_do(item)
```

- In order to manually loop over an iterable **(click)** we need to get an iterator from it
- Then we can loop repeatedly **(click)**
- And get the *next* item from the iterator each time we loop **(click)**
- Once we have that next item, we can execute whatever the body of our `for` loop is supposed to do **(click)**
- And if we get a `StopIteration` exception while we're asking for the next item **(click)**, we know it's time to stop looping *(pause)*
- **(click)** We've just re-invented a `for` loop by using a `while` loop and iterators
- This code pretty much defines the way looping works under the hood in Python
- If you understand the way the built-in `iter` and `next` functions work for looping over things, you understand how Python's `for` loops work

```python
def funky_for_loop(iterable, action_to_do):
    iterator = iter(iterable)
    done_looping = False
    while not done_looping:
        try:
            item = next(iterator)
        except StopIteration:
            done_looping = True
        else:
            action_to_do(item)
```

- In fact this is a little bit more than just how `for` loops work.
- **The iterator protocol** is a very fancy sounding way of saying "how looping works in Python"
- It's essentially the definition of the way the `iter` and `next` functions work in Python, which is what we just saw
- The iterator protocol is the thing that powers *all* forms of iteration in Python
- **(click)** For loops use the iterator protocol
- **(click)** Multiple assignment also uses the iterator protol
- **(click)** star expressions use it
- **(click)** many built-in functions rely on the iterator protocol
- Anything in Python that works with an *iterable* probably uses the iterator protocol in some way
- Any time you're looping over an iterable, you're relying on the iterator protocol

```python
for n in numbers:
    print(n)
```

```python
x, y, z = coordinates
```

```python
a, b, *rest = numbers
print(*numbers)
```

```python
unique_numbers = set(numbers)
```


## Generators are iterators

- So you might be thinking: iterators seem cool, but they also just seem like an implementation detail and we might not need to *care* about them as users of Python
- Because we're not Python core developers, we're just using Python... so why do we care about these?
- *(pause)* I have news for you: you have seen iterators before
- In fact you've seen them earlier during my talk

- This is a generator **(click)**
- This generator object is **also** an iterator
- Which means that we can pass it to the `next` function **(click)** to get its next item **(click)**
- So generators are iterators...
- *(pause)* If you've used a generator before, you know that there is something else that we can do with them **(click)**
- You can loop over generators **(click)**
- If we can loop over something what type of thing is it? *(pause)*... it's an iterable
- An iterable is anything that can be looped over
- So I just showed you that you can use the `next` function with generators... which means generators are **iterators**
- But we can also loop over generators... which means generators are **also** **iterables**
- So generators are iterators, but they're also iterables.
- What's going on here?  How and why are they both iterators and iterables?

```pycon
>>> numbers = [1, 2, 3]
>>> squares = (n**2 for n in numbers)
>>> next(squares)
1
>>> next(squares)
4
>>> squares = (n**2 for n in numbers)
>>> for n in squares:
...     print(n)
...
1
4
9
```


## I've been lying to you


- So I haven't quite been telling you the truth... at least not the whole truth
- There's something pretty *important* that I've neglected to mention so far...

- **Iterators** are also **iterables**
- Which means that we can get an iterator from an *iterator* using the built-in `iter` function **(click)**
- Just like we can with any other iterable **(click)**
- So we can also call `iter` on an *iterator* to ask **it** for an iterator
- When we *do that* **(click)** , it will give us **itself** back **(click)**
- Iterators are iterables and their iterator is themselves
- Iterators are their own iterators

```pycon
>>> numbers = [1, 2, 3]
>>> iterator = iter(numbers)
>>> iterator2 = iter(iterator)
>>> iterator2
<listiterator object at 0x7f92db9bf350>
>>> iterator is iterator2
True
```

- This fact that I've neglected to mention so far, that iterators are also iterables... this is the last key part of Python's **iterator protocol**
- If you ask an iterable for an iterator and it gives you *itself* back, that iterable **must** be also an iterator
- All iterators are iterables
- And all iterators are their own iterators
- Who's confused right now?
- Who wants me to say the words iterator and iterable a few more times?
- The similarity between these words makes talking about these stuff a little confusing sometimes
- So iterables are something you can loop over.
- Iterators are the thing that helps you loop over an iterable.
- But iterators are *also* something you can loop over.  All iterators are also iterables.
- Let's talk about why that matters

```python
def is_iterator(iterable):
    return iter(iterable) is iterable
```

- So iterators are iterables, but they have no idea how many items they contain
- **(click)** So they have no length
- **(click)** They also can't be indexed
- The only things you can do with iterators are:
  - call `next` on them **(click)**
  - and loop over them **(click)**
- And if we loop over an iterator a second time, we'll get nothing back **(click)**
- You can think of iterators are **lazy iterables** that can be looped over **one time only**
- Iterators are lazy iterables that can *only* be looped over once, and then they're done

Iterators are single-purposed

```pycon
>>> numbers = [1, 2, 3, 5, 7]
>>> iterator = iter(numbers)
>>> len(iterator)
TypeError: object of type 'list_iterator' has no len()
>>> iterator[0]
TypeError: 'list_iterator' object is not subscriptable
>>> next(iterator)
1
>>> list(iterator)
[2, 3, 5, 7]
>>> list(iterator)
[]
```

- So some quick review
- So iterables are not necessarily iterators
- But iterators are always iterables
- For example generators are iterators
- But lists are not iterators
- Iterables are not *always* iterators, but iterators *are* always iterables

<table>
<thead>
<tr>
<th>Object</th>
<th>Iterable?</th>
<th>Iterator?</th>
</tr>
</thead>
<tbody>
<tr><td>Iterable</td><td>&#x2714;&#xfe0f;</td><td>&#x2753;</td></tr>
<tr><td>Iterator</td><td>&#x2714;&#xfe0f;</td><td>&#x2714;&#xfe0f;</td></tr>
<tr><td>Generator</td><td>&#x2714;&#xfe0f;</td><td>&#x2714;&#xfe0f;</td></tr>
<tr><td>List</td><td>&#x2714;&#xfe0f;</td><td>&#x274c;</td></tr>
</tbody>
</table>


## The iterator protocol, in full

**TODO**


## Iterators enable laziness

- Okay this is all a little bit confusing

- And I still haven't really answered the question of...
- Do we really need to know any of this?

1. Iterators allow for lazily evaluated iterables
2. Iterators allow for infinitely long iterables
3. Iterators allow us to save memory and (sometimes) time

- So there are some very good reasons for understanding the iterator protocol in Python
- **(click)** Understanding iterators will allow *you* to be lazy and they will allow *your code* to be lazy
- Iterators allow us to both *work with* and *create* **lazy iterables** that don't do *any work* until we *ask them* for their **next item**
- **(click)** Because we can create lazy iterables, we can make **infinitely long** iterables
- **(click)** And we can create iterables that are conservative with system resources, that save us memory of save us time


## Iterators are everywhere

- You've already seen lots of iterators in Python
- I've already mentioned that generators are iterators
- **(click)** `enumerate` objects are also iterators
- **(click)** and so are `zip` objects
- **(click)** and a number of other objects including files
- There are lots of iterators built-in to Python, in the standard library, and in third-party libraries that you use all the time
- These iterators **all** act like **lazy iterables**
- They don't do any work, until you start looping them

```pycon
>>> letters = ['a', 'b']
>>> next(enumerate(letters))
(0, 'a')
>>> next(zip(letters, letters))
('a', 'a')
>>> next(open('hello.txt'))
'hello world\n'
```


## Creating your own iterator

- So it's useful to know that you're already using iterators
- But I'd like you to know that you can use iterators to create *your own* lazy iterables **(click)**
- This class makes an iterator that accepts an *iterable of numbers* and squares each of those numbers
- but it doesn't do any work until we start looping over it
- This iterator works, but we *don't* usually make iterators this way with classes
- Usually when we want to make a custom iterator, we make a generator function **(click)**
- This generator function is equivalent to that class
- *(pause)* That `yield` statement probably seem magical, but it is *very* powerful: that `yield` allows us to put our generator on pause between `next` calls
- *(pause)* Another way we could implement this same iterator is with a generator expression **(click)**
- This does the same thing as that generator function but it uses a syntax that looks like a list comprehension
- If you need to make a lazy iterable, think of iterators... and consider making a generator function or a generator expression

```python
class square_all:
    def __init__(self, numbers):
        self.numbers = iter(numbers)
    def __next__(self):
        return next(self.numbers) ** 2
    def __iter__(self):
        return self
```

```python
def square_all(numbers):
    for n in numbers:
        yield n**2
```

```python
def square_all(numbers):
    return (n**2 for n in numbers)
```


## How iterators can improve your code

**TODO**


## Looping Problems: Revisited

**TODO**


## Recap and related resources

**TODO**
