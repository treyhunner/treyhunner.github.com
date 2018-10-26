---
layout: post
title: "Asterisks in Python: what they are and how to use them"
date: 2018-10-11 07:30:00 -0700
comments: true
categories: python
---

There are a lot of places you'll see `*` and `**` used in Python.
These two operators can be a bit mysterious at times, both for brand new programmers and for folks moving from many other programming languages which may not have completely equivalent operators.
I'd like to discuss what those operators are and the many ways they're used.

The `*` and `**` operators have grown in ability over the years and I'll be discussing all the ways that you can currently use these operators and noting which uses only work in modern versions of Python.
So if you learned `*` and `**` back in the days of Python 2, I'd recommend at least skimming this article because Python 3 has added a lot of new uses for these operators.

If you're newer to Python and you're not yet familiar with keyword arguments (a.k.a. named arguments), I'd recommend reading my article on [keyword arguments in Python][keyword arguments] first.


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
>>> numbers = [2, 1, 3, 4, 7]
>>> more_numbers = [*numbers, 11, 18]
>>> print(*more_numbers, sep=', ')
2, 1, 3, 4, 7, 11, 18
```

Two of the uses of `*` are shown in that code and no uses of `**` are shown.

This includes:

1. Using `*` and `**` to pass arguments to a function
2. Using `*` and `**` to capture arguments passed into a function
3. Using `*` to accept keyword-only arguments
3. Using `*` to capture items during tuple unpacking
4. Using `*` to unpack iterables into a list/tuple
5. Using `**` to unpack dictionaries into other dictionaries

Even if you think you're familiar with all of these ways of using `*` and `**`, I recommend looking at each of the code blocks below to make sure they're all things you're familiar with.
The Python core developers have continued to add new abilities to these operators over the last few years and it's easy to overlook some of the newer uses of `*` and `**`.


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

Here's another example:

```python
def transpose_list(list_of_lists):
    return [
        list(row)
        for row in zip(*list_of_lists)
    ]
```

Here we're accepting a list of lists and returning a "transposed" list of lists.

```pycon
>>> transpose_list([[1, 4, 7], [2, 5, 8], [3, 6, 9]])
[[1, 2, 3], [4, 5, 6], [7, 8, 9]]
```

The `**` operator does something similar, but with keyword arguments.
The `**` operator allows us to take a dictionary of key-value pairs and unpack it into keyword arguments in a function call.

```pycon
>>> date_info = {'year': "2020", 'month': "01", 'day': "01"}
>>> filename = "{year}-{month}-{day}.txt".format(**date_info)
>>> filename
'2020-01-01.txt'
```

From my experience, using `**` to unpack keyword arguments into a function call isn't particularly common.
The place I see this most is when practicing inheritance: calls to `super()` often include both `*` and `**`.

Both `*` and `**` can be used multiple times in function calls, as of Python 3.5.

Using `*` multiple times can sometimes be handy:

```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> numbers = [2, 1, 3, 4, 7]
>>> print(*numbers, *fruits)
2 1 3 4 7 lemon pear watermelon tomato
```

Using `**` multiple times looks similar:

```pycon
>>> date_info = {'year': "2020", 'month': "01", 'day': "01"}
>>> track_info = {'artist': "Beethoven", 'title': 'Symphony No 5'}
>>> filename = "{year}-{month}-{day}-{artist}-{title}.txt".format(
...     **date_info,
...     **track_info,
... )
>>> filename
'2020-01-01-Beethoven-Symphony No 5.txt'
```

You need to be careful when using `**` multiple times though.
Functions in Python can't have the same keyword argument specified multiple times, so the keys in each dictionary used with `**` must be distinct or an exception will be raised.


## Asterisks for packing arguments given to function

When defining a function, the `*` operator can be used to capture an unlimited number of positional arguments given to the function.
These arguments are captured into a tuple.

```python
from random import randint

def roll(*dice):
    return sum(randint(1, die) for die in dice)
```

This function accepts any number of arguments:

```pycon
>>> roll(20)
18
>>> roll(6, 6)
9
>>> roll(6, 6, 6)
8
```

Python's `print` and `zip` functions accept any number of positional arguments.
This argument-packing use of `*` allows us to make our own function which, like `print` and `zip`, accept any number of arguments.

The `**` operator also has another side to it: we can use `**` when defining a function to capture any keyword arguments given to the function into a dictionary:

```python
def tag(tag_name, **attributes):
    attribute_list = [
        f'{name}="{value}"'
        for name, value in attributes.items()
    ]
    return f"<{tag_name} {' '.join(attribute_list)}>"
```

That `**` will capture any keyword arguments we give to this function into a dictionary which will that `attributes` arguments will reference.

```pycon
>>> tag('a', href="http://treyhunner.com")
'<a href="http://treyhunner.com">'
>>> tag('img', height=20, width=40, src="face.jpg")
'<img height="20" width="40" src="face.jpg">'
```


## Positional arguments with keyword-only arguments

As of Python 3, we now have a special syntax for accepting keyword-only arguments to functions.
Keyword-only arguments are function arguments which can *only* be specified using the keyword syntax, meaning they cannot be specified positionally.

To accept keyword-only arguments, we can put named arguments after a `*` usage when defining our function:

```python
def get_multiple(*keys, dictionary, default=None):
    return [
        dictionary.get(key, default)
        for key in keys
    ]
```

The above function can be used like this:

```pycon
>>> fruits = {'lemon': 'yellow', 'orange': 'orange', 'tomato': 'red'}
>>> get_multiple('lemon', 'tomato', 'squash', dictionary=fruits, default='unknown')
['yellow', 'red', 'unknown']
```

The arguments `dictionary` and `default` come after `*keys`, which means they can *only* be specified as [keyword arguments][].
If we try to specify them positionally we'll get an error:

```pycon
>>> fruits = {'lemon': 'yellow', 'orange': 'orange', 'tomato': 'red'}
>>> get_multiple('lemon', 'tomato', 'squash', fruits, 'unknown')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: get_multiple() missing 1 required keyword-only argument: 'dictionary'
```

This behavior was introduced to Python through [PEP 3102][].


## Keyword-only arguments without positional arguments

That keyword-only argument feature is cool, but what if you want to require keyword-only arguments without capturing unlimited positional arguments?

Python allows this with a somewhat strange `*`-on-its-own syntax:

```python
def with_previous(iterable, *, fillvalue=None):
    """Yield each iterable item along with the item before it."""
    previous = fillvalue
    for item in iterable:
        yield previous, item
        previous = item
```

This function accepts an `iterable` argument, which can be specified positionally (as the first argument) or by its name and a `fillvalue` argument which is a keyword-only argument.  This means we can call `with_previous` like this:

```pycon
>>> list(with_previous([2, 1, 3], fillvalue=0))
[(0, 2), (2, 1), (1, 3)]
```

But not like this:

```pycon
>>> list(with_previous([2, 1, 3], 0))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: with_previous() takes 1 positional argument but 2 were given
```

This function accepts two arguments and one of them, `fillvalue` *must be specified as a keyword argument*.

I usually use keyword-only arguments used while capturing any number of positional arguments, but I do sometimes use this `*` to enforce an argument to only be specified positionally.

Python's built-in `sorted` function actually uses this approach.  If you look at the help information on `sorted` you'll see the following:

```
>>> help(sorted)
Help on built-in function sorted in module builtins:

sorted(iterable, /, *, key=None, reverse=False)
    Return a new list containing all items from the iterable in ascending order.

    A custom key function can be supplied to customize the sort order, and the
    reverse flag can be set to request the result in descending order.
```

There's an `*`-on-its-own, right in the documented arguments for `sorted`.


## Asterisks in tuple unpacking

Python 3 also added a new way of using the `*` operator that is only somewhat related to the `*`-when-defining-a-function and `*`-when-calling-a-function features above.

The `*` operator can also be used in tuple unpacking now:


```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> first, second, *remaining = fruits
>>> remaining
['watermelon', 'tomato']
>>> first, *remaining = fruits
>>> remaining
['pear', 'watermelon', 'tomato']
>>> first, *middle, last = fruits
>>> middle
['pear', 'watermelon']
```

If you're wondering "where could I use this in my own code", take a look at the examples in my article on [tuple unpacking in Python][].
In that article I show how this use of the `*` operator can sometimes be used as an alternative to sequence slicing.

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

The PEP that added this to Python 3.0 is [PEP 3132][] and it's not a very long one.


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

That function returns a new list where the first item in the given list (or other sequence) is moved to the end of the new list.

This use of the `*` operator is a great way to concatenate iterables of different types together.
The `*` operator works for any iterable, whereas using the `+` operator only works on particular sequences which have to all be the same type.

This isn't just limited to creating lists either.
We can also dump iterables into new tuples or sets:

```pycon
>>> fruits = ['lemon', 'pear', 'watermelon', 'tomato']
>>> (*fruits[1:], fruits[0])
('pear', 'watermelon', 'tomato', 'lemon')
>>> uppercase_fruits = (f.upper() for f in fruits)
>>> {*fruits, *uppercase_fruits}
{'lemon', 'watermelon', 'TOMATO', 'LEMON', 'PEAR', 'WATERMELON', 'tomato', 'pear'}
```

Notice that the last line above takes a list and a generator and dumps them into a new set.
Before this use of `*`, there wasn't previously an easy way to do this in one line of code.
There was a way to do this before, but it wasn't easy to remember or discover:

```pycon
>>> set().union(fruits, uppercase_fruits)
{'lemon', 'watermelon', 'TOMATO', 'LEMON', 'PEAR', 'WATERMELON', 'tomato', 'pear'}
```

## Double asterisks in dictionary literals

PEP 448 also expanded the abilities of `**` by allowing this operator to be used for dumping key/value pairs from one dictionary into a new dictionary:

```pycon
>>> date_info = {'year': "2020", 'month': "01", 'day': "01"}
>>> track_info = {'artist': "Beethoven", 'title': 'Symphony No 5'}
>>> all_info = {**date_info, **track_info}
>>> all_info
{'year': '2020', 'month': '01', 'day': '01', 'artist': 'Beethoven', 'title': 'Symphony No 5'}
```

I wrote another article on how this is now the [idiomatic way to merge dictionaries in Python][merge dictionaries].

This can be used for more than just merging two dictionaries together though.

For example we can copy a dictionary while adding a new value to it:

```pycon
>>> date_info = {'year': '2020', 'month': '01', 'day': '7'}
>>> event_info = {**date_info, 'group': "Python Meetup"}
>>> event_info
{'year': '2020', 'month': '01', 'day': '7', 'group': 'Python Meetup'}
```

Or copy/merge dictionaries while overriding particular values:

```pycon
>>> event_info = {'year': '2020', 'month': '01', 'day': '7', 'group': 'Python Meetup'}
>>> new_info = {**event_info, 'day': "14"}
>>> new_info
{'year': '2020', 'month': '01', 'day': '14', 'group': 'Python Meetup'}
```


## Python's asterisks are powerful

Python's `*` and `**` operators aren't just syntactic sugar.
Some of the things they allow you to do could be achieved through other means, but the alternatives to `*` and `**` tend to be more cumbersome and more resource intensive.
And some of the features they provide are simply impossible to achieve without them: for example there's no way to accept any number of positional arguments to a function without `*`.

After reading about all the features of `*` and `**`, you might be wondering what the names for these odd operators are.
Unfortunately, they don't really have succinct names.
I've heard `*` called the "packing" and "unpacking" operator.
I've also heard it called "splat" (from the Ruby world) and I've heard it called simply "star".

I tend to call these operators "star" and "double star" or "star star".
That doesn't distinguish them from their infix relatives (multiplication and exponentiation), but context usually makes it obvious whether we're talking about prefix or infix operators.

If you don't understand `*` and `**` or you're concerned about memorizing all of their uses, don't be!
These operators have many uses and memorizing the specific use of each one isn't as important as getting a feel for when you might be able to reach for these operators.
I suggest using this article as **a cheat sheet** or to making your own cheat sheet to help you use `*` and `**` in Python.


## Practice makes perfect

You don't learn by putting information in your head, you learn by attempting to retrieve information from your head.
So you've just read an article on something new, but **you haven't learned yet**.

Write some code that uses `*` and `**` in a number of different ways today.
Then quiz yourself on the many different ways to use `*` and `**` tomorrow!

If you'd like to get practice with `*` and `**`, **[sign up for Python Morsels][python morsels]**.
The first few problems use `*` in a couple different ways.
If you sign up for [Python Morsels][] I'll help you **level up your Python skills every week**.


[keyword arguments]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[tuple unpacking in Python]: https://treyhunner.com/2018/03/tuple-unpacking-improves-python-code-readability/
[pep 3132]: https://www.python.org/dev/peps/pep-3132/
[pep 468]: https://www.python.org/dev/peps/pep-0468/
[pep 3102]: https://www.python.org/dev/peps/pep-3102/
[pep 448]: https://www.python.org/dev/peps/pep-0448/
[merge dictionaries]: https://treyhunner.com/2016/02/how-to-merge-dictionaries-in-python/
[python morsels]: https://www.pythonmorsels.com/
