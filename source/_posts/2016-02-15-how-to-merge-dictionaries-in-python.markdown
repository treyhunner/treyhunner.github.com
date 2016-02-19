---
layout: post
title: "How to Merge Dictionaries in Python"
date: 2016-02-15 22:09:58 -0800
comments: true
categories: 
---

Have you ever wanted to combine two or more dictionaries in Python? I'm going to show you the most Pythonic way to do this.

We're going to walk through a number of methods for merging dictionaries and discuss which of these methods is the most idiomatic and which is the most accurate.

## Problem

We have a bit of code that has two dictionaries: `user_context` and `global_context` and we want to merge these two dictionaries into a new dictionary called `context`.

We have some requirements:

1. in cases of key collisions, `user_context` should "win" over `global_context` (the values in `user_context` are more important)
2. the keys in `global_context` and `user_context` can be anything that's a valid key
3. the values in `global_context` and `user_context` can be anything
4. `global_context` and `user_context` should not change: `context` should be a completely new dictionary
5. updating `context` should not change `global_context` or `user_context`

So we want something like this:

```pycon
>>> user_context = {'name': "Trey", 'website': "http://treyhunner.com"}
>>> global_context = {'name': "Anonymous User", 'page_name': "Profile Page"}
>>> context = merge_dicts(global_context, user_context)
>>> context
{'website': 'http://treyhunner.com', 'name': 'Trey', 'page_name': 'Profile Page'}
```

## Solutions

Let's look at different ways we could solve this problem.

### multiple update

Here's one of the simplest ways to merge our dictionaries:

```python
context = {}
context.update(global_context)
context.update(user_context)
```

Here we're making an empty dictionary and using the [update][] method to add items from each of the other dictionaries.  Notice that we're adding `global_context` first so that any common keys in `user_context` will override those in `global_context`.

How does this score?  All five of our requirements were met so this is **accurate**.  This solution is also pretty clear and fairly idiomatic. (why?)

- Accurate: yes
- Idiomatic: fairly


### copy and update

Alternatively, we could copy the `global_context` dictionary and update it with the items in `user_context`.

```python
context = global_context.copy()
context.update(user_context)
```

This solution is only slightly different from the previous one.

- Accurate: yes
- Idiomatic: yes

Personally, I prefer to copy the global dictionary to make it clear that it's represents the defaults but if the dictionaries being merged were of equal weight, I might prefer the first solution instead.


### dictionary constructor

We could also pass our dictionary to the `dict` constructor which will also copy the dictionary for us:

```python
context = dict(global_context)
context.update(user_context)
```

This solution is very similar to the previous one, but it's a little bit less explicit.

- Accurate: yes
- Idiomatic: somewhat, though I'd prefer the first two solutions over this


### keyword arguments hack

You may have seen this clever answer before, [possibly on StackOverflow](http://stackoverflow.com/a/39858/98187):

```python
context = dict(global_context, **user_context)
```

This is just one line of code.  That's kind of cool.  However, this solution is is a little hard to understand.

Beyond readability, there's an even bigger problem.  This solution is wrong.  The keys must be strings that represent valid variable names.  In CPython (the official Python interpreter), we can get away with invalid variable names as long as the keys are strings and in CPython 2.0 we could even use non-strings as keys.  But don't be fooled, this is a hack that only works by accident in Python 2.0 using the standard CPython runtime.

- Accurate: no.  Rule 2 breaks (keys may be any valid key)
- Idiomatic: no.  This is a hack.

Clever solutions are rarely idiomatic.


### dictionary comprehension

Just because we can, let's try doing this with a dictionary comprehension:

```python
context = {k: v for x in [global_context, user_context] for k, v in x.items()}
```

This works, but this is not easy to read at all.  Don't do this.

- Accurate: yes
- Idiomatic: not at all


### items concatenation

What if we get a `list` of items from each dictionary, concatenate them, and then create a new dictionary from that?

```python
context = dict(list(global_context.items()) + list(user_context.items()))
```

This actually works.  We know that the `user_context` keys will win out over `global_context` because those keys come at the end of our concatenated list.

- Accurate: yes
- Idiomatic: not really

Note: in Python 2 we actually don't need the `list` conversions, but we're working in Python 3.


### items union

In Python 3, `items` is a `dict_items` object, which is a quirky object that allows us to use a union operation on it.

```python
context = dict(global_context.items() | user_context.items())
```

That's kind of interesting.  But it's not accurate.

This fails both requirement 1 (`user_context` should "win" over `global_context`) and requirement 3 (the values can be anything).

The union of these two `dict_items` objects gives us a `set` of key-value tuples.  Sets are unordered so as `dict` iterates over the set, the `user_context` key-value pairs will not necessarily be provided after the ones in `global_context`.  Therefore requirement 1 fails because key collisions may resolve in an unpredictable way.

Requirement 3 fails because sets require their items to be hashable.  Since the items of this set are key-value pairs, the values must be hashable, so lists, dictionaries, and other non-hashable objects can not be values in our dictionary.

I'm not sure why the union operation is even allowed on `dict_items` objects.  What is this good for?

- Accurate: no, requirements 1 and 3 fail
- Idiomatic: no


### items chain

So far the only accurate way we've seen to perform this merge in a single line of code involves creating two lists of items, concatenating them, and forming a dictionary.  We can actually join our items together more succinctly with `itertools.chain`:

```python
from itertools import chain
context = dict(chain(global_context.items(), user_context.items()))
```

This works well and should be more efficient than creating two unnecessary lists.

- Accurate: yes
- Idiomatic: fairly, though it requires a standard library import


### ChainMap

All of our answers so far have required looping over every key-value pair in our two initial dictionaries in order to make a new one.

What if we could create a new dictionary without looping over our initial dictionaries at all?  We actually *can* do this with `ChainMap`:

```python
from collections import ChainMap
context = ChainMap({}, user_context, global_context)
```

This code raises a couple questions:

- Why does `user_context` come before `global_context`?
- Why is there an empty dictionary before `user_context`?
- Is this actually a dictionary?

According to the documentation, a `ChainMap` "groups multiple dictionaries or other mappings together to create a single, updateable view."

Whenever we lookup something in our `ChainMap`, each dictionary is queried until a matching key is found.  Because the dictionaries are searched in the order we provided them, `user_context` will return matches before `global_context`.  So we ordered our dictionaries this way to ensure requirement 1 is met.

But why is there an empty dictionary before `user_context`?  Changing a `ChainMap` object will change the first dictionary provided.  We don't want our `user_context` dictionary to change if the `ChainMap` is altered (requirement 5) so we provide an empty dictionary as the first mapping.

This is neat, but is `ChainMap` really even a dictionary?  Well, it depends on what we mean.  This new object is a mapping (a dictionary-like object) and it does meet all of our stated requirements, but it may not be exactly what we're looking for.

A `ChainMap` object is not identical to a dictionary.  For instance, we cannot remove items if they reside in the underlying mappings.

```pycon
>>> context = ChainMap({}, user_context, global_context)
>>> context['page_name'] = "About Page"
>>> context['page_name']
'About Page'
>>> del context['page_name']
>>> context['page_name']
'Profile Page'
```

Our `ChainMap` will also change behavior when the underlying dictionaries change:

```pycon
>>> context['name']
'Trey'
>>> user_context['name'] = "Guido"
>>> context['name']
'Guido'
```

These are not bugs in `ChainMap`, these are features.  If we really want a dictionary, we could convert our `ChainMap` to a dictionary:

```python
context = dict(ChainMap({}, user_context, global_context))
```

However, at this point we may as well use `itertools.chain`.

- Accurate: possibly, we'll need to consider our use cases
- Idiomatic: yes if we decide this suits our use case


### dictionary concatenation

What if we simply concatenate our dictionaries?

```python
context = global_context + user_context
```

This is cool, but it isn't valid.

This feature was discussed in a [python-ideas thread][python-ideas] last year though.

Some of the concerns brought up in this thread include:

- Maybe `|` makes more sense than `+` because dictionaries are more like sets
- Should duplicate keys raise exceptions or should one side override the other?
- For duplicate keys, should the left-hand side or right-hand side win?
- Should a view (like a `ChainMap`) be returned instead of a new dictionary?
- Looping over dictionaries iterates over just keys, so does this even make sense?
- Should there be an `updated` built-in instead (kind of like `sorted`)?

This syntax will probably never exist.

- Accurate: no. This doesn't work.
- Idiomatic: no. This doesn't work.


### dictionary unpacking

If you're using Python 3.5, thanks to [PEP 448][], there's a new way to merge dictionaries:

```python
context = {**global_context, **user_context}
```

This is simple and Pythonic.  This is a little verbose, but it's fairly clear that the output is a dictionary.

- Accurate: yes
- Idiomatic: yes


## Summary

There are a number of ways to combine multiple dictionaries, but there are few elegant ways to do this one one line of code.

If you're using Python 3.5, this is the one obvious way to solve this problem:

```python
context = {**global_context, **user_context}
```

[update]: https://docs.python.org/3.5/library/stdtypes.html#dict.update
[pep 448]: https://www.python.org/dev/peps/pep-0448/
[python-ideas]: https://mail.python.org/pipermail/python-ideas/2015-February/031748.html
