---
layout: post
title: "Check whether all items match a condition in Python"
date: 2016-10-14 21:11:33 -0700
comments: true
categories: python
---

In this article, we're going to look at a common programming pattern and discuss how we can refactor our code when we notice this pattern.

We'll be discussing how to make code with this shape a little more descriptive:

```python
all_good = True
for item in iterable:
    if condition(item)
        all_good = False
        break
```


## An Example: Primality

Here's a function that checks whether a given number is prime by trying to divide it by all numbers below it:

```python
def is_prime(candidate):
    for n in range(2, candidate):
        if candidate % n == 0:
            return False
    return True
```

**Note**: a [square root][square root check] makes this faster and our code breaks below `2` but we'll ignore those issues here

This function:

1. loops from 2 to the given number
2. returns `False` as soon as a divisor is found
3. returns `True` if no divisor was found

This primality check is asking "do any numbers evenly divide the candidate number".

Note that this function **returns as soon as it finds a divisor**, so it *only* iterates all the way through the number range when the candidate number is prime.

Let's take a look at how we can rewrite this function using `all`.


## What's `all`?

Python has a built-in function `all` that returns `True` if all items are **truthy**

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

You can think of truthy as meaning non-empty or non-zero (Python chat on [truthiness][]).  For our purposes, we'll treat it as pretty much the same as `True`.

The `all` built-in function is equivalent to this:

```python
def all(iterable):
    for element in iterable:
        if element:
            return False
    return True
```

Notice the similarity between `all` and our `is_prime` function?  Our `is_prime` function is similar, but they're not quite the same structure.

The `all` function checks for the truthiness of `element`, but we need something a little more than that: we need to check a condition on each element (whether it's a divsior).


## Using `all`

Our original `is_prime` function looks like this:

```python
def is_prime(candidate):
    for n in range(2, candidate):
        if candidate % n == 0:
            return False
    return True
```

If we want to use `all` in this function, we need an iterable (like a list) to pass to `all`.

If we wanted to be really silly, we could make such a list of boolean values like this:

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

We could simplify this function like this:

```python
def is_prime(candidate):
	divisibility = []
    for n in range(2, candidate):
		divisibility.append(candidate % n != 0)
	return all(divisibility)
```

I know this is probably doesn't seem like progress, but bear with me for a few more steps...


## List comprehensions

If you're familiar with list comprehensions, this code structure might look a little familiar.  We're creating one iterable from another which is exactly what list comprehensions are good for.

Let's copy-paste our way into a list comprehension (see my article on [how to write list comprehensions][list comprehensions]):

```python
def is_prime(candidate):
	divisibility = [
		candidate % n != 0
		for n in range(2, candidate)
	]
	return all(divisibility)
```

That's quite a bit shorter, but there's a problem: we're **building up an entire list just to loop over it once**!

This is less efficient than our original approach, which only looped all the way when `candidate` was prime.

Let's fix this inefficiency by turning our list comprehension into a generator expression.


## Generator expressions

A generator expression is like a list comprehension, but instead of making a list it makes a **generator** (Python chat on [generators][]).

A generator is a **lazy iterable**: generators don't compute the items they contain until you loop over them.  We'll see what that means in a moment.

We can turn our list comprehension into a generator expression by changing the brackets to parentheses:

```python
def is_prime(candidate):
	divisibility = (
		candidate % n != 0
		for n in range(2, candidate)
	)
	return all(divisibility)
```

Now our code doesn't create a list to loop over.  Instead it provides us with a generator that allows us to compute the divisibility of each number one-by-one.

We can make this code even more readable by putting that generator expression inside the function call (notice that we can drop the second set of parentheses):

```python
def is_prime(candidate):
	return all(
		candidate % n != 0
		for n in range(2, candidate)
    )
```

Note that because our generator is lazy, we stop computing divisibilities as soon as our `all` function finds a divisible number.  So we end up calculating `candidate % n != 0` only as many times as we did in our original function.


## Recap

So we started with a `for` loop, an `if` statement, a `return` statement for stopping once we find a divisor, and a `return` statement for the case where our number had no divisors (when it's prime).

```python
def is_prime(candidate):
    for n in range(2, candidate):
        if candidate % n == 0:
            return False
    return True
```

We turned all that into a generator expression passed to the `all` function.

```python
def is_prime(candidate):
    return all(
        candidate % n != 0
        for n in range(2, candidate)
    )
```

I prefer this second approach (a generator expression with `all`) because I find it **more descriptive**.

We're checking to see whether "all numbers in a range are not divisors of our candidate number".  That sounds quite a bit more like English to me than "loop over all numbers in a range and return False if a divisor is found otherwise return True".


## `any` or `all`

We've been working with the `all` function, but I haven't mentioned it's counterpart: the `any` function.  Let's take a look at how `all` and `any` compare.

These two expressions:

```python
all_good = all(
    condition(x)
    for x in things
)
some_bad = not all(
    condition(x)
    for x in things
)
```

Are equivalent to these two expressions (because of [DeMorgan's Laws](https://en.wikipedia.org/wiki/De_Morgan%27s_laws)):

```python
all_good = not any(
    not condition(x)
    for x in things
)
some_bad = any(
    not condition(x)
    for x in things
)
```

So this code:

```python
def is_prime(candidate):
    return all(
        candidate % n != 0
        for n in range(2, candidate)
    )
```

Is feature-identical to this code:

```python
def is_prime(candidate):
    return not any(
        candidate % n == 0
        for n in range(2, candidate)
    )
```

Both of them stop as soon as they find a divisor.

I find the use of `all` more readable here, but I wanted to mention that `any` would work just as well.


## Cheat sheet for refactoring with `any` and `all`

All that explanation above was valuable, but how can we use this new knowledge to refactor our own code?  Here's a cheat sheet for you.

Anytime you see code like this:

```python
all_good = True
for item in iterable:
    if condition(item)
        all_good = False
        break
```

You can replace that code with this:

```python
all_good = all(
    condition(item)
    for item in iterable
)
```

Anytime you see code like this:

```python
any_good = False
for item in iterable:
    if condition(item)
        any_good = True
        break
```

You can replace it with this:

```python
any_good = any(
    condition(item)
    for item in iterable
)
```

Note that `break` is used in the code above because we're not returning from a function.  Using `return` (like we did in `is_prime`) is another way to stop our loop early.

Python's `any` and `all` functions were *made* for use with generator expressions (discussion [here][proposal] and [here][discussion]).  You can use `any` and `all` without generator expressions, but I don't find a need for that as often.

**Quick note**: `any(item == 'something' for item in iterable)` is the same as `'something' in iterable`.  Don't use `all`/`any` for checking containment, use `in`. 😄


## Conclusion: code style in a process

As you discover new Python idioms and new language features are invented, your code style will evolve.  Your preferred code style may never stop evolving.  Code style is not concrete: it's a process.

I hope I've inspired you to embrace the use of `any`/`all` with generator expressions for improved readability and code clarity.

Have a question about code style?  Have a thought about `any`, `all`, and generator expressions?  Please [tweet me][], [email me][], or comment below.


[square root check]: http://stackoverflow.com/questions/5811151/why-do-we-check-upto-the-square-root-of-a-prime-number-to-determine-if-it-is-pri#5811176
[proposal]: https://mail.python.org/pipermail/python-dev/2005-March/thread.html#52010
[discussion]: https://mail.python.org/pipermail/python-dev/2005-March/thread.html#52010
[list comprehensions]: http://treyhunner.com/2015/12/python-list-comprehensions-now-in-color/
[generators]: https://www.crowdcast.io/e/generators
[truthiness]: https://www.crowdcast.io/e/truthiness
[tweet me]: http://twitter.com/treyhunner
[email me]: mailto:hello@truthful.technology
