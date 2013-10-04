---
layout: post
title: Visual Integration Tests for Django
date: 2013-10-03 15:19
comments: true
---

I recently added a new type of test to my testing arsenal: visual tests.  Visual tests ensure the CSS, markup, and JavaScript produce a webpage that looks right.

I now separate my web application tests into three groups:

1. Unit tests: test single functional units
2. Integration tests: tests full features end-to-end
3. Visual tests: tests that the web application looks pixel-perfect


## Visual testing suites

The visual testing tools I've found all do one thing: screenshot pages and diff the captured screenshots against pre-saved images to ensure they're the same.

Taking screenshots of a webpage requires a full-featured web browser to render the CSS and execute the JavaScript.  Selenium and PhantomJS are both great for in-browser integration tests and most of the visual testing tools I found use Selenium or PhantomJS.

I found three tools for visual testing and I found that only one of them met my needs.

### PhantomCSS

PhantomCSS uses PhantomJS for screenshot differencing.

PhantomCSS won't integrate directly with the Dango live server or your Python test suite, so if you want to run a visual integration test, you'd need to manually start the test server and setup test data between tests.

### Django-casper

Django-casper uses Django live server tests to execute CasperJS test files (which use PhantomJS) to compare screenshots.

Each test requires an additional Python test which references a JavaScript file that executes the navigation and screenshotting code.  I found this approach messy and difficult to setup.

### Needle

The needle Python library uses Selenium to navigate your website and screenshot rendered pages.

I had trouble integrating Needle with the Django so I added a mixin that can be used with a Django live server test case.  It works well for my needs, but I still occasionally find it tempermental.

This project seems to work, but it is in need of love.  Needle has poor test coverage, a seemingly failing test suite, and no change log.


## Continuous integration?

I don't run my visual tests during my continuous integration tests because they are very brittle and occasionally they break for no good reason (e.g. Google Maps is AB testing).
