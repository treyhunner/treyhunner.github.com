---
layout: post
title: "Python dunder methods to know"
date: 2021-10-29 07:08:46 -0700
comments: true
categories: python
---

You've just made a class.
You made a `__init__` method.
Now what?

What dunder methods could (and should) you add to your class to make it friendly for other Python programmers who use it?


### `__init__`: the initializer method

Does your class need to accept function arguments?
You'll need a `__init__` method.
In fact, you probably already *have* a `__init__` method!

This class uses its `__init__` method to accept 3 arguments:

```python
class Point:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z
```

Without that `__init__` method this code would give an error (because the default `__init__` accepts no arguments):

```pycon
>>> p = Point(1, 2, 3)
```

Python's `__init__` method is called **the [initializer][] method**.
Other programming languages often call their equivalent class-creation method **the constructor method**.
In Python, our class instance is **already constructed** by the time the initializer is called: `__init__`, like all methods, accepts `self` and that's our class instance.
We have a different method we call the constructor (`__new__`) and we pretty much never use it.

When *don't* you need a `__init__` method?
If you're inheriting from another class and that class has an initializer, you might not need a `__init__` method.
If you're not changing the arguments you accept and you don't need to perform any additional initialization after each instance of your class is created, you might be able to skip `__init__` when inheriting.
In general though, you'll *almost always* want a `__init__` method in your class.


### `__repr__`: the programmer-readable string representation

Your class should be *easy to work with*.
If someone is playing with your class in [the Python REPL][] or inside a [Python debugger][pdb] session, it would be helpful if your class had a friendly string representation.

The default string representation for an object at the Python REPL is controlled by the built-in `repr` function:

```pycon
>>> numbers = [2, 1, 3, 4]
>>> numbers
[2, 1, 3, 4]
>>> repr(numbers)
[2, 1, 3, 4]
```

Python's built-in `repr` function calls the `__repr__` dunder method on the object it's given:

```pycon
>>> numbers.__repr__()
'[2, 1, 3, 4]'
```

All Python objects inherit from the `object` class and the object class defines a default `__repr__` implementation that says the object type and it's unique `id` (as a hexadecimal number):

```pycon
>>> object.__repr__(numbers)
'<list object at 0x7fb9efb6bf00>'
```

Any object that doesn't define its own string representation will use this default.
For example the built-in `zip` class doesn't define its own `__repr__` method:

```pycon
>>> zip()
<zip object at 0x7fb9efb72240>
```

That default string representation isn't very helpful.
It's a common practice to write a string representation that represents the Python code you could type out to re-create a copy of your object.

For a `Point` class that accepts three coordinates:

```pycon
>>> p = Point(1, 2, 3)
```

A nice string representation might look like this:

```pycon
>>> p
Point(1, 2, 3)
```

Here's a `Point` class with a `__repr__` method that returns the above string representation:

```python
class Point:

    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self):
        return f"Point({self.x}, {self.y}, {self.z})"
```

This code-like string representation is a common practice, but it isn't the *only* practice.
Sometimes Python programmers put some helpful information about their class instances in angular brackets (to make it stand out but also make it clear that it's not Python).

For example Django `Model` class uses angle brackets in its default string representation:

```pycon
>>> user = User.objects.get(username='trey')
>>> user
<User: trey>
```

Whatever practice you choose, make sure every class you make has a nice string representation.
Pop open a Python REPL and try it out to make sure it looks nice because it can be easy to make typos while constructing a friendly `__repr__` method.


### `__eq__`: comparing two objects with equality

The next dunder method I always recommend is `__eq__`.
The `__eq__` method allows us to override what happens when our class instances compare themselves to other objects.

Taking our `Point` class from before, an equality method might look like this:

```python
    def __eq__(self, other):
        return (self.x, self.y, self.z) == (other.x, other.y, other.z)
```

So we can now two `Point` objects to each other:

```pycon
>>> a = Point(1, 2, 3)
>>> b = Point(1, 2, 3)
>>> a == b
True
>>> b.z = 9
>>> a == b
True
```

Note that we're assuming the other argument given to our `__eq__` method is another `Point` object.
That's a problem!

If we compare a `Point` object to a non-point we'll get an error:

```pycon
>>> a == 4
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 9, in __eq__
AttributeError: 'int' object has no attribute 'x'
```

The most common way to fix this is to add a sort of "guard" to our `__eq__` method to let Python know that `Point` objects only know how to compare themselves to other `Point` objects:

```python
    def __eq__(self, other):
        if not isinstance(other, Point):
            return NotImplemented
        return (self.x, self.y, self.z) == (other.x, other.y, other.z)
```

Note that we're returning `NotImplemented` and not `False`.
But when Python sees `NotImplemented` it will return `False` *for* us:

```pycon
>>> a == 4
False
```

You might think "well couldn't we just return `False` for non-points"?
We *could*, but then no one could ever implement equality between our `Point` objects and another object type.
In dunder method land (in most dunder methods at least), if we don't know what to do re are supposed to return `NotImplemented`.

For example take a look at how integers and floating point numbers work with equality:

```pycon
>>> a = 2
>>> b = 2.0
>>> a.__eq__(b)
NotImplemented
```

In Python, `int` objects don't know how to compare themselves to `float` objects.
But `float` objects *do* know how to compare themselves to `int` objects, so equality works as expected:

```pycon
>>> b.__eq__(a)
True
>>> a == b
True
```

When Python gets `NotImplemented` from a `__eq__` check, it knows that it should delegate to the other object to see whether it knows how to do the equality check.
If it doesn't, Python returns `False`.

Note that all objects *do* support equality checks by default, but they only compare as equal if they're identity (more on [identity and equality here][identity]).


### `__str__`: the human readable string representation

Most Python objects only need **one string representation**: `__repr__`.
The `__repr__` method makes the string representation for other Python programmers.
But there's another string representation we *could* make on our objects.

Python's `__str__` method defines what happens when you call the built-in `str` on an object:

```pycon
>>> numbers = [2, 1, 3, 4]
>>> str(numbers)
'[2, 1, 3, 4]'
```

But wait... `str` works on our `Point` objects already!

```pycon
>>> p = Point(1, 2, 3)
>>> str(p)
'Point(1, 2, 3)'
```

Why is that?

Well, all classes in Python inherit from the `object` class (the default base class) by default.
And the `object` class has a `__str__` method which just calls `__repr__`, so our `Point` class also has the same default `__str__` method:

```pycon
>>> Point.__str__
<slot wrapper '__str__' of 'object' objects>
>>> Point.__str__(p)
'Point(1, 2, 3)'
```

Python's `__str__` method defines the **human readable** string representation of our objects.
But most objects **don't define a human readable string representation**.

Lists, dictionaries, tuples, sets, and integers all have just one string representation:

TODO

The only Python built-in classes I frequently encounter with two string representations are strings and various objects in the `datetime` module:

TODO show str, datetime stuff, and other things (research)

Unless you'd really like to have a different string representation for printing your objects than for debugging your objects at the Python REPL, you probably don't need a `__str__` method.
A notable exception to this is Django.
Django's models define a `__repr__` which calls `__str__` (flipping the usual model on its head).
So when making a Django model you'll often define a `__str__` method but not a `__repr__` method.


### And now for something completely different

This is where things get weird.
At this point, which dunder method(s) we implement next (if any) becomes a bit more of a "choose your own adventure" game.

Here are our options:

- String formatting (shown below)
- Ordering (shown below)
- Iteration (shown below)
- Various container methods (shown below)
- Context manager methods (shown below)
- Callability (shown below)
- Arithmetic (shown below)
- In-place arithmetic (shown below)
- Boolean/set arithmetic
- Type conversion
    - Includes familiar things like truthiness (`__bool__`) and `__str__`
    - Also `__int__`, `__bytes__`, `__bool__`
    - There's no `__list__`, `__tuple__`, or `__set__` because those rely on iteration (you'll need `__iter__` for that)
    - There's no `__dict__` because that relies either on iteration or the presence of a `keys` method and a `__getitem__` method (Python's practicing very fuzzy duck typing here)
    - etc.?
- Constuction/destruction (rare)
- Metaprogramming: `__init_subclass__`, `__instancecheck__`, etc
- Iterator methods (rare)
- There are also dunder attributes you won't define (`__name__`, `__code__`, `__doc__`, `__class__`, `__bases__`, `__mro__`, etc.)

https://docs.python.org/3/reference/datamodel.html


### String formatting

Have an object that you might want to customize the string representation of on the fly?
You might consider customizing how string formatting works with your objects by making a `__format__` method.

Integers, floating point numbers, and `datetime.datetime` objects all allow for custom string formatting:

TODO show f strings with those objects

When your object is used in string formatting, everything after the `:` is considered a "format specification" and is sent to your object's `__format__` method.

For our `Point` class we could accept an `f` format specification the same way floating point numbers do, to control how many digits are shown after in coordinate numbers:

TODO show Point `__format__`

Just like with an `int` or `float`, we can now specify `.Nf` on our `Point` objects, where `N` is the number of digits to show after the decimal point:

TODO show Point with .0f and .2f


### Ordering

All objects support equality and inequality (`==` and `!=`), even if they just rely on the default `__eq__` implementation that treats equality the same as identity.
Some objects also support ordering (`<`, `>`, `<=`, `>=`).

The ordering operators are powered by the `__lt__`, `__gt__`, `__le__`, and `__ge__` methods.

**TODO** we need an example besides Point to demonstrate `<` and `>` with other types and the importance of implementing all of these operators


### Iteration

Should your object work with tuple unpacking?
You need your object to be an iterable.

Are you making an object that should work with `for` loop (like a custom data structure)?
You need your object to be an iterable.

From Python's perspective, an iterable is anything that can be passed to the built-in `iter` function to get an iterator from it.
All forms of iteration in Python rely on passing an object to `iter` to get an iterator and then repetedly passing the returned iterator to the built-in `next` function to get the next item from it.
If you're interested in how iterables and iterators, I briefly explain [The Iterator Protocol here][the iterator protocol] and I explain it in more depth in my [Loop Better article][] or [Loop Better talk][].

Here's the basics of iteration:

1. To make your objects iterable you need a `__iter__` method that returns an iterator
2. The [easiest way to make an iterator][make iterator] is with a generator (either a generator function or a generator expression)

Let's add a `__iter__` method to our `Point` class that's implemented as a generator function (using `yield` statements):

TODO `__iter__` that yields the point coordinates

Now we should be able to turn our `Point` objects into tuples:

TODO

Or use them in tuple unpacking:

TODO


### Containers (data structures)

Making a custom data structure?
You'll need a `__len__` method... and probably a bunch of other dunder methods too.

When making a custom data structure (sometimes called a "container" because it's an object that contains other arbittrary objects), there are some methods you'll many dunder methods you'll **almost always want** and even more dunder methods you'll **sometimes want**.

Data structures tend to support length checks with the built-in `len` function.
That relies on the `__len__` method.

TODO

Many data structures also use the `x[...]` notation to support index lookups or key lookups.
That relies on the `__getitem__` method.

TODO

But while `__getitem__` with a missing list index returns an `IndexError`:

TODO numbers.__getitem__(100)

The `__getitem__` method with a missing dictionary key returns a `KeyError`:

TODO

What if you want to support setting items and deleting items?

TODO numbers[1] = 5
TODO del numbers[1]

You'll want to implement `__setitem__` and `__delitem__` too.

You'll almost certainly want your data structure to be iterable, so you'll probably also want a `__iter__` method.

TODO `__reversed__`


### Context managers

Context managers are any object that can be passed to a `with` block.
Context managers are powered by the `__enter__` and `__exit__` methods.

Context managers are can sandwich a block of code within setup code and cleanup code.
They're most often used when cleanup code needs to be executed regardless of whether an exception occurred within the sandwhiched code block.

Here's an example context manager:

```python
class Connection:
    def __init__(self, name):
        self.name = name
    def __enter__(self):
        print("Open")
        return self
    def __exit__(self, cls, exc, tb):
        print("Close")
```

Because that `Connection` object implements `__enter__` and `__exit__` methods, it can now be used in a `with` block:

```pycon
>>> with Connection("Trey") as connection:
...     print("Name:", connection.name)
...
Open
Name: Trey
Close
```

Context managers *must* implement both a `__enter__` and a `__exit__` method.
The `__enter__` method controls what object is captured by the `as` part of the `with` block, so it's most common to return `self` (to pass back the context manager object itself).

See [this Python Morsels topic on context managers][context managers] for more.


### Callability

Anything you can "call" in Python is a callable.
Functions and classes are both callables (you can put parentheses after them to call them).

```pycon
>>> print
<built-in function print>
>>> print('hi')
hi
>>> int
<class 'int'>
>>> int('4')
4
```

All callables implement a `__call__` method.

```pycon
>>> print.__call__
<method-wrapper '__call__' of builtin_function_or_method object at 0x7fb9f153d170>
>>> int.__call__
<method-wrapper '__call__' of type object at 0x561ee02b7780>
```

The `__call__` method is what *makes* an object callable.
So if we could implement a `__call__` method on our own object to make it callable.

If you're interested in callability spend 2 minutes [reading/watching this Python Morsels topic][callable] or [read this longer article on callables][callable article].


### Arithmetic

Have you ever seen objects that act kind of like a number, but *aren't* a number?

For example the `datetime` and `timedelta` from Python's [datetime][] support arithmetic operations.

You can add `timedelta` objects together, subtract them from each other, and multiply them by numbers to scale them up and down:

```pycon
>>> from datetime import timedelta
>>> week = timedelta(days=7)
>>> day = timedelta(days=1)
>>> week + day
datetime.timedelta(days=8)
>>> week - day
datetime.timedelta(days=6)
>>> day * 365
datetime.timedelta(days=365)
```

And you can add and subtract `timedelta` objects from `datetime` objects to shift the `datetime`:

```pycon
>>> from datetime import datetime, timedelta
>>> nye = datetime(2025, 12, 31)
>>> week = timedelta(days=7)
>>> nye + week
datetime.datetime(2026, 1, 7, 0, 0)
>>> nye - week
datetime.datetime(2025, 12, 24, 0, 0)
```

To implement `+`, your object will need a `__add__` method:

```python
class Vector:
    def __init__(self, x, y):
        self.x, self.y = x, y
    def __add__(self, other):
        if not isinstance(other, Vector):
            return NotImplemented
        return Vector(self.x+other.x, self.y+other.y)
```

The `__add__` method should return `NotImplemented` whenever it's given a type of object it doesn't know how to add itself to.

If your objects need to be addable to other types of objects, you'll also need a `__radd__` method.
For example Python's `datetime` objects implement both `__add__` and `__radd__` methods to support addition with `timedelta` objects.

Python's `timedelta` objects don't know how to add themselves to `datetime` objects:

```pycon
>>> from datetime import datetime, timedelta
>>> nye = datetime(2025, 12, 31)
>>> week = timedelta(days=7)
>>> week.__add__(nye)
NotImplemented
```

When Python called `week.__add__(nye)` it got `NotImplemented`, which means that `week` doesn't know how to add itself to `nye`.
So Python attempts a **right-hand addition** on `nye` with `week`:

```pycon
>>> nye.__radd__(week)
datetime.datetime(2026, 1, 7, 0, 0)
```

Calling `__add__` on a `timedelta` with a `datetime` didn't work, but calling `__radd__` on a `datetime` object with a `timedelta` object did work. So both `nye + week` and `week + nye` will work as expected!

The addition operator is usually commutative (meaning `a + b` is the same as `b + a`), but Python doesn't assume that's the case.
So addition, subtraction, multiplication, and division all have support for left-hand operations as well as right-hand operations.

Here's a table showing each arithmetic operation and the dunder method that corresponds to it.

|    Operation   | Left Dunder Method  | Right Dunder Method  |
| -------------- | ------------------- | -------------------- |
|    `a + b`     | `a.__add__(b)`      | `b.__radd__(a)`      |
|    `a - b`     | `a.__sub__(b)`      | `b.__rsub__(a)`      |
|    `a * b`     | `a.__mul__(b)`      | `b.__rmul__(a)`      |
|    `a ** b`    | `a.__pow__(b)`      | `b.__rpow__(a)`      |
|      `-a`      | `a.__neg__()`       | --                   |
|      `+a`      | `a.__pos__()`       | --                   |
|   `a / b`      | `a.__truediv__(b)`  | `b.__rtruediv__(a)`  |
|   `a // b`     | `a.__floordiv__(b)` | `b.__rfloordiv__(a)` |
|    `a % b`     | `a.__mod__(b)`      | `b.__rmod__(a)`      |
| `divmod(a, b)` | `a.__divmod__(b)`   | `b.__rdivmod__(a)`   |
|    `int(a)`    | `a.__int__()`       | --                   |
|   `float(a)`   | `a.__float__()`     | --                   |
|    `abs(a)`    | `a.__abs__()`       | --                   |
|   `floor(a)`   | `a.__floor__()`     | --                   |
|    `ceil(a)`   | `a.__ceil__()`      | --                   |

All of the binary operations above (operations that have two objects instead of just one), have both a left-hand and right-hand support.
If you're implementing one of those operators **only for objects of the same type**, you'll only need to implement the **left dunder method**.
But if you're implementing the operator on objects of different types, you'll need to implement the **right dunder method** as well.

Here's one more example of left and right-hand operations with Python's `int` and `float` types.

```pycon
>>> i = 2
>>> f = 2.5
```

Even though integers don't know how to add themselves to floating point numbers in Python adding an `int` to a `float` still works.
It works because passing a `float` to `int`'s `__add__` method returns `NotImplemented` so Python attempts a right-hand side addition on the `float` instead:

```pycon
>>> i + f
4.5
>>> i.__add__(f)
NotImplemented
>>> f.__radd__(i)
4.5
```

The same thing happens with subtraction between `int` and `float` objects:

```pycon
>>> i - f
-0.5
>>> i.__sub__(f)
NotImplemented
>>> f.__rsub__(i)
-0.5
```

And with multiplication and division too:

```pycon
>>> i * f
5.0
>>> i.__mul__(f)
NotImplemented
>>> f.__rmul__(i)
5.0
>>> i / f
0.8
>>> i.__truediv__(f)
NotImplemented
>>> f.__rtruediv__(i)
0.8
```


### In-place arithmetic operators

Python has many **augmented assignment operators** (`+=`, `-=`, `*=` etc).
These are often called **in-place** operators because they're meant to operate on an object in-place.

Using the `+=` operator in a list will call the `__iadd__` method on that list:

```pycon
>>> numbers = [2, 1, 3, 4]
>>> numbers += [7, 11, 18]
>>> numbers
[2, 1, 3, 4, 7, 11, 18]
>>> numbers.__iadd__([29, 47, 76])
>>> numbers
[2, 1, 3, 4, 7, 11, 18, 29, 47, 76]
```

The `__iadd__` method mutates the list *and* returns the same list.
You can think of the list `__iadd__` method as equivalent to this:

```python
    def __iadd__(self, iterable):
        self.extend(iterable)
        return self
```

If you're making an immutable object (on an object that's meant to be immutable), you don't need to implement any in-place addition operators because Python will automatically fallback to the non-in-place operator along with an assignment instead.

For example with tuples and strings, `+=` is the same as `+` followed by `=`:

```pycon
TODO show tuple identity changing but list identity being the same?
```

- `__iadd__`
- `__isub__`
- `__imul__`
- `__itruediv__`
- `__itruediv__`
- `__ifloordiv__`
- `__imod__`
- `__ipow__`
- `__ipow__`


### Bitwise arithmetic / set operations

TODO


### Type conversions

TODO


### Everything else

TODO


[pdb]: TODO
[repl]: TODO
[how to make an iterator]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[the iterator protocol]: https://treyhunner.com/2016/12/python-iterator-protocol-how-for-loops-work/#Iterables:_what_are_they?
[loop better article]: https://treyhunner.com/2019/06/loop-better-a-deeper-look-at-iteration-in-python/
[loop better talk]: https://youtu.be/JYuE8ZiDPl4
[make iterator]: https://treyhunner.com/2018/06/how-to-make-an-iterator-in-python/
[identity]: https://www.pythonmorsels.com/topics/equality-vs-identity/
[initializer]: https://www.pythonmorsels.com/topics/what-is-init/
[callable]: https://www.pythonmorsels.com/topics/callables/
[callable article]: https://treyhunner.com/2019/04/is-it-a-class-or-a-function-its-a-callable/
[context managers]: https://www.pythonmorsels.com/topics/context-managers/
[datetime]: https://docs.python.org/3/library/datetime.html
