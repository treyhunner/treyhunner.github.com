---
layout: post
title: django-simple-history is back
type: post
published: true
comments: true
---

I wrote [a post][model history post] over a year ago about recording a history of changes for Django model instances.  I evaluated three different Django packages to record model history.  My favorite of the options, django-simple-history, was abandoned and development continued through multiple forks.

I recently attempted to revive [django-simple-history][github page].  I added tests, put it [on PyPI][], and made it easier to use with newer versions of Django.  I moved my fork of the project to git and Github, added Travis and Coveralls support for continuous integration and code coverage tracking, and noted future features on the issue tracker.

Soon after I started writing tests for the project I received feature requests, issues, pull requests, and emails with words of encouragement.  I appreciate all of the help I've had while reviving the project.  I plan to remain responsive to the suggestions for my fork of the code.  If you'd like to help out with the project please feel free to submit an issue, make a pull request, or comment on the code commits on the [Github page][].

[model history post]: http://treyhunner.com/2011/09/django-and-model-history/
[Github page]: https://github.com/treyhunner/django-simple-history
[on PyPI]: https://pypi.python.org/pypi/django-simple-history/
