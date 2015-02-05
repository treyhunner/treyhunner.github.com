---
layout: post
title: "ECMAScript 5: The Future is Now"
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

Returns a new array with all array items that pass the given test function included.

Equivalent to [\_.filter][]

### reduce and reduceRight

Reduces a list of values into a single value using an accumulator function (either left-to-right or right-to-left)

Equivalent to [\_.reduce][] and [\_.reduceRight][]

## Miscellaneous

### JSON.stringify and JSON.parse

TODO link to JSON polyfill

### Function.prototype.bind

Returns a function that when called has its `this` keyword argument set to the provided value

Equivalent to [\_.bind][]

### String.prototype.trim

Returns a copy of the string with whitespace removed from the beginning and end

## Underscore.js vs Native

### Not all iterables are arrays

Here's two non-array ordered collections:

1. NodeList objects in the browser
2. File buffers in Node.js

You cannot use array methods like `forEach` on these non-array collections, but you can the Underscore.js equivalents like `each`.

### So why not use Underscore for everything?

#### Native methods are more understandable

Web developers know JavaScript.  Web developers may not Underscore or your Underscore-like library of choice.  Don't stray far from vanilla JavaScript when you don't need to.

#### Underscore is less portable

Underscore doesn't come bundled with your rendering engine.

#### Native methods are future-proof

Underscore is cool today, but lodash might be cooler tomorrow.  Or maybe you'd prefer to use JFP.

#### Native methods can be faster

As browser engines improve their optimization of native code, your code improves in speed.  Underscore's equivalents of these methods cannot be further optimized at the low-level as their native equivalents.

TODO: add jsperf links

#### Which underscore methods can you stop using?

There are a few Underscore methods you can stop using entirely.

- Instead of [\_.keys][], use **Object.prototype.keys**
- Instead of [\_.isArray][] use **Array.isArray**
- Instead of [\_.now][] use **Date.now**

## More stuff

- Object.create
- Getters/setters


[\_.bind]: http://underscorejs.org/#bind
[\_.each]: http://underscorejs.org/#each
[\_.every]: http://underscorejs.org/#every
[\_.filter]: http://underscorejs.org/#filter
[\_.indexOf]: http://underscorejs.org/#indexOf
[\_.isArray]: http://underscorejs.org/#isArray
[\_.keys]: http://underscorejs.org/#keys
[\_.lastIndexOf]: http://underscorejs.org/#lastIndexOf
[\_.map]: http://underscorejs.org/#map
[\_.now]: http://underscorejs.org/#now
[\_.reduce]: http://underscorejs.org/#reduce
[\_.reduceRight]: http://underscorejs.org/#reduceRight
[\_.some]: http://underscorejs.org/#some
