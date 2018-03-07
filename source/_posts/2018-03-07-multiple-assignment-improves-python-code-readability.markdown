---
layout: post
title: "Multiple assignment and tuple unpacking improve Python code readability"
date: 2018-03-07 10:09:38 -0800
comments: true
categories: python
---

Whether I'm teaching new Pythonistas or long-time Python programmers, I frequently find that **Python programmers underutilize multiple assignment**.

Multiple assignment (also known as tuple unpacking or iterable unpacking) allows you to assign multiple variables at the same time in one line of code.
This feature often seems simple after you've learned about it, but **it can be tricky to recall multiple assignment when you need it most**.

In this article we'll see what multiple assignment is, we'll take a look at common uses of multiple assignment, and then we'll look at a few uses for multiple assignment that are often overlooked.

Note that in this article I will be using [f-strings][] which are a Python 3.6+ feature.
If you're on an older version of Python, you'll need to mentally translate those to use the string `format` method.


## How multiple assignment works

I'll be using the words **multiple assignment**, **tuple unpacking**, and **iterable unpacking** interchangeably in this article.
They're all just different words for the same thing.

Python's multiple assignment looks like this:

```pycon
>>> x, y = 10, 20
```

We're assigning `x` to `10` and `y` to `20` here.

What's happening at a lower level is that we're creating a tuple of `10, 20` and then looping over that tuple and taking each of the two items we get from looping and assigning them to `x` and `y` in order.

This syntax might make that a bit more clear:

```pycon
>>> (x, y) = (10, 20)
```

Parenthesis are optional around tuples in Python and they're also optional in multiple assignment (which uses a tuple-like syntax).
All of these are equivalent:

```pycon
>>> x, y = 10, 20
>>> x, y = (10, 20)
>>> (x, y) = 10, 20
>>> (x, y) = (10, 20)
```

Multiple assignment is often called "tuple unpacking" because it's frequently used with tuples.
But we can use multiple assignment with any iterable, not just tuples.
Here we're using it with a list:

```pycon
>>> x, y = [10, 20]
>>> x
10
>>> y
20
```

And with a string:

```pycon
>>> x, y = 'hi'
>>> x
'h'
>>> y
'i'
```

Anything that can be looped over can be "unpacked" with tuple unpacking.

Here's another example to demonstrate that multiple assignment works with any number of items and that it works with variables as well as objects we've just created:

```pycon
>>> coordinate = 10, 20, 30
>>> x, y, z = coordinate
>>> (x, y, z) = (z, y, x)
```

Okay let's talk about how multiple assignment can be used.


## Unpacking in a for loop

You'll commonly see multiple assignment used in `for` loops.

Let's take a dictionary:

```pycon
>>> person_dictionary = {'name': "Trey", 'company': "Truthful Technology LLC"}
```

Instead of looping over our dictionary like this:

```python
for item in person_dictionary.items():
    print(f"Key {item[0]} has value {item[1]}")
```

You'll often see Python programmers use multiple assignment by writing this:

```python
for key, value in person_dictionary.items():
    print(f"Key {key} has value {value}")
```

When you write the `for X in Y` line of a for loop, you're telling Python that it should do an assignment to X for each iteration of your loop.
Just like in a regular assignment statement, X here can be a single variable or a tuple of variables.

So this:

```python
for key, value in person_dictionary.items():
    print(f"Key {key} has value {value}")
```

Is essentially the same as this:

```python
for item in person_dictionary.items():
    key, value = item
    print(f"Key {key} has value {value}")
```

We're just not doing an unnecessary extra assignment.

So multiple assignment is great for unpacking dictionary items into key-value pairs.

It's also great when paired with the built-in `enumerate` function:

```python
for i, line in enumerate(my_file):
    print(f"Line {i}: {line}")
```

And the `zip` function:

```python
for color, ratio in zip(colors, ratios):
    print(f"It's {ratio*100}% {color}.")
```

```python
for (product, price, color) in zip(products, prices, colors):
    print(f"{product} is {color} and costs ${price:.2f}")
```

Multiple assignment is pairs so nicely with Python's looping tools that new Python programmers might be under the impression that it's somehow related to `for` loops and not assignment in general.
The tuple unpacking syntax used in `for` loops *is* the same as the tuple unpacking syntax used in regular assignment statements though.


## An alternative to hard coded indexes

It's not uncommon to see hard coded indexes (e.g. `coordinate[0]`, `items[1]`, `values[-1]`) in Python code (or code written in pretty much any programming language):

```python
print(f"The first item is {items[0]} and the last item is {items[-1]}")
```

When you see Python code that uses hard coded indexes there's often a way to use multiple assignment to make your code more readable.

Here's some code that has three hard coded indexes:

```python
def reformat_date(mdy_date_string):
    """Reformat MM/DD/YYYY string into YYYY-MM-DD string."""
    date = mdy_date_string.split('/')
    return f"{date[2]}-{date[0]}-{date[1]}"
```

We can make this code much more readable by using tuple unpacking to assign separate month, day, and year variables:

```python
def reformat_date(mdy_date_string):
    """Reformat MM/DD/YYYY string into YYYY-MM-DD string."""
    month, day, year = mdy_date_string.split('/')
    return f"{year}-{month}-{day}"
```

Whenever you see hard coded indexes in your code, stop to consider whether you could use tuple unpacking to make your code more readable.


## Multiple assignment is very strict

I didn't mention before that multiple assignment is actually fairly strict when it comes to unpacking the iterable we give to it.

If we try to unpack a larger iterable into a smaller number of variables, we'll get an error:

```pycon
>>> x, y = (10, 20, 30)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: too many values to unpack (expected 2)
```

If we try to unpack a smaller iterable into a larger number of variables, we'll also get an error:

```pycon
>>> x, y, z = (10, 20)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: not enough values to unpack (expected 3, got 2)
```

This strictness is pretty great.
If we're working with an item that has a different size than we expected, the multiple assignment will fail loudly and we'll hopefully now know about a bug in our program that we weren't aware of previously.

Imagine that we have a short command line program that parses command arguments in a rudimentary way like this:

```python
import sys

new_file = sys.argv[1]
old_file = sys.argv[2]
print(f"Copying {new_file} to {old_file}")
```

Our program is supposed to accept 2 arguments, like this:

```bash
$ my_program.py file1.txt file2.txt
Copying file1.txt to file2.txt
```

But if someone called our program with three arguments:

```bash
$ my_program.py file1.txt file2.txt file3.txt
Copying file1.txt to file2.txt
```

They won't see an error
The reason is that we're not validating that we receive exactly 2 arguments.

If we were using multiple assignment, we would be validating that we receive exactly the expected number of arguments:

```python
import sys

_, new_file, old_file = sys.argv
print(f"Copying {new_file} to {old_file}")
```

Note that we're using the variable name `_` to note that we don't care about `sys.argv[0]` (which is the name of our program).
Using `_` for variables you don't care about is just a convention.


## An alternative to slicing

So multiple assignment can be used for avoiding hard coded indexes and it can be used to ensure we're strict about the size of the tuples/iterables we're working with.

Multiple assignment can also be used to replace many hard coded slices also.

By hard coded slice I mean something like this:

```python
all_after_first = items[1:]
all_but_last_two = items[:-2]
items_with_ends_removed = items[1:-1]
```

Slices lists, tuples, and other sequences is a handy way to grab a specific portion of the items in that sequence.

Whenever you see slices that don't use any variables in their slice indexes, you can often use multiple assignment instead.
To do this we have to talk about a feature that I haven't mentioned yet though: the `*` operator.

In Python 3.0, the `*` operator was added to the multiple assignment syntax, allowing us to capture any remaining items into a list:

```pycon
>>> numbers = [1, 2, 3, 4, 5, 6]
>>> first, *rest = numbers
>>> rest
[2, 3, 4, 5, 6]
>>> first
1
```

The `*` operator allows us to replace hard coded slices near the ends of sequences.

These two lines are equivalent:

```pycon
>>> first, rest = numbers[0], numbers[1:]
>>> first, *rest = numbers
```

As are these lines:

```pycon
>>> head, middle, tail = numbers[0], numbers[1:-1], numbers[-1]
>>> head, *middle, tail = numbers
```

With the `*` operator and multiple assignment you can replace things like this:

```python
main(sys.argv[0], sys.argv[1:])
```

With this:

```python
program_name, *arguments = sys.argv
main(program_name, arguments)
```

So if you see hard coded slice indexes in your code, consider whether you could use multiple assignment to make it more clear what those slices represent.


## Deep unpacking

This next feature is something that long-time Python programmers often overlook.
It doesn't come up quite as often as the other uses for multiple assignment that I've discussed, but it can be very handy to know about when you do need it.

We've seen multiple assignment for unpacking tuples and other iterables.
We haven't yet seen that this is can be done *deeply*.

I'd say that tuple unpacking is *shallow* because it unpacks one level deep:

```pycon
>>> color, point = ("red", (1, 2, 3))
>>> color
'red'
>>> point
(1, 2, 3)
```

But this tuple unpacking is *deep* because it unpacks the previous `point` tuple further into `x`, `y`, and `z`:

```pycon
>>> color, (x, y, z) = ("red", (1, 2, 3))
>>> color
'red'
>>> x
1
>>> y
2
```

If it seems confusing what's going on there, maybe using parenthesis consistently on both sides will clarify things:

```pycon
>>> (color, (x, y, z)) = ("red", (1, 2, 3))
```

We're unpacking one level deep to get two objects, but then we take the second object and unpack it a second level down to get 3 more objects.
Then we assign to our new variables (`color`, `x`, `y`, and `z`).

Here's an example with shallow unpacking:

```python
for start, end in zip(start_points, end_points):
    if start[0] == -end[0] and start[1] == -end[1]:
        print(f"Point {start[0]},{start[1]} was negated.")
```

And here's the same thing with deeper unpacking:

```python
for (x1, y1), (x2, y2) in zip(start_points, end_points):
    if x1 == -x2 and y1 == -y2:
        print(f"Point {x1},{y1} was negated.")
```

Note that it's more clear what type of object we're working with here.
It's much more apparent that we're getting two two-itemed tuples each time we loop.

Deep unpacking comes up often when you need to combine a few looping utilities that each give you multiple items back.
For example, you'll often see it when using `enumerate` and `zip` together:

```python
for i, (first, last) in enumerate(zip(items, reversed(items))):
    if first != last:
        raise ValueError(f"Item {i} doesn't match: {first} != {last}")
```

I said before that multiple assignment allows is strict about the size of our iterables as we unpack them.
With deep unpacking we can also be **strict about the shape of our iterables**.

This works:

```pycon
>>> points = ((1, 2), (-1, -2))
>>> points[0][0] == -points[1][0] and points[0][1] == -point[1][1]
True
```

But so does this:

```pycon
>>> points = ((1, 2, 4), (-1, -2, 3), (6, 4, 5))
>>> points[0][0] == -points[1][0] and points[0][1] == -point[1][1]
True
```

Whereas this works:

```pycon
>>> points = ((1, 2), (-1, -2))
>>> (x1, y1), (x2, y2) = points
>>> x1 == -x2 and y1 == -y2
True
```

But this does not:

```pycon
>>> points = ((1, 2, 4), (-1, -2, 3), (6, 4, 5))
>>> (x1, y1), (x2, y2) = points
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: too many values to unpack (expected 2)
```

With multiple assignment we're assigning variables while also making particular assertions about the size and shape of our iterables.
Multiple assignment helps clarify your code to humans (for **better code readability**) and to computers (for **improved code correctness**).


## Using a list-like syntax

I said before that iterable unpacking (aka tuple unpacking or multiple assignment) uses a tuple-like syntax.

That's not the only way to use iterable unpacking though.

We can also use iterable unpacking with a list-like syntax:

```pycon
>>> [x, y, z] = 1, 2, 3
>>> x
1
```

This might seem really strange... what's the point of supporting both a list and tuple syntax for iterable unpacking?

This is about code clarity.

I use this feature rarely, but I find it helpful for code clarity in particular circumstances.

Let's say I have code that used to look like this:

```python
def most_common(items):
    return Counter(items).most_common(1)[0][0]
```

And our well-intentioned coworker has decided to use deep iterable unpacking to refactor our code to this:

```python
def most_common(items):
    (value, times_seen), = Counter(items).most_common(1)
    return value
```

See that trailing comma on the left-hand side of the assignment?
It's easy to miss and it makes this code look sort of weird.
What is it doing in this code?

That trailing comma is there to make a single item tuple.
We're doing deep unpacking here.

Here's another way we could write the same code:

```python
def most_common(items):
    ((value, times_seen),) = Counter(items).most_common(1)
    return value
```

This might be a bit more clear (or possibly more confusing if you still don't understand that comma) but I'd prefer to see code like this:

```python
def most_common(items):
    [(value, times_seen)] = Counter(items).most_common(1)
    return value
```

This makes it more clear that we're unpacking a one-item iterable and then unpacking that single item into `value` and `times_seen` variables.

When I see this, I also think *I bet we're unpacking a single-item list*.
That is in fact what we're doing.
We're using a [Counter][] object from the collections module here.
The `most_common` method on `Counter` objects allows us to limit the length of the list of items they return back to us.
We're limiting our list to a single item.

When you're unpacking structures that often hold lots of values (like lists) and structures that often hold a very specific number of values (like tuples) you may decide that your code seems more *semantically accurate* if you use a list-like syntax when unpacking those list-like structures.

If you'd like you might even decide to use a convention of always using a list-like syntax when list-like structures are involved, which is frequently the case when using `*` for iterable unpacking:

```pycon
>>> [first, *rest] = numbers
```

I don't usually use this convention myself mostly because I'm not in the habit of using it.
You can use this convention if you'd like though.
When using multiple assignment in your code, consider when and where a list-like syntax might make your code more descriptive and easier to understand.


## Don't forget about multiple assignment

Multiple assignment can improve both the readability of your code and the correctness of your code.  It can make your code more descriptive while also making implicit assertions about the size and shape of the iterables you're unpacking.

The biggest use case for multiple assignment that I see forgotten is the ability to **replace hard coded indexes** (most of them at least), including **replacing hard coded slices** (using the `*` syntax).  It's also helpful to remember that multiple assignment can be used deeply and that you can use it with a list-like syntax.

New Python programmers often have a hard time remembering to use multiple assignment, but long-time programmers with a strong background in another programming language often forget about this feature too!  It's tricky to recognize and remember all the cases that multiple assignment can come in handy.  Please feel free to use this article as your guide, but also remember to note in your own conventions for when and how you use multiple assignment in your project's style guide.


[f-strings]: https://cito.github.io/blog/f-strings/
[Counter]: https://docs.python.org/3/library/collections.html#collections.Counter
