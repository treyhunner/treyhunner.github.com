---
layout: post
title: "Python List Comprehensions: Explained Visually"
date: 2015-12-01 10:30:00 -0800
comments: true
categories: python
---

Sometimes a programming design pattern becomes common enough to warrant its own special syntax.  Python's list comprehensions are a prime example of such a syntactic sugar.

List comprehensions in Python are great, but mastering them can be tricky because they don't solve a new problem: they just provide a new syntax to solve an existing problem.

Let's learn what list comprehensions are and how to identify when to use them.

## What are list comprehensions?

List comprehensions are a tool for transforming one list (any [iterable][] actually) into another list.  During this transformation, elements can be conditionally included in the new list and each element can be transformed as needed.

If you're familiar with functional programming, you can think of list comprehensions as syntactic sugar for a ``filter`` followed by a ``map``:

```pycon
>>> doubled_odds = map(lambda n: n * 2, filter(lambda n: n % 2 == 1, numbers))
>>> doubled_odds = [n * 2 for n in numbers if n % 2 == 1]
```

If you're not familiar with functional programming, don't worry: I'll explain using `for` loops.

## From loops to comprehensions

Every list comprehension can be rewritten as a `for` loop but not every `for` loop can be rewritten as a list comprehension.

The key to understanding when to use list comprehensions is to practice identifying problems that *smell* like list comprehensions.

If you can rewrite your code to look *just like this `for` loop*, you can also rewrite it as a list comprehension:

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

That's great, but how did we do that?

We **copy-pasted** our way from a `for` loop to a list comprehension.

{% img /images/list-comprehension-condition.gif %}

Here's the order we copy-paste in:

1. Copy the variable assignment for our new empty list (line 3)
2. Copy the expression that we've been `append`-ing into this new list (line 6)
3. Copy the `for` loop line, excluding the final `:` (line 4)
4. Copy the `if` statement line, also without the `:` (line 5)

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

1. Copying the <span class="new-collection">variable assignment</span> for our <span class="collection-type">new empty list</span>
2. Copying <span class="item-mutation">the expression that we've been `append`-ing</span> into this new list
3. Copying <span class="for-loop">the `for` loop line</span>, excluding the final `:`
4. Copying <span class="conditional-clause">the `if` statement line</span>, also without the `:`

## Unconditional Comprehensions

But what about comprehensions that don't have a conditional clause (that `if SOMETHING` part at the end)?  These loop-and-append `for` loops are even simpler than the loop-and-conditionally-append ones we've already covered.

A `for` loop that doesn't have an `if` statement:

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span>:
    <span class="new-collection">doubled_numbers</span>.append(<span class="item-mutation">n * 2</span>)
</pre>

That same code written as a comprehension:

<pre class="colored-comprehension">
<span class="new-collection">doubled_numbers</span> = <span class="collection-type">[</span><span class="item-mutation">n * 2</span> <span class="for-loop">for <span class="item">n</span> in <span class="old-collection">numbers</span></span><span class="collection-type">]</span>
</pre>

Here's the transformation animated:

{% img /images/list-comprehension-no-condition.gif %}

We can copy-paste our way from a simple loop-and-append `for` loop by:

1. Copying the <span class="new-collection">variable assignment</span> for our <span class="collection-type">new empty list</span> (line 3)
2. Copying <span class="item-mutation">the expression that we've been `append`-ing</span> into this new list (line 5)
3. Copying <span class="for-loop">the `for` loop line</span>, excluding the final `:` (line 4)

## Nested Loops

What about list comprehensions with nested looping?... 😦

Here's a `for` loop that flattens a matrix (a list of lists):

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

Nested loops in list comprehensions do not read like English prose.

My brain wants to write this list comprehension as:

<pre class="colored-comprehension">
<span class="new-collection">flattened</span> = <span class="collection-type">[</span><span class="item-mutation">n</span> <span class="nested-for-loop">for <span class="item">n</span> in <span class="old-collection">row</span></span><span class="collection-type"> <span class="for-loop">for <span class="item">row</span> in <span class="old-collection">matrix</span></span><span class="collection-type">]</span>
</pre>

**But that's not right!**  I've mistakenly flipped the `for` loops here.

When working with nested loops in list comprehensions remember that **the `for` clauses remain in the same order** as in our original `for` loops.




## Other Comprehensions

This same principle applies to set comprehensions and dictionary comprehensions.

Code that creates a set of all the first letters in a sequence of words:

<pre class="colored-comprehension">
<span class="new-collection">first_letters</span> = <span class="collection-type">set()</span>
<span class="for-loop">for <span class="item">w</span> in <span class="old-collection">words</span></span>:
    <span class="new-collection">first_letters</span>.add(<span class="item-mutation">w[0]</span>)
</pre>

That same code written as a set comprehension:

<pre class="colored-comprehension">
<span class="new-collection">first_letters</span> = <span class="collection-type">{</span><span class="item-mutation">w[0]</span> <span class="for-loop">for <span class="item">w</span> in <span class="old-collection">words</span></span><span class="collection-type">}</span>
</pre>

Code that makes a new dictionary by swapping the keys and values of the original one:

<pre class="colored-comprehension">
<span class="new-collection">flipped</span> = <span class="collection-type">{}</span>
<span class="for-loop">for <span class="item">key, value</span> in <span class="old-collection">original.items()</span></span>:
    <span class="new-collection">flipped</span>[<span class="item-mutation">value</span>] = <span class="item-mutation">key</span>
</pre>

That same code written as a dictionary comprehension:

<pre class="colored-comprehension">
<span class="new-collection">flipped</span> = <span class="collection-type">{</span><span class="item-mutation">value</span>: <span class="item-mutation">key</span> <span class="for-loop">for <span class="item">key, value</span> in <span class="old-collection">original.items()</span></span><span class="collection-type">}</span>
</pre>

## Learn with me

I did a [class on list comprehensions][class] with [PyLadies Remote][] recently.

If you'd like to watch me walk through an explanation of any of the above topics, check out the video:

1. [list comprehensions][class-list]
2. [generator expressions][class-generator]
3. [set comprehensions][class-set]
4. [dictionary comprehensions][class-dict]


## In Summary

When struggling to write a comprehension, don't panic.  Start with a `for` loop first and copy-paste your way into a comprehension.

Any `for` loop that looks like this:

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[]</span>
<span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span>:
    <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>:
        <span class="new-collection">new_things</span>.append(<span class="item-mutation">"something with " + ITEM</span>)
</pre>

Can be rewritten into a list comprehension like this:

<pre class="colored-comprehension">
<span class="new-collection">new_things</span> = <span class="collection-type">[</span><span class="item-mutation">"something with " + ITEM</span> <span class="for-loop">for <span class="item">ITEM</span> in <span class="old-collection">old_things</span></span><span class="collection-type"> <span class="conditional-clause">if <span class="condition">condition_based_on(ITEM)</span></span>]</span>
</pre>

If you can nudge a `for` loop until it looks like the ones above, you can rewrite it as a list comprehension.

This blog post was based on my Intro to Python class.  If you're interested in chatting about my [Python training services][], [drop me a line][].


[iterable]: https://docs.python.org/3/glossary.html#term-iterable
[class]: https://www.youtube.com/watch?v=u-mhKtC1Xh4
[class-list]: https://youtu.be/u-mhKtC1Xh4?t=3m30s
[class-generator]: https://youtu.be/u-mhKtC1Xh4?t=35m05s
[class-set]: https://youtu.be/u-mhKtC1Xh4?t=44m44s
[class-dict]: https://youtu.be/u-mhKtC1Xh4?t=47m44s
[pyladies remote]: http://remote.pyladies.com/
[python training services]: http://truthful.technology/
[drop me a line]: mailto:hello@truthful.technology
