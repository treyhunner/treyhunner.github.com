---
layout: post
title: "Turn your loops inside-out with generators"
date: 2016-04-01 11:15:27 -0700
comments: true
categories: python
---

## Simplifying for loops

If your `for` loop filters data using a `continue`, you might want to use a generator for that filter.

If your `for` loop exits using a `break` statement, you might want to use a generator.

If your `for` loop requires massaging the looped-over data during each iteration, you might want to use a generator to hide away that data cleaning.

Generators can also be used to flatten nested loops.

```python
for file_name in file_names:
    with open(file_name) as file:
        file_data = file.read()
        do_something(file_data)
```

```python
def open_files(file_names):
    for file_name in file_names:
        with open(file_name) as file:
            yield file

for file in open_files(file_names):
    file_data = file.read()
    do_something(file_data)
```

```python
# https://projecteuler.net/problem=10
total = 0
for n in range(1000000):
    if is_prime(n):
        total += n
```

```python
def primes_up_to(number):
    for n in range(number):
        if is_prime(n):
            yield n

total = sum(primes_up_to(1000000))
```

```python
for time in times:
    if not is_valid_time(time):
        continue
    process_time(time)
```

```python
def valid_times(times):
    for time in times:
        if is_valid_time(time):
            yield time

for time in valid_times(times):
    process_time(time)
```

```python
for columns in rows:
    for cell in columns:
        do_something(cell)
```

```python
def get_cells(rows):
    for columns in rows:
        for cell in columns:
            yield cell

for cell in get_cells(rows):
    do_something(cell)
```

```python
for key, value in sorted(six.iteritems(self)):
    if key == key.upper():
        # Uppercase options aren't used by prepared options (a primary
        # use of prepared options is to generate the filename -- these
        # options don't alter the filename).
        continue
    if not value or key in ('size', 'quality', 'subsampling'):
        continue
    if value is True:
        prepared_opts.append(key)
        continue
    if not isinstance(value, six.string_types):
        try:
            value = ','.join([six.text_type(item) for item in value])
        except TypeError:
            value = six.text_type(value)
    prepared_opts.append('%s-%s' % (key, value))
```

```python
def valid_options(self):
    for key, value in sorted(six.iteritems(self)):
        if key == key.upper():
            # Uppercase options aren't used by prepared options (a primary
            # use of prepared options is to generate the filename -- these
            # options don't alter the filename).
            continue
        if not value or key in ('size', 'quality', 'subsampling'):
            continue
        yield key, value

for key, value in self.valid_options():
    if value is True:
        prepared_opts.append(key)
        continue
    if not isinstance(value, six.string_types):
        try:
            value = ','.join([six.text_type(item) for item in value])
        except TypeError:
            value = six.text_type(value)
    prepared_opts.append('%s-%s' % (key, value))
```

```python
def process_actions(self):
    parser = main._get_parser()
    for action in parser._actions:
        if not action.option_strings:
            continue
        for line in self._format_action(action):
            self.view_list.append(line, "")

```

```python
for pos, info in enumerate(reversed(path)):
    if len(joins) == 1 or not info.direct:
        break
    join_targets = set(t.column for t in info.join_field.foreign_related_fields)
    cur_targets = set(t.column for t in targets)
    if not cur_targets.issubset(join_targets):
        break
    targets = tuple(r[0] for r in info.join_field.related_fields if r[1].column in cur_targets)
    self.unref_alias(joins.pop())
```

```python
def 
for pos, info in enumerate(reversed(path)):
    if len(joins) == 1 or not info.direct:
        break
    join_targets = set(t.column for t in info.join_field.foreign_related_fields)
    cur_targets = set(t.column for t in targets)
    if not cur_targets.issubset(join_targets):
        break
    targets = tuple(r[0] for r in info.join_field.related_fields if r[1].column in cur_targets)
    self.unref_alias(joins.pop())
```

```python
for template_name in templates:
    try:
        template = parser.parse(template_name)
    except IOError:  # unreadable file -> ignore
        if verbosity > 0:
            log.write("Unreadable template at: %s\n" % template_name)
        continue
    except TemplateSyntaxError as e:  # broken template -> ignore
        if verbosity > 0:
            log.write("Invalid template %s: %s\n" % (template_name, e))
        continue
    except TemplateDoesNotExist:  # non existent template -> ignore
        if verbosity > 0:
            log.write("Non-existent template at: %s\n" % template_name)
        continue
    except UnicodeDecodeError:
        if verbosity > 0:
            log.write("UnicodeDecodeError while trying to read "
                      "template %s\n" % template_name)
    try:
        nodes = list(parser.walk_nodes(template))
    except (TemplateDoesNotExist, TemplateSyntaxError) as e:
        # Could be an error in some base template
        if verbosity > 0:
            log.write("Error parsing template %s: %s\n" % (template_name, e))
        continue
    if nodes:
        template.template_name = template_name
        compressor_nodes.setdefault(template, []).extend(nodes)
```

```python
def get_templates(templates):
    for template_name in templates:
        try:
            template = parser.parse(template_name)
        except IOError:  # unreadable file -> ignore
            if verbosity > 0:
                log.write("Unreadable template at: %s\n" % template_name)
            continue
        except TemplateSyntaxError as e:  # broken template -> ignore
            if verbosity > 0:
                log.write("Invalid template %s: %s\n" % (template_name, e))
            continue
        except TemplateDoesNotExist:  # non existent template -> ignore
            if verbosity > 0:
                log.write("Non-existent template at: %s\n" % template_name)
            continue
        except UnicodeDecodeError:
            if verbosity > 0:
                log.write("UnicodeDecodeError while trying to read "
                          "template %s\n" % template_name)
        try:
            nodes = list(parser.walk_nodes(template))
        except (TemplateDoesNotExist, TemplateSyntaxError) as e:
            # Could be an error in some base template
            if verbosity > 0:
                log.write("Error parsing template %s: %s\n" % (template_name, e))
            continue
        yield name, template, nodes


for template_name, template, nodes in get_templates(templates):
    if nodes:
        template.template_name = template_name
        compressor_nodes.setdefault(template, []).extend(nodes)
```

## Changing while loops to for loops

We have an infinite loop that looks like this:

```python
while True:
    answer = input("What would you like to play?")
    if answer.lower() == "quit":
        break
    play_game(answer)
```

Let's write a generator that handles the question asking:

```python
def prompt_for_games():
    while True:
        answer = input("What would you like to play?")
        if answer.lower() == "quit":
            return
        yield answer
```

Now we can rewrite our loop as a `for` loop:

```python
for game_name in prompt_for_games():
    play_game(game_name)
```
