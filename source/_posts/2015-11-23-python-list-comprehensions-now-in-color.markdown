---
layout: post
title: "Python List Comprehensions: Explained Visually"
date: 2015-11-23 13:11:36 -0800
comments: true
categories: python
---

Sometimes a programming design pattern becomes common enough to warrant its own special syntax.  In Python, list comprehensions are an example of such a syntactic sugar.

List comprehensions in Python are wonderful, but they're often tricky at first because:

1. They don't solve a new problem, they just provide a shorter syntax for solving an existing problem.
2. They don't have a direct analogue in many other programming languages

Let's learn what list comprehensions are and how to identify when to use them.

## What are list comprehensions?

List comprehensions are a tool for transforming one list (any [iterable][] actually) into another list.  During this transformation, elements can be conditionally included in the new list and each element can be transformed as needed.

If you're familiar with functional programming, you can think of list comprehensions as syntactic sugar for a ``filter`` followed by a ``map``.  If you're not familiar with functional programming, don't worry: I'll explain using `for` loops.

```pycon
>>> doubled_odds = map(lambda n: n * 2, filter(lambda n: n % 2 == 1, numbers))
>>> doubled_odds = [n * 2 for n in numbers if n % 2 == 1]
```

## From loops to comprehensions

Every list comprehension can be written as a `for` loop but not every `for` loop can be rewritten as a list comprehension.

Read that last sentence again.  The key to understanding when to use list comprehensions is to practice identifying problems that *smell* like list comprehensions.

If you can rewrite your `for` loop to look *just like this one*, you can also rewrite it as a list comprehension:

```python
new_things = []
for ITEM in old_things:
    if condition_based_on(ITEM):
        new_things.append("something with " + ITEM)
```

You can rewrite the above `for` loop as a list comprehension like this:

```python
new_things = ["something with " + ITEM for ITEM in old_things if condition_based_on(ITEM)]
```

## List Comprehensions: The Animated Movie™

That's great, but how did I do that?

I **copy-pasted** my way from a `for` loop to a list comprehension.

{% img /images/list-comprehension-condition.gif %}

Here's the order I copy-paste in:

1. Copy the assignment of the variable we'll be pointing to the new list (line 3)
2. Copy the expression that we've been appending into this new list (line 6)
3. Copy the `for` loop line, but don't copy the last `:` (line 4)
4. Copy the `if` statement line also without the last `:` (line 5)

We've now copied our way from this:

```python
numbers = [1, 2, 3, 4, 5]

doubled_odds = []
for n in numbers:
    if n % 2 == 1:
        doubled_odds.append(n * 2)
```

To this:

```python
numbers = [1, 2, 3, 4, 5]

doubled_odds = [n * 2 for n in numbers if n % 2 == 1]
```

## List Comprehensions: Now in Color

Let's use colors to highlight what's going on.

<pre class="colored-comprehension">
<span class="new-collection">doubled_odds</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span>:
    <span class="conditional-clause">if <span class="condition">n % 2 == 1</span></span>:
        <span class="new-collection">doubled_odds</span>.append(<span class="item-mutation">n * 2</span>)
</pre>

<pre class="colored-comprehension">
<span class="new-collection">doubled_odds</span> = <span class="collection-type">[</span><span class="item-mutation">n * 2</span> <span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span><span class="collection-type"> <span class="conditional-clause">if <span class="condition">n % 2 == 1</span></span>]</span>
</pre>

We copy-paste from a `for` loop into a list comprehension by:

1. Copying the <span class="new-collection">assignment of the variable</span> we'll be pointing to the <span class="collection-type">new list</span> (line 3)
2. Copying <span class="item-mutation">the expression that we've been appending</span> into this new list (line 6)
3. Copying <span class="for-loop">the "for" loop line</span>, but don't copy the last `:` (line 4)
4. Copying <span class="conditional-clause">the "if" statement line</span> also without the last `:` (line 5)


## Unconditional Comprehensions

But what about comprehensions that don't have a conditional clause (that `if SOMETHING` part at the end)?  These loop-and-append `for` loops are even simpler than the loop-and-conditionally-append ones we've already covered.

A `for` loops that doesn't have an `if` statement:

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span>:
    <span class="new-collection">doubled_numbers</span>.append(<span class="item-mutation">n * 2</span>)
</pre>

That same code written as a comprehension:

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[</span><span class="item-mutation">n * 2</span> <span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span><span class="collection-type">]</span>
</pre>

We can copy-paste our way from a simple loop-and-append `for` loop by:

1. Copying the <span class="new-collection">assignment of the variable</span> we'll be pointing to the <span class="collection-type">new list</span> (line 3)
2. Copying <span class="item-mutation">the expression that we've been appending</span> into this new list (line 5)
3. Copying <span class="for-loop">the "for" loop line</span>, but don't copy the last `:` (line 4)

Here's the same thing, animated:

{% img /images/list-comprehension-no-condition.gif %}

## Nested Loops

What list comprehensions with nested looping?... Someone's playing on hard mode. 😦

Nested loops in comprehensions do not read like English prose.  They're the reverse of the way my brain reads it.

My brain wants to write list comprehensions like this:

<pre class="colored-comprehension">
flattened = [n for n in row for row in matrix]
</pre>

But that's not right!  I've accidentally flipped the `for` loops in that comprehension.

Let's take a closer look at this example.  Here's a `for` loop that flattens our matrix:

<pre class="colored-comprehension">
<span class="new-collection">flattened</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">row</span> in <span class="old-collection">matrix</span></span>:
    <span class="nested-for-loop">for <span class="item">n</span> in <span class="old-collection">row</span></span>:
        <span class="new-collection">flattened</span>.append(<span class="item-mutation">n</span>)
</pre>

Here's a list comprehension that does the same thing:

<pre class="colored-comprehension">
<span class="new-collection">flattened</span> = <span class="collection-type">[</span><span class="item-mutation">n</span> <span class="for-loop">for <span class="item">row</span> in <span class="old-collection">matrix</span></span><span class="collection-type"> <span class="nested-for-loop">for <span class="item">n</span> in <span class="old-collection">row</span></span><span class="collection-type">]</span>
</pre>

When working with nested loops in list comprehensions remember that **the `for` clauses remain in the same order as in our original `for` loops**.




## Other Comprehensions

This same principle works for set comprehensions, dictionary comprehensions, and generator expressions.

You probably won't need set and dictionary comprehensions as often as list comprehensions, but it's nice to have a cheat sheet for when you do.

Code that makes a set containing letters that appear as the first letter in a sequence of words:

<pre class="colored-comprehension">
<span class="new-collection">first_letters</span> = <span class="collection-type">set()</span>
<span class="for-loop">for <span class="item">w</span> in <span class="old-collection">words</span></span>:
    <span class="new-collection">first_letters</span>.add(<span class="item-mutation">w[0]</span>)
</pre>

That same code written as a set comprehension:

<pre class="colored-comprehension">
<span class="new-collection">first_letters</span> = <span class="collection-type">{</span><span class="item-mutation">w[0]</span> <span class="for-loop">for <span class="item">w</span> in <span class="old-collection">words</span></span><span class="collection-type">}</span>
</pre>

Dictionary comprehensions are a little more complicated since they need both keys and values.  You'll need to do slightly more than just copy-paste.  Basically you just need to convert `[new_key] = new_value` to `new_key: new_value`.

Code that makes a new dictionary, swapping the keys and values of the original one:

<pre class="colored-comprehension">
<span class="new-collection">flipped</span> = <span class="collection-type">{}</span>
<span class="for-loop">for <span class="item">key, value</span> in <span class="old-collection">original.items()</span></span>:
    <span class="new-collection">flipped</span>[<span class="item-mutation">value</span>] = <span class="item-mutation">key</span>
</pre>

That same code written as a dictionary comprehension:

<pre class="colored-comprehension">
<span class="new-collection">flipped</span> = <span class="collection-type">{</span><span class="item-mutation">value</span>: <span class="item-mutation">key</span> <span class="for-loop">for <span class="item">key, value</span> in <span class="old-collection">original.items()</span></span><span class="collection-type">}</span>
</pre>

As for generator expressions, those are just list comprehensions optimized for immediate consumption.

## Learn with me

I did a class on list comprehensions with PyLadies remote recently.

If you'd like to watch me walk through an explanation of any of the above topics, check out the video:

1. list comprehensions
2. generator expressions
3. set comprehensions
4. dictionary comprehensions


## Summary

- In summary
  - If "for loop" can be transformed into one of these forms, a comprehension can be made from it
  - When struggling to write a list comprehension, write a for loop in one of those formats and copy-paste your way into a list comprehension
- Want to know more about list comprehensions? I taught a PyLadies Remote class on list comprehensions recently. Here's the link

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span>:
    <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>:
        <span class="new-collection">new_things</span>.append(<span class="item-mutation">"something with " + ITEM</span>)
</pre>

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[</span><span class="item-mutation">"something with " + ITEM</span> <span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span><span class="collection-type"> <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>]</span>
</pre>

This blog post was based on my Intro to Python class.  If you're interested in chatting about Python training, drop me a line.

I have more Python blog posts in development and I'm planning to publish at least one Python mailing list soon.  If you're interested in learning more from me, subscribe to my newsletter below.


[iterable]: https://docs.python.org/3/glossary.html#term-iterable
