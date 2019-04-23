---
layout: post
title: "Python built-ins worth learning"
date: 2019-04-18 06:20:48 -0700
comments: true
categories: python
---

TODO google octopress table of contents

In every Intro to Python class I teach, there's always at least one "how can we be expected to know all this" question.

It's usually along the lines of either:

1. Python has so many functions in it, what's the best way to remember all these?
2. What's the best way to know about 'enumerate` and `range` and other functions day-to-day?
3. How do you know about all the ways to solve problems in Python?  Do you memorize them?

There are dozens of built-in functions and classes, hundreds more tools bundled in Python's [standard library][], and thousands of third-party librarys on PyPI that can make your life easier as well.
There's no way anyone could ever memorize all of these things.

I recommend triaging your knowledge:

1. Things I should memorize such that I know them well
2. Things I should know *about* so I can look them up more effectively later
3. Things I shouldn't bother with at all until/unless I need it one day

I'd like to demonstrate this approach with the Python documentation's [Built-in Functions page][].


## Which built-ins should you know about?

I estimate there are about 30 built-ins that most Python developers will ever use, but which 30 depends on what you're actually doing with Python.

We're going to take a look at all of the 69 Python built-in functions, in a birds eye view sort of way.

I'll attempt to categorize these built-ins into five categories:

1. Commonly known: most newer Pythonistas get exposure to these built-ins pretty quickly out of necessity
2. Overlooked by beginners: these functions are useful to know about, but they're easy to overlook when you're newer to Python
3. Learn it later: these built-ins are generally useful to know about, but you'll find them when/if you need them
4. Maybe learn it eventually: these can come in handy, but only in specific circumstances
5. You likely don't need these: you're unlikely to need these unless you're doing something fairly specialized

TODO I will be referring to all of these built-in functions as *functions*, even though 27 of them aren't actually functions (as I discussed in my article on [functions and callables][]).

The commonly known built-in functions (which you likely already know about):

1. print
2. len
3. str
4. int
5. float
6. list
7. tuple
8. dict
9. set
10. range

The built-in functions which are often overlooked by newer Python programmers:

1. sum()
2. enumerate()
3. zip()
4. bool() ???
5. reversed()
6. sorted()
7. min()
8. max()
9. any()
10. all()

There are also 4 commonly overlooked built-ins which I recommend knowing about solely because they make debugging easier:

1. dir
2. var
3. breakpoint
4. type
5. help


## 10 Commonly known built-in functions

If you've been writing Python code, these built-ins are likely familiar already.

### print

You already know the `print` function.
Implementing [hello world][] requires `print`.

You may not know about the various [keyword arguments][] accepted by `print` though:

```python
>>> words = ["Welcome", "to", "Python"]
>>> print(words)
['Welcome', 'to', 'Python']
>>> print(*words)
Welcome to Python
>>> print(*words, sep='\n')
Welcome
to
Python
```

You can look up `print` on your own.


### len

In Python, we don't write things like `my_list.length()` or `my_string.length`;
instead we, strangely for new Pythonistas, say `len(my_list)` and `len(my_string)`.

```python
>>> words = ["Welcome", "to", "Python"]
>>> len(words)
3
```

Regardless of whether you like this operator-like `len` function, you're stuck with it so you'll need to get used to it.


### str

Unlike many other programming languages, you cannot concatenate strings and numbers in Python.

```python
>>> version = 3
>>> "Python " + version
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: can only concatenate str (not "int") to str
```

Python refuses to coerce that `3` integer to a string, so we need to manually do it ourselves, using the built-in `str` function:

```python
>>> version = 3
>>> "Python " + str(version)
'Python 3'
```


### int

Have user input and need to convert it to a number?
The `int` function will convert strings to integers:

```python
>>> program_name = "Python 3"
>>> version_number = program_name.split()[-1]
>>> int(version_number)
3
```

You can also use `int` to truncate a floating point number to an integer:

```python
>>> from math import sqrt
>>> sqrt(28)
5.291502622129181
>>> int(sqrt(28))
5
```

Note that if you need to truncate while dividing, the `//` is likely more appropriate (`int(3/2) == 3//2`).


### float

Is the string you're converting to a number not actually an integer?
Then you'll want to use `float` instead of `int` for this conversion.

```python
>>> program_name = "Python 3"
>>> version_number = program_name.split()[-1]
>>> float(version_number)
3.0
>>> pi_digits = '3.141592653589793238462643383279502884197169399375'
>>> len(pi_digits)
50
>>> float(pi_digits)
3.141592653589793
```

In Python 2, we used to use `float` to convert integers to floating point numbers to force float division instead of integer division.
"Integer division" isn't a thing anymore in Python 3 (unless you're specifically using the `//` operator), so we don't need `float` for that purpose anymore.
So if you ever see `float(x) / y` in your Python 3 code, you can change that to just `x / y`.


### list

Want to make a list out of some other iterable?

The `list` function does that:

```python
>>> numbers = [2, 1, 3, 5, 8]
>>> squares = (n**2 for n in numbers)
>>> list_of_squares = list(squares)
>>> list_of_squares
[4, 1, 9, 25, 64]
>>> zip(numbers, list_of_squares)
<zip object at 0x7f3d43b38788>
>>> list(zip(numbers, list_of_squares))
[(2, 4), (1, 1), (3, 9), (5, 25), (8, 64)]
```

If you know you're working with a list, you could use the `copy` method to make a new copy of a list:

```python
>>> copy_of_squares = list_of_squares.copy()
```

But if you don't know what the iterable you're working with is, the `list` function is the more general way to loop over an iterable and copy it:

```python
>>> copy_of_squares = list(list_of_squares)
```

You could also use a list comprehension for this, [but I wouldn't recommend it][overusing comprehensions].

Note that when you want to make an empty list, using the *list literal syntax* (those `[]` brackets) is recommended:

```python
>>> my_list = list()  # Don't do this
>>> my_list = []  # Do this instead
```


### tuple

The `tuple` function is pretty much just like the `list` function, except it makes tuples instead:

```python
>>> numbers = [2, 1, 3, 4, 7]
>>> tuple(numbers)
(2, 1, 3, 4, 7)
```


### dict

The `dict` function makes a new dictionary.

Similar to like `list` and `tuple`, the `dict` function is equivalent to looping over an iterable of key-value pairs and making a dictionary from them.

This:

```python
>>> to_squares = {}
>>> for n, s in zip(numbers, list_of_squares):
...     to_squares[n] = s
...
>>> to_squares
{2: 4, 1: 1, 3: 9, 4: 16, 7: 49}
```

Can instead be done with the `dict` function:

```python
>>> to_squares = dict(zip(numbers, list_of_squares))
```

This function accepts two types of arguments:

1. another dictionary (mapping is the generic term), in which case that dictionary will be copied
2. a list of key-value tuples (more correctly, an iterable of two-item iterables), in which case a new dictionary will be constructed from these

So this works as well:

```python
>>> to_squares
{2: 4, 1: 1, 3: 9, 4: 16, 7: 49}
>>> new_dictionary = dict(to_squares)
>>> new_dictionary
{2: 4, 1: 1, 3: 9, 4: 16, 7: 49}
```

The `dict` function can also accept keyword arguments to make a dictionary with string-based keys:

```python
>>> person = dict(name='Trey Hunner', profession='Python Trainer')
```

I very much prefer to use a dictionary literal instead:

```python
>>> person = {'name': 'Trey Hunner', 'profession': 'Python Trainer'}
```

Like with `list` and `tuple`, an empty dictionary should be made using the literal syntax as well:

```python
>>> my_list = dict()  # Don't do this
>>> my_list = {}  # Do this instead
```


### set

The `set` function makes a new set.
It accepts an iterable of hashable values (strings, numbers, or other immutible types):

```python
>>> numbers = [1, 1, 2, 3, 5, 8]
>>> set(numbers)
{1, 2, 3, 5, 8}
```

There's no way to make an empty set with the `{}` set literal syntax (plain `{}` makes a dictionary), so the `set` function is the only way to make an empty set:

```python
>>> numbers = set()
>>> numbers
set()
```

Actually that's a lie because we have this:

```python
>>> {*()}  # This makes an empty set
set()
```

But that syntax is confusing (it relies on [a lesser-used feature of the `*` operator][asterisks]), so I don't recommend it.


### range

The `range` function gives us a `range` object, which represents a range of numbers:

```python
>>> range(10_000)
range(0, 10000)
>>> range(-1_000_000_000, 1_000_000_000)
range(-1000000000, 1000000000)
```

The `range` function is useful you'd like to loop over numbers.

```python
>>> for n in range(0, 50, 10):
...     print(n)
...
0
10
20
30
40
```

A common use case is to do an operation `n` times:

```python
first_five = [get_things() for _ in range(5)]
```

By the way that's a [list comprehension][] syntax.

Python 2's `range` function returned a list, which means the expressions above would make very very large lists.
Python 3's `range` works like Python 2's `xrange` (though they're [a bit different][xrange]) in that numbers are computed lazily as we loop over these items.


## Built-ins overlooked by new Pythonistas

If you've been programming Python for a bit or if you just taken an introduction to Python class, you probably already knew about most of the built-in functions above.

I'd now like to show off 15 built-in functions that are very handy to know about, but are more frequently overlooked by new Pythonistas.

The first 10 of these functions you'll find floating around in Python code, but the last 5 you'll most often use while debugging.

### bool

The `bool` function checks the **truthiness** of a Python object.

For numbers, truthiness is a question of non-zeroness:

```python
>>> bool(5)
True
>>> bool(-1)
True
>>> bool(0)
False
```

For collections, truthiness is usually a question of non-emptiness:

```python
>>> bool('hello')
True
>>> bool('')
False
>>> bool(['a'])
True
>>> bool([])
False
>>> bool({})
False
>>> bool({1: 1, 2: 4, 3: 9})
True
>>> bool(range(5))
True
>>> bool(range(0))
False
```

Truthiness is kind of a big deal in Python.

Instead of asking questions about the length of a container, many Pythonistas ask questions about truthiness instead:

```python
# Instead of doing this
if len(numbers) == 0:
    print("The numbers list is empty")

# Many of us do this
if not numbers:
    print("The numbers list is empty")
```


### enumerate

Whenever you need to count upward, one number at a time, while looping over an iterable at the same time, the `enumerate` function will come in handy.

That might seem like a very niche task, but it comes up quite often.

For example we might want to keep track of the line number in a file:

```python
with open('hello.txt', mode='rt') as my_file:
    for n, line in enumerate(my_file, start=1):
        print(f"{n:03}", line)
```

The `enumerate` function is also very commonly used to keep track of the *index* of items in a sequence.

```python
def palindromic(sequence):
    """Return True if the sequence is the same thing in reverse."""
    for i, item in enumerate(sequence):
        if item != sequence[-(i+1)]:
            return False
    return True
```

Note that you may see newer Pythonistas use `range(len(sequence))` in Python.
If you ever see code with `range(len(...))`, you'll almost always want to use `enumerate` instead.

```python
def palindromic(sequence):
    """Return True if the sequence is the same thing in reverse."""
    for i in range(len(sequence)):
        if sequence[i] != sequence[-(i+1)]:
            return False
    return True
```

If `enumerate` is news to you (or if you often use `range(len(...))`), see my article on [looping with indexes in Python][looping with indexes].


### zip

The `zip` function is even more specialized than `enumerate`.

The `zip` function is used for looping over multiple iterables at the same time.
We actually used it above (in the explanations of `list` and `dict`).

```python
>>> one_iterable = [2, 1, 3, 4, 7, 11]
>>> another_iterable = ['P', 'y', 't', 'h', 'o', 'n']
>>> for n, letter in zip(one_iterable, another_iterable):
...     print(letter, n)
...
P 2
y 1
t 3
h 4
o 7
n 11
```

If you ever have to loop over two lists (or any other iterable at the same time), `zip` is preferred over `enumerate`.
The `enumerate` function is handy when you need indexes while looping, but `zip` makes it so we don't even need indexes.

If you're new to `zip`, I also talk about it in my [looping with indexes][] article.

Both `enumerate` and `zip` return iterators to us.
Iterators are the lazy iterables that [power `for` loops][how for loops work].
I have [a whole talk on iterators][loop better] as well as a somewhat advanced article on [how to make your own iterators][make iterators].


### reversed

The `reversed` function, like `enumerate` and `zip` returns an iterator.

```python
>>> numbers = [2, 1, 3, 4, 7]
>>> reversed(numbers)
<list_reverseiterator object at 0x7f3d4452f8d0>
```

The only thing we can do with this iterator is loop over it (but only once):

```python
>>> list(reversed_numbers)
[7, 4, 3, 1, 2]
>>> list(reversed_numbers)
[]
```

Like `enumerate` and `zip`, `reversed` is a looping helper function.
You pretty see `reversed` used exclusively in the `for` part of a `for` loop:

```python
>>> for n in reversed(numbers):
...     print(n)
...
7
4
3
1
2
```

There are other some ways to accomplish the same thing (with lists that is):

```python
# Slicing syntax
for n in numbers[::-1]:
    print(n)

# In-place reverse method
numbers.reverse()
for n in numbers:
    print(n)
```

But the `reversed` function is often *the best* way to reverse an iterable.

Unlike the list `reverse` method (e.g. `numbers.reverse()`), `reversed` doesn't mutate (it just returns an iterator of the reversed items).

Unlike the weird `numbers[::-1]` slice syntax, `reversed(numbers)` doesn't build up a whole new list: the lazy iterator it returns just retrieves the next item in reverse as we loop.

The non-copying nature of the `reversed` function along with `zip` allow us to rewrite the `palindromic` function (from `enumerate` above) without taking any extra memory (no copying of lists is done here):

```python
def palindromic(sequence):
    """Return True if the sequence is the same thing in reverse."""
    for n, m in zip(sequence, reversed(sequence)):
        if n != m:
            return False
    return True
```


### sum

The `sum` function accepts an iterable of numbers and returns the sum of those numbers.

```python
>>> sum([2, 1, 3, 4, 7])
17
```

There's not much more to it than that.

Python has lots of helper functions that **do the looping for you**, partly because they pair nicely with generator expressions:

```python
>>> numbers = [2, 1, 3, 4, 7, 11, 18]
>>> sum(n**2 for n in numbers)
524
```

If you're curious about generator expressions, I discuss them in my [Comprehensible Comprehensions][] talk (and my [3 hour tutorial on comprehensions and generator expressions][comprehensions tutorial]).


### min and max

The `min` and `max` functions do what you'd expect: they give you the minimum and maximum items in an iterable.

```python
>>> numbers = [2, 1, 3, 4, 7, 11, 18]
>>> min(numbers)
1
>>> max(numbers)
18
```

The `min` and `max` functions compare the items given to them by using the `<` operator.
So all values need to be orderable and comparable to each other (fortunately [many objects are orderable in Python][deep ordering]).

TODO They also accept a `key` function (https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/)


### sorted

The `sorted` function accepts any iterable and returns a new lit of all the values in that iterable in sorted order.

```python
>>> numbers = [1, 8, 2, 13, 5, 3, 1]
>>> words = ["python", "is", "lovely"]
>>> sorted(numbers)
[1, 1, 2, 3, 5, 8, 13]
>>> sorted(words)
['is', 'lovely', 'python']
```

The `sorted` function, like `min` and `max`, compares the items given to it by using the `<` operator, so all values given to it need so to be orderable.

TODO key function again

TODO link https://medium.com/@DahlitzF/list-sort-vs-sorted-list-aab92c00e17


### any and all

The `any` and `all` functions are looping helpers for determining whether *any* or *all* items in an iterable match a given condition.

Our `palindromic` function from earlier checked whether *all* items were equal to their corresponding item in the reversed sequence (is the first value equal to the last, second to the second from last, etc.).

We could rewrite `palindromic` using `all` like this:

```python
def palindromic(sequence):
    """Return True if the sequence is the same thing in reverse."""
    return all(
        n == m
        for n, m in zip(sequence, reversed(sequence))
    )
```

Negating the condition and the return value from `all` would allow us to use `any` equivalently (though this is more confusing in this case):

```python
def palindromic(sequence):
    """Return True if the sequence is the same thing in reverse."""
    return not any(
        n != m
        for n, m in zip(sequence, reversed(sequence))
    )
```

I've written an article on `any` and `all` in Python called [Checking Whether All Items Match a Condition in Python][any-all article].


### The 5 debugging functions

TODO

- Useful debugging tools
    - dir() / vars() (no more obj.__dict__)
    - breakpoint() (this was added in Python 3.7. For earlier versions, you can type `import pdb ; pdb.set_trace()`)
    - type(). Not just for debugging!
    "No more `self.__class__` ... that's a Python 2 habit you should kick"

#### dir

#### type

#### breakpoint

#### vars


### help

If you're in a Python REPL, maybe debugging code (using `breakpoint`), and you'd like to know how a certain object, method, or attribute works, the `help` function is very handy.

Realistically, you'll likely resort to getting help from your favorite search engine more often than you use the `help` function.
But if you're already in a Python REPL, it's quicker to call `help(list.insert)` (if you've forgotten the order of the arguments for the `insert` method) than it is to find the answer in Google.


## Learn it later

There are quite a few built-in functions you'll likely want *eventually*, but you may not need *right now*.

I'm going to mention 13 more built-in functions which are handy to know about, but not worth learning until you actually need to use them.

### open

Need to open a file in Python?
You need the `open` function!

Don't work with files directly because you do everything with databases?
You likely don't need the `open` function.

Most Python programmers will at some point read from or write to a file using the built-in `open` function.
At that point (which you're likely already at), you'll learn about `open`.
Until then, don't worry about it.

By the way, you might want to [look into pathlib][pathlib] (which is in the Python standard library) as an alternative to using `open`.
I love the `pathlib` module so much I've considered teaching files in Python by mentioning `pathlib` first and the built-in `open` function later.


### input

The `input` function prompts the user for input, waits for them to hit the Enter key, and then returns the text they typed.

Reading from [standard input][] (which is what the `input` function does) is one way to get inputs into your Python program, but there are so many other ways too!
You could accept command-line arguments, read from a configuration file, read from a database, and much more.

You'll learn this once you need to prompt the user of a command-line program for input.
Until then, you won't need it.
And if you've been writing Python for a while and don't know about this function, you may simply never need it.


### repr

Need the programmer-readable representation of an object?
You need the `repr` function.

For many objects, the `str` and `repr` representations are the same:

```python
>>> str(4), repr(4)
('4', '4')
>>> str([]), repr([])
('[]', '[]')
```

But for some objects, they're different:

```python
>>> str('hello'), repr("hello")
('hello', "'hello'")
>>> from datetime import date
>>> str(date(2020, 1, 1)), repr(date(2020, 1, 1))
('2020-01-01', 'datetime.date(2020, 1, 1)')
```

The string representation we see at the Python REPL uses `repr`, while the `print` function relies on `str`:

```python
>>> date(2020, 1, 1)
datetime.date(2020, 1, 1)
>>> "hello!"
'hello!'
>>> print(date(2020, 1, 1))
2020-01-01
>>> print("hello!")
hello!
```

You'll see `repr` used when logging, handling exceptions, and implementing dunder methods.


### super

If you create classes in Python, you'll likely need to use `super`.
The `super` function is pretty much essential whenever you're inheriting from another Python class.

Many Python users rarely create classes.
Creating classes isn't an *essential* part of Python, though many types of programming require it.
For example, you can't really use the [Django][] web framework without creating classes.

If you don't already know about `super`, you'll end up learning this if and when you need it.


### property

The `property` function is a decorator (and also a descriptor) and it'll likely seem somewhat magical when you first learn about it.

This decorator allows us to create an attribute which will always seem to contain the return value of a particular function call.
It's easiest to understand with an example.

Here's a class that uses `property`:

```python
class Circle:
    def __init__(self, radius=1):
        self.radius = radius
    @property
    def diameter(self):
        return self.radius * 2
```

Here's an access of that `diameter` attribute on a `Circle` object:

```python
>>> circle = Circle()
>>> circle.diameter
2
>>> circle.radius = 5
>>> circle.diameter
10
```

If you're doing object-oriented Python programming (you're making classes a whole bunch), you'll likely want to learn about `property` at some point.
We use properties instead of getter methods and setter methods.


### issubclass and isinstance

The `issubclass` function checks whether a class is a subclass of one or more other classes.

```python
>>> issubclass(int, bool)
False
>>> issubclass(bool, int)
True
>>> issubclass(bool, object)
True
```

The `isinstance` function checks whether an object is an instance of one or more classes.

```python
>>> isinstance(True, str)
False
>>> isinstance(True, bool)
True
>>> isinstance(True, int)
True
>>> isinstance(True, object)
True
```

You can think of `isinstance` as delegating to `issubclass`:

```python
>>> issubclass(type(True), str)
False
>>> issubclass(type(True), bool)
True
>>> issubclass(type(True), int)
True
>>> issubclass(type(True), object)
True
```

If you're [overloading operators][] you might need to use `isinstance`, but in general we try to avoid strong type checking in Python so we don't see these much.

In Python we usually prefer duck typing over type checking.
These functions actually do a bit more than the strong type checking I noted above ([the behavior of both can be customized][subclasscheck]) so it's actually possible to practice a sort of `isinstance`-powered duck typing with abstract base classes like [collections.abc.Iterable][].
But this isn't seen much either (partly because we tend to practice exception-handling and [EAFP][] a bit more than condition-checking and [LBYL][] in Python).

The last two paragraphs were filled with confusing jargon that I may explain more thoroughly in a future serious of articles if there's enough interest.


### hasattr, getattr, setattr, and delattr

Need to work with an attribute on an object but the attribute name is dynamic?
You need `hasattr`, `getattr`, `setattr`, and `delattr`.

Say we have some `thing` object we want to check for a particular value on:

```python
>>> class Thing: pass
...
>>> thing = Thing()
```

The `hasattr` function allows us to check whether the object *has* a certain attribute:

```python
>>> hasattr(thing, 'x')
False
>>> thing.x = 4
>>> hasattr(thing, 'x')
True
```

The `getattr` function allows us to retrieve the value of that attribute:

```python
>>> getattr(thing, 'x')
4
```

The `setattr` function allows for setting the value:

```python
>>> setattr(thing, 'x', 5)
>>> thing.x
5
```

And `delattr` deletes the attribute:

```python
>>> delattr(thing, 'x')
>>> thing.x
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'Thing' object has no attribute 'x'
```

These functions allow for a specific flavor of [metaprogramming][] and you likely won't see them often.


### classmethod and staticmethod

The `classmethod` and `staticmethod` decorators are somewhat magical in the same way the `property` decorator is somewhat magical.

If you have a method that should be callable on either an instance or a class, you want the `classmethod` decorator.
Factory methods (alternative constructors) are a common use case for this:

TODO

It's a bit harder to come up with a good use for `staticmethod`, since you can pretty much always use a module-level function instead of a static method.

TODO

I find that learning these causes folks to *think* they need them when they often don't.
You can go looking for these if you really need them eventually.


### next

The `next` function returns the *next* item in an iterator.

I've written about iterators before ([how for loops work][] and [how to make an iterator][]) but a very quick summary of iterators you'll likely run into includes:

- `enumerate` objects
- `zip` objects
- the return value of the `reversed` function
- files (the thing you get back from the `open` function)
- `csv.reader` objects
- generator expressions
- generator functions

You can think of `next` as a way to manually loop over an iterator to get a single item and then break.

```python
>>> numbers = [2, 1, 3, 4, 7, 11]
>>> squares = (n**2 for n in numbers)
>>> next(squares)
4
>>> for n in squares:
...     break
...
>>> n
1
>>> next(squares)
9
```


## Maybe learn it eventually

We've already covered nearly half of the built-in functions.

The rest of Python's built-in functions definitely aren't useless, but they're a bit more special-purposed.

For the sake of space, I'm going to dedicate at most one bullet point to each of the rest of the built-ins.

- `iter`: get an iterator from an iterable: this function [powers `for` loops][how for loops work] and it can be very useful when you're making helper functions for looping lazily
- `callable`: return `True` if the argument is a callable (I talked about this a bit in my article [functions and callables][])
- `filter` and `map`: as I discuss in my article on [overusing lambda functions][], I recommend using generator expressions over the built-in `map` and `filter` functions
- `id`, `locals`, and `globals`: these are great tools for teaching Python and you may have already seen them, but you won't see these much in real Python code
- `round`: you'll look this up if you need to round a number
- `divmod`: this function does a floor division (`//`) and a modulo operation (`%`) at the same time
- `bin`, `oct`, and `hex`: if you need to display a number as a string in binary, octal, or hexadecimal form, you'll want these functions
- `abs`: when you need the absolute value of a number, you'll look this up
- `hash`: dictionaries and sets rely on the `hash` function, but you likely won't need it unless you're implementing a clever de-duplication algorithm
- `object`: this function is useful for making [unique default values and sentinel values][sentinel values], if you ever need those

You're unlikely to need all the above built-ins, but if you write Python code for long enough you're likely to see nearly all of them.


## You likely don't need these

You're unlikely to need these built-ins.
There are sometimes really appropriate uses for a few of these, but you'll likely be able to get away with never learning about these.

- `ord` and `chr`: these are fun for teaching ASCII tables and unicode code points, but I've never really found a use for them in my own code
- `compile`: 
- `exec` and `eval`
- `slice`: if you're implementing `__getitem__` to make a custom sequence, you may need this (some [Python Morsels][] exercises require this actually), but unless you make your own custom sequence you'll likely never see `slice`
- `bytes`, `bytearray`, and `memoryview`: if you're working with bytes often, you'll reach for some of these.  Until then, you can mostly ignore them.
- `ascii`: like `repr` but returns an ASCII-only representation of an object; I haven't needed this in my code yet
- `frozenset`: like `set`, but it's immutable; neat but not something I've reached for in my own code
- `__import__`: this function isn't really meant to be used by you, use [importlib][] instead.
- `format`: this calls the `__format__` method, which is used for string formatting; you usually don't need to call this function directly
- `pow`: the exponentiation operator (`**`) usually supplants this... unless you're doing modulo-math (maybe you're implementing [RSA encryption][] from scratch...?)
- `complex`: if you didn't know that `4j+3` is valid Python code, you likely don't need the `complex` function


## There's always more to learn


[built-in functions page]: https://docs.python.org/3/library/functions.html
[standard library]: https://docs.python.org/3/library/index.html
[RSA encryption]: http://code.activestate.com/recipes/578838-rsa-a-simple-and-easy-to-read-implementation/
[hello world]: https://en.wikipedia.org/wiki/Hello_world_program
[keyword arguments]: https://treyhunner.com/2018/04/keyword-arguments-in-python/
[functions and callables]: https://treyhunner.com/2019/04/is-it-a-class-or-a-function-its-a-callable/
[overusing comprehensions]: https://treyhunner.com/2019/03/abusing-and-overusing-list-comprehensions-in-python/
[asterisks]: https://treyhunner.com/2018/10/asterisks-in-python-what-they-are-and-how-to-use-them/
[xrange]: https://treyhunner.com/2018/02/python-3-s-range-better-than-python-2-s-xrange/
[list comprehension]: https://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[looping with indexes]: https://treyhunner.com/2016/04/how-to-loop-with-indexes-in-python/
[make iterators]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[loop better]: https://youtu.be/JYuE8ZiDPl4
[comprehensible comprehensions]: https://youtu.be/5_cJIcgM7rw
[comprehensions tutorial]: https://pycon2018.trey.io
[deep ordering]: https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/
[any-all article]: https://treyhunner.com/2016/11/check-whether-all-items-match-a-condition-in-python/
[pathlib]: https://treyhunner.com/2018/12/why-you-should-be-using-pathlib/
[django]: https://djangoproject.com/
[subclasscheck]: https://docs.python.org/3/reference/datamodel.html#customizing-instance-and-subclass-checks
[overloading operators]: https://docs.python.org/3/library/numbers.html#implementing-the-arithmetic-operations
[collections.abc.Iterable]: https://docs.python.org/3/library/collections.abc.html#collections.abc.Iterable
[eafp]: https://docs.python.org/3/glossary.html#term-eafp
[lbyl]: https://docs.python.org/3/glossary.html#term-lbyl
[metaprogramming]: https://en.wikipedia.org/wiki/Metaprogramming
[how for loops work]: https://treyhunner.com/2016/12/python-iterator-protocol-how-for-loops-work/
[overusing lambda functions]: https://treyhunner.com/2018/09/stop-writing-lambda-expressions/
[sentinel values]: https://treyhunner.com/2019/03/unique-and-sentinel-values-in-python/
[importlib]: https://docs.python.org/3/library/importlib.html#importlib.import_module
