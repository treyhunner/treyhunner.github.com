---
layout: post
title: "Python dunder methods to know"
date: 2021-10-29 07:08:46 -0700
comments: true
categories: 
---

You've just made a class.
You made a `__init__` method.
Now what?

What dunder methods could (and should) you add to your class to make it friendly for other Python programmers who use it?


### `__init__`: the initializer method

Does your class need to accept function arguments?
You'll need a `__init__` method.
In fact, you probably already *have* a `__init__` method!

Python's `__init__` method is called **the initializer method**.
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

Python's built-in `repr` function calls the `__repr__` dunder method:

TODO

The default string representation (defined on `object`, which is the base class of all classes) looks like this:

```pycon
TODO
```

That's not very helpful.

It's a common practice to write a string representation that represents the Python code you could type out to re-create a copy of your object.

For a `Point` class that accepts three coordinates:

TODO

A nice string representation might look like this:

TODO

But this isn't the *only* practice.
Sometimes Python programmers put some helpful information about their class instances in angular brackets (to make it stand out but also make it clear that it's not Python).

TODO

Whatever practice you choose, make sure every class you make has a nice string representation.
Pop open a Python REPL and try it out to make sure it looks nice because it can be easy to make typos while constructing a friendly `__repr__` method.


### `__eq__`: comparing two objects with equality

The next dunder method I always recommend is `__eq__`.
The `__eq__` method allows us to override what happens when our class instances compare themselves to other objects.

Taking our `Point` class from before, an equality method might look like this:

TODO

So we can now two `Point` objects to each other:

TODO

Note that we're assuming the other argument given to our `__eq__` method is another `Point` object.
That's a problem!

If we compare a `Point` object to a non-point we'll get an error:

TODO

The most common way to fix this is to add a sort of "guard" to our `__eq__` method to let Python know that `Point` objects only know how to compare themselves to other `Point` objects:

TODO

You might think "well couldn't we just return `False` for non-points"?

TODO

We *could*, but then no one could ever implement equality between our `Point` objects and another object type.
In dunder method land (in most dunder methods at least), if we don't know what to do re are supposed to return `NotImplemented`.

For example take a look at how integers and floating point numbers work with equality:

TODO

TODO talk about how the default equality method checks identity

TODO also more in this section


### `__str__`: the human readable string representation

Most Python objects only need **one string representation**: `__repr__`.
The `__repr__` method makes the string representation for other Python programmers.
But there's another string representation we *could* make on our objects.

Python's `__str__` method defines what happens when you call the built-in `str` on an object:

```pycon
TODO str on a list
```

But wait... `str` works on our `Point` objects already!

```pycon
TODO
```

Why is that?

Well, all classes in Python inherit from the `object` class (the default base class) by default.
And the `object` class has a `__str__` method which just calls `__repr__`:

```pycon
TODO show Point.__str__ and show calling Point.__str__
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

- String formatting
- Ordering
- Iteration
- Various container methods
- Context manager methods
- Arithmetic
- Type conversion
    - Includes familiar things like truthiness (`__bool__`) and `__str__`
    - `__int__`, `__bytes__`, `__bool__`
    - etc.?
- Boolean/set arithmetic
- Callability
- Constuction/destruction (rare)
- Metaprogramming: `__init_subclass__`, `__instancecheck__`, etc
- Iterator methods (rare)
- Dunder attributes you won't define (`__name__`, `__code__`, `__doc__`, etc.)

https://docs.python.org/3/reference/datamodel.html


[pdb]: TODO
[repl]: TODO
