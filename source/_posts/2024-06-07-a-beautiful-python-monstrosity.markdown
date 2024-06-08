---
layout: post
title: "A beautiful Python monstrosity"
date: 2024-06-08 14:30:00 -0700
comments: true
categories: python
---

Creating performance tests for [Python Morsels][] exercises is a frequent annoyance

I loathe writing automated tests for performance-related exercises because they're *always* flaky.
How flaky depends on the exercise, what I'm testing, and the time variability inherent in the particular Python features that a learner might use.

I came up with a solution for flaky tests recently, but it also makes my tests less readable.
I then came up with a tool to improve the readability, but that has its own trade-offs.

The code I eventually came up with is a **beautiful Python monstrosity**.

```python
    @attempt_n_times(10)
    def _():
        nonlocal micro_time, tiny_time
        micro_time = time(micro_numbers)
        tiny_time = time(tiny_numbers)
        self.assertLess(tiny_time, micro_time*n)
```

I'll explain what that code does, but first let's talk about why it's needed.


## The flaky performance tests

My flaky performance tests initially looked like this:

```python
def test_some_test(self):
    n, m = 2.45, 2.04

    micro_time = time(micro_numbers)
    tiny_time = time(tiny_numbers)
    self.assertLess(tiny_time, micro_time*n)

    small_time = time(small_numbers)
    self.assertLess(small_time, tiny_time*n)
    self.assertLess(small_time, micro_time*n*m)

    medium_time = time(medium_numbers)
    self.assertLess(medium_time, micro_time*n*m*m)
    self.assertLess(medium_time, tiny_time*n*m)
    self.assertLess(medium_time, small_time*n)
```

The first block runs a performance test for the user's function on a very small list and on a slightly larger list and then asserting that the slightly larger list didn't take *too* much longer to run.
The next two blocks run the same code on even larger lists and make further assertions about the relative times that the code took to run.

This roughly approximates the [time complexity][] of this code.


## Running performance checks in a loop

These performance checks need to:

1. Predictably fail for inefficient solutions
2. Predictably pass for efficient solutions
3. Run *fast* (within just a few seconds) even when the code is inefficient
4. Avoid the use of `threading` because they'll be running on WebAssembly in the browser
5. Run consistently on pretty much any computer

These 5 requirements together have caused me countless headaches.
I get the tests passing well, but they don't always fail when they should.
I get the tests failing and passing when they should, but then they're too slow.
And so on...

Notice the `n` and `m` factors in the above assertions:

```python
    self.assertLess(small_time, micro_time*n*m)
```

If `n` and `m` are too big, we'll get false positives (tests passing when they should fail).
If `n` and `m` are too small, we'll get false negatives (tests failing when they should pass).

To avoid both [Type I and Type II errors][type errors], I decided to keep `n` and `m` small but attempt the assertion block multiple times.

Here's the (far less flaky) revised code:

```python
def test_some_test(self):
    n, m = 2.45, 2.04

    for attempts_left in reversed(range(10)):
        try:
            micro_time = time(micro_numbers)
            tiny_time = time(tiny_numbers)
            self.assertLess(tiny_time, micro_time*n)
            break
        except AssertionError:
            if attempts_left == 0:
                raise

    for attempts_left in reversed(range(5)):
        try:
            small_time = time(small_numbers)
            self.assertLess(small_time, tiny_time*n)
            self.assertLess(small_time, micro_time*n*m)
            break
        except AssertionError:
            if attempts_left == 0:
                raise

for attempts_left in reversed(range(3)):
    try:
        medium_time = time(medium_numbers)
        self.assertLess(medium_time, micro_time*n*m*m)
        self.assertLess(medium_time, tiny_time*n*m)
        self.assertLess(medium_time, small_time*n)
        break
    except AssertionError:
        if attempts_left == 0:
            raise
```

The `for` loop runs the code multiple times, the `break` statement stops the code as soon as the assertions all pass, and the `except` and `if` ensure that any assertion errors are suppressed until/unless we're on the final iteration of the loop.

Let's call this a `for`-`try`-`break`-`except`-`if`-`raise` pattern.
It's an absurdly verbose name fitting of absurdly verbose code.

This `for`-`try`-`break`-`except`-`if`-`raise` pattern works pretty well!
But it's not pretty.

Like many programmers, I believe that **Don't Repeat Yourself** ([DRY][]) need not apply to tests.
Tests are *allowed* to be repetitive if [the verbosity improves readability][damp].

But there is *so much noise* in that code!
I decided that removing some noise might improve readability.
So I devised a helper utility to reduce the repetition.


## In search of a solution

While pondering the repetitive noise in this code, I wondered what Python features I could use to abstract away this `for`-`try`-`break`-`except`-`if`-`raise` pattern.

Could I make a context manager and use a `with` block?
That might help with the `try`-`except`, but context managers can't run their code block multiple times, so that wouldn't help with the `for` and the `break`.
So a context manager is out.

Could I abstract this away into a looping helper by implementing a generator function?
We *are* looping and generator functions *can* `break` early.
But, a generator function can't catch an exception that's raised within the *body* of a loop.
So a generator function wouldn't work either.

What about a decorator? 🤔

Context managers and decorators both sandwich a block of code.
But decorators sandwich functions and they have the power to run the same function *repeatedly*.
A decorator might work!

Here's a decorator that will run a given function up to 10 times (until no `AssertionError` is raised):

```python
def try_10_times(function):
    def wrapper():
        for attempts_left in reversed(range(10)):
            try:
                return function()
            except AssertionError:
                if attempts_left == 0:
                    raise
    return wrapper
```

To use this decorator, we would need to define a function and then call that function:

```python
@try_10_times
def assertions():
    micro_time = time(micro_numbers)
    tiny_time = time(tiny_numbers)
    self.assertLess(tiny_time, micro_time*n)

assertions()
```

This isn't *quite* good enough though...

1. We need a pattern to run code N times (not necessarily exactly 10)
2. We reference the variables defined in each block in later blocks, so `micro_time` and `tiny_time` will need to be available *outside* that function
3. We need this function to run just one time right after it's defined... could we do that automatically?

All 3 of these problems are solvable:

1. We need a decorator that accepts arguments
2. We need to use *rarely seen* [`nonlocal`](https://stackoverflow.com/a/1261961/98187) statement
3. We could have the decorator automatically call the decorated function


## The final *weird* decorator

Here's the decorator I ended up with:

```python
def attempt_n_times(n):
    """
    Run tests multiple times if assertions are raised.

    Allows for more forgiving tests when assertions may be a bit flaky.
    """
    def decorator(function):
        """This looks like a decorator, but it actually runs the function!"""
        for attempts_left in reversed(range(n)):
            try:
                return function()
            except AssertionError:
                if attempts_left == 0:
                    raise
    return decorator
```

This decorator accepts an `n` argument which determines the maximum number of times the decorated function should be called.
The decorator then *calls* the function repeatedly in a `for` loop and a `try`-`except` block.
As soon as an `AssertionError` is *not* raised during one of these function calls, the looping stops.

The *weirdest* part about this decorator is that it calls the decorated function.
Note that the `decorator` function doesn't define a `wrapper` function within itself... it just runs code right away!


## The resulting beautiful Python monstrosity

Here's the final refactored test code:

```python
def test_some_test(self):
    n, m = 2.45, 2.04
    micro_time = tiny_time = small_time = medium_time = 0

    @attempt_n_times(10)
    def _():
        nonlocal micro_time, tiny_time
        micro_time = time(micro_numbers)
        tiny_time = time(tiny_numbers)
        self.assertLess(tiny_time, micro_time*n)

    @attempt_n_times(5)
    def _():
        nonlocal small_time
        small_time = time(small_numbers)
        self.assertLess(small_time, tiny_time*n)
        self.assertLess(small_time, micro_time*n*m)

    @attempt_n_times(3)
    def _():
        nonlocal medium_time
        medium_time = time(medium_numbers)
        self.assertLess(medium_time, micro_time*n*m*m)
        self.assertLess(medium_time, tiny_time*n*m)
        self.assertLess(medium_time, small_time*n)
```

The `attempt_n_times` decorator **immediately calls the function it decorates**.
Each function is defined and immediately called one or more times, in a `try`-`except` block within a loop.

That's why we've named these functions with the [throwaway][] `_` name: **we don't care about the name of a function we're never going to refer to again**.

Also note the use of the `nonlocal` statement.
Each function in Python has its own scope and all assignments [assign to the local scope][local] by default.
That `nonlocal` variable pulls those variables to the scope of the outer function instead.

Compare the above code to the code just before this refactor:

```python
def test_some_test(self):
    n, m = 2.45, 2.04

    for attempts_left in reversed(range(10)):
        try:
            micro_time = time(micro_numbers)
            tiny_time = time(tiny_numbers)
            self.assertLess(tiny_time, micro_time*n)
            break
        except AssertionError:
            if attempts_left == 0:
                raise

    for attempts_left in reversed(range(5)):
        try:
            small_time = time(small_numbers)
            self.assertLess(small_time, tiny_time*n)
            self.assertLess(small_time, micro_time*n*m)
            break
        except AssertionError:
            if attempts_left == 0:
                raise

    for attempts_left in reversed(range(3)):
        try:
            medium_time = time(medium_numbers)
            self.assertLess(medium_time, micro_time*n*m*m)
            self.assertLess(medium_time, tiny_time*n*m)
            self.assertLess(medium_time, small_time*n)
            break
        except AssertionError:
            if attempts_left == 0:
                raise
```

I find the refactored version easier to skim.

But that `attempt_n_times` decorator *does* abuse the decorator syntax.
Decorators aren't *meant* to call the function they're decorating.

Is this misuse of decorators worth it?

## Is this worth it?

Decorators aren't supposed to immediately call the function they decorate.
But there's nothing stopping them from doing so.
I feel that I've traded "normal code" for a beautiful monstrosity that's easier to skim at a glance.

The `attempt_n_times` decorator is pretending that it's a block-level tool by using a function because there's no other way to invent such a tool in Python.

I think abstracting away the `for`-`try`-`break`-`except`-`if`-`raise` pattern was worth it, even though I ended up abusing Python's decorator syntax in the process.

What do you think?
Was that `attempt_n_times` abstraction worth it?


[time complexity]: https://www.pythonmorsels.com/time-complexities/
[python morsels]: https://www.pythonmorsels.com
[type errors]: https://en.wikipedia.org/wiki/Type_I_and_type_II_errors
[dry]: https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
[damp]: https://stackoverflow.com/questions/6453235/what-does-damp-not-dry-mean-when-talking-about-unit-tests
[throwaway]: https://stackoverflow.com/questions/36315309/how-does-python-throw-away-variable-work
[local]: https://www.pythonmorsels.com/local-and-global-variables/#assigning-to-local-and-global-variables
