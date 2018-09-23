---
layout: post
title: "Stop writing lambda expressions in Python"
date: 2018-09-13 10:00:00 -0700
comments: true
categories: 
---

It's hard for me to teach an in-depth Python class without discussing lambda expressions.
I almost always get questions about them.
My students tend to see them in code on StackOverflow or they see them in a coworker's code (which, realistically, may have also come from StackOverflow).

While I often get questions about lambda, I'm hesitant to recommend my students embrace Python's lambda expressions.
I have had an aversion to lambda expressions for many years, and since I started teaching Python more regularly a few years ago, my aversion to lambda expressions has only grown stronger.

I'm going to explain how I see lambda expressions and why I tend to recommend my students avoid using them.


## Lambda expressions in Python: what are they?

Lambda expressions a special syntax in Python for creating [anonymous functions][].
I'll call the `lambda` syntax itself a **lambda expression** and the function you get back from this I'll call a **lambda function**.

Python's lambda allows a function to be created and passed around (often into another function) all in one line of code.

Python's lambda expressions allow us to take this code:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])

def normalize_case(string):
    return string.casefold()

normalized_colors = map(normalize_case, colors)
```

And turn it into this code:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])

normalized_colors = map(lambda s: s.casefold(), colors)
```

Lambda expressions are just a special syntax for making functions.
They can only have one statement in them and they return the result of that statement automatically.

The inherent limitations of lambda expressions are actually part of their appeal.
When an experienced Python programmer sees a lambda expression they know that they're working with a function that is **only used in one place** and does **just one thing**.


## Where they're usually used

You'll typically see `lambda` expressions used when calling functions (or classes) that accept a function as an argument.

Python's built-in `sorted` function accepts a function as its `key` argument.  This *key function* is used to compute a comparison key when determining the sorting order of items.

So ``sorted`` is a great example of a place that lambda expressions are often used:

```python
>>> colors = ["Goldenrod", "purple", "Salmon", "turquoise", "cyan"]
>>> sorted(colors, key=lambda s: s.casefold())
['cyan', 'Goldenrod', 'purple', 'Salmon', 'turquoise']
```

The above code returns the given colors sorted in a case-insensitive way.


## When not to use them

Regardless of what you think of lambda expressions, there are sometimes that you simply shouldn't use them.

PEP8, the official Python style guide, advises never to write code like this:

```python
normalize_case = lambda s: s.casefold()
```

The above statement makes an anonymous function and then assigns it to a variable.
We're sidestepping the reason lambda expressions are useful: they can be passed around without needing to be assigned to a variable first.

If you want to create a one-liner function and store it in a variable, you should use `def` instead:

```python
def normalize_case(s): return s.casefold()
```

PEP8 recommends this because named functions are a common and easily understood thing.
This also has the benefit of giving our function a proper name, which could make debugging easier.
Unlike functions defined with `def` lambda functions never have a name (it's always `<lambda>`):

```python
>>> normalize_case = lambda s: s.casefold()
>>> normalize_case
<function <lambda> at 0x7f264d5b91e0>
>>> def normalize_case(s): return s.casefold()
...
>>> normalize_case
<function normalize_case at 0x7f247f68fea0>
```

If you want to create a function and store it in a variable, use `def`.
That's exactly what it's for.
It doesn't matter if your function is a single line of code or if you're defining a function inside of another function, `def` works just fine for those use cases.


## The pros and cons of lambda

I'd like to take this advice from PEP8 a step further and propose that lambda expressions should almost never be used.

I frame my thinking around lambda expressions as a constant comparison to using `def` to define functions.
Both of these tools give us functions, but they each have different limitations and use a different syntax.

Here are the main ways lambda expressions are different from `def`:

1. They can be immediately passed around (no variable needed)
2. They can only have a single line of code within them
3. They return automatically
4. They can't have a docstring and they don't have a name
5. They use a different and unfamiliar syntax

I find #2 mostly neutral and #3 neat but not a big benefit.  It's #1 that is the big benefit of lambda expressions but I find #4 and #5 are problems that usually outweigh the benefit of #1.


## Lambda expressions are often unnecessary

My main gripe with lambda isn't with lambda expressions so much as their use.
I often find code that uses lambda expressions to be more complicated than it needs to be.

For example take this code:

```python
sorted_numbers = sorted(numbers, key=lambda n: abs(n))
```

The person who wrote this code likely learned that lambda expressions are used for making a function that can be passed around.
But they missed out on a slightly bigger picture idea: all functions in Python can be passed around.

Since `abs` (which returns the absolute value of a number) is a function and all functions can be passed around, we could actually have written the above code like this:

```python
sorted_numbers = sorted(numbers, key=abs)
```

Now this example might feel contrived, but it's not terribly uncommon to overuse lambda expressions in this way.  Here's another example I've seen:

```python
pairs = [(4, 11), (8, 8), (5, 7), (11, 3)]
sorted_by_smallest = sorted(pairs, key=lambda x, y: min(x, y))
```

Because we're accepting exactly the same arguments as we're passing into `min`, we don't need that extra function call.  We can just pass the `min` function to `key` instead:

```python
pairs = [(4, 11), (8, 8), (5, 7), (11, 3)]
sorted_by_smallest = sorted(pairs, key=min)
```

Here's a more common use of lambda:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])
length_sorted_colors = sorted(colors, key=lambda c: (len(c), c.casefold()))
```

That `key` function here is helping us sort these colors by their length followed by their case-normalized name.

I find this to be a more readable version of the same thing:

```python
def length_and_alphabetical(string):
    return (len(string), string.casefold())

colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])
length_sorted_colors = sorted(colors, key=length_and_alphabetical)
```

This code is quite a bit more verbose, but I find the name of that key function makes it clearer what we're sorting by.
We're not just sorting by the length and we're not not just sorting by the color.

**If a function is important, it deserves a name**.
You could argue that most functions that are used in a lambda expression are so trivial that they don't deserve a name, but there's often little downside to naming functions and I find it usually makes my code more readable overall.

Naming functions often makes code more readable, the same way [using tuple unpacking to name variables][tuple unpacking] instead of using arbitrary index-lookups often makes code more readable.


## But what about map and filter?

Python's map and filter functions are almost always paired with lambda expressions.

It's not uncommon to see StackOverflow questions asking "what is lambda" answered with code examples like this:

```python
>>> numbers = [2, 1, 3, 4, 7, 11, 18]
>>> squared_numbers = map(lambda n: n**2, numbers)
>>> odd_numbers = filter(lambda n: n % 2 == 1, numbers)
```

I find these examples a bit confusing because I almost never use map and filter in my code.

Python's `map` and `filter` functions are used for looping over an iterable and making a new iterable that either slightly changes each element or filters the iterable down to only elements that match a certain condition.
We can accomplish both of those tasks just as well with list comprehensions and generator expressions:

```python
>>> numbers = [2, 1, 3, 4, 7, 11, 18]
>>> squared_numbers = (n**2 for n in numbers)
>>> odd_numbers = (n for n in numbers if n % 2 == 1)
```

Personally, I'd prefer to see those generator expressions written over multiple lines of code ([see my article on comprehensions](http://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/)) but I find even these one-line generator expressions more readable than those `map` and `filter` calls.

Mapping and filtering are very useful operations, but you don't need the `map` and `filter` functions to do them.  Generator expressions are a special syntax that exists just for the tasks of mapping and filtering.


## What about the simple cases?

Comprehensions and generator expressions are a great replacement for using map and filter and some functions really do deserve a name, but what about other cases where it's useful to pass around simple functions that perform a single operation?

I sometimes see code like this written by newer Pythonistas who are keen or functional programming:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
total = reduce(lambda x, y: x + y, numbers)
```

We're adding all the numbers in this list.  There's a better way to do this in Python:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
total = sum(numbers)
```

Python's built-in `sum` function was made just for this task.
The `sum` function, along with a number of other specialized Python tools, are easy to overlook.
But I'd encourage you to seek out the more specialized tools when you need them because they often make for more readable code.

If we were multiplying these numbers together, we wouldn't be able to use the `sum` function:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
product = reduce(lambda x, y: x * y, numbers)
```

This lambda expression is only necessary because we're not allowed to pass the `*` operator around as if it were a function.
Python's standard library actually has a whole module meant to address this problem:

```python
from functools import reduce
from operator import mul

numbers = [2, 1, 3, 4, 7, 11, 18]
product = reduce(mul, numbers)
```

Python's [operator module][] exists to make various Python operators easy to use as functions.
If you're practicing functional(ish) programming in Python, the `operator` module is your friend.

In addition to providing functions corresponding to Python's many operators, the `operator` module provides a couple common higher level functions for accessing items and attributes and calling methods.

There's `itemgetter` for accessing indexes of a list/sequence or keys of a dictionary/mapping:

```python
# Without operator: accessing a key/index
rows_sorted_by_city = sorted(rows, key=lambda row: row['city'])

# With operator: accessing a key/index
from operator import itemgetter
rows_sorted_by_city = sorted(rows, key=itemgetter('city'))
```

There's also `attrgetter` for accessing attributes on an object:

```python
# Without operator: accessing an attribute
products_sorted_by_quantity = sorted(rows, key=lambda product: product.quantity)

# With operator: accessing an attribute
from operator import attrgetter
products_sorted_by_quantity = sorted(rows, key=attrgetter('quantity'))
```

And `methodcaller` for calling methods on an object:

```python
# Without operator: calling a method
sorted_colors = sorted(colors, key=lambda s: s.casefold())

# With operator: calling a method
from operator import methodcaller
sorted_colors = sorted(colors, key=methodcaller('casefold'))
```

Sometimes the `operator` module doesn't make things much clearer, but I *usually* find it more clear than an equivalent lambda expression.

In general though, higher order functions (functions that accept functions as arguments), can make for confusing code.
Functional programming techniques are great, but Python is a multi-paradigm language and we can mix and match different coding techniques while working toward the goal of more readable and maintainable code.

Compare this:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
product = reduce(lambda x, y: x * y, numbers)
```

To this:

```python
def multiply_all(numbers):
    """Return the product of the given numbers."""
    product = 1
    for n in numbers:
        product *= n
    return product

numbers = [2, 1, 3, 4, 7, 11, 18]
product = multiply_all(numbers)
```

The second code is longer, but it's also easier to understand.
Anyone who has gone through one of my Python training courses can probably understand what that `multiply_all` function does, whereas that `reduce`/`lambda` combination is likely a bit more cryptic for many Python programmers.


TODO looking at lambda in sorted call

This works but that lambda expression is rarely more immediately clear than a clearly named function


1. Lambda expressions are an odd and unfamiliar syntax to many Python programmers
2. Lambda expressions inherently lack a name or documentation, meaning reading their code is the only way to figure out what they do
3. Lambda expressions can have only one statement in them so certain language features that improve readability, like tuple unpacking, can't be used with them
3. Many common uses of lambda can be replaced with already existing functions in the standard libray or built-in to Python



## Should you ever use lambda expressions?

Using lambda expressions is fine if:

- The operation you're doing is trivial: the function doesn't deserve a name
- Having a lambda expression makes your code more understandable than any function name you can think of
- Everyone on your team understands lambda expressions fairly well and you've all agreed to use them

[anonymous functions]: https://en.wikipedia.org/wiki/Anonymous_function
[tuple unpacking]: http://treyhunner.com/2018/03/tuple-unpacking-improves-python-code-readability/
[operator module]: https://docs.python.org/3/library/operator.html
