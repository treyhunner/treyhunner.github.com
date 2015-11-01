---
layout: post
title: Log all outgoing emails in Django
type: post
published: true
comments: true
categories: django python
---

Ever needed to determine whether an email was sent from a Django project?  I
made a Django application that does exactly that: [django-email-log][].

I got the idea from [a StackOverflow answer][] and I decided to make a real
application out of it.  All emails are stored in a single model which can
easily be viewed, searched, sorted, and filtered from the admin site.

I used test-driven development when making the app and I baked in Python 3
support from the beginning.  I found the process of TDD for a standalone
Python package fairly easy and enjoyable.

[django-email-log]: https://github.com/treyhunner/django-email-log
[a stackoverflow answer]: http://stackoverflow.com/a/7553759/98187
