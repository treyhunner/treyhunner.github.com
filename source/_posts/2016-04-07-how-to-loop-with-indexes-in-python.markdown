---
layout: post
title: "How to loop with indexes in Python"
date: 2016-04-25 09:00:00 -0700
comments: true
categories: python
---

If you're moving to Python from C or Java, you might be confused by Python's `for` loops.  **Python doesn't actually have for loops**... at least not the same kind of `for` loop that C-based languages have.  Python's `for` loops are actually [foreach loops][foreach].

In this article I'll compare Python's `for` loops to those of other languages and discuss the usual ways we solve common problems with `for` loops in Python.

## For loops in other languages

Before we look at Python's loops, let's take a look at a for loop in JavaScript:

```javascript
var colors = ["red", "green", "blue", "purple"];
for (var i = 0; i < colors.length; i++) {
    console.log(colors[i]);
}
```

This JavaScript loop looks nearly identical in C/C++ and Java.

In this loop we:

1. Set a counter variable `i` to 0
2. Check if the counter is less than the array length
3. Execute the code in the loop *or* exit the loop if the counter is too high
4. Increment the counter variable by 1


## Looping in Python

Now let's talk about loops in Python.  First we'll look at two slightly more familiar looping methods and then we'll look at the idiomatic way to loop in Python.

### while

If we wanted to mimic the behavior of our traditional C-style `for` loop in Python, we could use a `while` loop:

```python
colors = ["red", "green", "blue", "purple"]
i = 0
while i < len(colors):
    print(colors[i])
    i += 1
```

This involves the same 4 steps as the `for` loops in other languages (note that we're setting, checking, and incrementing `i`) but it's not quite as compact.

This method of looping in Python is very uncommon.

### range of length

I often see new Python programmers attempt to recreate traditional `for` loops in a slightly more creative fashion in Python:

```python
colors = ["red", "green", "blue", "purple"]
for i in range(len(colors)):
    print(colors[i])
```

This first creates a range corresponding to the indexes in our list (`0` to `len(colors) - 1`).  We can loop over this range using Python's for-in loop (really a [foreach][]).

This provides us with the index of each item in our `colors` list, which is the same way that C-style `for` loops work.  To get the actual color, we use `colors[i]`.

### for-in: the usual way

Both the while loop and range-of-len methods rely on looping over indexes.  But we don't actually care about the indexes: we're only using these indexes for the purpose of retrieving elements from our list.

Because we don't actually care about the indexes in our loop, there is **a much simpler method of looping** we can use:

```python
colors = ["red", "green", "blue", "purple"]
for color in colors:
    print(color)
```

So instead of retrieving the item indexes and looking up each element, we can just loop over our list using a plain for-in loop.

The other two methods we discussed are sometimes referred to as [anti-patterns][] because they are programming patterns which are widely considered unidiomatic.

## What if we need indexes?

What if we actually need the indexes?  For example, let's say we're printing out president names along with their numbers (based on list indexes).

### range of length

We could use `range(len(our_list))` and then lookup the index like before:

```python
presidents = ["Washington", "Adams", "Jefferson", "Madison", "Monroe", "Adams", "Jackson"]
for i in range(len(presidents)):
    print("President {}: {}".format(i + 1, presidents[i]))
```

But there's a more idiomatic way to accomplish this task: use the `enumerate` function.

### enumerate

Python's built-in `enumerate` function allows us to loop over a list and retrieve both the index and the value of each item in the list:

```python
presidents = ["Washington", "Adams", "Jefferson", "Madison", "Monroe", "Adams", "Jackson"]
for num, name in enumerate(presidents, start=1):
    print("President {}: {}".format(num, name))
```

The `enumerate` function gives us an iterable where each element is a tuple that contains the index of the item and the original item value.

This function is meant for solving the task of:

1. Accessing each item in a list (or another iterable)
2. Also getting the index of each item accessed

So whenever we need item indexes while looping, we should think of `enumerate`.

**Note**: the `start=1` option to `enumerate` here is optional.  If we didn't specify this, we'd start counting at `0` by default.

## What if we need to loop over multiple things?

Often when we use list indexes, it's to look something up in another list.

### enumerate

For example, here we're looping over two lists at the same time using indexes to look up corresponding elements:

```python
colors = ["red", "green", "blue", "purple"]
ratios = [0.2, 0.3, 0.1, 0.4]
for i, color in enumerate(colors):
    ratio = ratios[i]
    print("{}% {}".format(ratio * 100, color))
```

Note that we only need the index in this scenario because we're using it to lookup elements at the same index in our second list.  What we really want is to loop over two lists simultaneously: the indexes just provide a means to do that.

### zip

We don't actually care about the index when looping here.  Our real goal is to loop over two lists at once.  This need is common enough that there's a special built-in function just for this.

Python's `zip` function allows us to **loop over multiple lists at the same time**:

```python
colors = ["red", "green", "blue", "purple"]
ratios = [0.2, 0.3, 0.1, 0.4]
for color, ratio in zip(colors, ratios):
    print("{}% {}".format(ratio * 100, color))
```

The `zip` function takes multiple lists and returns an iterable that provides a tuple of the corresponding elements of each list as we loop over it.

Note that `zip` with different size lists will stop after the shortest list runs out of items.  You may want to look into [itertools.zip_longest][] if you need different behavior.  Also note that `zip` in Python 2 returns a list but `zip` in Python 3 returns a lazy iterable.  In Python 2, `itertools.izip` is equivalent to the newer Python 3 `zip` function.

## Looping cheat sheet

Here's a very short looping cheat sheet that might help you remember the preferred construct for each of these three looping scenarios.

Loop over a single list with a regular for-in:

```python
for n in numbers:
    print(n)
```

Loop over multiple lists at the same time with `zip`:

```python
for header, rows in zip(headers, columns):
    print("{}: {}".format(header, ", ".join(rows)))
```

Loop over a list while keeping track of indexes with `enumerate`:

```python
for num, line in enumerate(lines):
    print("{0:03d}: {}".format(num, line))
```

## In Summary

If you find yourself tempted to use `range(len(my_list))` or a loop counter, think about whether you can reframe your problem to allow usage of `zip` or `enumerate` (or a combination of the two).

In fact, if you find yourself reaching for `enumerate`, think about whether you actually need indexes at all.  It's quite rare to need indexes in Python.

1. If you need to loop over multiple lists at the same time, use `zip`
2. If you only need to loop over a single list just use a for-in loop
3. If you need to loop over a list and you need item indexes, use `enumerate`

If you find yourself struggling to figure out the best way to loop, try using the cheat sheet above.

For more a more detailed explanation of the fundamentals of looping in Python, see Ned Batchelder's [Loop Like a Native][] presentation.

Thanks [Steven Kryskalla][] and [Diane Chen][] for proof-reading this post.

Happy looping!

[anti-patterns]: https://en.wikipedia.org/wiki/Anti-pattern
[foreach]: https://en.wikipedia.org/wiki/Foreach_loop
[loop like a native]: http://nedbatchelder.com/text/iter.html
[itertools.zip_longest]: https://docs.python.org/3/library/itertools.html#itertools.zip_longest
[Steven Kryskalla]: http://lost-theory.org/
[Diane Chen]: http://purplediane.github.io/
