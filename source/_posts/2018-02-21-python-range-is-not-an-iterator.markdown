---
layout: post
title: "Python: range is not an iterator!"
date: 2018-03-05 08:00:00 -0800
comments: true
categories: python
---

Someone asked a great question recently: iterators are lazy iterables and range is a lazy iterable, so is range an iterator?

I was asked this by someone in the hallway after I gave my [Loop Better talk at PyGotham 2017][loop better].  Unfortunately, I don't remember the name of the person who asked me this question.  I do remember saying something along the lines of "oh I love that question!"

I love this question because `range` objects in Python 3 ([xrange in Python 2][xrange]) are lazy, but **`range` objects are not iterators**.

I've seen a lot of people get confused about this.  In the last year I've heard Python beginners, long-time Python programmers, and even other Python trainers mistakenly refer to Python 3's `range` objects as iterators.

When people talk about iterators and iterables in Python, you're likely to hear the someone repeat the misconception that `range` is an iterator.  This mistake might seem unimportant at first, but I think it's actually a pretty critical one.  If you believe that `range` objects are iterators, your mental model of how iterators work in Python isn't clear enough yet.  Both `range` and iterators are "lazy" in a sense, but they're lazy in fairly different ways.

With this article I'm going to explain how iterators work, how `range` works, and how the laziness of these two types of "lazy iterables" differs.


## What's an iterator?


## How is range different?


## So what is range?


## Why does this distinction matter?



[loop better]: https://www.youtube.com/watch?v=Wd7vcuiMhxU
[xrange]: treyhunner.com/2018/02/python-3-s-range-better-than-python-2-s-xrange/
