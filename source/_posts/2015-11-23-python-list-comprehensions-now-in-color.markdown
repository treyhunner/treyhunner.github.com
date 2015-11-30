---
layout: post
title: "Python List Comprehensions, Now in Color"
date: 2015-11-23 13:11:36 -0800
comments: true
categories: python
---

- In summary
  - If "for loop" can be transformed into one of these forms, a comprehension can be made from it
  - When struggling to write a list comprehension, write a for loop in one of those formats and copy-paste your way into a list comprehension
- Want to know more about list comprehensions? I taught a PyLadies Remote class on list comprehensions recently. Here's the link

## What are list comprehensions?

Sometimes a programming design pattern becomes common enough to warrant its own special syntax.  List comprehensions are an example of such a syntactic sugar.

List comprehensions don't solve a new problem, they mostly just provide a shorter syntax for solving an existing problem.

Because list comprehensions don't have much of an analogue in other languages, they can often be tricky to understand at first.

## Transform loops to comprehensions

Every list comprehension can be written as a "for" loop but not every "for" loop can be rewritten as a list comprehension.

If your `for` loop can be rewritten to look like this, you can rewrite it as a list comprehension:

<pre class="colored-comprehension">
new_things = []
for ITEM in old_things:
    if condition_based_on(ITEM):
        new_things.append("something with " + ITEM)
</pre>

You can rewrite the above `for` loop as a list comprehension like this:

<pre class="colored-comprehension">
new_things = ["something with " + ITEM for ITEM in old_things if condition_based_on(ITEM)]
</pre>

## How I see list comprehensions

- Here's the way I think of list comprehensions:
  - If you can write your "for loop" in a particular way then you can rewrite it as a comprehension
  - You can build your list comprehension by just copy-pasting parts of your "for loop"
  - Here's a color-coded version of the various "for loops" and list comprehensions
  - Here are animated versions of the "for loops" too

If you can write your "for" loop in one of these ways, then you can also rewrite it as a comprehension.

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span>:
    <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>:
        <span class="new-collection">new_things</span>.append(<span class="item-mutation">"something with " + ITEM</span>)
</pre>

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[</span><span class="item-mutation">"something with " + ITEM</span> <span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span><span class="collection-type"> <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>]</span>
</pre>

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span>:
    <span class="new-collection">doubled_numbers</span>.append(<span class="item-mutation">n * 2</span>)
</pre>

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[</span><span class="item-mutation">n * 2</span> <span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span><span class="collection-type">]</span>
</pre>

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span>:
    <span class="conditional-clause">if <span class="condition">n % 2 == 1</span></span>:
        <span class="new-collection">doubled_numbers</span>.append(<span class="item-mutation">n * 2</span>)
</pre>

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[</span><span class="item-mutation">n * 2</span> <span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span><span class="collection-type"> <span class="conditional-clause">if <span class="condition">n % 2 == 1</span></span>]</span>
</pre>
