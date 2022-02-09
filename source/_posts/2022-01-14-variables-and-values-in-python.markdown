---
layout: post
title: "Variables and Values in Python"
date: 2022-01-14 06:31:57 -0800
comments: true
categories: python
---

In Python, variables and data structures **don't contain objects**.
This fact is easy to miss when new to Python and it can be tricky to internalize.

Let's talk about a concept that's both crucial to understanding Python's model of the world *and* very commonly common overlooked when learning (and teaching) Python.

## Definitions

"Value" and "object" are synonyms in this thread.
These terms refer to *things*: lists, dictionaries, strings, numbers, tuples, and even functions and modules (I often say [everything is an object in Python][]).

"Variable" and "name" are also synonyms.
These terms refer to the names we use to refer to objects.

"Pointer" is a Computer Science term that represents the connection between variables and values.
This term is complex in some programming languages, but fairly simple in Python (by comparison at least).
We define this below.


## Python's variables are pointers, not buckets

Variables in Python are not buckets containing things; they're **pointers** (they *point* to values).

That word "pointer" may sound scary (it is both scarier and more complex in C and C++), but it mostly means what it sounds like.
You can think of variables as living in variable land and values as living in value land and an arrow connects each variable to each value.

{% img "no-radius full-width" /images/variable-diagram-different-values.svg %}

Note that 2 variables can even point to the same value.

{% img "no-radius full-width" /images/variable-diagram-same-value.svg %}

But only one arrow comes out of each variable (and there must be an arrow because each variable always has a value).


## Assignments point a variable to a value

Assignment statements point a variable to a value.
That's it.

So assigning one name to another name is an odd thing to do:

```pycon
>>> numbers = [2, 1, 3, 4, 7]
>>> plus_another = numbers
```

Python doesn't copy anything when we make an assignment.
So all we've done is point two names to **the same value**.

If two variables point to the same value and we *change* that value, look at what happens:

```pycon
>>> y = [2, 1]
>>> x = y
>>> x.pop()
1
>>> y
[2]
```

Our two variables (`numbers` and `plus_another`) still point to the same single object, but we've *changed* that object and both variables seem to "see" that change.
Note that **we didn't change either of our variables**: we've only changed the object that these two variables both point to.


## The 2 types of "change" in Python

The word "change" is often ambiguous in Python.
The phrase "when we changed x" could mean two different things.

The 2 distinct types of change we have in Python are:

1. **Assignments**: an assignment changes a variable (specifically which object a variable points to)
2. **Mutations**: mutations change an object (which may be pointed to by any number of variables)

**Mutations change objects**, not variables.
But variables *point to* objects.
So if another variable points to an object that we've just mutated it will reflect the same change; not because the variable changed but because **the object it happens to point to** has changed.


## Other mental models tend to be more complex or erroneous

Remember when I said that word "pointer" is scary?
It's scary because in necessitates a *distinction* between variables and objects.
Variables point to objects and we change one independent of the other.

To avoid thinking in terms of pointers or references (or whatever other term you can think of to describe the separation between variables and object), sometimes Python educators will try to (overly) simplify this mental model.

Some folks try to form a mental model that avoids this distinction between variables and objects.
I call this less accurate mental model the **as-if mental model**.
It goes something like this: <q>When an object changes it's "as if" each variable that points to it changed.</q>

I said **this mental model isn't accurrate**.
But what's the problem with it?

Well, this as-if mental model breaks down for assignment statements.

Let's say `numbers` and `other_numbers` point to the same list:

```pycon
>>> numbers = [2, 1, 3]
>>> other_numbers = numbers
```

And then we assign to the `numbers` variable:

```pycon
>>> numbers = [9, 8, 7]
```

Our `numbers` variable changed but `other_numbers` didn't change:

```pycon
>>> numbers
[9, 8, 7]
>>> other_numbers
[2, 1, 3]
```

The `numbers` and `other_numbers` variables both pointed to the same object before.
If we had mutated that object, they both would have "seen" that change (because the object they both point to changed), just as with `numbers` and `plus_another` before.

But **we didn't mutate any objects here**.
Instead we reassigned `numbers`, pointing it to a *new* object.
We changed which object `numbers` pointed to, which doesn't affect `other_numbers` at all.

Our as-if mental model attempts to remove the separation between variables and objects.
But that separation is *essential* to understanding how Python's variables and values actually work.


## Identity and equality exist because variables are pointers

Python's `==` operator checks that two objects **represent the same data**:

```pycon
>>> my_numbers = [2, 1, 3, 4]
>>> your_numbers = [2, 1, 3, 4]
>>> my_numbers == your_numbers
True
```

The `my_numbers` and `your_numbers` variables point to lists that have the same number of objects and each object in the same relative position is equal (represents the same data) to the other.

If we modified one of these two lists, they wouldn't be equal anymore:

```pycon
>>> my_numbers[0] = 7
>>> my_numbers == your_numbers
False
```

Python's `is` operator checks whether two objects **are the same object**:

```pycon
>>> my_numbers = [2, 1, 3, 4]
>>> your_numbers = [2, 1, 3, 4]
>>> my_numbers_again = my_numbers
>>> my_numbers is your_numbers
False
>>> my_numbers is my_numbers_again
True
```

The `my_numbers` variable and the `my_numbers_again` variable **point to the same object**.
Changing one object will change the other (because the two objects are one in the same):

```pycon
>>> my_numbers_again.append(7)
>>> my_numbers_again
[2, 1, 3, 4, 7]
>>> my_numbers
[2, 1, 3, 4, 7]
```

But the `your_numbers` variable points to a different object (the `is` operator returned `False` when comparing it to `my_numbers`), so that object didn't change:

```pycon
>>> your_numbers
[2, 1, 3, 4]
```

The `is` operator checks for **identity** and the `==` operator checks for **equality**.
In Python equality checks are very common and identity checks are very rare.

Another way to check identity is by comparing the `id` of an object:

```pycon
>>> id(my_numbers)
140418754598848
>>> id(your_numbers)
140418754532352
>>> id(my_numbers_again)
140418754598848
```

The `my_numbers` and `my_numbers_again` variables above point to objects that have the same `id`, which means they point to the same object.

This distinction between identity and equality exists because variables **don't contain objects**, they **point to objects**.


## Data structures contain pointers

Like variables, data structures also **do not contain objects**.
Data structures **contain pointers to objects**.

Let's say we make a list-of-lists:

```pycon
>>> matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
```

And then we make a variable that points to the second list in our list-of-lists:

```pycon
>>> row = matrix[1]
>>> row
[4, 5, 6]
```

If we mutate this list object, we'll see it change in both places:

```pycon
>>> row[0] = 1000
>>> row
[1000, 5, 6]
>>> matrix
[[1, 2, 3], [1000, 5, 6], [7, 8, 9]]
```

Index `1` in our `matrix` list **points to the same object** as the `row` variable:

```pycon
>>> [id(x) for x in matrix]
[140418754597888, 140418754594240, 140418754576448]
>>> id(row)
140418754594240
>>> matrix[1] is row
True
```

The `id` of second object (index `1`) in our `matrix` list is the same as the `id` of `row` and the `is` operator tells us that they are identical (they're literally *the same object*).

Here's a visual diagram showing this deceptively complex relationship.

{% img "no-radius full-width" /images/data-structures-diagram.svg %}

Not only can a data structure and a variable point to the same object.
Two data structures can point to the same object:

```pycon
>>> second_matrix = [matrix[0], [7, 8, 9], [10, 11, 12]]
>>> second_matrix
[[1, 2, 3], [7, 8, 9], [10, 11, 12]]
>>> second_matrix[0] is matrix[0]
True
```

The first row in `matrix` is the same object as the first row in `second_matrix`.

So changing one changes the other:

```pycon
>>> second_matrix[0][0] = 0
>>> second_matrix
[[0, 2, 3], [7, 8, 9], [10, 11, 12]]
>>> matrix
[[0, 2, 3], [1000, 5, 6], [7, 8, 9]]
```

Note that even though the second item in `second_matrix` looks like the third item in `matrix`, the two are not identical, so changing one doesn't change the other:

```pycon
>>> second_matrix[1][0] = 100
>>> second_matrix
[[0, 2, 3], [100, 8, 9], [10, 11, 12]]
>>> matrix
[[0, 2, 3], [1000, 5, 6], [7, 8, 9]]
```

The two rows were equal but not identical: they represented the same data but were different objects.


## Function arguments act like assignment statements

Variables are pointers and data structures contain pointers.
But what about function arguments?

Function arguments work basically the same way as assignment statements.
The Python documentation distinguishes between [arguments][] (the objects passed-in to a function) and [parameters][] (the names within a function definition that will refer to the passed arguments).

Parameters are just local variables and arguments are just values.
Meaning if you mutate an object that's passed into your function, you've mutated the original object passed-in by the caller.
But if you reassign a parameter name (the name that points to an argument) to a different object, the passed-in object doesn't change (you've changed a variable, not a value).

When defining a function, your guiding rule for arguments should be: **don't mutate the arguments** that are passed into your function unless the function caller expects you to.

If you're writing a function that's meant to mutate a given list, mutate.
If you're not, make sure you don't mutate that list!

Also note that each default value is defined once and [shared between all function calls][shared defaults].
So avoid using mutable default values and use them very carefully if/when you do.


## Copies are shallow and that's usually okay

Need to copy a list in Python?

```pycon
>>> numbers = [2000, 1000, 3000]
```

You could call the `copy` method (if you're certain you have a list and not some other iterable):

```pycon
>>> my_numbers = numbers.copy()
```

Or you could slice the list (if you're comfortable with hard-to-read code...):

```pycon
>>> my_numbers = numbers[:]
```

Or you could pass it to the `list` constructor (this works on **any iterable**, not just on lists):

```pycon
>>> my_numbers = list(numbers)
```

All of these techniques make a new list which **points to the same objects** as the original list.

The two lists are distinct, but the objects within them are the same:

```pycon
>>> numbers is my_numbers
False
>>> numbers[0] is my_numbers[0]
True
```

Integers are immutable in Python (as are floating point numbers and strings), so we don't really care that are objects are the same above.
But occasionally we might care.

If we pass a list-of-lists to the `list` constructor, Python will copy 3 pointers to 3 lists to make a new list:

```pycon
>>> matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
>>> new_matrix = list(matrix)
```

Our two lists aren't the same, but each item within them is the same:

```pycon
>>> matrix is new_matrix
False
>>> matrix[0] is new_matrix[0]
True
```

So if we mutate the first row in one, it'll mutate the same object within the other:

```pycon
>>> matrix[0].append(100)
>>> matrix
[[1, 2, 3, 100], [4, 5, 6], [7, 8, 9]]
>>> new_matrix
[[1, 2, 3, 100], [4, 5, 6], [7, 8, 9]]
```

When you copy an object in Python, if that object **points to other objects**, you'll copy pointers to those other objects instead of copying the objects themselves.

New Python programmers sometimes see this behavior and decide to start sprinkling `copy.deepcopy` into their code.
The `deepcopy` function attempts to recursively copy the object given to it as well as every object it points to (and the objects those point to and so on).

```python
from copy import deepcopy
from datetime import datetime

tweet_data = [
    {
        "created_at": "Tue Feb 04 00:51:01 +0000 2014",
        "full_text": "I finally decided it was time to get my own Twitter account.",
    },
    {
        "created_at": "Wed Apr 16 06:05:52 +0000 2014",
        "full_text": 'OH: "Mallic acid? They just made that word up" #pycon2014',
    },
]

def parse_time(string):
    return datetime.strptime(string, "%a %b %d %H:%M:%S %z %Y")

# Parse date strings into datetime objects
processed_data = deepcopy(tweet_data)
for tweet in processed_data:
    tweet["created_at"] = parse_time(tweet["created_at"])
```

While `deepcopy` works, there's usually a simpler approach that most Python programmers take: **don't mutate an object that doesn't belong to you**.

Instead of changing an object you were given, you could make new objects that contain the data you'd like:

```python
from datetime import datetime

tweet_data = [
    {
        "created_at": "Tue Feb 04 00:51:01 +0000 2014",
        "full_text": "I finally decided it was time to get my own Twitter account.",
    },
    {
        "created_at": "Wed Apr 16 06:05:52 +0000 2014",
        "full_text": 'OH: "Mallic acid? They just made that word up" #pycon2014',
    },
]

def parse_time(string):
    return datetime.strptime(string, "%a %b %d %H:%M:%S %z %Y")

# Parse date strings into datetime objects
processed_data = [
    {**tweet, "created_at": parse_time(tweet["created_at"])}
    for tweet in tweet_data
]
```

The `deepcopy` function has its uses, but it's often unnecessary.


## Summary

Variables in Python are not buckets containing things; they're **pointers** (they *point* to values).

Python's model of variables and values boils down to two primary rules:

1. **Mutation** changes an object
2. **Assignment** points a variable to a value

As well as these corollary rules:

1. **Reassigning** a variable points the variable **to a different object**, leaving the original object unchanged
2. **Assignments don't copy** anything, so it's up to you to copy objects as needed

Furthermore, data structures work the same way: lists and dictionaries container **pointers to objects** rather than the objects themselves.
And attributes work the same way: **attributes point to objects** (just like any variable points to an object).
So **objects cannot contain objects in Python** (they can only *point to* objects).

And note that while **mutations change objects** (not variables), multiple variables *can* point to the same object.
If two variables point to the same object and that object gets mutated, that change will be seen when accessing either variable (because they both point to the same object).

I teach this concept in both introductory and intermediate Python trainings because it's so often overlooked.
It's possible (and common) to happily use Python for years without really understanding how variables and data structures actually work.
But understanding this variable and value distinction can alleviate *many* common Python gotchas.

This mental model of Python can be tricky to internalize and it's okay if you haven't yet!
Python was designed to embrace this idea and continually pushes us in the direction of *doing the right thing* when it comes to variables and values.


[comprehension article]: https://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[comprehension screencasts]: https://www.pythonmorsels.com/topics/playlist/comprehensions/
[parameters]: https://docs.python.org/3/glossary.html#term-parameter
[arguments]: https://docs.python.org/3/glossary.html#term-argument
[shared defaults]: https://docs.python.org/3/faq/programming.html#why-are-default-values-shared-between-objects
[everything is an object in Python]: https://www.pythonmorsels.com/topics/everything-is-an-object/
