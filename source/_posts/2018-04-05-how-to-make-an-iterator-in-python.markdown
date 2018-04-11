---
layout: post
title: "How to make an iterator in Python"
date: 2018-04-11 09:00:00 -0700
comments: true
categories: python
---

- I wrote an article on for loops in which I explained the iterator protocol, which is the thing that powers for loops

- One thing I left out of that post was how to make your own iterators

- First: why make an iterator?
  - iterators allow you to make an iterable that computes its items as it goes
  - so you can make iterables that are lazy
  - memory efficiency: sometimes time efficiency

- __iter__ and __next__

- generator function

- generator expression
