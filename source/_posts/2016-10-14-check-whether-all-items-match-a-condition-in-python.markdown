---
layout: post
title: "Check whether all items match a condition in Python"
date: 2016-10-14 21:11:33 -0700
comments: true
categories: python
---

Python's `any` and `all` functions were made to be used with generator expressions (discussion about their inception [here][proposal] and [here][discussion]).

Let's take a look at the common programming patterns that `any` and `all` can be used to simplify.

## An Example: Finding Primes

Here's a function that checks whether a given number is prime by trying to divide it by all numbers below it (yes I know [there's a better way to do this][square root check]):

```python
def is_prime(candidate):
    for n in range(2, candidate):
        if candidate % n == 0:
            return False
    return True
```

This function:

1. loops from 2 to the given number
2. returns `False` as soon as a divisor is found
3. returns `True` if no divisor was found

This primality check is asking "do any numbers evenly divide the candidate number".

Notice that this function **returns as soon as it finds a divisor**, so it *only* iterates all the way through the number range if the number is prime (or the last first divisor is the last number).

We're going to look at how we can write this function using `any`/`all`, but first let's define those.

## all built-in function

Python has a built-in function `all` that returns `True` if all items are **truthy**:

```pycon
>>> all(['hello, 'there'])
True
>>> all(['hello, 'there', ''])
False
>>> all([1, 2, 3])
True
>>> all([0, 1, 2, 3])
False
```

The `all` built-in function is equivalent to this:

```python
def all(iterable):
    for element in iterable:
        if element:
            return False
    return True
```

Notice the similarity between `all` and our `is_prime` function?  It's close, but it's not quite the same structure.  The `all` function checks for the [truthiness][] of `element`, but we need something a little more than that.

## all with a condition

We're looking for a variation on `all` that checks not for truthiness of each item, but instead checks whether each item matches a certain condition:

```python
def all_fails(condition, iterable):
    for element in iterable:
        if condition(element):
            return False
    return True
```

Here's a rewrite of `is_prime` using the `all_fails` function we just invented:

```python
def is_prime(candidate):
    def is_divisor(n): return candidate % n == 0
    return all_fails(is_divisor, range(2, candidate))
```

This isn't the simplified solution we're looking for, but it's a step in the right direction.

## List comprehensions

Our original `is_prime` function looks like this:

```python
def is_prime(candidate):
    for n in range(2, candidate):
        if candidate % n == 0:
            return False
    return True
```

If we want to use `all` in this function, we need an iterable (like a list) to pass to `all`.  If we wanted to be silly, we could make such a list of boolean values like this:

```python
def is_prime(candidate):
	divisibility = []
    for n in range(2, candidate):
        if candidate % n == 0:
            divisibility.append(False)
        else:
            divisibility.append(True)
	return all(divisibility)
```

We can write this function like this (notice `==` flipped to `!=`):

```python
def is_prime(candidate):
	divisibility = []
    for n in range(2, candidate):
		divisibility.append(candidate % n != 0)
	return all(divisibility)
```

This should look familiar: we're creating one iterable from another.  From here we can copy-paste our way into a list comprehension (see my article on [how to write list comprehensions][list comprehensions]):

```python
def is_prime(candidate):
	divisibility = [
		candidate % n != 0
		for n in range(2, candidate)
	]
	return all(divisibility)
```


## Generator expression

Using a list comprehension means we build up a list of `True` and `False` values and then loop over the list when we use `all`.  This is less efficient than our original approach because we store an extra list in memory needlessly.

Does that mean we should we give up on using a list comprehension?  No!  We that means we should turn our list comprehension into a generator expression.

A [generator expression][]

## Finding Primes: The Rewrite

The above function is feature-identical to this one:

```python
def is_prime(candidate):
    return all(
        candidate % n != 0
        for n in range(2, candidate)
    )
```

It is also feature-identical to this one:

```python
def is_prime(candidate):
    return not any(
        candidate % n == 0
        for n in range(2, candidate)
    )
```

TODO: using all with a list of conditions

TODO: converting a list of conditions to a list comprehension and then to a generator expression

TODO: any/all are two sides of the same coin

TODO: note any(a == x for a in i) is the same as "x" in it


[square root check]: http://stackoverflow.com/questions/5811151/why-do-we-check-upto-the-square-root-of-a-prime-number-to-determine-if-it-is-pri#5811176
[proposal]: https://mail.python.org/pipermail/python-dev/2005-March/thread.html#52010
[discussion]: https://mail.python.org/pipermail/python-dev/2005-March/thread.html#52010
[list comprehensions]: http://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[generator expression]: https://www.crowdcast.io/e/generators
[truthiness]: https://www.crowdcast.io/e/truthiness
