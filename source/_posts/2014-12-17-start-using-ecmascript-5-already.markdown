---
layout: post
title: "Start using ECMAScript 5 already"
date: 2014-12-17 16:57:17 -0800
comments: true
categories: 
---

It's 2014.  ECMAScript 5 has been finalized for years now and yet the world still seems to be using ECMAScript 3.

## Arrays

### indexOf and lastIndexOf

Returns the index (or last index) at which a value can be found in the array

Equivalent to [\_.indexOf][] and [\_.lastIndexOf][]

### every

Returns true if **all** the values in the array pass the test implemented by the provided function

Equivalent to [\_.every][]

### some

Returns true if **any** of the values in the array pass the test implemented by the provided function

Equivalent to [\_.some][]

### forEach

Executes a provided function once for each array item

Equivalent to [\_.each][]

### map

Returns a new array with the results of calling a provided function on each item of the array

Equivalent to [\_.map][]

### filter

Returns a new array with all array items that pass the given test function implemented.

Equivalent to [\_.filter][]

### reduce and reduceRight

Reduces a list of values into a single value using an accumulator function (either left-to-right or right-to-left)

Equivalent to [\_.reduce][] and [\_.reduceRight][]

[\_.bind]: http://underscorejs.org/#bind
[\_.each]: http://underscorejs.org/#each
[\_.every]: http://underscorejs.org/#every
[\_.filter]: http://underscorejs.org/#filter
[\_.indexOf]: http://underscorejs.org/#indexOf
[\_.lastIndexOf]: http://underscorejs.org/#lastIndexOf
[\_.map]: http://underscorejs.org/#map
[\_.reduce]: http://underscorejs.org/#reduce
[\_.reduceRight]: http://underscorejs.org/#reduceRight
[\_.some]: http://underscorejs.org/#some

## Miscellaneous

### JSON.stringify and JSON.parse

TODO link to JSON polyfill

### Function.prototype.bind

Returns a function that when called has its `this` keyword argument set to the provided value

Equivalent to [\_.bind][]

### String.prototype.trim

Returns a copy of the string with whitespace removed from the beginning and end

## Don't use Underscore

Underscore Array methods you should stop using:

Underscore Object methods you should stop using:

- \_.keys -> Object.prototype.keys


Underscore Function methods you should stop using:

- \_.bind -> Function.prototype.bind

Others:

- \_.isArray -> Array.isArray
- \_.now -> Date.now

## More stuff

- Object.create
- Getters/setters
