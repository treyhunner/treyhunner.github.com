---
layout: post
title: "Functions can be passed around"
date: 2020-01-07 07:16:50 -0800
comments: true
categories: python
---

A concept that often trips up newer Python programmers is the fact that **functions are objects**.

By "functions are objects" I meant that you can treat a function pretty much the same way you'd treat any other object, like the list `[1, 2, 3]` or the string `"hello"`.
This concept isn't an essential one at first, but as you dive deeper into Python you'll find that it can be quite convenient to treat functions **just like any other object**.

This is part 1 of what I expect to be a series on the various properties of function objects.
This article focuses on what a new Python program should know and appreciate about the object-nature of functions.


## Functions can be referenced

If you try to use a function without putting parenthesis after it Python won't complain but it also won't do anything useful:

```pycon
>>> def greet():
...     print("Hello world!")
...
>>> greet
<function greet at 0x7ff246c6d9d0>
```

This applies to methods as well (methods are functions which live on objects):

```pycon
>>> numbers = [1, 2, 3]
>>> numbers.pop
<built-in method pop of list object at 0x7ff246c76a80>
```

Python is allowing us to *refer* to this function object, the same way we might refer to a string, a number, or a `range` object:

```pycon
>>> "hello"
'hello'
>>> 2.5
2.5
>>> range(10)
range(0, 10)
```

Since functions can be referred to like any other object, we can point a variable to them:

```pycon
>>> numbers = [2, 1, 3, 4, 7, 11, 18, 29]
>>> gimme = numbers.pop
```

That `gimme` variable now points to the `pop` method on our `numbers` list.
So if we call `gimme`, it'll do the same thing that calling `numbers.pop` would have done:

```pycon
>>> gimme()
29
>>> numbers
[2, 1, 3, 4, 7, 11, 18]
>>> gimme(0)
2
>>> numbers
[1, 3, 4, 7, 11, 18]
>>> gimme()
18
```

Note that this doesn't change our original `numbers.pop` function at all.
It's just pointing another variable name to it:

```pycon
>>> gimme
<built-in method pop of list object at 0x7ff246c76bc0>
>>> numbers.pop
<built-in method pop of list object at 0x7ff246c76bc0>
```

It's not very common to take a function and give another name to it like this, but Python allows it because functions are objects, just like everything else.


## Functions can be passed into other functions

Functions, like any other object, can be passed as an argument to another function.

For example we could define a function:

```pycon
>>> def greet(name="world"):
...     """Greet a person (or the whole world by default)."""
...     print(f"Hello {name}!")
...
>>> greet("Trey")
Hello Trey!
```

And then pass it into the built-in `help` function to see what it does:

```pycon
>>> help(greet)
Help on function greet in module __main__:

greet(name='Trey')
    Greet a person (or the whole world by default).
```

There are actually quite a few functions built-in to Python that are specifically meant to accept other functions as arguments.

The built-in `filter` function accepts two things as an argument: a `function` and an `iterable`.

```
 |  filter(function or None, iterable) --> filter object
 |
 |  Return an iterator yielding those items of iterable for which function(item)
 |  is true. If function is None, return the items that are true.
```

The given iterable (list, tuple, string, etc.) is looped over and the given function is called on each element of that iterable: whenever the function returns `True` (or another truthy value) the item is included in the `filter` output.

So if we pass an `is_odd` function (which returns `True` when a given number is odd) and a list of numbers to `filter`, we'll get back all of the numbers we gave it which are odd.

```pycon
>>> numbers = [2, 1, 3, 4, 7, 11, 18, 29]
>>> def is_odd(n): return n % 2 == 1
...
>>> filter(is_odd, numbers)
<filter object at 0x7ff246c8dc40>
>>> list(filter(is_odd, numbers))
[1, 3, 7, 11, 29]
```

The object returned from `filter` is lazy so we needed to convert it to a list to actually see its output.

Since functions can be passed into functions, that also means that functions can accept another function as an argument.
The `filter` function assumes its first argument is a function.
You can think of the `filter` function as pretty much the same as this function:

```pycon
def filter(predicate, iterable):
    return (
        item
        for item in iterable
        if predicate(item)
    )
```


## Lambda functions are an example of this

A lambda expression is a special syntax in Python for creating an [anonymous function][].
When you evaluate a **lambda expressions** return the object you'll get back is a **lambda function**.

```pycon
>>> is_odd = lambda n: n % 2 == 1
>>> is_odd(3)
True
>>> is_odd(4)
False
```

Unlike other functions, lambda functions don't have a name (their name shows up as `<lambda>`) and they can't have docstrings.

```pycon
>>> add = lambda x, y: x + y
>>> add(2, 3)
5
>>> add
<function <lambda> at 0x7ff244852f70>
>>> add.__doc__
```

You can think of a lambda expressions as a shortcut for making a function which will evaluate a single Python expression and return the result of that expression.

So defining a lambda expression doesn't actually evaluate that expression: it returns a function that can evaluate that expression later.

```pycon
>>> greet = lambda name="world": print(f"Hello {name}")
>>> greet("Trey")
Hello Trey
>>> greet()
Hello world
```

All three of the above examples of `lambda` are bad examples.

If you want a variable name to point to a function object that you can use later, you should use `def` to define a function: that's the *usual* way to define a function.

Lambda expressions are for when we'd like to define a function and **pass it into another function immediately**.

For example here we're using `filter` to get even numbers, but we're using a lambda expression so we don't have to define an `is_even` function before we use it:

```pycon
>>> numbers
[2, 1, 3, 4, 7, 11, 18, 29]
>>> list(filter(lambda n: n % 2 == 0, numbers))
[2, 4, 18]
```

This is *the* use of lambda expressions: passing a function into another function while defining that passed function all on one line of code.

As I've written about in [Overusing lambda expressions][], I'm not a fan of lambda expressions.

Regardless of whether you use `lambda` in your own code, note that:

1. Lambda expressions are a special syntax for creating a function and then passing it around all on one line of code
2. Lambda functions are just like any other function objects: neither is more special than the other and both can be passed around


## A common example: key functions

Besides the built-in `filter` function, where will you ever see a function passed into another function?
The most common place is probably you'll see this in Python itself is with a **key function**.

It's a common convention for functions which accept iterables for ordering to also accept a [named argument][] called `key`.
This `key` argument should be a function [or another callable][callable].

The `sorted`, `min`, and `max` functions all use this convention:

```pycon
>>> fruits = ['kumquat', 'Cherimoya', 'Loquat', 'longan', 'jujube']
>>> def normalize_case(s): return s.casefold()
...
>>> sorted(fruits, key=normalize_case)
['Cherimoya', 'jujube', 'kumquat', 'longan', 'Loquat']
>>> min(fruits, key=normalize_case)
'Cherimoya'
>>> max(fruits, key=normalize_case)
'Loquat'
```

That [key function][] is called for each value in the given iterable and the return value is used to order/sort each of the iterable items.
You can think of this key function as computing *a comparison key* for each item in the iterable.

In the above example our comparison key returns a lowercased string, so each string is compared by its lowercased version (which results in a case-insensitive ordering).

We used a `normalize_case` function to do this, but the same thing could be done using `str.casefold`:

```pycon
>>> sorted(fruits, key=str.casefold)
['Cherimoya', 'jujube', 'kumquat', 'longan', 'Loquat']
```

**Note**: That `str.casefold` trick is a bit odd if you aren't familiar with how classes work.
Classes store the *unbound methods* that will accept an instance of that class when called.
We normally type `my_string.casefold()` but `str.casefold(my_string)` is what Python translates that to.
That's a story for another time.

Here we're finding the string with the most letters in it:

```pycon
>>> max(fruits, key=len)
'Cherimoya'
```

If there are multiple maximums or minimums, the earliest ones *wins* (that's how `min`/`max` work):

```pycon
>>> min(fruits, key=len)
'Loquat'
>>> sorted(fruits, key=len)
['Loquat', 'longan', 'jujube', 'kumquat', 'Cherimoya']
```

Here's a function which will return a 2-item tuple of the length of a given string and the case-normalized version of that string:

```python
def length_and_alphabetical(string):
    """Return sort key: length first, then case-normalized string."""
    return (len(string), string.casefold())
```

We could pass this `length_and_alphabetical` function as the `key` argument to `sorted` to sort our strings by their length first and by their case-insensitive letters afterward:

```pycon
>>> fruits = ['kumquat', 'Cherimoya', 'Loquat', 'longan', 'jujube']
>>> fruits_by_length = sorted(fruits, key=length_and_alphabetical)
>>> fruits_by_length
['jujube', 'longan', 'Loquat', 'kumquat', 'Cherimoya']
```


## Other examples of passing functions around

The `key` argument accepted by `sorted`, `min`, and `max` is just one common example of passing functions into functions.

Two more function-accepting functions built-in to Python are `map` and `filter`.

We've already seen that `filter` will *filter* our list based on a given function's return value.

```pycon
>>> numbers
[2, 1, 3, 4, 7, 11, 18, 29]
>>> def is_odd(n): return n % 2 == 1
...
>>> list(filter(is_odd, numbers))
[1, 3, 7, 11, 29]
```

The `map` function will call the given function on each item in the iterable given and use the result of that function call as the new item:

```pycon
>>> list(map(is_odd, numbers))
[False, True, True, False, True, True, False, True]
```

For example here we're converting our numbers all to strings and squaring each of our numbers:

```pycon
>>> list(map(str, numbers))
['2', '1', '3', '4', '7', '11', '18', '29']
>>> list(map(lambda n: n**2, numbers))
[4, 1, 9, 16, 49, 121, 324, 841]
```

**Note**: as I noted in my article on overusing lambda, I prefer to [use generator expressions instead of map and filter][].

The [defaultdict][] class in the `collections` module is another example.
The `defaultdict` class creates dictionary-like objects which will never raise a `KeyError` when a missing key is accessed, but will instead add a new value to the dictionary automatically.

```pycon
>>> from collections import defaultdict
>>> counts = defaultdict(int)
>>> counts['jujubes']
0
>>> counts
defaultdict(<class 'int'>, {'jujubes': 0})
```

The `defaultdict` class accepts a [callable][] (function or class) that will be called to create a default value whenever a missing key is accessed.

The above code worked because `int` returns `0` when called with no arguments:

```pycon
>>> int()
0
```

Here the default value is `list`, which returns an empty list when called with no arguments.

```pycon
>>> things_by_color = defaultdict(list)
>>> things_by_color['purple'].append('socks')
>>> things_by_color['purple'].append('shoes')
>>> things_by_color
defaultdict(<class 'list'>, {'purple': ['socks', 'shoes']})
```

The [partial][] function in the `functools` module is another example.
`partial` accepts a function and any number of arguments and returns a new function (technically it returns a [callable object][]).

```pycon
TODO
```

You'll also find functions-which-accept functions 

- callable objects work too


## Other topics to explore later

Programming languages like Python are sometimes referred to as having **higher order functions** or **first-class functions**.

TODO callable objects
TODO defining functions dynamically
TODO decorators
TODO storing attributes on functions


[key function]: https://docs.python.org/3/glossary.html#term-key-function
[anonymous functions]: https://en.wikipedia.org/wiki/Anonymous_function
[overusing lambda expressions]: https://docs.python.org/3/glossary.html#term-key-function
[named arguments]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[callable]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[use generator expressions instead of map and filter]: https://treyhunner.com/2018/09/stop-writing-lambda-expressions/#Overuse:_lambda_with_map_and_filter
[defaultdict]: https://docs.python.org/3/library/collections.html#collections.defaultdict
[callable object]: https://treyhunner.com/2019/04/is-it-a-class-or-a-function-its-a-callable/#Callable_objects
