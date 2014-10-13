---
layout: post
title: "The many flavors of mock.patch"
date: 2014-09-29 08:42:16 -0700
comments: true
categories: 
---

I write a lot of unit tests.  Unfortunately, my code often requires monkey patching to be properly unit tested.  I frequently use the ``patch`` function from [Michael Foord's][voidspace] [mock][] library to monkey patch my code.

While chatting with other users of ``patch``, I realized that everyone seems to have their own favorite way to use it.  In this post I will discuss the ways I use patch.


### Decorator

patch can be used as a method decorator:

```python
from mock import patch

class MyModelTest:
    @patch('mylib.utils.other_func')
    def test_some_func(self, other_func):
        other_func.return_value = "MY STRING"
        assert some_func("my string") == "MY STRING"
        other_func.assert_called_once_with("my string")
```

or as a class decorator:

```python
from mock import patch

@patch('mylib.utils.other_func')
class MyModelTest:
    def test_some_func(self, other_func):
        other_func.return_value = "MY STRING"
        assert some_func("my string") == "MY STRING"
        other_func.assert_called_once_with("my string")
```

I use patch as a decorator when I have a function I want patched during my whole test.  I tend not to use patch as a class decorator and I'll explain why below.

[Decorator example][]


### Context Manager

patch can be used as a context manager:

```python
from mock import patch

class MyModelTest:
    def test_some_func(self):
        other_func.return_value = "MY STRING"
        with patch('mylib.utils.other_func') as other_func:
            assert some_func("my string") == "MY STRING"
        other_func.assert_called_once_with("my string")
```

I prefer to use patch as a context manager when I want to patch a function for only part of a test.  I do not use patch as a context manager when I want a function patched for an entire test.

[Context manager example][]


### Manually using start and stop

patch can also be used to manually patch/unpatch using `start` and `stop` methods:

```python
from mock import patch

class MyModelTest:

    def setUp(self):
        self.other_func_patch = patch('mylib.utils.other_func')
        self.other_func = self.other_func_patch.start()
        self.other_func.return_value = "MY STRING"

    def tearDown(self):
        self.other_func_patch.stop()

    def test_some_func(self):
        assert some_func("my string") == "MY STRING"
        self.other_func.assert_called_once_with("my string")
```

I prefer to use patch using start/stop when I need a function to be patched for every function in a test class.

This is probably the most common way I use patch in my tests.  I often group my tests into test classes where each method is focused around testing the same function.  Therefore I will usually want the same functions/objects patched for every test method.

I noted above that I prefer not to use class decorators to solve this problem.  Instead, I prefer to use test class attributes to store references to patched functions instead of accepting patch arguments on every test method with decorators.  I find this more [DRY][].

[start and stop example][]


### Summary

Patch can be used:

1. as a method or class decorator
2. as a context manager
3. using start and stop methods

I prefer my tests to be readable, [DRY][], and easy to modify.  I tend to use start/stop methods for that reason, but I also frequently use patch method decorators and sometimes use patch context managers.  It's useful to know the different flavors of `patch` because your favorite flavor may not always be the most suitable one for the problem at hand.

Did I miss a flavor?  Want to let me know which flavor you prefer and why?  Please comment below.


[context manager example]: https://github.com/treyhunner/pep438/blob/cdb57e2cb1c3053255a0caf2a5ebb64672da661c/test_pep438.py#L46
[decorator example]: https://github.com/treyhunner/pep438/blob/cdb57e2cb1c3053255a0caf2a5ebb64672da661c/test_pep438.py#L79
[dry]: https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
[start and stop example]: https://github.com/treyhunner/pep438/blob/cdb57e2cb1c3053255a0caf2a5ebb64672da661c/test_pep438.py#L128
[mock]: https://pypi.python.org/pypi/mock/
[voidspace]: http://www.voidspace.org.uk/
