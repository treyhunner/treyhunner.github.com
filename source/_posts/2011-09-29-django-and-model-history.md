---
layout: post
title: Django and model history
type: post
published: true
comments: true
---
Recently I had a need to store a snapshot of every state of particular model instance in a Django application.  I basically needed version control for the rows in my database tables.  When searching for applications that provided this feature, which I call **model history**, I found [many different approaches][model-audit] but few good comparisons of them.  In an attempt to fill that void, I'm going to detail some of my findings here.

### django-reversion

The [django-reversion][] application was started in 2008 by Dave Hall.  Reversion uses only one table to store data for all version-tracked models.  Each version of a model adds a new row to this table, using a JSON object representing the model state.  Models can be reverted to previous versions from the admin interface.  This single-table version structure makes django-reversion very easy to install and to uninstall, but it also creates [problems when model fields are changed][reversion problem].

### django-revisions

The [django-revisions][] application was created by Stijn Debrouwere in 2010 because the existing Django model history applications at the time were abandoned or suffered from fundamental design problems.  Revisions uses a model history method called same-table versioning ([design details outlined here][revisions design]).  Same-table versioning adds a few fields to each version-tracked model which allows it to record the most recent version of each model as well as old versions in the original model table.  Model changes are simplified because they change all versions at once and no new tables need to be added to use revisions (just new fields on existing tables).  The only problem I found with revisions was that it does not currently support database-level uniqueness constraints.  Adding `unique=True` to a model field or a `unique_together` Meta attribute will result in an error.  Currently uniqueness constraints must be specified in a separate way for Revisions to honor them when saving models.

### django-simple-history

The [django-simple-history][] application was based on code originally written by Marty Alchin, author of Pro Django.  Marty Alchin posted [AuditTrail][] on the Django trac wiki in 2007 and later revised and republished the code in his book Pro Django in 2008, renaming it to HistoricalRecords.  Corey Bertram created django-simple-history from this code and put it online in 2010.

Simple History works by creating a separate "historical" model for each model that requires an audit trail and storing a snapshot of each changed model instance in that historical model.  For example, a Book model would have a HistoricalBook created from it that would store a new HistoricalBook instance every time a Book instance was changed.  Collisions are avoided by disabling uniqueness constraints and model schema changes are accepted by automatically changing historical models as well.  This method comes at the cost of creating an extra table in the database for each model that needs history.

### My conclusions

When testing these three applications myself, I immediately eliminated django-reversion because I needed to allow easy model schema changes for my project.  I found that both django-revisions and django-simple-history worked well with schema migrations through [South][] (which I use on everything).  Django-revisions worked better for data migrations in South (due to only needing to change one model), but the uniqueness constraint problems with django-revisions would have been problematic for some of my models.  So eventually I settled on [django-simple-history][].

[model-audit]: http://djangopackages.com/grids/g/model-audit/
[django-reversion]: http://stdbrouw.github.com/django-revisions/
[django-revisions]: https://github.com/etianen/django-reversion
[django-simple-history]: https://bitbucket.org/q/django-simple-history/
[audittrail]: https://code.djangoproject.com/wiki/AuditTrail
[south]: http://south.aeracode.org/docs/about.html

[reversion problem]: http://groups.google.com/group/django-reversion/browse_thread/thread/922b4e42d9577e0b
[revisions design]: http://stdbrouw.github.com/django-revisions/design.html
