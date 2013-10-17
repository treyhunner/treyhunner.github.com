---
layout: post
title: Visual Integration Tests for Django
date: 2013-10-03 15:19
comments: true
---

I recently added a new type of test to my testing arsenal: visual tests.  Visual tests ensure the CSS, markup, and JavaScript produce a webpage that looks right.


## Visual testing suites

Visual testing tools compare screenshots to ensure tested webpages look pixel perfect.  Capturing webpage screenshots requires a full-featured web browser to render CSS and execute JavaScript.  All three of the visual testing tools I found rely on Selenium or PhantomJS for rendering.

### PhantomCSS

[PhantomCSS][] uses PhantomJS for screenshot differencing.  PhantomCSS won't integrate directly with the Django live server or your Python test suite, so if you want to run a visual integration test, you'd need to manually start and stop the test server between tests.  I might eventually try out PhantomCSS for CSS unit tests, but I wanted to visually test my full website so I found the lack of integration with the Django live server.

### Django-casper

[Django-casper][] uses Django live server tests to execute CasperJS test files (which use PhantomJS) to compare screenshots.  Each test requires an additional Python test which references a JavaScript file that executes the navigation and screenshotting code.  I found this approach messy and difficult to setup.

### Needle

The [needle][] Python library uses Selenium to navigate your website and screenshot rendered pages.  Unfortunately needle has poor test coverage, a seemingly failing test suite, and no change log.  Despite these shortcomings, I went with needle for my visual integration tests because it got the job done.


## Django and Needle

I used the following mixin to integrate the Django live server with needle.  I used PhantomJS, but Firefox or another Selenium web driver should work as well.

```python
from django.test import LiveServerTestCase
from needle.cases import NeedleTestCase
from selenium.webdriver import PhantomJS


class DjangoNeedleTestCase(NeedleTestCase, LiveServerTestCase):

    """Needle test case for use with Django live server"""

    driver = PhantomJS

    @classmethod
    def get_web_driver(cls):
        return type('NeedleWebDriver', (NeedleWebDriverMixin, cls.driver), {})()
```

Unfortunately the above code only works with the version of needle on Github.  The PyPI version does not yet include the `NeedleWebDriverMixin` (which I contributed recently for Django support).  I have created [an issue][PyPI issue] suggesting a new PyPI release be made to resolve this problem.


## Continuous integration

Currently I only run my visual tests manually.  Visual tests are very brittle and occasionally they just break without any changes.  If I manage to stabilize my visual tests so that they pass consistently on different platforms, I may add them to my continuous integration test suite.

[PhantomCSS]: https://github.com/Huddle/PhantomCSS
[django-casper]: https://github.com/dobarkod/django-casper
[needle]: https://github.com/bfirsh/needle
[pypi issue]: https://github.com/bfirsh/needle/issues/13
