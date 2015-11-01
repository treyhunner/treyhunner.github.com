---
layout: post
title: "Counting things in Python: a history"
date: 2015-11-01 01:56:53 -0700
comments: true
categories: python
---

Let's take a look at different ways to count the number of times things appear in a list.  The "Pythonic" way to do this has changed as Python has changed so we also discuss a bit of Python history to put these methods in context.

## The Obvious Ways: For Loop

- the obvious ways: a simple for loop
  - if a.has_key(k) -> k in a (added in 2.2)
    "https://docs.python.org/2.2/lib/typesmapping.html"
  - if-else (lots of lines of code, one less hash in initial case for each) more performant than plain if on sparse lists, about the same on dense lists
  - if statement: three hashes in base case for each
  - try-except: it's better to ask forgiveness than permission (no LBYL)!
    "more performant than if/if-else cases on dense lists, less performant on sparse lists"
  - performance: https://gist.github.com/treyhunner/0987601f960a5617a1be

- a[k] = a.get(k, 0) + 1
  "introduced in Python 1.5
  https://docs.python.org/release/1.5.2/lib/typesmapping.html
  https://docs.python.org/release/1.4/lib/node13.html#SECTION00316000000000000000"
  - one line of code
  - requires two hashes every time
  - too clever to me

## setdefault

- setdefault
  "introduced in Python 2.0
  https://docs.python.org/2.0/lib/typesmapping.html
  https://docs.python.org/release/1.6/lib/typesmapping.html"
  - only two hashes each time
  - two lines of code... not bad: looks more Pythonic
  - actually slower than the cases we've seen so far (probably due to the function call)

## defaultdict

- defaultdict
  "introduced in Python 2.5
  https://docs.python.org/release/2.5/lib/module-collections.html
  https://docs.python.org/release/2.4/lib/module-collections.html"
  - only one hash each time, no containment/default check at all
  - as elegant as the for loop counter can get
  - faster for dense lists, slower for sparse ones

## Counter

- Counter
  "introduced in Python 2.7
  https://docs.python.org/release/2.7/library/collections.html"
  - Counter does all the work of the for loop, passing back a mapping
  - convert to dict if you really need a dict, but there usually isn't a need
-  this is clever but was never Pythonic: {x: my_list.count(x) for x in set(my_list)}
