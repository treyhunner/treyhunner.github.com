---
layout: post
title: "Functions are Objects in Python"
date: 2020-01-02 16:37:48 -0800
comments: true
categories: python
published: false
---

A concept that often trips up newer Python programmers is the fact that **functions are objects**.

By "functions are objects" I meant that you can treat a function pretty much the same way you'd treat any other object, like the list `[1, 2, 3]` or the string `"hello"`.
This concept isn't an essential one at first, but as you dive deeper into Python you'll find that it can be quite convenient to treat functions **just like any other object**.

The first two sections of this article are quite useful to understand.
Until the day you need to create a decorator in Python, you can probably get away with skipping over the other sections.


## Functions can be referenced

You've probably accidentally done this by accessing a function without using parenthesis to call it (you'll see function or bound method with some name).
You can assign a variable which points to a function.

You would rarely do this, except in some odd cases (append = numbers.append before a for loop).


## Functions can be passed into other functions

- Functions can be passed into other functions (whenever you see a lambda function used, it's very likely being passed into another function)
- A "key function" is probably the most common use case of functions being passed into other functions
    - Some functions built-in to Python  which accept iterables for ordering (`sorted`, `min`, `max`) also accept a `key` [keyword argument][]
    - This `key` argument should be a function [or another callable][].  This callable will be called for each value in the given iterable and the return value will be used to order/sort each of the iterable items
    - This is a common convention that other functions use as well (examples in standard lib and third party libraries)
- Since functions can be passed into functions, that means that functions can accept other functions as arguments, so we could re-implement the built-in `map` or `filter` functions for example


## Functions can be defined inside other functions

- Functions can be defined inside other functions
- Functions can be returned from functions
- This is how decorators work in Python: a decorator is a function that accepts a function and returns a function (if that sounds confusing, it *is*... it's a useful abstraction though)
    - Note: decorators can also accept classes (class decorators) or return non-functions (property doesn't return a function) and they can even be implemented using classes instead of functions (property, classmethod, and staticmethod are all classes)


## Functions returned from functions form a closure

Sometimes decorators take advantage of the enclosing scope that comes from a function.
When this enclosing scope is used, it's called a closure.
In Python 2 this enclosing scope was read-only, but in Python 3 you can write to it by using the `nonlocal` statement.

There's a `__closure__` on all functions

Reading from closures happens quite a bit with decorators, but closures aren't written to much because usually when you want to store state along with a function, you'll turn it into a class instead.


## Functions can also have attributes

Another way to associate state with a particular function is to store attributes on it.

If you want to store state for a function which is meant to be read from the outside (don't reach into `__closure__` from the outside: that's weird), you could assign an attribute on a function.

This isn't a very common thing to see because usually when you want to store some state associated with a bit of functionality, you'd turn your function into a class

You'll sometimes see this with decorator functions that store state on the function they return


## Everything is an object: not just functions

Everything in Python is an object.
The word "object" often makes people think of "an instance of a particular class".
For example we talk about "list objects" or "dictionary objects".
Instances of classes are the most obvious "object" in Python.

We now know that functions are also objects.
In addition to class instances and functions, classes are objects too.
And so are modules.

You can add attributes to classes and modules and you can change attributes within classes and modules.
