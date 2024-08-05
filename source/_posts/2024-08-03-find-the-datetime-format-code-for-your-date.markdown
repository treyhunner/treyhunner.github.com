---
layout: post
title: "Quickly find the right datetime format code for your date"
date: 2024-08-05 11:30:00 -0700
comments: true
categories: python
---

I often find myself with a string representing a date and time and the need to create a format string that will parse this string into a `datetime` object.

I decided to make a tool that solves this problem for me: https://pym.dev/strptime


## Finding the code to parse a date format with `strptime`

Here's how I'm now using this new tool.

I find a date string in a random spreadsheet or log file that I need to parse.
For example, the string `30-Jun-2024 20:09`, which I recently found in a spreadsheet.

I then paste the string into the tool and watch the format appear:

[{% img /images/strptime-1.png %}](https://pym.dev/strptime)

Then I click on the date format to copy-paste it.
That's it!

This tool works by cycling through a number of common formats.
It also works for dates without a time, like `Jul 1, 2024`.

[{% img /images/strptime-2.png %}](https://pym.dev/strptime)

This input field works great when you're in need of a code for the `datetime` class's `strptime` method (which *parses* dates).
But what if you need a code for `strftime` (for *formatting* dates)?


## Finding the code to format a date with `strftime`

If you don't have a date but instead want to *construct* a date in a specific common format, scroll down the page a bit.

This page includes a table of common formats.

[{% img /images/strptime-table.png %}](https://pym.dev/strptime#formats)

Click on the format to copy it.
That's it.


## Playing with format codes

What if you have a date format already but you're not sure what it represents?

Paste it in the box!

For example if you're wondering what the `%B` in `%B %d, %Y` means, paste it in to see what that represent with the current date and time:

[{% img /images/strptime-reverse.png %}](https://pym.dev/strptime)


## Other features

There are a few other hidden features in this tool:

- After a date or date format is pasted, if it corresponds to one of the formats listed in the table of common formats, that row will be highlighted
- Hitting the `Enter` key anywhere on the page will select the input field
- Clicking on a date within the format table will fill that date into the input box
- The bottom of the page includes links to other useful datetime formatting/parsing tools as well as a link to the relevant Python documentation


## Thoughts? Feature requests?

What do you think of this tool?

Is this something you'd bookmark and use often?
Is this missing a key feature that you would need for it to be valuable for your use?

Are there date and time formats you'd like to see that don't seem to be supported yet?

Comment or email me to let me know!
