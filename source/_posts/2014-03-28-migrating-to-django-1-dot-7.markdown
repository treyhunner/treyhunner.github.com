---
layout: post
title: "Supporting both Django 1.7 and South"
date: 2014-03-27 13:05
comments: true
categories: 
---

Have an open source Django app with South migrations?  Adding support for Django 1.7 might be a little painful.  In this post I will discuss the difficulty of supporting Django 1.7 while maintaining South migrations for users of Django 1.6 and below.

Django 1.7 uses the `migrations` sub-package in your app for database migrations and South relies on the same package.  Unfortunately, you can't store both packages in the same place.  At first glance, it seems we cannot support both Django 1.7 and previous versions of Django using South.  However, as I explain below, we can support both at once.

## Assessing your options

In order to support both Django 1.7 and Django 1.6 with South we can rename the `migrations` package and instruct users to reference the new package in their settings module.  We can do this with the [MIGRATION_MODULES][] or [SOUTH_MIGRATION_MODULES][] settings.  There are three options:

1. Move existing `migrations` directory to `south_migrations` and create Django 1.7 migrations in `migrations` package
2. Create new Django 1.7 migrations package in `django_migrations` directory and leave existing South migrations package
3. Move existing `migrations` directory to `south_migrations` and create Django 1.7 migrations in `django_migrations` directory

The first option requires existing users either switch to Django 1.7 or update their settings module before upgrading to the new version of your app.  The second option requires all Django 1.7 users to customize their settings module to properly install your app.  The third option requires everyone (both Django 1.7 and South users) to update their settings module.

Out of those options I prefer the first one.  When you eventually drop support for South, you will probably want your Django 1.7 migrations to live in the `migrations` directory.  If you don't force that switch now, you would eventually need to break backwards-compatibility or maintain two duplicate migrations directories.

So our plan is to move the South migrations to `south_migrations` and create Django 1.7 migrations.  An example with the [django-email-log][] app:

```bash
$ git mv email_log/migrations email_log/south_migrations
$ python manage.py makemigrations email_log
$ git add email_log/migrations
```

## Breaking South support

If you move `migrations` to `south_migrations` and make a Django 1.7 `migrations` package, what happens to existing users with South?

Your new app upgrade will break backwards compatibility for South users and you want to make sure they *know* they need to make a change immediately after upgrading.  Users should see a loud and clear error message instructing them what they need to do.  This can be done by hijacking their use of the **migrate** command with South.

Existing users will run **migrate** when upgrading your app.  If they don't migrate immediately, they will when they notice a problem and realize they need to run **migrate**.  Upon migrating, we want to show a clear error message telling the user what to do.

## Failing loudly and with a clear error message

When South looks for app migrations it will import our `migrations` package.  Our `migrations` package contains Django 1.7 migrations, which South won't understand.  So we want to make sure that if our `migrations` package is imported either Django 1.7 is installed or a proper error message is displayed.  Upon importing this package, we can check for the presence of the new `django.db.migrations` module and if not found we will raise an exception with a descriptive error message.

For example, this is the code I plan to add to the ``email_log/migrations/__init__.py`` file for [django-email-log][] to add Django 1.7 support:

```python
"""
Django migrations for email_log app

This package does not contain South migrations.  South migrations can be found
in the ``south_migrations`` package.
"""

SOUTH_ERROR_MESSAGE = """\n
For South support, customize the SOUTH_MIGRATION_MODULES setting like so:

    SOUTH_MIGRATION_MODULES = {
        'email_log': 'email_log.south_migrations',
    }
"""

# Ensure the user is not using Django 1.6 or below with South
try:
    from django.db import migrations  # noqa
except ImportError:
    from django.core.exceptions import ImproperlyConfigured
    raise ImproperlyConfigured(SOUTH_ERROR_MESSAGE)
```

Now when we run **migrate** with Django 1.6 and South, we'll see the following exception raised:

```
django.core.exceptions.ImproperlyConfigured:

For South support, customize the SOUTH_MIGRATION_MODULES setting like so:

    SOUTH_MIGRATION_MODULES = {
        'email_log': 'email_log.south_migrations',
    }
```

## Conclusion

This breaks backwards compatibility, but our users should immediately understand what has broken and how to fix it.  Remember to upgrade the major number of your package version to note this backwards-incompatible change.

I would love to hear your thoughts about this approach in the comments below.  Let me know if you have other ideas about how to handle supporting Django 1.7 migrations and South at the same time.

[django-email-log]: https://github.com/treyhunner/django-email-log
[MIGRATION_MODULES]: https://docs.djangoproject.com/en/1.7/ref/settings/#std:setting-MIGRATION_MODULES
[SOUTH_MIGRATION_MODULES]: http://south.readthedocs.org/en/latest/settings.html#south-migration-modules
