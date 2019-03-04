---
layout: post
title: "Deep comparisons and code readability in Python"
date: 2019-03-12 08:00:00 -0700
comments: true
categories: python readability tuples
---

Comparing things in Python.
It sounds like something that almost doesn't even need to be taught.
But I've found that Python's comparison operators are often misunderstood and under-appreciated by newer Pythonistas.

Let's review how Python's comparison operators work on different types of objects and then take a look at how we can use this to improve the readability of our code.


## Python's comparison operators

By "comparison operators" I mean the equality operators (`==` and `!=`) and the ordering operators (`<`, `<=`, `>`, `>=`).

We can use these operators to compare numbers, as you'd expect.

But we can also use these operators to compare strings:

And even tuples:


## Deep equality

(self.x, self.y, self.z) == (other.x, other.y, other.z) ... also (x1, y1, z1) == (x2, y2, z2) when multiple assignment/tuple unpacking works on an object

## Deep ordering


## Lexicographical ordering


## Deep hashability (and unhashability)


## Deep comparisons are a tool to remember


