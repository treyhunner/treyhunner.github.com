---
layout: post
title: Random name generator in Python
type: post
published: true
categories: python
---

I've used multiple websites to generate random names for my test data when
running manual or automated QA tests.

Since discovering DuckDuckGo's [random word][] generation, I've
[hoped][random names] that someone would make a DuckDuckGo plugin to generate
random names also.

I didn't want to write my own DuckDuckGo plugin yet so I made a Python-powered
command line tool instead using [1990 Census data][census].

The program is called `names` and can be found on [Github][] and [PyPI][].

### It's really simple

It's basically just one file currently that's [about 40 lines long][current].
There is only one feature available from the command line currently: generate a
single random full name.  There's a few more features if importing as a Python
package: generate random last name or generate random first name (with or
without specifying gender), generate random full name (also without or without
gender).

The random name picker relies on the cumulative frequencies listed in the
included Census data files.  Here's the steps that are taken:
1. A random floating point number is chosen between 0.0 and 90.0
2. Name file lines are iterated through until a cumulative frequency is found
that is less than the randomly generated number
3. The name on that line is chosen and returned (or printed out)

### Examples

Here's how you use it from the command line:

    $ names
    Kara Lopes

Here's how you use it as a Python package:

    >>> import names
    >>> names.get_full_name()
    u'Patricia Halford'
    >>> names.get_full_name(gender='male')
    u'Patrick Keating'
    >>> names.get_first_name()
    'Bernard'
    >>> names.get_first_name(gender='female')
    'Christina'
    >>> names.get_last_name()
    'Szczepanek'

[random names]: https://duckduckhack.uservoice.com/forums/5168-ideas-for-duckduckgo-instant-answer-plugins/suggestions/2850418-random-name
[random word]: https://duckduckgo.com/?q=random+word
[census]: https://www.census.gov/genealogy/www/data/1990surnames/index.html
[github]: https://github.com/treyhunner/names
[pypi]: http://pypi.python.org/pypi/names/0.1
[current]: https://github.com/treyhunner/names/blob/f99542dc21f48aa82da4406f8ce408e92639430d/names/__init__.py
