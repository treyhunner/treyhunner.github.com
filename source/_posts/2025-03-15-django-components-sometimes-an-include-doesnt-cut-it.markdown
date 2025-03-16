---
layout: post
title: "Django components: sometimes an include doesn't cut it"
date: 2025-03-15 21:00:00 -0700
comments: true
categories: django
---

Have you ever wished that Django's `include` template tag could accept blocks of content?

I have.

Unfortunately, Django's `{% raw %}{% include %}{% endraw %}` tag doesn't accept blocks of text.

Let's look at a few possible solutions to this problem.


## The Problem: Hack Include Workarounds

Let's say we have HTML and CSS that make up a modal that is powered by Alpine.js and HTMX and we want to include this base modal template into many different templates for many different actions.

The problem is that the main content of our modal changes for different use cases.

We could try to fix this problem by breaking up our "include" into two parts (a top and a bottom).

Here's the top include (`_modal_top.html`):

```
<div
  x-data="{}"
  id="base-modal"
  {{ close_event }}="$dispatch('close-modal')"
  x-on:keydown.escape.prevent.stop="$dispatch('close-modal')"
  x-on:close-modal.stop="$el.remove()"
  role="dialog"
  aria-modal="true"
  x-id="['modal-title']"
  :aria-labelledby="$id('modal-title')"
  class="tw-fixed tw-inset-0 tw-z-10 tw-overflow-y-auto"
  style="z-index: 2000;"
>
  <!-- Overlay -->
  <div x-transition.opacity class="tw-fixed tw-inset-0 tw-bg-black tw-bg-opacity-50"></div>

  <!-- Panel -->
  <form
    id="modal-panel"
    hx-{{ htmx_method }}="{{ htmx_action }}"
    hx-select="#modal-panel"
    hx-swap="outerHTML"
    x-transition
    x-on:click="$dispatch('close-modal')"
    class="tw-relative tw-flex tw-min-h-screen tw-items-center tw-justify-center tw-p-4"
  >
    <div
        x-on:click.stop
        x-trap.noscroll.inert="true"
        class="tw-relative tw-w-full tw-max-w-lg tw-overflow-y-auto tw-rounded-xl tw-bg-white tw-p-6 tw-shadow-lg"
    >
      <!-- Title -->
      <h5 h:id="$id('modal-title')">{{ title }}</h5>
```

And here's the bottom include (`_modal_bottom.html`):

```
    </div>
  </form>
</div>
```

This is how we might use these modals:

```
{% raw %}{% url "api:delete" object.pk as delete_url %}
{% include "_modal_top.html" title="Delete Object" close_event="@solution-deleted.window" htmx_method="delete" htmx_action=delete_url %}

<div class="tw-mt-7 tw-text-gray-600">
  <p>Are you sure you want to delete <strong>{{ object }}</strong>?</p>
</div>

<div class="tw-mt-9 tw-flex tw-justify-end tw-space-x-2">
  <button class="btn btn-danger" type="submit">Delete</button>
  <button class="btn btn-secondary" type="reset" x-on:click.prevent="$dispatch('close-modal')" data-dismiss="modal">Cancel</button>
</div>

{% include "_modal_bottom.html" %}
{% endraw %}
```

This is pretty awful.

What other solutions are there?


## One Solution: Just Copy-Paste

Instead of messy with includes, we could just copy-paste the HTML we need every time we need it:

```
{% raw %}<div
  x-data="{}"
  id="base-modal"
  @solution-deleted.window="$dispatch('close-modal')"
  x-on:keydown.escape.prevent.stop="$dispatch('close-modal')"
  x-on:close-modal.stop="$el.remove()"
  role="dialog"
  aria-modal="true"
  x-id="['modal-title']"
  :aria-labelledby="$id('modal-title')"
  class="tw-fixed tw-inset-0 tw-z-10 tw-overflow-y-auto"
  style="z-index: 2000;"
>
  <!-- Overlay -->
  <div x-transition.opacity class="tw-fixed tw-inset-0 tw-bg-black tw-bg-opacity-50"></div>

  <!-- Panel -->
  <form
    id="modal-panel"
    hx-delete="{% url "api:delete" object.pk %}"
    hx-select="#modal-panel"
    hx-swap="outerHTML"
    x-transition
    x-on:click="$dispatch('close-modal')"
    class="tw-relative tw-flex tw-min-h-screen tw-items-center tw-justify-center tw-p-4"
  >
    <div
        x-on:click.stop
        x-trap.noscroll.inert="true"
        class="tw-relative tw-w-full tw-max-w-lg tw-overflow-y-auto tw-rounded-xl tw-bg-white tw-p-6 tw-shadow-lg"
    >
      <!-- Title -->
      <h5 h:id="$id('modal-title')">Delete Object</h5>

      <!-- Content -->
      <div class="tw-mt-7 tw-text-gray-600">
        <p>Are you sure you want to delete <strong>{{ object }}</strong>?</p>
      </div>

      <!-- Buttons -->
      <div class="tw-mt-9 tw-flex tw-justify-end tw-space-x-2">
        <button class="btn btn-danger" type="submit">Delete</button>
        <button class="btn btn-secondary" type="reset" x-on:click.prevent="$dispatch('close-modal')" data-dismiss="modal">Cancel</button>
      </div>
    </div>
  </form>
</div>{% endraw %}
```

Honestly, I think this solution isn't a bad one.
Yes it is repetitive, but it's *so* much easier to understand and maintain this big block of fairly straightforward HTML.

The biggest downside to this approach is that enhancements made to one of the styling and features of these various copy-pasted modals will likely diverge over time if we're not careful to update all of them whenever we update one of them.


## A Better Solution: Components

If I was using a component-based front-end web framework, I might be tempted to push all this logic into that front-end framework.
But I'm not using a component-based front-end front-end web framework *and* I don't want to be forced to push any component-ish logic into the front-end.

Fortunately, in 2025, Django has [a number of component frameworks](https://djangopackages.org/grids/g/components/).

If we setup [django-cotton][], we could make a `cotton/modal.html` file like this:

```
{% raw %}<div
  x-data="{}"
  id="base-modal"
  {{ close_event }}="$dispatch('close-modal')"
  x-on:keydown.escape.prevent.stop="$dispatch('close-modal')"
  x-on:close-modal.stop="$el.remove()"
  role="dialog"
  aria-modal="true"
  x-id="['modal-title']"
  :aria-labelledby="$id('modal-title')"
  class="tw-fixed tw-inset-0 tw-z-10 tw-overflow-y-auto"
  style="z-index: 2000;"
>
  <!-- Overlay -->
  <div x-transition.opacity class="tw-fixed tw-inset-0 tw-bg-black tw-bg-opacity-50"></div>

  <!-- Panel -->
  <form
    id="modal-panel"
    hx-{{ htmx_method }}="{{ htmx_action }}"
    hx-select="#modal-panel"
    hx-swap="outerHTML"
    x-transition
    x-on:click="$dispatch('close-modal')"
    class="tw-relative tw-flex tw-min-h-screen tw-items-center tw-justify-center tw-p-4"
  >
    <div
        x-on:click.stop
        x-trap.noscroll.inert="true"
        class="tw-relative tw-w-full tw-max-w-lg tw-overflow-y-auto tw-rounded-xl tw-bg-white tw-p-6 tw-shadow-lg"
    >
      <!-- Title -->
      <h5 h:id="$id('modal-title')">{{ title }}</h5>

      <!-- Content -->
      <div class="tw-mt-7 tw-text-gray-600">
        {{ slot }}
      </div>

      <!-- Buttons -->
      <div class="tw-mt-9 tw-flex tw-justify-end tw-space-x-2">
        {{ buttons }}
      </div>

    </div>
  </form>
</div>{% endraw %}
```

We can then use our modal component like this:

```
{% raw %}<c-modal
  title="Delete Object"
  close_event="@solution-deleted.window"
  htmx_method="delete"
  htmx_action={% url "api:delete" object.pk %}
>
  <div class="tw-mt-7 tw-text-gray-600">
    <p>Are you sure you want to delete <strong>{{ object }}</strong>?</p>
  </div>

  <c-slot name="buttons">
    <button class="btn btn-danger" type="submit">Delete</button>
    <button class="btn btn-secondary" type="reset" x-on:click.prevent="$dispatch('close-modal')" data-dismiss="modal">Cancel</button>
  </c-slot>
</c-modal>{% endraw %}
```

I find this a *lot* easier to read than the `include` approach and a lot easier to maintain than the copy-pasted approach.


## The Downsides: Too Much Magic

The biggest downside I see to [django-cotton][] is that it's a bit magical.

If you see `<c-some-name>` in a template, you need to know that this includes things from `cotton/some_name.html`.

There are lots of [action at a distance](https://en.wikipedia.org/wiki/Action_at_a_distance) issues that come up with Django, which can make it feel a bit magical but which are nonetheless worthwhile tradeoffs.
But this one also doesn't look like a Django template tag, filter, or variable.
That feels *very* magical to me.

I've been enjoying trying out django-cotton over the past week and enjoying it.

Here are 2 other Django component libraries I have considered trying:

- [django-bird](https://github.com/joshuadavidthomas/django-bird) 
- [slippers](https://github.com/mixxorz/slippers)

I doubt I will try these 3, as they require writing Python code for each new component, which I would rather avoid:

- [django-components](https://github.com/django-components/django-components)
- [django-web-components](https://github.com/Xzya/django-web-components)
- [django-viewcomponent](https://github.com/rails-inspire-django/django-viewcomponent)

All Django component libraries (except for django-cotton) disallow line breaks between passed-in attributes due to a limitation of Django's template tags (see below).


## The Future: Multi-line Django Template Tags?

If Django's template tags could be wrapped over multiple lines, we could create a library that worked like this:

```
{% raw %}{% url "api:delete" object.pk as delete_url %}
{% component "_modal.html"
  title="Delete Object"
  close_event="@solution-deleted.window"
  htmx_method="delete"
  htmx_action=delete_ul
%}
  <div class="tw-mt-7 tw-text-gray-600">
    <p>Are you sure you want to delete <strong>{{ object }}</strong>?</p>
  </div>

  {% slot "buttons" %}
    <button class="btn btn-danger" type="submit">Delete</button>
    <button class="btn btn-secondary" type="reset" x-on:click.prevent="$dispatch('close-modal')" data-dismiss="modal">Cancel</button>
  {% endslot %}
{% endcomponent %}{% endraw %}
```

But that first multi-line `{% raw %}{% component %}{% endraw %}` tag is a big problem.
This is invalid in Django's template language because tags cannot have linebreaks within them (see [this old ticket](https://code.djangoproject.com/ticket/8652), [this discussion](https://forum.djangoproject.com/t/allow-newlines-inside-tags/36040), and [this new ticket](https://code.djangoproject.com/ticket/35899)):

```
{% raw %}{% component "_modal.html"
  title="Delete Object"
  close_event="@solution-deleted.window"
  htmx_method="delete"
  htmx_action=delete_ul
%}{% endraw %}
```

Until Django's template language allows tags to span over multiple lines, we're stuck with hacks like the ones that django-cotton uses.


[django-cotton]: https://django-cotton.com
