---
layout: post
title: "Python Oddities"
date: 2019-04-10 13:53:02 -0700
comments: true
categories: python
---


## Variables and scope


_MyClass__number = 1
class MyClass:
     def get_number(self):
         return __number

MyClass().get_number()
>>> 1

🐍 #Python scope oddity 👇
class A:
    a, z = [1], 0
    c = [z for x in a]

Python 2: A.c==[0]
Python 3: NameError


## Mutability

🐍 #Python in-place add oddity 👇
tuple
>>> a = b = (1,)
>>> a += (2,)
>>> b
(1,)
list
>>> c = d = [1]
>>> c += [2]
>>> d
[1, 2]


## Operations
 
🐍 Python syntax oddity 👇
This += raises error but also works!
>>> a = ([],)
>>> a[0] += ['hi']…

🐍 Python 3 comparison short-circuit oddity 👇
>>> (0, 'a') < (1, 0)
True 😕
>>> (1, 'a') < (1, 0)
TypeError raised 😮❗


## Tricky code and silly code

#PythonOddity
>>> "hello" + True
TypeError: Can't convert 'bool' object to str implicitly
>>> "hello" * True
'hello'

🐍 #Python string oddity 👇
>>> '\n'.join(['hi' 'there'])
'hithere'
😕
>>> '\n'.join(('hi' 'there'))
'h\ni\nt\nh\ne\nr\ne'
😮

@treyhunner · 23 Feb 2016
🐍 Python oddity (in CPython) 👇
You can delete builtins
>>> globals().clear()
>>> import math
ImportError: __import__ not found

Python 3.6 nested f-string oddity:
>>> f"""{f'''{f'{f"{42}"}'}'''}"""
42

🐍 #Python assignment oddity 👇
name can be created & used in the same line
>>> x = [1, 2]
>>> i, x[i] = 1, 4
>>> x
[1, 4]

🐍 #Python loop oddity 👇
>>> x = {'a': 1, 'b': 2}
>>> y = {}
>>> for k, y[k] in x.items(): pass
...
>>> y
{'a': 1, 'b': 2}


## Unexpected Behaviors

🐍 Python list multiplication oddity 👇
>>> matrix = [[0] * 2] * 2
>>> matrix[0][0] = 1
>>> matrix
[[1, 0], [1, 0]]

Python title-case oddity 🐍💼
>>> "I ain't sorry".title()
"I Ain'T Sorry"

🐍 #python containment oddity 😕

>>> nums = reversed([1, 2, 3, 4])
>>> 2 in nums
True
>>> 2 in nums
False


## Identity and equality

🐍 python identity oddity 😕

>>> a = {}
>>> id(a.pop) == id(a.pop)
True
>>> a.pop is a.pop
False

🐍 Python oddity (in CPython) 👇
>>> x, y = 999, 999
>>> x is y
True
>>> x = 999
>>> y = 999
>>> x is y
False


>>> x = 4
>>> y = 4
>>> x is y
True
>>> x = 999
>>> y = 999
>>> x is y
False

🐍 #Python equality oddity 👇
enumerate is comparable... but in an odd way
>>> a = [1, 2]
>>> enumerate(a) == enumerate(a)
False


## Interesting Behaviors

>>> greeting = 'hello'
>>> greeting[0]
'h'
>>> greeting[0][0]
'h'
>>> greeting[0][0][0][0][0][0][0][0]
'h'

Python list extend oddity 🐍😮
>>> x = []
>>> x += "hello"
>>> x
['h', 'e', 'l', 'l', 'o']

>>> a = [1]
>>> a += (2,)
>>> a
[1, 2]

>>> b = (1,)
>>> b += [2]
TypeError

🐍 #Python split('\n') vs. splitlines() 👇
>>> abc = 'a\nb\n'
>>> abc.split('\n')
['a', 'b', '']
>>> abc.splitlines()
['a', 'b']

#pythonoddity from @dbader_org
>>> {True: 'yes', 1: 'no', 1.0: 'maybe'}
{True: 'maybe'}
Explanation: https://dbader.org/blog/python-mystery-dict-expression …

from itertools import count, takewhile
n=count()
tiny = lambda n: n<3

>>> list(takewhile(tiny, n)), next(n)
([0, 1, 2], 4)

>>> isinstance(type, object), isinstance(object, type), isinstance(type, type)
(True, True, True)

Python repr oddity 🐍

>>> a = []
>>> for i in range(999): a = [a]
... 
RecursionError

>>> a = [1,2,3]
>>> b = {'a': 'b', 'c': 'd'}
>>> a += b
>>> a
[1, 2, 3, 'a', 'c']

🐍 Python hashing oddity 👇
Functions are valid dict keys!
>>> def greet(): return a
>>> d = {greet: 4}
>>> d[greet]
4

from random import shuffle
>>> x={0:'a',1:'b'}
>>> shuffle(x)
>>> x
{0: 'b', 1: 'a'}
>>> y={2:'c'}
>>> shuffle(y)
KeyError

🐍 #Python oddity 👇
>>> sum([[1, 2], [3, 4]], [])
[1, 2, 3, 4]
>>> sum(["ab", "cd"], "")
TypeError: sum() can't sum strings

🐍 Python regex oddity 👇
>>> import re
>>> re.findall('\D$', 'a\n')
['a', '\n']
\D$ matches two things here!


## Interesting Syntax

[1 if 2 else 3 for x4 in [5] if 6 if 7 if 8 if 9 or 0]

>>> ''
''
>>> ''''''
''
>>> ''''''''
''
>>> ''''''''''''
''
>>> ''''''''''''''
''
Figure out the pattern


>>> a = [1, 2]
>>> a.extend([3, 4])
>>> a += [5, 6]
>>> a[len(a):] = [7, 8]
>>> a
[1, 2, 3, 4, 5, 6, 7, 8]

(slightly) relevant #python (3.6) oddity:
>>> 0_0
0
>>> +_+ 0_0
0
hint: only works at the REPL

🐍 Python syntax oddity 👇
>>> (4).__add__(5)
9
>>> 4.__add__(5)
SyntaxError: invalid syntax
>>> 4.0.__add__(5)
9.0

🐍 Python syntax oddity 👇
Slashes: you can't end rawstrings with just 1 😦
>>> r'\\'
'\\\\'
>>> r'\'
SyntaxError






Python locals() oddity 🐍

>>> for var in locals(): print(var)
RuntimeError (after printing 1 variable)

🐍 #Python iteration oddity
>>> d = {0}
>>> for n, k in enumerate(d, 1):
...   d.remove(k)
...   d.add(n)
...
>>>
>>> d
{8}


>>> 5 in range(10) == True
False


🐍 #Python finally oddity 👇
break in finally suppressed exception
while True:
    try: raise Exception
    finally: break


🐍 Python string oddity 👇
>>> "⅐ↁⅣⅧↂⅪ".isnumeric()
True
>>> "ⅬⅭⅮ⅟Ⅿ³₉ↀ".isnumeric()
True
>>> "-3".isnumeric()
False 

🐍#Python continue oddity
>>> while 1:
...   try: break
...   finally: continue
SyntaxError
😕 continue not supported in finally

🐍 Python recursion oddity 👇
>>> x = []
>>> x.append(x)
>>> x in x
True
>>> y = []
>>> y.append([y])
>>> y in y
RecursionError

🐍 #Python function oddity 👇
>>> def cube(x): return x ** 3
>>> cube()
TypeError
>>> cube.__defaults__ = (0,)
>>> cube()
0


🐍 Python syntax oddity 👇
This += raises error but also works!
>>> a = ([],)
>>> a[0] += ['hi']
TypeError
>>> a[0]
['hi']

🐍 Python syntax oddity 👇
>>> []={}
>>> ()=[]
>>> []=()

last one used to give an error https://bugs.python.org/issue23275 
