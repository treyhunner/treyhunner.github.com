---
layout: post
title: "Functions can be passed into other functions in Python"
date: 2020-01-07 07:16:50 -0800
comments: true
categories: python
---

One of the more hair-raising facts we learn in my introductory Python trainings is that **you can pass functions into other functions**.
You can pass functions around because in Python, **functions are objects**.

You likely don't need to know about this in your first week of using Python, but as you dive deeper into Python you'll find that it can be quite convenient to understand how to pass a function into another function.

This is part 1 of what I expect to be a series on the various properties of "function objects".
This article focuses on what a new Python program should know and appreciate about **the object-nature of Python's functions**.

<ul data-toc=".entry-content"></ul>


## Functions can be referenced

If you try to use a function without putting parenthesis after it Python won't complain but it also won't do anything useful:

```pycon
>>> def greet():
...     print("Hello world!")
...
>>> greet
<function greet at 0x7ff246c6d9d0>
```

This applies to methods as well ([methods][] are functions which live on objects):

```pycon
>>> numbers = [1, 2, 3]
>>> numbers.pop
<built-in method pop of list object at 0x7ff246c76a80>
```

Python is allowing us to *refer* to these *function objects*, the same way we might refer to a string, a number, or a `range` object:

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

Note that we **didn't make a new function**.
We've just pointed the `gimme` variable name to the `numbers.pop` function:

```pycon
>>> gimme
<built-in method pop of list object at 0x7ff246c76bc0>
>>> numbers.pop
<built-in method pop of list object at 0x7ff246c76bc0>
```

You can even store functions inside data structures and then reference them later:

```pycon
>>> def square(n): return n**2
...
>>> def cube(n): return n**3
...
>>> operations = [square, cube]
>>> numbers = [2, 1, 3, 4, 7, 11, 18, 29]
>>> for i, n in enumerate(numbers):
...     action = operations[i % 2]
...     print(action.__name__, action(n))
...
square 4
cube 1
square 9
cube 64
square 49
cube 1331
square 324
cube 24389
```

It's not very common to take a function and give another name to it or to store it inside a data structure, but Python allows us to do these things because **functions can be passed around, just like any other object**.


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

And we can pass the function into itself (yes this is weird), which converts it to a string here:

```pycon
>>> greet(greet)
Hello <function greet at 0x7f93416be8b0>!
```

There are actually quite a few functions built-in to Python that are specifically meant to accept other functions as arguments.

The built-in `filter` function accepts two things as an argument: a `function` and an `iterable`.

```
 |  filter(function or None, iterable) --> filter object
 |
 |  Return an iterator yielding those items of iterable for which function(item)
 |  is true. If function is None, return the items that are true.
```

The given iterable (list, tuple, string, etc.) is looped over and the given function is called on each item in that iterable: whenever the function returns `True` (or another truthy value) the item is included in the `filter` output.

So if we pass `filter` an `is_odd` function (which returns `True` when given an odd number) and a list of numbers, we'll get back all of the numbers we gave it which are odd.

```pycon
>>> numbers = [2, 1, 3, 4, 7, 11, 18, 29]
>>> def is_odd(n): return n % 2 == 1
...
>>> filter(is_odd, numbers)
<filter object at 0x7ff246c8dc40>
>>> list(filter(is_odd, numbers))
[1, 3, 7, 11, 29]
```

The object returned from `filter` is [a lazy iterator][iterator] so we needed to convert it to a list to actually see its output.

Since functions can be passed into functions, that also means that functions can accept another function as an argument.
The `filter` function assumes its first argument is a function.
You can think of the `filter` function as pretty much the same as this function:

```python
def filter(predicate, iterable):
    return (
        item
        for item in iterable
        if predicate(item)
    )
```

This function expects the `predicate` argument to be a function (technically it could be any [callable][]).
When we call that function (with `predicate(item)`), we pass a single argument to it and then check the truthiness of its return value.


## Lambda functions are an example of this

A lambda expression is a special syntax in Python for creating an [anonymous function][].
When you evaluate a **lambda expressions** the object you get back is called a **lambda function**.

```pycon
>>> is_odd = lambda n: n % 2 == 1
>>> is_odd(3)
True
>>> is_odd(4)
False
```

Lambda functions are pretty much just like regular Python functions, with a few caveats.

Unlike other functions, lambda functions don't have a name (their name shows up as `<lambda>`).
They also can't have docstrings and they can only contain a single Python expression.

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

I'd like to note that all three of the above examples of `lambda` are poor examples.
If you want a variable name to point to a function object that you can use later, you should use `def` to define a function: that's the *usual* way to define a function.


```pycon
>>> def is_odd(n): return n % 2 == 1
...
>>> def add(x, y): return x + y
...
>>> def greet(name="world"): print(f"Hello {name}")
...
```

Lambda expressions are for when we'd like to define a function and **pass it into another function immediately**.

For example here we're using `filter` to get even numbers, but we're using a lambda expression so we don't have to define an `is_even` function before we use it:

```pycon
>>> numbers
[2, 1, 3, 4, 7, 11, 18, 29]
>>> list(filter(lambda n: n % 2 == 0, numbers))
[2, 4, 18]
```

This is *the most appropriate* use of lambda expressions: passing a function into another function while defining that passed function all on one line of code.

As I've written about in [Overusing lambda expressions][], I'm not a fan of Python's lambda expression syntax.
Whether or not you like this syntax, you should know that this syntax is just a shortcut for creating a function.

Whenever you see `lambda` expressions, keep in mind that:

1. A lambda expression is a special syntax for creating a function and passing it to another function all on one line of code
2. Lambda functions are just like all other function objects: neither is more special than the other and both can be passed around

All functions in Python can be passed as an argument to another function (that just happens to be the *sole* purpose of lambda functions).


## A common example: key functions

Besides the built-in `filter` function, where will you ever see a function passed into another function?
Probably the most common place you'll see this in Python itself is with a **key function**.

It's a common convention for functions which accept an iterable-to-be-sorted/ordered to also accept a [named argument][] called `key`.
This `key` argument should be a function [or another callable][callable].

The [sorted][], [min][], and [max][] functions all follow this convention of accepting a `key` function:

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
You can think of this key function as computing **a comparison key** for each item in the iterable.

In the above example our comparison key returns a lowercased string, so each string is compared by its lowercased version (which results in a case-insensitive ordering).

We used a `normalize_case` function to do this, but the same thing could be done using `str.casefold`:

```pycon
>>> fruits = ['kumquat', 'Cherimoya', 'Loquat', 'longan', 'jujube']
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
>>> fruits = ['kumquat', 'Cherimoya', 'Loquat', 'longan', 'jujube']
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

This relies on the fact that [Python's ordering operators do deep comparisons][deep comparisons].


## Other examples of passing a function as an argument

The `key` argument accepted by `sorted`, `min`, and `max` is just one common example of passing functions into functions.

Two more function-accepting Python built-ins are `map` and `filter`.

We've already seen that `filter` will *filter* our list based on a given function's return value.

```pycon
>>> numbers
[2, 1, 3, 4, 7, 11, 18, 29]
>>> def is_odd(n): return n % 2 == 1
...
>>> list(filter(is_odd, numbers))
[1, 3, 7, 11, 29]
```

The `map` function will call the given function on each item in the given iterable and use the result of that function call as the new item:

```pycon
>>> list(map(is_odd, numbers))
[False, True, True, False, True, True, False, True]
```

For example here we're converting numbers to strings and squaring numbers:

```pycon
>>> list(map(str, numbers))
['2', '1', '3', '4', '7', '11', '18', '29']
>>> list(map(lambda n: n**2, numbers))
[4, 1, 9, 16, 49, 121, 324, 841]
```

**Note**: as I noted in my article on overusing lambda, I personally prefer to [use generator expressions instead of the `map` and `filter` functions][generator expressions].

Similar to `map`, and `filter`, there's also [takewhile][] and [dropwhile][] from the `itertools` module.
The first one is like `filter` except it stops once it finds a value for which the *predicate function* is false.
The second one does the opposite: it only includes values after the predicate function has become false.

```pycon
>>> from itertools import takewhile, dropwhile
>>> colors = ['red', 'green', 'orange', 'purple', 'pink', 'blue']
>>> def short_length(word): return len(word) < 6
...
>>> list(takewhile(short_length, colors))
['red', 'green']
>>> list(dropwhile(short_length, colors))
['orange', 'purple', 'pink', 'blue']
```

And there's [functools.reduce][] and [itertools.accumulate][], which both call a 2-argument function to accumulate values as they loop:

```pycon
>>> from functools import reduce
>>> from itertools import accumulate
>>> numbers = [2, 1, 3, 4, 7]
>>> def product(x, y): return x * y
...
>>> reduce(product, numbers)
168
>>> list(accumulate(numbers, product))
[2, 2, 6, 24, 168]
```

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

This `defaultdict` class accepts a [callable][] (function or class) that will be called to create a default value whenever a missing key is accessed.

The above code worked because `int` returns `0` when called with no arguments:

```pycon
>>> int()
0
```

Here the default value is `list`, which returns a new list when called with no arguments.

```pycon
>>> things_by_color = defaultdict(list)
>>> things_by_color['purple'].append('socks')
>>> things_by_color['purple'].append('shoes')
>>> things_by_color
defaultdict(<class 'list'>, {'purple': ['socks', 'shoes']})
```

The [partial][] function in the `functools` module is another example.
`partial` accepts a function and any number of arguments and returns a new function (technically it returns a [callable object][]).

Here's an example of `partial` used to "bind" the `sep` keyword argument to the `print` function:

```pycon
>>> print_each = partial(print, sep='\n')
```

The `print_each` function returned now does the same thing as if `print` was called with `sep='\n'`:

```pycon
>>> print(1, 2, 3)
1 2 3
>>> print(1, 2, 3, sep='\n')
1
2
3
>>> print_each(1, 2, 3)
1
2
3
```

You'll also find functions-that-accept-functions in third-party libraries, like [in Django][], and [in numpy][].
Anytime you see a class or a function with documentation stating that one of its arguments should be a **callable** or a **callable object**, that means "you could pass in a function here".


## A topic I'm skipping over: nested functions

Python also supports nested functions (functions defined inside of other functions).
Nested functions power Python's [decorator][] syntax.

I'm not going to discuss nested functions in this article because nested functions warrant exploration of [non-local variables][], [closures][], and other weird corners of Python that you don't need to know when you're first getting started with treating functions as objects.

I plan to write a follow-up article on this topic and link to it here later.
In the meantime, if you're interested in nested functions in Python, a search for [higher order functions in Python][] may be helpful.


## Treating functions as objects is normal

Python has [first-class functions][], which means:

1. You can assign functions to variables
2. You can store functions in lists, dictionaries, or other data structures
3. You can pass functions into other functions
4. You can write functions that return functions

It might seem odd to treat functions as objects, but it's not that unusual in Python.
By my count, about 15% of the Python built-ins are meant to accept functions as arguments (`min`, `max`, `sorted`, `map`, `filter`, `iter`, `property`, `classmethod`, `staticmethod`, `callable`).

The most important uses of Python's first-class functions are:

1. Passing a `key` function to the built-in `sorted`, `min`, and `max` functions
2. Passing functions into looping helpers like `filter` and `itertools.dropwhile`
3. Passing a "default-value generating factory function" to classes like `defaultdict`
4. "Partially-evaluating" functions by passing them into `functools.partial`

This topics goes *much deeper* than what I've discussed here, but until you find yourself writing decorator functions, you probably don't need to explore this topic any further.


[methods]: https://docs.python.org/3/glossary.html#term-method
[key function]: https://docs.python.org/3/glossary.html#term-key-function
[anonymous function]: https://en.wikipedia.org/wiki/Anonymous_function
[overusing lambda expressions]: https://docs.python.org/3/glossary.html#term-key-function
[named argument]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[callable]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[generator expressions]: https://treyhunner.com/2018/09/stop-writing-lambda-expressions/#Overuse:_lambda_with_map_and_filter
[defaultdict]: https://docs.python.org/3/library/collections.html#collections.defaultdict
[callable object]: https://treyhunner.com/2019/04/is-it-a-class-or-a-function-its-a-callable/#Callable_objects
[in django]: https://docs.djangoproject.com/en/3.0/ref/models/fields/#default
[in numpy]: https://numpy.org/doc/1.17/reference/generated/numpy.fromfunction.html
[first-class functions]: https://en.wikipedia.org/wiki/First-class_function
[non-local variables]: https://en.wikipedia.org/wiki/Non-local_variable
[closures]: https://en.wikipedia.org/wiki/Closure_(computer_programming)
[decorator]: https://docs.python.org/3/glossary.html#term-decorator
[takewhile]: https://docs.python.org/3/library/itertools.html#itertools.takewhile
[dropwhile]: https://docs.python.org/3/library/itertools.html#itertools.dropwhile
[functools.reduce]: https://docs.python.org/3/library/functools.html#functools.reduce
[itertools.accumulate]: https://docs.python.org/3/library/itertools.html#itertools.accumulate
[iterator]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[deep comparisons]: https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/
[sorted]: https://treyhunner.com/2019/05/python-builtins-worth-learning/#sorted
[min]: https://treyhunner.com/2019/05/python-builtins-worth-learning/#min_and_max
[max]: https://treyhunner.com/2019/05/python-builtins-worth-learning/#min_and_max
[partial]: https://docs.python.org/3/library/functools.html#functools.partial
[higher order functions in Python]: https://duckduckgo.com/?q=higher-order+functions+in+Python
