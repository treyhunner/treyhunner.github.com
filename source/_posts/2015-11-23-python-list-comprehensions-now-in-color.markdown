---
layout: post
title: "Python List Comprehensions: Explained Visually"
date: 2015-12-01 10:30:00 -0800
comments: true
categories: python favorite
---

Sometimes a programming design pattern becomes common enough to warrant its own special syntax.  Python's [list comprehensions][] are a prime example of such a syntactic sugar.

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

**Note:** My brain wants to write this list comprehension as:

<pre class="colored-comprehension">
<span class="new-collection">flattened</span> = <span class="collection-type">[</span><span class="item-mutation">n</span> <span class="nested-for-loop">for <span class="item">n</span> in <span class="old-collection">row</span></span><span class="collection-type"> <span class="for-loop">for <span class="item">row</span> in <span class="old-collection">matrix</span></span><span class="collection-type">]</span>
</pre>

**But that's not right!**  I've mistakenly flipped the `for` loops here.  The correct version is the one above.

When working with nested loops in list comprehensions remember that **the `for` clauses remain in the same order** as in our original `for` loops.


## Other Comprehensions

This same principle applies to [set comprehensions][] and [dictionary comprehensions][].

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


## Readability Counts

Did you find the above list comprehensions hard to read?  I often find longer list comprehensions very difficult to read when they're written on one line.

Remember that [Python allows line breaks][line continuation] between brackets and braces.

### List comprehension

Before

```python
doubled_odds = [n * 2 for n in numbers if n % 2 == 1]
```

After

```python
doubled_odds = [
    n * 2
    for n in numbers
    if n % 2 == 1
]
```

### Nested loops in list comprehension

Before

```python
flattened = [n for row in matrix for n in row]
```

After

```python
flattened = [
    n
    for row in matrix
    for n in row
]
```

### Dictionary comprehension

Before

```python
flipped = {value: key for key, value in original.items()}
```

After

```python
flipped = {
    value: key
    for key, value in original.items()
}
```

Note that we are not adding line breaks arbitrarily: we're breaking between each of the lines of code we copy-pasted to make these comprehension.  Our line breaks occur where color changes occur in the colorized versions.


## Copy-paste into comprehensions

When struggling to write a comprehension, don't panic.
Start with a `for` loop first and copy-paste your way into a comprehension.

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

## Make them readable and don't abuse them

I highly recommend writing your comprehensions over multiple lines.
Comprehensions don't need to be one-liners to be useful.

If you find that you're a fan of comprehensions, please [try not to overuse list comprehensions][overusing comprehensions].
It's easy to use list comprehensions for purposes they weren't meant for.

If you'd like to dive a bit deeper into this topic, you might want to watch my 30 minute [Comprehensible Comprehensions][] talk for more.


## Practice Python list comprehensions right now!

**The best way to learn** is through **regular practice**.
Every week I send out carefully crafted Python exercises through my Python skill-building service, [Python Morsels][].

If you'd like to practice comprehensions through one Python exercise right now, you can sign up for [Python Morsels][] using the form below.
After you sign up, I'll immediately give you **one exercise to practice your comprehension copy-pasting skills**.

<form method="post" action="https://www.pythonmorsels.com/signup/">
  <input type="email" name="email" placeholder="Your email" class="subscribe-email form-big" required>
  <input type="hidden" name="exercise_track" value="comprehension2">
  <input type="hidden" name="form_id" value="comprehensions in color">
  <button type="submit" class="subscribe-btn form-big">Get my Python Morsels exercise</button>
<br>
<small>
You can <a href="https://www.pythonmorsels.com/privacy/">find the Privacy Policy for Python Morsels here</a>.
</small>

</form>


[crowdcast]: http://ccst.io/e/list-comprehensions
[iterable]: https://docs.python.org/3/glossary.html#term-iterable
[class]: https://www.youtube.com/watch?v=u-mhKtC1Xh4
[class-list]: https://youtu.be/u-mhKtC1Xh4?t=3m30s
[class-generator]: https://youtu.be/u-mhKtC1Xh4?t=35m05s
[class-set]: https://youtu.be/u-mhKtC1Xh4?t=44m44s
[class-dict]: https://youtu.be/u-mhKtC1Xh4?t=47m44s
[pyladies remote]: http://remote.pyladies.com/
[team Python training]: http://truthful.technology/
[drop me a line]: mailto:hello@truthful.technology
[line continuation]: https://docs.python.org/3/reference/lexical_analysis.html#implicit-line-joining
[list comprehensions]: https://docs.python.org/3/tutorial/datastructures.html#tut-listcomps
[dictionary comprehensions]: https://docs.python.org/3/tutorial/datastructures.html#dictionaries
[set comprehensions]: https://docs.python.org/3/tutorial/datastructures.html#sets
[comprehensible comprehensions]: https://youtu.be/5_cJIcgM7rw?t=52s
[3 hour tutorial]: http://pycon2018.trey.io/
[python morsels]: https://www.pythonmorsels.com/
[overusing comprehensions]: https://treyhunner.com/2019/03/abusing-and-overusing-list-comprehensions-in-python/
