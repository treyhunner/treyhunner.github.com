---
layout: post
title: "Asterisks in Python: what they are and how to use them"
date: 2018-09-23 19:20:15 -0700
comments: true
categories: python
---

There are a lot of places you'll see `*` and `**` used in Python.
I'd like to discuss what those operators are and the many ways they're used.

If you learned `*` and `**` back in the days of Python 2, make sure to skim this article because Python 3 has added a lot of new uses for these operators.


## What we're not talking about

When I discuss `*` and `**` in this article, I'm talking about the `*` and `**` *prefix* operators, not the *infix* operators.

So I'm not talking about multiplication and exponentiation:

```pycon
>>> 2 * 5
10
>>> 2 ** 5
32
```

I'm talking about these:

TODO various ways to use * and **



Asterisks for unpacking into function call

Asterisks for packing arguments given to function

Keyword-only arguments come after the asterisks in function call

Setting keyword-only arguments without capturing positional args: asterisk on its own

In list literals: [*items[1:], items[0]]
Only Python 3.5+

Using asterisks multiple times in function calls
Good example?? (Python 3.5+ only)

