---
layout: post
title: "Craft Your Python Like Poetry"
date: 2017-07-23 10:00:00 -0700
comments: true
categories: python readability favorite
---

Line length is a big deal... programmers argue about it quite a bit.  PEP 8, the Python style guide, recommends a [79 character maximum line length][PEP8 line length] but concedes that a line length up to 100 characters is acceptable for teams that agree to use a specific longer line length.

So 79 characters is recommended... but isn't line length completely obsolete?  After all, programmers are no longer restricted by [punch cards][], [teletypes][], and 80 column [terminals][].  The laptop screen I'm typing this on can fit about 200 characters per line.


## Line length is not obsolete

Line length is not a technical limitation: it's a human-imposed limitation.  Many programmers prefer short lines because **long lines are hard to read**.  This is true in typography and it's true in programming as well.

Short lines are easier to read.

In the typography world, a line length of 55 characters per line is recommended for electronic text (see [line length on Wikipedia][]).  That doesn't mean we should use a 55 character limit though; typography and programming are different.


## Python isn't prose

Python code isn't structured like prose.  English prose is structured in flowing sentences: each line wraps into the next line.  In Python, **statements** are somewhat like **sentences**, meaning each sentence begins at the *start* of each line.

Python code is more like poetry than prose.  Poets and Python programmers don't wrap lines once they hit an arbitrary length; they wrap lines when they make sense for readability and beauty.

    I stand amid the roar Of a surf-tormented shore, And I hold within my hand
    Grains of the golden sand— How few! yet how they creep Through my fingers to
    the deep, While I weep—while I weep! O God! can I not grasp Them with a
    tighter clasp? O God! can I not save One from the pitiless wave? Is all that we
    see or seem But a dream within a dream?

Don't wrap lines arbitrarily. Craft each line with care to help readers **experience your code exactly the way you intended**.

    I stand amid the roar
    Of a surf-tormented shore,
    And I hold within my hand
    Grains of the golden sand—
    How few! yet how they creep
    Through my fingers to the deep,
    While I weep—while I weep!
    O God! can I not grasp
    Them with a tighter clasp?
    O God! can I not save
    One from the pitiless wave?
    Is all that we see or seem
    But a dream within a dream?


## Examples

It's not possible to make a single rule for when and how to wrap lines of code.  [PEP8 discusses line wrapping briefly][indentation], but it only discusses one case of line wrapping and three different acceptable styles are provided, leaving the reader to choose which is best.

Line wrapping is best discussed through examples.  Let's look at a few examples of long lines and few variations for line wrapping for each.


### Example: Wrapping a Comprehension

This line of code is over 79 characters long:

```python
employee_hours = [schedule.earliest_hour for employee in self.public_employees for schedule in employee.schedules]
```

Here we've wrapped that line of code so that it's two shorter lines of code:

```python
employee_hours = [schedule.earliest_hour for employee in
                  self.public_employees for schedule in employee.schedules]
```

We're able to insert that line break in this line because we have an **unclosed square bracket**.  This is called an **implicit line continuation**.  Python knows we're continuing a line of code whenever there's a line break inside unclosed square brackets, curly braces, or parentheses.

This code still isn't very easy to read because the line break was inserted arbitrarily.  We simply wrapped this line just before a specific line length.  We were thinking about line length here, but we completely neglected to think about readability.

This code is the same as above, but we've inserted line breaks in very particular places:

```python
employee_hours = [schedule.earliest_hour
                  for employee in self.public_employees
                  for schedule in employee.schedules]
```

We have two lines breaks here and we've purposely inserted them before our `for` clauses in this list comprehension.

Statements have logical components that make up a whole, the same way sentences have clauses that make up the whole.  We've chosen to break up this list comprehension by inserting line breaks **between these logical components**.

Here's another way to break up this statement:

```python
employee_hours = [
    schedule.earliest_hour
    for employee in self.public_employees
    for schedule in employee.schedules
]
```

Which of these methods you prefer is up to you.  It's important to make sure you break up the logical components though.  And whichever method you choose, **be consistent**!


### Example: Function Calls

This is a Django model field with a whole bunch of arguments being passed to it:

```python
default_appointment = models.ForeignKey(othermodel='AppointmentType',
                                        null=True, on_delete=models.SET_NULL,
                                        related_name='+')
```

We're already using an implicit line continuation to wrap these lines of code, but again we're wrapping this code at an arbitrary line length.

Here's the same Django model field with one argument specific per line:

```python
default_appointment = models.ForeignKey(othermodel='AppointmentType',
                                        null=True,
                                        on_delete=models.SET_NULL,
                                        related_name='+')
```

We're breaking up the component parts (the arguments) of this statement onto separate lines.

We could also wrap this line by indenting each argument instead of aligning them:

```python
default_appointment = models.ForeignKey(
    othermodel='AppointmentType',
    null=True,
    on_delete=models.SET_NULL,
    related_name='+'
)
```

Notice we're also leaving that closing parenthesis on its own line.  We could additionally add a trailing comma if we wanted:

```python
default_appointment = models.ForeignKey(
    othermodel='AppointmentType',
    null=True,
    on_delete=models.SET_NULL,
    related_name='+',
)
```

**Which of these is the best way to wrap this line?**

Personally for this line I prefer that last approach: each argument on its own line, the closing parenthesis on its own line, and a comma after each argument.

It's important to decide what you prefer, reflect on why you prefer it, and always maintain consistency within each project/file you create.  And keep in mind that consistence of your personal style is less important than **consistency within a single project**.


### Example: Chained Function Calls

Here's a long line of chained Django queryset methods:

```python
    books = Book.objects.filter(author__in=favorite_authors).select_related('author', 'publisher').order_by('title')
```

Notice that there aren't parenthesis around this whole statement, so the only place we can currently wrap our lines is inside those parenthesis.  We could do something like this:

```python
    books = Book.objects.filter(
        author__in=favorite_authors
    ).select_related(
        'author', 'publisher'
    ).order_by('title')
```

But that looks kind of weird and it doesn't really improve readability.

We could add backslashes at the end of each line to allow us to wrap at arbitrary places:

```python
    books = Book.objects\
        .filter(author__in=favorite_authors)\
        .select_related('author', 'publisher')\
        .order_by('title')
```

This works, but [PEP8 recommends against this][backslashes].

We could wrap the whole statement in parenthesis, allowing us to use implicit line continuation wherever we'd like:

```python
    books = (Book.objects
        .filter(author__in=favorite_authors)
        .select_related('author', 'publisher')
        .order_by('title'))
```

It's not uncommon to see extra parenthesis added in Python code to allow implicit line continuations.

That indentation style is a little odd though.  We could align our code with the parenthesis instead:

```python
    books = (Book.objects
             .filter(author__in=favorite_authors)
             .select_related('author', 'publisher')
             .order_by('title'))
```

Although I'd probably prefer to align the dots in this case:

```python
    books = (Book.objects
                 .filter(author__in=favorite_authors)
                 .select_related('author', 'publisher')
                 .order_by('title'))
```

A fully indentation-based style works too (we've also moved `objects` to its own line here):

```python
    books = (
        Book
        .objects
        .filter(author__in=favorite_authors)
        .select_related('author', 'publisher')
        .order_by('title')
    )
```

There are yet more ways to resolve this problem.  For example we could try to use intermediary variables to avoid line wrapping entirely.

Chained methods pose a different problem for line wrapping than single method calls and require a different solution.  Focus on readability when picking a preferred solution and be consistent with the solution you pick.  **Consistency lies at the heart of readability**.


### Example: Dictionary Literals

I often define long dictionaries and lists defined in Python code.

Here's a dictionary definition that has been over multiple lines, with line breaks inserted as a maximum line length is approached:

```python
MONTHS = {'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5,
          'June': 6, 'July': 7, 'August': 8, 'September': 9, 'October': 10,
          'November': 11, 'December': 12}
```

Here's the same dictionary with each key-value pair on its own line, aligned with the first key-value pair:

```python
MONTHS = {'January': 1,
          'February': 2,
          'March': 3,
          'April': 4,
          'May': 5,
          'June': 6,
          'July': 7,
          'August': 8,
          'September': 9,
          'October': 10,
          'November': 11,
          'December': 12}
```

And the same dictionary again, with each key-value pair indented instead of aligned (with a trailing comma on the last line as well):

```python
MONTHS = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
}
```

This is the strategy I prefer for wrapping long dictionaries and lists.  I very often wrap short dictionaries and lists this way as well, for the sake of readability.


## Python is Poetry

The moment of **peak readability** is **the moment just after you write a line of code**.  Your code will be far less readable to you one day, one week, and one month after you've written it.

When crafting Python code, use spaces and line breaks to split up the logical components of each statement.  Don't write a statement on a single line unless it's already *very* clear.  If you break each line over multiple lines for clarity, lines length shouldn't be a major concern because your lines of code will mostly be far shorter than 79 characters already.

Make sure to craft your code carefully as you write it because your future self will have a much more difficult time cleaning it up than you will **right now**.  So take that line of code you just wrote and carefully add line breaks to it.


[punch cards]: https://en.wikipedia.org/wiki/Punched_card
[teletypes]: https://en.wikipedia.org/wiki/Teletype_Corporation
[terminals]: https://en.wikipedia.org/wiki/Computer_terminal
[PEP8 line length]: http://pep8.org/#maximum-line-length
[backslashes]: http://pep8.org/#maximum-line-length
[line length on Wikipedia]: https://en.wikipedia.org/wiki/Line_length
[indentation]: http://pep8.org/#indentation
