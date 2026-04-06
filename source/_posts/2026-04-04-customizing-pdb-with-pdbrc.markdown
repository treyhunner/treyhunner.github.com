---
layout: post
title: "Using a ~/.pdbrc file to customize the Python Debugger"
date: 2026-04-06 07:30:00 -0700
comments: true
categories: python
---

Did you know that you can customize the Python debugger (PDB) by creating custom aliases within a `.pdbrc` file in your home directory or Python's current working directory?

I recently learned this and I'd like to share a few helpful aliases that I now have access to in my PDB sessions thanks to my new `~/.pdbrc` file.

## The aliases in my `~/.pdbrc` file

Here's my new `~/.pdbrc` file:

```
# Custom PDB aliases

# dir obj: print non-dunder attributes and methods
alias dir print(*(f"%1.{n} = {v!r}" for n, v in __import__('inspect').getmembers(%1) if not n.startswith("__")), sep="\n")

# attrs obj: print non-dunder data attributes
alias attrs import inspect as __i ;; print(*(f"%1.{n} = {v!r}" for n, v in __i.getmembers(%1, lambda v: not __i.isroutine(v)) if not n.startswith("__")), sep="\n") ;; del __i

# vars obj: print instance variables (object must have __dict__)
alias vars print(*(f"%1.{k} = {v!r}" for k, v in vars(%1).items()), sep="\n")

# src obj: print source file, line number, and code where a class/function was defined
alias src import inspect as __i;; print(f"{__i.getsourcefile(%1)} on line {__i.getsourcelines(%1)[1]}:\n{''.join(__i.getsource(%1))}") ;; del __i

# loc: print local variables from current frame
alias loc print(*(f"{name} = {value!r}" for name, value in vars().items() if not name.startswith("__")), sep="\n")
```

This allows me to use:

- `dir`, `attrs`, and `vars` to inspect Python objects
- `src` to see the source code of a particular function/class
- `loc` to see the local variables

You might wonder "Can't I use `dir(x)` instead of `dir x` and `vars(x)` instead of `vars x` and `locals()` instead of `loc`?"

You can!... but those aliases print things out in a nicer format.


## A demo of these 5 aliases

Let's use `-m pdb -m calendar` to launch Python's `calendar` module from the command line while dropping into PDB immediately:

```bash
$ python -m pdb -m calendar
> /home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/calendar.py(1)<module>()
-> """Calendar printing functions
(Pdb)
```

Then we'll set a breakpoint after lots of stuff has been defined and continue to that breakpoint:

```pycon
(Pdb) b 797
Breakpoint 1 at /home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/calendar.py:797
(Pdb) c
> /home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/calendar.py(797)<module>()
-> firstweekday = c.getfirstweekday
(Pdb) l
792
793
794     # Support for old module level interface
795     c = TextCalendar()
796
797 B-> firstweekday = c.getfirstweekday
798
799     def setfirstweekday(firstweekday):
800         if not MONDAY <= firstweekday <= SUNDAY:
801             raise IllegalWeekdayError(firstweekday)
802         c.firstweekday = firstweekday
```

The string representation for that `c` variable doesn't tell us much:

```pycon
(Pdb) !c
<__main__.TextCalendar object at 0x7416de93af90>
```

If we use the `dir` alias, we'll see every attribute that's accessible on `c` printed in a pretty friendly format:

```pycon
(Pdb) dir c
c._firstweekday = 0
c.firstweekday = 0
c.formatday = <bound method TextCalendar.formatday of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatmonth = <bound method TextCalendar.formatmonth of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatmonthname = <bound method TextCalendar.formatmonthname of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatweek = <bound method TextCalendar.formatweek of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatweekday = <bound method TextCalendar.formatweekday of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatweekheader = <bound method TextCalendar.formatweekheader of <__main__.TextCalendar object at 0x7416de93af90>>
c.formatyear = <bound method TextCalendar.formatyear of <__main__.TextCalendar object at 0x7416de93af90>>
c.getfirstweekday = <bound method Calendar.getfirstweekday of <__main__.TextCalendar object at 0x7416de93af90>>
c.itermonthdates = <bound method Calendar.itermonthdates of <__main__.TextCalendar object at 0x7416de93af90>>
c.itermonthdays = <bound method Calendar.itermonthdays of <__main__.TextCalendar object at 0x7416de93af90>>
c.itermonthdays2 = <bound method Calendar.itermonthdays2 of <__main__.TextCalendar object at 0x7416de93af90>>
c.itermonthdays3 = <bound method Calendar.itermonthdays3 of <__main__.TextCalendar object at 0x7416de93af90>>
c.itermonthdays4 = <bound method Calendar.itermonthdays4 of <__main__.TextCalendar object at 0x7416de93af90>>
c.iterweekdays = <bound method Calendar.iterweekdays of <__main__.TextCalendar object at 0x7416de93af90>>
c.monthdatescalendar = <bound method Calendar.monthdatescalendar of <__main__.TextCalendar object at 0x7416de93af90>>
c.monthdays2calendar = <bound method Calendar.monthdays2calendar of <__main__.TextCalendar object at 0x7416de93af90>>
c.monthdayscalendar = <bound method Calendar.monthdayscalendar of <__main__.TextCalendar object at 0x7416de93af90>>
c.prmonth = <bound method TextCalendar.prmonth of <__main__.TextCalendar object at 0x7416de93af90>>
c.prweek = <bound method TextCalendar.prweek of <__main__.TextCalendar object at 0x7416de93af90>>
c.pryear = <bound method TextCalendar.pryear of <__main__.TextCalendar object at 0x7416de93af90>>
c.setfirstweekday = <bound method Calendar.setfirstweekday of <__main__.TextCalendar object at 0x7416de93af90>>
c.yeardatescalendar = <bound method Calendar.yeardatescalendar of <__main__.TextCalendar object at 0x7416de93af90>>
c.yeardays2calendar = <bound method Calendar.yeardays2calendar of <__main__.TextCalendar object at 0x7416de93af90>>
c.yeardayscalendar = <bound method Calendar.yeardayscalendar of <__main__.TextCalendar object at 0x7416de93af90>>
```

If we use `attrs` we'll see *just* the non-method attributes:

```pycon
(Pdb) attrs c
c._firstweekday = 0
c.firstweekday = 0
```

And `vars` will show us just the attributes that live as proper instance attributes in that object's `__dict__` dictionary:

```pycon
(Pdb) vars c
c._firstweekday = 0
```

The `src` alias can be used to see the source code for a given method:

```pycon
(Pdb) src c.prmonth
/home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/calendar.py on line 404:
    def prmonth(self, theyear, themonth, w=0, l=0):
        """
        Print a month's calendar.
        """
        print(self.formatmonth(theyear, themonth, w, l), end='')
```

And the `loc` alias will show us all the local variables defined in the current scope:

```pycon
(Pdb) loc
APRIL = __main__.APRIL
AUGUST = __main__.AUGUST
Calendar = <class '__main__.Calendar'>
DECEMBER = __main__.DECEMBER
Day = <enum 'Day'>
FEBRUARY = __main__.FEBRUARY
FRIDAY = __main__.FRIDAY
HTMLCalendar = <class '__main__.HTMLCalendar'>
IllegalMonthError = <class '__main__.IllegalMonthError'>
IllegalWeekdayError = <class '__main__.IllegalWeekdayError'>
IntEnum = <enum 'IntEnum'>
JANUARY = __main__.JANUARY
JULY = __main__.JULY
JUNE = __main__.JUNE
LocaleHTMLCalendar = <class '__main__.LocaleHTMLCalendar'>
LocaleTextCalendar = <class '__main__.LocaleTextCalendar'>
MARCH = __main__.MARCH
MAY = __main__.MAY
MONDAY = __main__.MONDAY
Month = <enum 'Month'>
NOVEMBER = __main__.NOVEMBER
OCTOBER = __main__.OCTOBER
SATURDAY = __main__.SATURDAY
SEPTEMBER = __main__.SEPTEMBER
SUNDAY = __main__.SUNDAY
THURSDAY = __main__.THURSDAY
TUESDAY = __main__.TUESDAY
TextCalendar = <class '__main__.TextCalendar'>
WEDNESDAY = __main__.WEDNESDAY
_CLIDemoCalendar = <class '__main__._CLIDemoCalendar'>
_CLIDemoLocaleCalendar = <class '__main__._CLIDemoLocaleCalendar'>
_get_default_locale = <function _get_default_locale at 0x7416de7c0930>
_locale = <module 'locale' from '/home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/locale.py'>
_localized_day = <class '__main__._localized_day'>
_localized_month = <class '__main__._localized_month'>
_monthlen = <function _monthlen at 0x7416de7c0720>
_nextmonth = <function _nextmonth at 0x7416de7c0880>
_prevmonth = <function _prevmonth at 0x7416de7c07d0>
_validate_month = <function _validate_month at 0x7416de7c05c0>
c = <__main__.TextCalendar object at 0x7416de93af90>
datetime = <module 'datetime' from '/home/trey/.local/share/uv/python/cpython-3.15.0a3-linux-x86_64-gnu/lib/python3.15/datetime.py'>
day_abbr = <__main__._localized_day object at 0x7416de941090>
day_name = <__main__._localized_day object at 0x7416de93acf0>
different_locale = <class '__main__.different_locale'>
error = <class 'ValueError'>
global_enum = <function global_enum at 0x7416dee17480>
isleap = <function isleap at 0x7416dea92770>
leapdays = <function leapdays at 0x7416de7c0460>
mdays = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
month_abbr = <__main__._localized_month object at 0x7416de9411d0>
month_name = <__main__._localized_month object at 0x7416de93ae40>
monthrange = <function monthrange at 0x7416de7c0670>
repeat = <class 'itertools.repeat'>
standalone_month_abbr = <__main__._localized_month object at 0x7416de954fc0>
standalone_month_name = <__main__._localized_month object at 0x7416de941310>
sys = <module 'sys' (built-in)>
weekday = <function weekday at 0x7416de7c0510>
```

## `~/.pdbrc` isn't as powerful as `PYTHONSTARTUP`

I also have a custom `PYTHONSTARTUP` file, which is launched every time I start a new Python REPL (see [Handy Python REPL modifications][pythonstartup]).
A `PYTHONSTARTUP` file is just Python code, which makes it easy to customize.

A `~/.pdbrc` file is *not* Python code... it's a very limited custom file format.

You may notice that every `alias` line defined in my `~/.pdbrc` file is a bunch of code shoved all on one line.
That's because there's no way to define an alias over multiple lines.

Also any variables assigned in an `alias` will leak into the surrounding scope... so I have a `del` statement in a couple of those aliases to clean up a stray variable assignment (from an `import`).

See the documentation on [`alias`][alias] and the top of the [debugger commands][] for more on how `~/.pdbrc` files work.


[pythonstartup]: https://treyhunner.com/2025/10/handy-python-repl-modifications/
[alias]: https://docs.python.org/3/library/pdb.html#pdbcommand-alias
[debugger commands]: https://docs.python.org/3/library/pdb.html#debugger-commands
