---
layout: post
title: "Keyword Argument Anti-Patterns in Python 3"
date: 2018-04-11 09:00:00 -0700
comments: true
categories: python
---

Python 3 includes a variety of new features involving the `*` and `**` packing/unpacking operators that didn't exist in Python 2.

Some of these features have caused certain Python 2 programming patterns to look a lot more like anti-patterns in Python 3 code.

In this article I'm going to discuss a number of Python 3 anti-patterns I've noticed in relation to working with keyword arguments.

If you aren't familiar with any of the features I discuss below, I recommend reading my article on [keyword arguments in Python][]


## Defining required keyword-only arguments

Let's say we have a function that we want to accept one positional argument `sequence` and one keyword-only argument `last`:

```pycon
>>> pairwise([1, 2, 3, 4], last=0)
[(1, 2), (2, 3), (3, 4), (4, 0)]
>>> pairwise([1, 2, 3, 4], 0)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: pairwise() takes 1 positional argument but 2 were given
```

So we want the `last` argument to be required and we want to require that it be specified using its name.

This function allows all of its arguments to be specified positionally:

```python
def pairwise(sequence, last):
    return list(zip(sequence, [*sequence[1:], last]))
```

You might occasionally see something like this code to require an argument to be named:

```python
def pairwise(sequence, **kwargs):
    last = kwargs.pop('last')
    assert not kwargs
    return list(zip(sequence, [*sequence[1:], last]))
```

Here we're using `**kwargs` to accept any number of keyword arguments.  Then we're popping off `last` (which requires that it be specified) and then asserting that no extra keyword arguments were specified.

This code works, but it's inelegant.  It's not the most readable code and it provides somewhat unclear error messages when called with too many or too few keyword arguments.

A better solution to this problem is to use `*`.  When you use `*` in a function definition, it signifies to Python that all arguments following it can only be specified as keyword arguments.

```python
def pairwise(sequence, *, last):
    return list(zip(sequence, [*sequence[1:], last]))
```

This feature has existed since Python 3.0 ([PEP 3102][] has more details).


## Defining keyword-only arguments with default values

Sometimes you'll see a slight variation of the code above to allow keyword-only arguments with default values.

This code passes a second argument to the dictionary `pop` method to default `last` to `None`:

```python
def pairwise(sequence, **kwargs):
    last = kwargs.pop('last', None)
    assert not kwargs
    return list(zip(sequence, [*sequence[1:], last]))
```

This allows us to leave off the `last` value:

```pycon
>>> pairwise([1, 2, 3, 4])
[(1, 2), (2, 3), (3, 4), (4, None)]
```

But it still requires `last` to be specified as a keyword argument:

```pycon
>>> pairwise([1, 2, 3, 4], 0)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: pairwise() takes 1 positional argument but 2 were given

```

This code again can be re-written pretty much the same way as before:

```python
def pairwise(sequence, *, last=None):
    return list(zip(sequence, [*sequence[1:], last]))
```

If you find code that uses the `get` method or the `pop` method on a captured keyword arguments dictionary, think about whether this `*` feature could be used instead.


## Removing a keyword argument while passing them on

It's common to capture all keyword arguments and pass them up to a parent class in Python.

You'll frequently see code like this:

```python
def __init__(*args, **kwargs):
    # Do something here
    super().__init__(*args, **kwargs)
```

It's not uncommon to specify your own keyword arguments in a child class which shouldn't be passed up to your parent class.

This pattern was common to see in Python 2:

```python
def __init__(self, *args, **kwargs):
    self.name = kwargs.pop('name', None)
    super().__init__(*args, **kwargs)
```

Just as we could avoid popping an item from our keyword arguments dictionary before, we can avoid it here as well.  That `*args` is similar to the lone `*` we saw before in that all arguments after it are keyword-only arguments.

We can do this to accept `name` as an optional keyword-only argument:

```python
def __init__(self, *args, name=None, **kwargs):
    self.name = name
    super().__init__(*args, **kwargs)
```

If we wanted `name` to be required, we'd just need to remove the default value:

```python
def __init__(self, *args, name, **kwargs):
    self.name = name
    super().__init__(*args, **kwargs)
```


## Passing on keyword arguments with a default value

What if we want to pass specific default values to our parent method?

You'll sometimes see code like this:

```python
def get_context_data(self, **kwargs):
    kwargs.setdefault('page', "Unknown")
    return super().get_context_data(**kwargs)
```

This is a method which accepts keyword arguments, makes sure the `page` keyword argument has a default value of "Unknown", and passes those keyword arguments to its parent method (this is inspired by Django's [get_context_data][] class-based view method).

We could do the same thing this way:

```python
def get_context_data(self, *, page="Unknown", **kwargs):
    return super().get_context_data(page=page, **kwargs)
```

Here we're again accepting a `page` keyword-only argument and setting its default value to "Unknown" it it's not specified.  Then we're passing the `page` keyword argument up to our parent class's `get_context_data` method.

This code does exactly the same thing as the code above it.  I'd argue that it's also more clear.


## Overriding the value of a passed on keyword argument

```python
def get_context_data(self, **kwargs):
    kwargs['form'] = self.form
    return super().get_context_data(**kwargs)
```

```python
def get_context_data(self, **kwargs):
    return super().get_context_data(**kwargs, form=self.form)
```


## Combining dictionaries of keyword arguments

```python
def get_context_data(self, **kwargs):
    kwargs.update(self.team_data())
    kwargs.update(self.user_data())
    return super().get_context_data(**kwargs)
```

```python
def get_context_data(self, **kwargs):
    kwargs = {**kwargs, **self.team_data(), **self.user_data()}
    return super().get_context_data(**kwargs)
```

```python
def get_context_data(self, **kwargs):
    return super().get_context_data(
        **kwargs,
        **self.team_data(),
        **self.team_data(),
    )
```


## Use keyword arguments more often!

What does the `1` represent in the `enumerate` call below?

```python
for n, line in enumerate(lines, 1):
    print(f"{n}: {line}")
```

What about `start=1` in this `enumerate` call?

```python
for n, line in enumerate(lines, start=1):
    print(f"{n}: {line}")
```

If you didn't know that `enumerate` took a second argument, you might feel the need to look up what it means.  But the name `start` makes it much more apparent what that `1` represents.

Regardless of what version of Python you're in, make sure you're embracing keyword arguments to improve the readability of your code.


## Your keyword argument check list


## Watch out for keyword argument anti-patterns

If you spot these anti-patterns in someone else's Python 3 code, consider kindly making a pull request.


[keyword arguments in Python]: http://treyhunner.com/2018/04/keyword-arguments-in-python/
[pep 3102]: https://www.python.org/dev/peps/pep-3102/
[get_context_data]: https://docs.djangoproject.com/en/2.0/ref/class-based-views/mixins-simple/#django.views.generic.base.ContextMixin.get_context_data
