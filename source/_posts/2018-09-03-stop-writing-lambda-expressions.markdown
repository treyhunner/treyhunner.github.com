---
layout: post
title: "Stop writing lambda expressions in Python"
date: 2018-09-13 10:00:00 -0700
comments: true
categories: 
---

It's hard for me to teach an in-depth Python class without discussing lambda expressions.
I almost always get questions about them.
My students tend to see them in code on StackOverflow or they see them in a coworker's code (which, realistically, may have also come from StackOverflow).

I'm hesitant to recommend my students embrace Python's lambda expressions.
Python's lambda is a "love it or hate" feature and while I wouldn't say I hate them, I have acquired a general dislike of them.
And from the time I started teaching Python more regularly a few years ago, my aversion to lambda expressions has only grown stronger.

I'm going to explain how I see lambda expressions and why I tend to dislike them.

## Lambda expressions in Python: what are they?

Lambda expressions a special syntax in Python for creating [anonymous functions][].
I'll call the `lambda` syntax itself a **lambda expression** and the function you get back from this I'll call a **lambda function**.

Python's lambda allows a function to be created and passed around (often into another function) all in one line of code.
Instead of this:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])

def lowercase(string):
    return string.lower()

normalized_colors = map(lowercase, colors)
```

We could do this:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])

normalized_colors = map(lambda s: s.lower(), colors)
```

Lambda expressions are just a special syntax for making functions.
They can only have one statement in them and they return the result of that statement automatically.

The limitations of lambda expressions are also part of their appeal.
When you see a lambda expression you know you're working with a function that does a single thing and is only used in one place.



The function you get back from a `lambda` expression has no name.

You could try to "name" a lambda function but assigning a lambda function to a variable name isn't the same as actually giving the function object itself a name:

```python
>>> lowercase = lambda s: s.lower()
>>> lowercase
<function <lambda> at 0x7f264d5b91e0>
```

## Where they're usually used

You'll typically see `lambda` expressions used when calling functions (or classes) that accept a function as their argument.

Python's built-in `sorted` function accepts a function as its `key` argument.  This *key function* is used to compute a comparison key when determining the sorting order of items.  For example, here we're sorting words by ignoring their case:

```python
>>> colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])
>>> sorted(colors, key=lambda s: s.lower())
```

This works but that lambda expression is rarely more immediately clear than a clearly named function

They ...

JavaScript's anonymous function syntax looks pretty much identical to it's non-anonymous function syntax.  Python's doesn't.

JavaScript's anonymous functions allow for multiple statements and a proper return statement for added familiarity and clarity.  Python's doesn't.

As far as language features go, Python's lambda expressions sometimes feel like an afterthought.


## When not to use them

```python
my_func = lambda x: x
```
PEP8 says not to do this


## Why I dislike them

lambda functions are very restrictive: they don't have a name, they can't be documented, they can't have more than a single expression


## But they're useful with functional programming

map and filter.

While you're at it, stop using map and filter and use generator expressions or list comprehensions instead.

Functions are good at functional programming.

Lambda expressions are just nameless functions that were never given a name.


## How to stop using lambda expressions

Comprehensions and generator expressions are a great replacement for using map and filter and some functions really do deserve a name, but what about functions that just add two numbers together?

The operators module!

If you're trying to stop using lambda expressions, the operators module is your friend.
named "key" functions can look silly sometimes.

In general, though higher order functions (functions that accept functions as arguments), can make for confusing code.
Functional programming techniques are great, but Python is a multi-paradigm language and we can mix and match different coding techniques while working toward the goal of more readable and maintainable code.
Try not using the reduce function and other higher order functions so much if you can avoid it because it can make your code confusing for others, especially for folks who don't have a very strong functional programming background.  There's often a simpler alternative: like the `sum` function or a custom-made reduce-like function (e.g. a `product` function).


## Should you ever use lambda expressions?

Using lambda expressions is fine if:

- The operation you're doing is trivial: the function doesn't deserve a name
- Having a lambda expression makes your code more understandable than any function name you can think of
- Everyone on your team understands lambda expressions fairly well and you've all agreed to use them

[anonymous functions]: https://en.wikipedia.org/wiki/Anonymous_function
