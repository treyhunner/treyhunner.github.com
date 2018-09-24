---
layout: post
title: "Stop writing lambda expressions in Python"
date: 2018-09-25 07:30:00 -0700
comments: true
categories: python
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

If you've ever used anonymous functions in JavaScript before, you can think of Python's lambda expressions as the same, except they have more restrictions and use a very different syntax than the traditional function syntax.


## Where they're usually used

You'll typically see `lambda` expressions used when calling functions (or classes) that accept a function as an argument.

Python's built-in `sorted` function accepts a function as its `key` argument.  This *key function* is used to compute a comparison key when determining the sorting order of items.

So `sorted` is a great example of a place that lambda expressions are often used:

```python
>>> colors = ["Goldenrod", "purple", "Salmon", "turquoise", "cyan"]
>>> sorted(colors, key=lambda s: s.casefold())
['cyan', 'Goldenrod', 'purple', 'Salmon', 'turquoise']
```

The above code returns the given colors sorted in a case-insensitive way.

The `sorted` function isn't the only use of lambda expressions, but it's a common one.


## The pros and cons of lambda

I frame my thinking around lambda expressions as a constant comparison to using `def` to define functions.
Both of these tools give us functions, but they each have different limitations and use a different syntax.

Here are the main ways lambda expressions are different from `def`:

1. They can be immediately passed around (no variable needed)
2. They can only have a single line of code within them
3. They return automatically
4. They can't have a docstring and they don't have a name
5. They use a different and unfamiliar syntax

The fact that lambda expressions can be passed around is their biggest benefit.  Returning automatically is neat but not a big benefit in my mind.  I find the "single line of code" limitation is neither good nor bad overall.  And the fact that they can't have docstrings and don't have a name is unfortunate and their unfamiliar syntax can be troublesome for newer Pythonistas.


## Lambda is both misused and overused

When I see a lambda expression in unfamiliar code I immediately become skeptical.
When I encounter a lambda expression on Stack Overflow, programming exercise websites, or another forum for folks learning and practicing Python, I usually find that the code can be refactored to be more improve readability.

Sometimes the issue is that lambda expressions are being misused, meaning they're **used in a way that is nearly always unideal**.
Other times lambda expressions are simply being overused, meaning they're acceptable but I'd personally **prefer to see the code written a different way**.

Let's take a look at the various ways lambda expressions are misused and overused.


## Misuse: naming lambda expressions

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

**If you want to create a function and store it in a variable, define your function using `def`**.
That's exactly what it's for.
It doesn't matter if your function is a single line of code or if you're defining a function inside of another function, `def` works just fine for those use cases.


## Misuse: needless function calls

I frequently see lambda expressions used to wrap around a function that was already appropriate for the problem at hand.

For example take this code:

```python
sorted_numbers = sorted(numbers, key=lambda n: abs(n))
```

The person who wrote this code likely learned that lambda expressions are used for making a function that can be passed around.
But they missed out on a slightly bigger picture idea: **all functions in Python (not just lambda functions) can be passed around**.

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


## Overuse: simple, but non-trivial functions

It's common to see lambda expressions used to make a function that returns a couple of values in a tuple:

```python
colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])
length_sorted_colors = sorted(colors, key=lambda c: (len(c), c.casefold()))
```

That `key` function here is helping us sort these colors by their length followed by their case-normalized name.

This code is the same as the above code, but I find it more readable:

```python
def length_and_alphabetical(string):
    """Return sort key: length first, then case-normalized string."""
    return (len(string), string.casefold())

colors = ["Goldenrod", "Purple", "Salmon", "Turquoise", "Cyan"])
length_sorted_colors = sorted(colors, key=length_and_alphabetical)
```

This code is quite a bit more verbose, but I find the name of that key function makes it clearer what we're sorting by.
We're not just sorting by the length and we're not not just sorting by the color.

**If a function is important, it deserves a name**.
You could argue that most functions that are used in a lambda expression are so trivial that they don't deserve a name, but there's often little downside to naming functions and I find it usually makes my code more readable overall.

Naming functions often makes code more readable, the same way [using tuple unpacking to name variables][tuple unpacking] instead of using arbitrary index-lookups often makes code more readable.


## Overuse: lambda with map and filter

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

Mapping and filtering are very useful operations, but you don't need the `map` and `filter` functions to do them.
Generator expressions are a special syntax that exists just for the tasks of mapping and filtering.
**Use generator expressions instead of the map and filter functions**.


## Misuse: sometimes you don't even need to pass a function

What about cases where you need to pass around a function that performs a single operation?

Newer Pythonistas who are keen on functional programming sometimes write code like this:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
total = reduce(lambda x, y: x + y, numbers)
```

This code adds all the numbers in the `numbers` list.
There's an even better way to do this:

```python
numbers = [2, 1, 3, 4, 7, 11, 18]
total = sum(numbers)
```

Python's built-in `sum` function was made just for this task.

The `sum` function, along with a number of other specialized Python tools, are easy to overlook.
But I'd encourage you to seek out the more specialized tools when you need them because they often make for more readable code.

Passing functions around adds complexity and you should **avoid passing functions around whenever possible**.


## Overuse: using lambda for very simple operations

Let's say instead of adding numbers up, we're multiply numbers together:

```python
from functools import reduce

numbers = [2, 1, 3, 4, 7, 11, 18]
product = reduce(lambda x, y: x * y, numbers)
```

The above lambda expression is necessary because we're not allowed to pass the `*` operator around as if it were a function.
If there was a function that was equivalent to `*`, we could pass it into the `reduce` function instead.

Python's standard library actually has a whole module meant to address this problem:

```python
from functools import reduce
from operator import mul

numbers = [2, 1, 3, 4, 7, 11, 18]
product = reduce(mul, numbers)
```

Python's [operator module][] exists to make various Python operators easy to use as functions.
If you're practicing functional(ish) programming, **Python's `operator` module is your friend**.

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
products_sorted_by_quantity = sorted(products, key=lambda p: p.quantity)

# With operator: accessing an attribute
from operator import attrgetter
products_sorted_by_quantity = sorted(products, key=attrgetter('quantity'))
```

And `methodcaller` for calling methods on an object:

```python
# Without operator: calling a method
sorted_colors = sorted(colors, key=lambda s: s.casefold())

# With operator: calling a method
from operator import methodcaller
sorted_colors = sorted(colors, key=methodcaller('casefold'))
```

I *usually* find using the functions in the `operator` module make my code clearer than if I'd used an equivalent lambda expression.


## Overuse: using lambda when the alternative is more readable

Lambda expressions are useful when you're passing functions into other functions, which common when practicing functional programming.  Functional programming isn't the only way to use Python though: Python is a multi-paradigm language so we can mix and match coding disciplines to make our code more readable.

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

The second code is longer, but folks without a functional programming background will often find it easier to understand.

Anyone who has gone through one of my Python training courses can probably understand what that `multiply_all` function does, whereas that `reduce`/`lambda` combination is likely a bit more cryptic for many Python programmers.

In general, the act of using a higher order function, that is **passing one function into another function, tends to makes code more complex, which can hurt readability**.


## Should you ever use lambda expressions?

So lambda expressions:

- are an odd and unfamiliar syntax to many Python programmers
- inherently lack a name or documentation, meaning reading their code is the only way to figure out what they do
- can have only one statement in them so certain language features that improve readability, like tuple unpacking, can't be used with them
- can often be replaced with already existing functions in the standard libray or built-in to Python

Lambda expressions are rarely more immediately readable than a well-named function.

Using lambda expressions is fine if your situation meets all three of these criteria:

1. The operation you're doing is trivial: the function doesn't deserve a name
2. Having a lambda expression makes your code more understandable than any function name you can think of
3. You're pretty sure there's not already a function that does what you're looking for
4. Everyone on your team understands lambda expressions fairly well and you've all agreed to use them

If any three of those three statements don't fit your situation, I'd recommend writing a new function or (even better) embracing a function that already exists.


[anonymous functions]: https://en.wikipedia.org/wiki/Anonymous_function
[tuple unpacking]: http://treyhunner.com/2018/03/tuple-unpacking-improves-python-code-readability/
[operator module]: https://docs.python.org/3/library/operator.html
