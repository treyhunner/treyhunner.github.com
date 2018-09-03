---
layout: post
title: "Stop writing lambda expressions in Python"
date: 2018-09-13 10:00:00 -0700
comments: true
categories: 
---

It's hard for me to teach an in-depth Intro to Python class without mentioning lambda expressions.
I've tried, but I *always* get questions about them.
Sometimes it's because my students see them in code that their coworkers wrote.
Sometimes it's because they see lambda expressions in answers on Stack Overflow.
Sometimes it's because they see lambda expressions in code that their coworkers copy-pasted from Stack Overflow. 😉

Python's lambda expressions are a "love it or hate" feature.
I wouldn't say I hate them, but I have acquired a general dislike of them.
My aversion to lambda expressions has been strengthened since I started teaching Python more regularly a few years ago.

I'd like to discuss how I see lambda expressions and why I tend to dislike them.

## Lambda expressions in Python: what are they?

Python's lambda expressions are Python's version of anonymous functions.

They ...

JavaScript's anonymous function syntax looks pretty much identical to it's non-anonymous function syntax.  Python's doesn't.

JavaScript's anonymous functions allow for multiple statements and a proper return statement for added familiarity and clarity.  Python's doesn't.

As far as language features go, Python's lambda expressions sometimes feel like an afterthought.


## When not to use them

my_func = lambda x: x
PEP8 says not to do this


## Where they're usually used

sorted(things, key=lambda x: x)

This works but that lambda expression is rarely more immediately clear than a clearly named function


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
