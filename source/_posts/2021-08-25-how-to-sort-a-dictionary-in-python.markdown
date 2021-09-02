---
layout: post
title: "How to sort a dictionary in Python"
date: 2021-08-25 06:19:08 -0700
comments: true
categories: python
---

Dictionaries are best used for key-value lookups: **we provide a key** and the dictionary *very* quickly **returns the corresponding value**.

But what if you need both key-value lookups and iteration?
It is possible to loop over a dictionary and when looping, we *might* care about **the order of the items** in the dictionary.

How can we *sort* a dictionary?


### Dictionaries are ordered

As of Python 3.6 dictionaries are **ordered**.

The keys in dictionaries are stored in **insertion order**, meaning whenever a new key is added it goes at the very end.

TODO code

If we update a key-value pair, the key remains where it was before:

TODO code

So if you plan to populate a dictionary with some specific data and then leave that dictionary as-is, all you need to do is make sure that original data is in the order you'd like.

If our input data is already ordered correctly, our dictionary will end up ordered correctly as well.
For example if we have a CSV file of US state abbreviations and our file is ordered alphabetically by state name, our dictionary will be ordered the same way:

TODO code


### How to sort a dictionary by its keys

What if our data isn't sorted yet?

Say we have a... TODO example where we're sorting keys

We could use the built-in `sorted` function to sort it:

TODO code

The `sorted` function uses the `<` operator to compare many items in the given iterable and return a sorted list.
The `sorted` function always returns a list.

To make these key-value pairs into a dictionary, we can pass them straight the `dict` constructor:

TODO code

The `dict` constructor will accept a list of 2-item tuples (or any iterable of 2-item iterables) and make a dictionary out of it, using the first item from each tuple as a key and the second as the corresponding value.


### Key-value pairs are sorted lexicographically... what?

We're sorting tuples of the key-value pairs before making a dictionary out of them.
But how does sorting tuples work?

TODO code

When sorting tuples, Python uses lexicographical ordering (which sounds fancier than it is).
Comparing a 2-item tuple basically boils down to this algorithm:

```python
def compare_two_item_tuples(a, b):
    """This is the same as a < b for two 2-item tuples."""
    if a[0] != b[0]:  # If the first item of each tuple is unequal
        return a[0] < b[0]  # Compare the first item from each tuple
    else:
        return a[1] < b[1]  # Compare the second item from each tuple
```

I've written [an article on tuple ordering][tuple ordering] that explains this in more detail.

You might be thinking: **it seems like this sorts not just by keys but by keys *and* values**.
And you're right!
But only sort of.

The keys in a dictionary *should* always compare as unequal (if two keys are equal, they're seen as *the same key*).
So as long as the keys are comparable to each other with the less than operator (`<`), sorting 2-item tuples of key-value pairs should always sort by the keys.


### Dictionaries can't be sorted in-place

What if we already have our items *in* a dictionary and we'd like to sort that dictionary?
Unlike lists, **there's no `sort` method on dictionaries**.

We can't sort a dictionary in-place.
But we could get the items from the dictionary and use the same technique we used before to sort them and then make them into a new dictionary:

TODO code

If we *really* wanted to sort a dictionary in-place, we could take the items from the dicionary, sort them, clear the dictionary of all its items, and then add all the items back into the dictionary:

```pycon
>>> sorted_items = sorted(old_dictionary.items())
>>> old_dictionary.clear()
>>> old_dictionary.update(sorted_items)
```

But why bother?
We don't usually *want* to operate on data structures in-place in Python: we tend to prefer making a new data structure rather than re-using an old one.


### How to sort a dictionary by its values

What if we wanted to sort a dictionary by its values instead of its keys?

We could make a new list of value-key tuples, sort that, then flip them back to key-values tuples and recreate our dictionary:

TODO code

This works but it's a bit long.
Also this technique actually sorts both our values and our keys (giving the values precedence in the sorting).

What if we wanted to *just* sort by the values, ignoring the contents of the keys entirely?
Python's `sorted` function accepts `key` argument that we can use for this!

TODO show sorted help output

The `sorted` function accepts a `key` argument which should be a function that accepts an item from the iterable we're sorting and returns the *key* to sort by.
Note that the word "key" here isn't related to dictionary keys.
Dictionary keys are used for looking up dictionary values whereas this key function returns an object that determines how to order items in an iterable.

If we want to sort by our values, we could make a key function that accepts each the items in our list of 2-item tuples and **returns just the value**:

TODO code of a value_from_item function with a docstring

Then we'd use our `key` function by passing it to the `sorted` function (yes [functions can be passed to other functions in Python][passing functions]):

TODO code


### Ordering a dictionary in some other way

TODO code that uses either key and value in some weird combo or lowercased key or something?

TODO lowercased key maybe??


### Should you sort a dictionary?

When you're about to sort a dictionary, first ask yourself "do I need to do this"?
In fact, when you're considering looping over a dictionary you might ask "do I really need a dictionary here"?

Dictionaries are used for key-value lookups: you can quickly get a value given a key.
They're very fast at retrieving values for keys.
But dictionaries take up more space than a list of tuples.

If you can get away with using a list of tuples in your code (because you don't actually need a key-value lookup), you probably *should* use a list of tuples instead of a dictionary.

But if key lookups is what you need, it's unlikely that you also need to loop over your dictionary.
Now this situation certainly isn't impossible.
TODO example... Django choice field?

TODO


### Summary


[tuple ordering]: https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/
[passing functions]: https://treyhunner.com/2020/01/passing-functions-as-arguments/
