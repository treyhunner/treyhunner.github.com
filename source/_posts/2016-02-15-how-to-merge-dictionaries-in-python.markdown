---
layout: post
title: "How to Merge Dictionaries in Python"
date: 2016-02-22 10:00:00 -0800
comments: true
categories: 
---

Have you ever wanted to combine two or more dictionaries in Python?

There are multiple ways to solve this problem: some are awkward, some are inaccurate, and most require multiple lines of code.

Let's walk through the different ways of solving this problem and discuss which is the most [Pythonic][].

## Our Problem

Before we can discuss solutions, we need to clearly define our problem.

Our code has two dictionaries: `user` and `global`.  We want to merge these two dictionaries into a new dictionary called `context`.

We have some requirements:

1. `user` values should override `global` values in cases of duplicate keys
2. keys in `global` and `user` may be any valid keys
3. the values in `global` and `user` can be anything
4. `global` and `user` should not change during the creation of `context`
5. updates made to `context` should never alter `global` or `user`

So we want something like this:

```pycon
>>> user = {'name': "Trey", 'website': "http://treyhunner.com"}
>>> global = {'name': "Anonymous User", 'page_name': "Profile Page"}
>>> context = merge_dicts(global, user)  # magical merge function
>>> context
{'website': 'http://treyhunner.com', 'name': 'Trey', 'page_name': 'Profile Page'}
```


## Possible Solutions

Now that we've defined our problem, let's discuss some possible solutions.

We're going to walk through a number of methods for merging dictionaries and discuss which of these methods is the most accurate and which is the most idiomatic.


### Multiple update

Here's one of the simplest ways to merge our dictionaries:

```python
context = {}
context.update(global)
context.update(user)
```

Here we're making an empty dictionary and using the [update][] method to add items from each of the other dictionaries.  Notice that we're adding `global` first so that any common keys in `user` will override those in `global`.

All five of our requirements were met so this is **accurate**.  This solution takes three lines of code and cannot be performed inline, but it's pretty clear.

- Accurate: yes
- Idiomatic: fairly


### Copy and update

Alternatively, we could copy `global` and update the copy with `user`.

```python
context = global.copy()
context.update(user)
```

This solution is only slightly different from the previous one.

Personally, I prefer to copy the `global` dictionary to make it clear that it represents default values but I might prefer the first solution in another scenario.

- Accurate: yes
- Idiomatic: yes


### Dictionary constructor

We could also pass our dictionary to the `dict` constructor which will also copy the dictionary for us:

```python
context = dict(global)
context.update(user)
```

This solution is very similar to the previous one, but it's a little bit less explicit.

- Accurate: yes
- Idiomatic: somewhat, though I'd prefer the first two solutions over this


### Keyword arguments hack

You may have seen this clever answer before, [possibly on StackOverflow][kwargs hack]:

```python
context = dict(global, **user)
```

This is just one line of code.  That's kind of cool.  However, this solution is is a little hard to understand.

Beyond readability, there's an even bigger problem.  **This solution is wrong.**

The keys must be strings that represent valid variable names.  In CPython (the official Python interpreter), we can get away with invalid variable names as long as the keys are strings and in CPython 2.0 we could even use non-strings as keys.

But don't be fooled, this is a hack that only works by accident in Python 2.0 using the standard CPython runtime.

- Accurate: no.  Rule 2 breaks (keys may be any valid key)
- Idiomatic: no.  This is a hack.


### Dictionary comprehension

Just because we can, let's try doing this with a dictionary comprehension:

```python
context = {k: v for d in [global, user] for k, v in d.items()}
```

This works, but this is not easy to read at all.  Don't do this.

- Accurate: yes
- Idiomatic: not at all


### Concatenate items

What if we get a `list` of items from each dictionary, concatenate them, and then create a new dictionary from that?

```python
context = dict(list(global.items()) + list(user.items()))
```

This actually works.  We know that the `user` keys will win out over `global` because those keys come at the end of our concatenated list.

In Python 2 we actually don't need the `list` conversions, but we're working in Python 3 here (you are on Python 3, right?).

- Accurate: yes
- Idiomatic: not particularly


### Union items

In Python 3, `items` is a `dict_items` object, which is a quirky object that supports union operations.

```python
context = dict(global.items() | user.items())
```

That's kind of interesting.  But this is **not accurate**.

Requirement 1 (`user` should "win" over `global`) fails because the union of two `dict_items` objects is a [set][] of key-value pairs and sets are unordered so duplicate keys may resolve in an *unpredictable* way.

Requirement 3 (the values can be anything) fails because sets require their items to be [hashable][] so both the keys *and values* in our key-value tuples must be hashable.

Side note: I'm not sure why the union operation is even allowed on `dict_items` objects.  What is this good for?

- Accurate: no, requirements 1 and 3 fail
- Idiomatic: no


### Chain items

So far the most idiomatic way we've seen to perform this merge in a single line of code involves creating two lists of items, concatenating them, and forming a dictionary.

We can join our items together more succinctly with [itertools.chain][]:

```python
from itertools import chain
context = dict(chain(global.items(), user.items()))
```

This works well and should be more efficient than creating two unnecessary lists.

- Accurate: yes
- Idiomatic: fairly


### ChainMap

What if we could create a new dictionary without looping over our initial dictionaries?

We can *sort of* do this with [ChainMap][]:

```python
from collections import ChainMap
context = ChainMap({}, user, global)
```

A `ChainMap` groups dictionaries together; lookups query each one until a match is found.

This code raises a few questions.

#### Why did we put `user` before `global`?

We ordered our arguments this way to ensure requirement 1 was met.  The dictionaries are searched in order, so `user` returns matches before `global`.

#### Why is there an empty dictionary before `user`?

This is to ensure requirement 5 is met.  Changing a `ChainMap` object will change the first dictionary provided.  We don't want `user` to change if the `ChainMap` is altered so we provided an empty dictionary as the first mapping.

#### Does this actually give us a dictionary?

A `ChainMap` object is a mapping (a dictionary-like object) but it is not a dictionary.  If our code is practicing duck typing properly we may be okay with this, but we need to take a look at how `ChainMap` objects behave to find out.

We [cannot remove items][ChainMap remove] if they reside in mappings beyond the first (empty) one.  Our `ChainMap` will also change behavior when the [underlying dictionaries change][ChainMap alter].  These are not bugs in `ChainMap`, these are features.

If we really want a dictionary, we could convert our `ChainMap` to a dictionary:

```python
context = dict(ChainMap(user, global))
```

- Accurate: possibly, we'll need to consider our use cases
- Idiomatic: yes if we decide this suits our use case


### Dictionary concatenation

What if we simply concatenate our dictionaries?

```python
context = global + user
```

This is cool, but it **isn't valid** and this syntax will probably never work.

This feature was discussed in a [python-ideas thread][python-ideas] last year though.

Some of the concerns brought up in this thread include:

- Maybe `|` makes more sense than `+` because dictionaries are more like sets
- For duplicate keys, should the left-hand side or right-hand side win?
- Should there be an `updated` built-in instead (kind of like `sorted`)?

So:

- Accurate: no. This doesn't work.
- Idiomatic: no. This doesn't work.


### Dictionary unpacking

If you're using Python 3.5, thanks to [PEP 448][], there's a new way to merge dictionaries:

```python
context = {**global, **user}
```

This is simple and Pythonic.  This is a little verbose, but it's fairly clear that the output is a dictionary.

- Accurate: yes
- Idiomatic: yes


## Summary

There are a number of ways to combine multiple dictionaries, but there are few elegant ways to do this one one line of code.

If you're using Python 3.5, this is the one obvious way to solve this problem:

```python
context = {**global, **user}
```

Clever solutions are rarely idiomatic.

[kwargs hack]: http://stackoverflow.com/a/39858/98187
[chainmap]: https://docs.python.org/3/library/collections.html#collections.ChainMap
[update]: https://docs.python.org/3.5/library/stdtypes.html#dict.update
[pep 448]: https://www.python.org/dev/peps/pep-0448/
[python-ideas]: https://mail.python.org/pipermail/python-ideas/2015-February/031748.html
[set]: https://docs.python.org/3/library/stdtypes.html#set-types-set-frozenset
[hashable]: https://docs.python.org/3/glossary.html#term-hashable
[itertools.chain]: https://docs.python.org/3/library/itertools.html#itertools.chain
[ChainMap remove]: https://gist.github.com/treyhunner/5260810b4cced03359d9
[ChainMap alter]: https://gist.github.com/treyhunner/2abe2617ea029504ef8e
[pythonic]: https://docs.python.org/3/glossary.html#term-pythonic
