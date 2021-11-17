---
layout: post
title: "How to sort a dictionary in Python"
date: 2021-11-17 07:00:00 -0800
comments: true
categories: python
---

Dictionaries are best used for key-value lookups: **we provide a key** and the dictionary *very* quickly **returns the corresponding value**.

But what if you need both key-value lookups and iteration?
It is possible to loop over a dictionary and when looping, we *might* care about **the order of the items** in the dictionary.

With dictionary item order in mind, you might wonder how can we *sort* a dictionary?


### Dictionaries are ordered

As of Python 3.6 dictionaries are **ordered** (technically the ordering [became official in 3.7][ordered dicts]).

Dictionary keys are stored in **insertion order**, meaning whenever a new key is added it gets added at the very end.

```pycon
>>> color_amounts = {"purple": 6, "green": 3, "blue": 2}
>>> color_amonuts["pink"] = 4
>>> color_amounts
{'purple': 6, 'green': 3, 'blue': 2, 'pink': 4}
```

But if we update a key-value pair, the key remains where it was before:

```pycon
>>> color_amonuts["green"] = 5
>>> color_amounts
{'purple': 6, 'green': 5, 'blue': 2, 'pink': 4}
```

So if you plan to populate a dictionary with some specific data and then leave that dictionary as-is, all you need to do is make sure that original data is in the order you'd like.

For example if we have a CSV file of US state abbreviations and our file is ordered alphabetically by state name, our dictionary will be ordered the same way:

```pycon
>>> import csv
>>> state_abbreviations = {}
>>> for name, abbreviation in csv.reader("state-abbreviations.csv")
...     state_abbreviations[name] = abbreviation
...
>>> state_abbreviations
{'Alabama': 'AL', 'Alaska': 'AK', 'Arizona': 'AZ', 'Arkansas': 'AR', 'California': 'CA', ...}
```

If our input data is already ordered correctly, our dictionary will end up ordered correctly as well.


### How to sort a dictionary by its keys

What if our data isn't sorted yet?

Say we have a list-of-tuples that pair meeting rooms to their corresponding room numbers:

```pycon
>>> rooms = [("Pink", "Rm 403"), ("Space", "Rm 201"), ("Quail", "Rm 500"), ("Lime", "Rm 503")]
```

And we'd like to sort this dictionary by its keys.

We could use the built-in `sorted` function to sort it:

```pycon
>>> sorted(rooms)
[('Lime', 'Rm 503'), ('Pink', 'Rm 403'), ('Quail', 'Rm 500'), ('Space', 'Rm 201')]
```

The `sorted` function uses the `<` operator to compare many items in the given iterable and return a sorted list.
The `sorted` function always returns a list.

To make these key-value pairs into a dictionary, we can pass them straight to the `dict` constructor:

```pycon
>>> sorted_rooms = dict(sorted(rooms))
>>> sorted_rooms
{'Lime': 'Rm 503', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Space': 'Rm 201'}
```

The `dict` constructor will accept a list of 2-item tuples (or any iterable of 2-item iterables) and make a dictionary out of it, using the first item from each tuple as a key and the second as the corresponding value.


### Key-value pairs are sorted lexicographically... what?

We're sorting tuples of the key-value pairs before making a dictionary out of them.
But how does sorting tuples work?

```pycon
>>> some_tuples = [(1, 3), (3, 1), (1, 9), (0, 3)]
>>> sorted(some_tuples)
[(0, 3), (1, 3), (1, 9), (3, 1)]
```

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

We can't sort a dictionary in-place, but we could get the items from our dictionary, sort those items using the same technique we used before, and then turn those items them into a new dictionary:

```pycon
>>> rooms = {"Pink": "Rm 403", "Space": "Rm 201", "Quail": "Rm 500", "Lime": "Rm 503"}
>>> sorted_rooms = dict(sorted(rooms.items()))
>>> sorted_rooms
{'Lime': 'Rm 503', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Space': 'Rm 201'}
```

That creates a new dictionary object.
If we *really* wanted to update our original dictionary object, we could take the items from the dictionary, sort them, clear the dictionary of all its items, and then add all the items back into the dictionary:

```pycon
>>> old_dictionary = {"Pink": "Rm 403", "Space": "Rm 201", "Quail": "Rm 500", "Lime": "Rm 503"}
>>> sorted_items = sorted(old_dictionary.items())
>>> old_dictionary.clear()
>>> old_dictionary.update(sorted_items)
```

But why bother?
We don't usually *want* to operate on data structures in-place in Python: we tend to prefer making a new data structure rather than re-using an old one (this preference is partly thanks to [how variables work in Python][variables]).


### How to sort a dictionary by its values

What if we wanted to sort a dictionary by its values instead of its keys?

We could make a new list of value-key tuples (actually a generator in our case below), sort that, then flip them back to key-value tuples and recreate our dictionary:

```pycon
>>> rooms = {"Pink": "Rm 403", "Space": "Rm 201", "Quail": "Rm 500", "Lime": "Rm 503"}
>>> room_to_name = sorted((room, name) for (name, room) in rooms.items())
>>> sorted_rooms = {
...     name: room
...     for room, name in room_to_name
... }
>>> sorted_rooms
{'Space': 'Rm 201', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503'}
```

This works but it's a bit long.
Also this technique actually sorts both our values and our keys (giving the values precedence in the sorting).

What if we wanted to *just* sort by the values, ignoring the contents of the keys entirely?
Python's `sorted` function accepts a `key` argument that we can use for this!

```pycon
>>> help(sorted)
Help on built-in function sorted in module builtins:

sorted(iterable, /, *, key=None, reverse=False)
    Return a new list containing all items from the iterable in ascending order.

    A custom key function can be supplied to customize the sort order, and the
    reverse flag can be set to request the result in descending order.
```

The key function we pass to sorted should accept an item from the iterable we're sorting and return the *key* to sort by.
Note that the word "key" here isn't related to dictionary keys.
Dictionary keys are used for looking up dictionary values whereas this key function returns an object that determines how to order items in an iterable.

If we want to sort by our values, we could make a key function that accepts each item in our list of 2-item tuples and **returns just the value**:

```python
def value_from_item(item):
    """Return just the value from a given (key, value) tuple."""
    key, value = item
    return value
```

Then we'd use our key function by passing it to the `sorted` function (yes [functions can be passed to other functions in Python][passing functions]) and pass the result to `dict` to create a new dictionary:

```pycon
>>> sorted_rooms = dict(sorted(rooms.items(), key=value_from_item))
>>> sorted_rooms
{'Space': 'Rm 201', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503'}
```

If you prefer not to create a custom key function just to use it once, you could use a lambda function (which I [don't usually recommend][lambda]):

```pycon
>>> sorted_rooms = dict(sorted(rooms.items(), key=lambda item: item[1]))
>>> sorted_rooms
{'Space': 'Rm 201', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503'}
```

Or you could use `operator.itemgetter` to make a key function that gets the second item from each key-value tuple:

```pycon
>>> from operator import itemgetter
>>> sorted_rooms = dict(sorted(rooms.items(), key=itemgetter(1)))
>>> sorted_rooms
{'Space': 'Rm 201', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503'}
```

I discussed my preference for `itemgetter` [in my article on lambda functions][itemgetter].


### Ordering a dictionary in some other way

What if we needed to sort by something other than just a key or a value?
For example what if our room number strings include numbers that aren't always the same length:

```python
rooms = {
    "Pink": "Rm 403",
    "Space": "Rm 201",
    "Quail": "Rm 500",
    "Lime": "Rm 503",
    "Ocean": "Rm 2000",
    "Big": "Rm 30",
}
```

If we sorted these rooms by value, those strings wouldn't be sorted in the numerical way we're hoping for:

```pycon
>>> from operator import itemgetter
>>> sorted_rooms = dict(sorted(rooms.items(), key=itemgetter(1)))
>>> sorted_rooms
{'Ocean': 'Rm 2000', 'Space': 'Rm 201', 'Big': 'Rm 30', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503'}
```

**Rm 30** should be first and **Rm 2000** should be last.
But we're sorting strings, which are ordered character-by-character based on the unicode value of each character (I [noted this][string comparisons] in my article on tuple ordering).

We could customize the `key` function we're using to sort numerically instead:

```python
def by_room_number(item):
    """Return numerical room given a (name, room_number) tuple."""
    name, room = item
    _, number = room.split()
    return int(number)
```

When we use this key function to sort our dictionary:

```pycon
>>> sorted_rooms = dict(sorted(rooms.items(), key=by_room_number))
```

It will be sorted by the integer room number, as expected:

```pycon
>>> sorted_rooms
{'Big': 'Rm 30', 'Space': 'Rm 201', 'Pink': 'Rm 403', 'Quail': 'Rm 500', 'Lime': 'Rm 503', 'Ocean': 'Rm 2000'}
```


### Should you sort a dictionary?

When you're about to sort a dictionary, first ask yourself "do I need to do this"?
In fact, when you're considering looping over a dictionary you might ask "do I really need a dictionary here"?

Dictionaries are used for key-value lookups: you can quickly get a value given a key.
They're very fast at retrieving values for keys.
But dictionaries take up more space than a list of tuples.

If you can get away with using a list of tuples in your code (because you don't actually need a key-value lookup), you probably *should* use a list of tuples instead of a dictionary.

But if key lookups are what you need, it's unlikely that you also need to loop over your dictionary.

Now it's certainly possible that right now you do in fact have a good use case for sorting a dictionary (for example maybe you're [sorting keys in a dictionary of attributes][sort attributes]), but keep in mind that you'll need to sort a dictionary **very rarely**.


### Summary

Dictionaries are used for quickly looking up a value based on a key.
The *order* of a dictionary's items is rarely important.

In the rare case that you care about the order of your dictionary's items, keep in mind that dictionaries are ordered by the *insertion order* of their keys (as of Python 3.6).
So the keys in your dictionary will remain in the order they were added to the dictionary.

If you'd like to sort a dictionary by its keys, you can use the built-in `sorted` function along with the `dict` constructor:

```pycon
>>> sorted_dictionary = dict(sorted(old_dictionary.items()))
```

If you'd like to sort a dictionary by its values, you can pass a custom `key` function (one which returns the value for each item) to `sorted`:

```pycon
>>> def value_from_item(item):
...     key, value = item
...     return value
...
>>> sorted_dictionary = dict(sorted(old_dictionary.items(), key=value_from_item))
```

But remember, it's not often that we care about the order of a dictionary.
Whenever you're sorting a dictionary, please remember to ask yourself **do I really need to sort this data structure** and **would a list of tuples be more suitable than a dictionary here**?


[tuple ordering]: https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/
[passing functions]: https://treyhunner.com/2020/01/passing-functions-as-arguments/
[lambda]: https://treyhunner.com/2018/09/stop-writing-lambda-expressions/
[sort attributes]: https://gist.github.com/treyhunner/7adcbc96870b79642f1754c3cc602ac6
[ordered dicts]: https://docs.python.org/3/whatsnew/3.7.html#summary-release-highlights
[variables]: https://www.pythonmorsels.com/topics/variables-are-pointers/
[string comparisons]: https://treyhunner.com/2019/03/python-deep-comparisons-and-code-readability/#String_comparisons_in_Python
[itemgetter]: https://treyhunner.com/2018/09/stop-writing-lambda-expressions/#Overuse:_using_lambda_for_very_simple_operations
