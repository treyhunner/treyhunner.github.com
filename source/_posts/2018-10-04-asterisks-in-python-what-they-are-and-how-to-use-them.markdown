---
layout: post
title: "Asterisks in Python: what they are and how to use them"
date: 2018-10-04 07:30:00 -0700
comments: true
categories: python
---

There are a lot of places you'll see `*` and `**` used in Python.
I'd like to discuss what those operators are and the many ways they're used.

The `*` and `**` operators have grown in ability over the years and I'll be discussing all the ways that you can currently use these operators and noting which uses only work in modern versions of Python.
So if you learned `*` and `**` back in the days of Python 2, I'd recommend at least skimming this article because Python 3 has added a lot of new uses for these operators.

If you're newer to Python and you're not yet familiar with keyword arguments (a.k.a. named arguments), I'd recommend reading my article on [keyword arguments in Python][] first.


## What we're not talking about

When I discuss `*` and `**` in this article, I'm talking about the `*` and `**` *prefix* operators, not the *infix* operators.

So I'm not talking about multiplication and exponentiation:

```pycon
>>> 2 * 5
10
>>> 2 ** 5
32
```

## So what are we talking about?

We're talking about the `*` and `**` prefix operators, that is the `*` and `**` operators that are used before a variable.  For example:

```python
TODO
```

This includes:

1. Using `*` and `**` to capture arguments passed into a function
2. Using `*` and `**` to pass arguments to a function
3. Using `*` to capture items during tuple unpacking
4. Using `*` to unpack iterables into a list/tuple
5. Using `**` to merge dictionaries

TODO various ways to use * and **


## Asterisks for unpacking into function call

When calling a function, the `*` operator can be used to unpack an iterable into the arguments in the function call:

```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> print(fruits[0], fruits[1], fruits[2], fruits[3])
lemon pear watermelon tomato
>>> print(*fruits)
lemon pear watermelon tomato
```

That `print(*fruits)` line is passing all of the items in the `fruits` list into the `print` function call as separate arguments, without us even needing to know how many arguments are in the list.

The `*` operator isn't just syntactic sugar here.
This ability of sending in all items in a particular iterable as separate arguments wouldn't be possible without `*`, unless the list was a fixed length.

The `**` operator does something similar, but with keyword arguments.
The `**` operator allows us to take a dictionary of key-value pairs and unpack it into keyword arguments in a function call.

```pycon
date_info = {'year': "2020", 'month': "01", 'day': "01"}
filename = "{year}-{month}-{day}.txt".format(**date_info)
```

I find that using `**` to unpack keyword arguments into a function call isn't very common.
The place I see this most is when practicing inheritance: calls to `super()` often include both `*` and `**`.

Both `*` and `**` can be used multiple times in function calls, as of Python 3.5.

Using `*` multiple times can sometimes be handy:

```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> numbers = [2, 1, 3, 4, 7]
>>> print(*numbers, *fruits)
2 1 3 4 7 lemon pear watermelon tomato
```

You need to be careful when using `**` multiple times though:

```pycon
date_info = {'year': "2020", 'month': "01", 'day': "01"}
track_info = {'artist': "Beethoven", 'title': 'Symphony No 5'}
filename = "{year}-{month}-{day}-{artist}-{title}.txt".format(
    **date_info,
    **track_info,
)
```

Functions in Python can't have the same keyword argument specified multiple times, so the keys in each dictionary used with `**` must be distinct or an exception will be raised.


## Asterisks for packing arguments given to function

When defining a function, the `*` operator can be used to capture an unlimited number of positional arguments given to the function.
These arguments are captured into a tuple.

```python
def transpose_list(list_of_lists):
    return [
        list(row)
        for row in zip(*list_of_lists)
    ]
```

This is often used with the argument unpacking use of `*` we saw above:

```python
def TODO
```

Python's `print` and `zip` functions accept any number of positional arguments.
This argument-packing use of `*` allows us to make our own `print`- and `zip`-like functions.

The `**` operator also has another side to it: we can use `**` when defining a function to capture any keyword arguments given to the function into a dictionary:

```python
TODO
```


## Positional arguments with keyword-only arguments

As of Python 3, we now have a special syntax for accepting keyword-only arguments to functions.
To accept keyword-only arguments, we can put named arguments after a `*` usage when defining our function:

```
def get_multiple(*keys, dictionary, default=None):
    return [
        dictionary.get(key, default)
        for key in keys
    ]
```

The above function can be used like this:

```
>>> fruits = {'lemon': 'yellow', 'orange': 'orange', 'tomato': 'red'}
>>> get_multiple('lemon', 'tomato', 'squash', dictionary=fruits, default='unknown')
['yellow', 'red', 'unknown']
```

The arguments `dictionary` and `default` come after `*keys`, which means they can *only* be specified as keyword arguments.
If we try to specify them positionally we'll get an error:

```
>>> fruits = {'lemon': 'yellow', 'orange': 'orange', 'tomato': 'red'}
>>> get_multiple('lemon', 'tomato', 'squash', fruits, 'unknown')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: get_multiple() missing 1 required keyword-only argument: 'dictionary'
```

This behavior was introduced to Python through [PEP 3012][].


## Keyword-only arguments without positional arguments

That keyword-only argument feature is cool, but what if you want to require keyword-only arguments without capturing unlimited positional arguments?

Python allows this with a somewhat strange `*`-on-its-own syntax:

```
TODO
```


## Asterisks in tuple unpacking

Python 3 also added a new way of using the `*` operator that is only somewhat related to the `*`-when-defining-a-function and `*`-when-calling-a-function features above.

The `*` operator can also be used in tuple unpacking now:


```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> first, second, *remaining = fruits
>>> remaining
['watermelon', 'tomato']
>>> first, *remaining = fruits
>>> first, *middle, last = fruits
>>> middle
['pear', 'watermelon']
```

In my article on [tuple unpacking in Python][], I noted how the `*` operator can be used as an alternative to slicing.

The PEP that added this to Python 3.0 is [PEP 3132][] and it's not a very long one.

Usually when I teach `*` I note that you can only use one `*` expression in a single multiple assignment call.
That's technically incorrect because it's possible to use two in a nested unpacking (I talk about nested unpacking in my tuple unpacking article):

```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> ((first_letter, *remaining), *other_fruits) = fruits
>>> remaining
['e', 'm', 'o', 'n']
>>> other_fruits
['pear', 'watermelon', 'tomato']
```

I've never seen a good use for this though and I don't think I'd recommend using it even if you found one because it seems a bit cryptic.


## Asterisks in list literals

Python 3.5 introduced a ton of new `*`-related features through [PEP 448][].
One of the biggest new features is the ability to use `*` to dump an iterable into a new list.

Say you have a function that takes any sequence and returns a list with the sequence and the reverse of that sequence concatenated together:

```python
def palindromify(sequence):
    return list(sequence) + list(reversed(sequence))
```

This function needs to convert things to lists a couple times in order to concatenate the lists and return the result.
In Python 3.5, we can type this instead:

```python
def palindromify(sequence):
    return [*sequence, *reversed(sequence)]
```

This code removes some needless list calls so our code is both more efficient and more readable.

Here's another example:

```python
def rotate_first_item(sequence):
    return [*sequence[1:], sequence[0]]
```

This use of the `*` operator is a great way to concatenate iterables of different types together.

This isn't just limited to lists either.
We can also dump iterables into new tuples or sets:

```python
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> uppercase_fruits = (f.upper() for f in fruits)
>>> {*fruits, *uppercase_fruits}
>>> (*fruits[1:], fruits[0])
```

TODO
- For dumping some iterables into a list (often useful for concatenating iterables of different types together)
- Works in tuple/set literal too
- Only Python 3.5+
- Link to relevant PEP


## Asterisks for merging multiple dictionaries

TODO


## Python's asterisks are powerful

TODO they're not just syntactic sugar: they allow for some features that simply don't exist otherwise


[keyword arguments in Python]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[tuple unpacking in Python]: https://treyhunner.com/2018/03/tuple-unpacking-improves-python-code-readability/
[pep 3132]: https://www.python.org/dev/peps/pep-3132/
[pep 468]: https://www.python.org/dev/peps/pep-0468/
[pep 3102]: https://www.python.org/dev/peps/pep-3102/
[pep 448]: https://www.python.org/dev/peps/pep-0448/
