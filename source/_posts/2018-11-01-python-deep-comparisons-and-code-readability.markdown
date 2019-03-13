---
layout: post
title: "Deep comparisons and code readability in Python"
date: 2019-03-13 08:00:00 -0700
comments: true
categories: python readability tuples
---

Comparing things in Python.
That sounds like something that almost doesn't even need to be taught.
But I've found that **Python's comparison operators are often misunderstood and under-appreciated by newer Pythonistas**.

Let's review how Python's comparison operators work on different types of objects and then take a look at how we can use this to improve the readability of our code.


## Python's comparison operators

By "comparison operators" I mean the equality operators (`==` and `!=`) and the ordering operators (`<`, `<=`, `>`, `>=`).

We can use these operators to compare numbers, as you'd expect:

```python
>>> 3 == 4
False
>>> 3 != 4
True
>>> 3 < 4
True
>>> 3 > 4
False
```

But we can also use these operators to compare strings:

```python
>>> "pear" == "pickle"
False
>>> "pear" != "pickle"
True
>>> "pear" < "pickle"
True
>>> "pear" > "pickle"
False
```

And even tuples:

```python
>>> target = (3, 6, 2)
>>> installed = (3, 7, 0)
>>> target == installed
False
>>> target <= installed
True
>>> target > installed
False
```

Many programming languages don't have an equivalent to Python's very flexible comparison operators.

We'll take a look at how these operators work on tuples and more complex objects in a moment, but we'll start with something simpler: string comparisons.


## String comparisons in Python

Equality and inequality with strings is fairly simple.
If two strings have exactly the same characters, they're equal:

```python
>>> "hello" == "hello"
True
>>> "hello" == "hella"
False
```

Note that I'm glossing over a very big exception: unicode characters.
There are often multiple ways to represent the same text and those different representations must be [normalized][normalize] before they're seen as equal.
For simplicity, we're going to stick to ASCII characters in this article.

Ordering of strings is where things get a bit interesting in Python:

```python
>>> "pickle" < "python"
True
```

The string `"pickle"` is *less than* the string `"python"` because we're ordering alphabetically... sort of.
Capitalization matters:

```python
>>> "pickle" < "Python"
False
```

The string `"Python"` is less than `"pickle"` because `P` is less than `p`.

We're not actually ordering alphabetically here so much as **ASCII-betically** (unicode-betically really since we're in Python 3).
These strings are being ordered by the ASCII values of their characters (`p` is 112 in [ASCII][] and `P` is 80).

```python
>>> ord("p")
112
>>> ord("P")
80
>>> "P" < "p"
True
```

Technically Python compares the Unicode code point (which is what [ord][] does) for these characters and that happens to be the same as the ASCII value for ASCII characters.

The rules for ordering strings are:

1. Compare the n-th characters of each string (starting with the first character, index `0`) using the `==` operator; if they're equal, repeat this step with the next character
2. For two unequal characters, take the character that has the lower code point and declare its string "less than" the other
3. If all characters are equal, the strings are equal
4. If one string runs out of characters during step 1 (one string is a "prefix" of the other), the shorter string is "less than" the longer one

The ordering algorithm Python uses for strings might seem complicated, but it's **very similar to the ordering algorithm used in dictionaries**; not Python dictionaries but [physical dictionaries][dictionary] (those things we used before the Internet existed).
We give precedence to the first characters when ordering words in dictionaries and if one word is a prefix of another, it comes first.


## Tuple comparisons

We can ask tuples if they're equal, just as we can ask strings if they're equal:

```python
>>> (3, 6, 2) == (3, 6, 2)
True
>>> (3, 6, 2) == (3, 7, 0)
False
```

But we can also compare tuples using the ordering operators (`<`, `<=`, `>`, `>=`):

```python
>>> (3, 6, 2) < (3, 6, 2)
False
>>> (3, 6, 2) <= (3, 6, 2)
True
>>> (3, 6, 2) < (3, 7, 0)
True
>>> (3, 6, 2) >= (3, 7, 0)
False
```

String ordering might have been somewhat intuitive (most of us learned alphabetical ordering before Python), but tuple ordering doesn't often feel quite as intuitive at first.
But you're actually somewhat much familiar with tuple ordering already because **tuple ordering uses the same algorithm as string ordering**.

The rules for ordering tuples (which are essentially the same as ordering strings):

1. Compare the n-th items of each tuple (starting with the first, index `0`) using the `==` operator; if they're equal, repeat this step with the next item
2. For two unequal items, the item that is "less than" makes the tuple that contains it also "less than" the other tuple
3. If all items are equal, the tuples are equal
4. If one tuple runs out of items during step 1 (one tuple is a "prefix" of the other), the shorter tuple is "less than" the longer one

In Python, this algorithm might look sort of like this:

```python
def less_than(tuple1, tuple2):
    for x, y in zip(tuple1, tuple2):
        if x == y:
            continue
        return (x < y)
    if len(tuple1) < len(tuple2):
        return True  # There were more items in the second tuple
    else:
        return False  # The first tuple had more items or they are equal
```

Note that we'd never write code like this because Python is doing all this work for us already.
That whole function is the same as using the `<` operator:

```python
def less_than(tuple1, tuple2):
    return tuple1 < tuple2
```


## Lexicographical ordering

This **alphabetical-like style of ordering** that gives precedence to the first items in an iterable is called [lexicographical ordering][].
You don't need to know that phrase, but if you ever need to describe *the way ordering works in Python*, **lexicographical** is the word to use.

Strings and tuples are ordered lexicographically, as we've seen, but so are lists:

```python
>>> [1, 2, 3] < [1, 4]
True
>>> [1, 2, 3] < [1, 2, 2]
False
```

In fact, most [sequences][] in Python [should be ordered lexicographically][sequence ordering] (`range` objects are an exception to this as they can't be ordered at all).

But not every collection in Python is relies on lexicographical ordering.


## Dictionary and set comparisons

Many objects in Python work with equality but don't work with ordering at all.

For example dictionaries compare "equal" when they have all the same keys and values:

```python
>>> expected = {'name': 'Trey', 'python_version': 3.7.0}
>>> actual = {'name': 'Trey', 'python_version': 2.7.0}
>>> expected == actual
False
>>> actual['python_version'] = 3.7.0
>>> expected == actual
True
```

But **dictionaries can't be ordered** using the `<` or `>` operators:

```python
>>> expected < actual
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: '<' not supported between instances of 'dict' and 'dict'
```

Sets are similar, except that sets *do* work with ordering operators... they just don't use those operators for ordering:

```python
>>> {1, 2} < {1, 2, 3}
True
>>> {1, 3} < {1, 2, 4}
False
```

Sets overload these operators to answer questions about **whether one set is a subset or superset of another** ([see sets in the documentation][sets]).


## Deep equality

Comparisons between two data structures in Python tend to be **deep comparisons**.
Whether we're comparing lists, tuples, sets, or dictionaries, when we ask whether two of these objects are "equal" Python will recurse through each sub-object and ask whether each is "equal".

So given a dictionary that maps tuples to lists of tuples:

```python
>>> current_portals = {(1, 2): [(2, 1)], (2, 1): [(1, 2), (3, 4)]}
>>> previous_portals = {(1, 2): [(2, 1)], (2, 1): [(1, 2)]}
```

Asking whether these two dictionaries are equal is equivalent to asking whether each key-value pair is equal, recursively:

```python
>>> current_portals == previous_portals
False
>>> current_portals[2, 1].pop()
(3, 4)
>>> current_portals == previous_portals
True
```

The dictionaries ask each of their keys "are you in the other dictionary" and then asks each of the corresponding values for those keys "are you equal to the other value".
But each of these operations may (as in this case) require another level of depth: the keys are tuples which need to be traversed and the values are lists which need to be traversed.
And in this case those values, the lists, need to be traversed even deeper because they contain more data structures: tuples.

**We don't have to worry about any of this though**: Python just does these deep comparisons for us automatically.

While you don't need to worry about how deep comparisons work, the fact that Python's comparisons *are* deep can be pretty handy to know.

For example if we have [a class][point] with `x`, `y`, and `z` attributes we'd like to compare in our `__eq__` method, instead of this long boolean expression:

```python
def __eq__(self, other):
    return self.x == other.x and self.y == other.y and self.z == other.z
```

We could bundle these values into 3-item tuples and compare them that way instead:

```python
def __eq__(self, other):
    return (self.x, self.y, self.z) == (other.x, other.y, other.z)
```

I find this more readable, mostly because **we've added symmetry to our code**: we have one `==` expression with the same kind of object on each side of it.


## Deep ordering

This "deep comparison" works for equality, but it also works for ordering.

The use case for deep ordering isn't as obvious as for deep equality, but identifying places where deep ordering is handy can help you drastically improve the readability of your code.

Take this example method:

```python
def __lt__(self, other):
    if self.last_name < other.last_name:
        return True
    elif other.last_name < self.last_name:
        return False
    elif self.first_name < other.first_name:
        return True
    else:
        return False
```

This `__lt__` method implements the `<` operator on [its class][person], returning `True` if `self` is less than `other`.
Storing and comparing `first_name` and `last_name` attributes this way is [an anti-pattern][names] but we'll to ignore that fact for this example.

That `__lt__` method above gives precedence to the `last_name`: the `first_name` is only checked if the `last_name` attribute of these two objects happens to be equal.

If we wanted to collapse this logic some, we could rewrite our code like this:

```python
def __lt__(self, other):
    return (
        self.last_name < other.last_name or
        self.last_name == other.last_name and self.first_name < other.first_name
    )
```

Or... we could rely on the deep ordering of tuples instead:

```python
def __lt__(self, other):
    return (self.last_name, self.first_name) < (other.last_name, other.first_name)
```

Here we're ordering our tuples lexicographically (by their first item first).
Our tuples happen to contain strings, which are also ordered lexicographically (by their first character first).
So we're **deeply ordering** these objects.


## Sorting by multiple attributes at once

Knowing about lexicographical ordering and deep ordering of Python sequences can be quite useful when sorting Python objects.
From Python's perspective, **sorting is really just ordering over and over**.

Python's built-in `sorted` function accepts a `key` function which can return a corresponding key object to sort each of these items by.

Here we're specifying a `key` function that accepts a word and returns a tuple of two things: the length of the word and the case-normalized word:

```python
>>> fruits = ['kumquat', 'Cherimoya', 'Loquat', 'longan', 'jujube']
>>> def length_and_word(word): return (len(word), word.casefold())
...
>>> sorted(fruits, key=length_and_word)
['jujube', 'longan', 'Loquat', 'kumquat', 'Cherimoya']
```

With the key function above we're able to sort fruits first by their length and *then* by their case-normalized equivalent.
So "jujube" comes first because it's 6 letters (like `longan` and `Loquat`) but it's also alphabetically before `longan` and `Loquat`.

If we just sorted by length we would have had a different ordering:

```python
>>> sorted(fruits, key=len)
['Loquat', 'longan', 'jujube', 'kumquat', 'Cherimoya']
```

**Slight aside**: deep comparisons actually predate the `sorted` function's `key` argument in Python.
Before there was a key function Python developers would create lists of tuples, sort the lists of tuples, and then grab the actual value they cared about out of that list (which is [discussed in the docs][decorate-sort-undecorate]).

The `sorted` function isn't the only place where tuple ordering can come in handy.
Any place where you see a `key` function might be a candidates for relying on tuple ordering.
For example the `min` and `max` functions:

```
>>> min(fruits, key=str.casefold)
'Cherimoya'
>>> max(fruits, key=str.casefold)
'Loquat'
```

Anywhere Python does an ordering operation might be a place you could rely on the deep ordering of Python's data structures.


## Deep hashability (and unhashability)

Python has both deep equality and deep orderability.
But Python's deep comparisons don't stop there: there's also deep hashability.

This is something that mostly comes up with tuples.
Tuples can be used as a key in a dictionary (as we saw earlier), and they can be used in sets:

```python
>>> current_portals = {(1, 2): [(2, 1)], (2, 1): [(1, 2), (3, 4)]}
>>> points = {(1, 2), (2, 1), (3, 4)}
```

But this only works for tuples that contain immutable values:

```python
>>> things = {(["dress", "truck"], "yellow"), (["ball", "plane"], "purple")}
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: unhashable type: 'list'
```

Tuples with lists in them aren't hashable because lists aren't hashable: each object inside a tuple must be hashable for the tuple itself to be hashable.

So while tuples containing lists aren't hashable, tuples containing tuples *are* hashable:

```python
>>> things = {(("dress", "truck"), "yellow"), (("ball", "plane"), "purple")}
>>> things
{(('dress', 'truck'), 'yellow'), (('ball', 'plane'), 'purple')}
```

Tuples compute their hash values by delegating to the hash values of the items they contain:

```python
>>> x = (1, 2)
>>> y = (1, 2)
>>> hash(x)
3713081631934410656
>>> hash(x) == hash(y)
True
```

While hashability is a big subject, this is really all I'm going to say about it.
You don't really need to know how hashing works in Python so if you found this section confusing, that's okay!

The takeaway here is that Python supports **deep hashability** which is **the reason we can use tuples as dictionary keys** and the reason we can use tuples in sets.


## Deep comparisons are a tool to remember

When you have code that compares two objects based on subparts in a particular order:

```python
d1 = (1999, 12, 31)
d2 = (1999, 12, 1)
if d1[0] > d2[0]:
    greater = d1
elif d1[0] < d2[0]:
    greater = d2
elif d1[1] > d2[1]:
    greater = d1
elif d2[1] > d2[1]:
    greater = d2
elif d1[2] > d2[2]:
    greater = d1
else:
    greater = d2
```

You could probably rely on tuple ordering instead:

```python
d1 = (1999, 12, 31)
d2 = (1999, 12, 1)
if d1 < d2:
    greater = d1
else:
    greater = d2
```

If you are comparing many different things as equal:

```python
>>> d1 = (1999, 12, 31)
>>> d2 = (1999, 12, 1)
>>> d1[0] == d2[0] and d1[1] == d2[1] and d1[2] == d2[2]
False
```

You could probably rely on deep equality instead:

```python
>>> d1 = (1999, 12, 31)
>>> d2 = (1999, 12, 1)
>>> d1 == d2
False
```

And if you need to use a dictionary that has a key made up of multiple parts, if those parts are each hashable, you could probably use a tuple:

```python
>>> points = {}
>>> points[1, 2] = 'red'
>>> points
{(1, 2): 'red'}
```

**Python's support for lexicographical ordering and deep comparisons is often overlooked by folks moving from other programming languages**.
Remember these features: you may not need them today, but they'll almost certainly come in handy at some point.


[ascii]: https://en.wikipedia.org/wiki/ASCII#Printable_characters
[dictionary]: https://en.wikipedia.org/wiki/Dictionary
[ord]: https://docs.python.org/3/library/functions.html#ord
[lexicographical ordering]: https://en.wikipedia.org/wiki/Lexicographical_order
[sequence ordering]: https://docs.python.org/3/tutorial/datastructures.html#comparing-sequences-and-other-types
[sets]: https://docs.python.org/3.7/library/stdtypes.html#set-types-set-frozenset
[sequences]: https://docs.python.org/3/glossary.html#term-sequence
[names]: https://www.youtube.com/watch?v=458KmAKq0bQ&feature=youtu.be&t=148
[decorate-sort-undecorate]: https://docs.python.org/3/howto/sorting.html#the-old-way-using-decorate-sort-undecorate
[normalize]: https://docs.python.org/3/library/unicodedata.html#unicodedata.normalize
[point]: https://pastebin.com/raw/yspKmfyj
[person]: https://pastebin.com/raw/u8uGDArq
