---
layout: post
title: "Is it a class or a function? It's a callable!"
date: 2019-04-16 08:00:00 -0700
comments: true
categories: python
---
If you search course curriculum I've written (or GitHub repos for that matter), you'll often find phrases like "zip function", "enumerate function", "list function".
Those terms are technically misnomers.

When I use terms like "the bool function" or "the str function" I'm incorrectly implying that `bool` or `str` are functions.
But they're not: they're classes.

I'm going to explain why that's the case and then argue that this distinction between functions and classes in Python is frequently overlooked because **it often doesn't matter**.


## Class or function?

When I'm teaching a new group of Python developers, there's an activity we often do as a group: the class or function game.

In **the class or function game**, we take something that we call and we guess whether it's a class or a function.

For example, we can call `zip` with iterables and we get another iterable back, so is `zip` a class or a function?
When we call `len`, are we calling a class or a function?
And what about `int`: is it a class or a function?

TODO examples of what is a class and what is actually a function
- Classes that we often think of as functions: reversed, itertools.count, enumerate, range, zip, str, int, bool, map, filter

After this game we discuss **callables** and the fact that **we often don't care whether something is a class or a function**.


## What's a callable?

Callables: they're a pretty important concept in Python


## Classes are callables

- The syntax for class instantiation is the same as the syntax for function calls. Classes are just callables that give you back class instances.


## The distinction between functions and classes often doesn't matter

- generator functions functions that return iterators
- functions that give an iterable back vs classes that are iterable
- factory functions that return an instance vs a class (which returns an instance when you call it)
- defaultdict accepts a callable
- the key function for sorted accepts a callable
- map accepts a callable


## Callable objects

classes with a `__call__` method


## Disguising classes as functions

- property, classmethod, and staticmethod decorators
- most context managers
- you can even use a class to make a decorator, even though we normally think of decorators as functions


## Think in terms of "callables" not "classes"

In Python Morsels exercises, I often ask learners to make a "callable".
Sometimes I don't care whether their callable is a generator function, an iterator class, or a function that returns a generator expression.
All of these things are *callables* that return the right type that I'm testing for (an iterator).

