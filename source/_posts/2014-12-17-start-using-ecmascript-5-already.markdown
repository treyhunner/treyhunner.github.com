---
layout: post
title: "ECMAScript 5: The Future is Now"
date: 2015-02-08 18:00:00 -0800
comments: true
categories: 
---

ECMAScript 5 was finalized over five years ago and it is well supported in all modern browsers.  So, with ECMAScript 6 nearing standardization, let's talk about ECMAScript 5.

Do you know what features were added in ECMAScript 5?

Do your target browsers support ECMAScript 5 yet?

<aside>
    <dfn>ECMAScript</dfn> is a scripting language standardized by <abbr title="European Computer Manufacturers Association">Ecma</abbr> International and is the core specification of the JavaScript language.
</aside>

## Arrays

[Underscore.js][] is a popular JavaScript library containing "a whole mess of useful functional programming helpers".  Most of these helpers work on arrays and other enumerable objects (collections, as Underscore calls them).

The ECMAScript 5 spec includes a handful of these functional programming helpers as methods on native JavaScript Array objects.

- **[`indexOf`][]** and **[`lastIndexOf`][]**, like [`_.indexOf`][] and [`_.lastIndexOf`][], return the index (or last index) at which a value can be found in the array

- **[`every`][]**, like [`_.every`][], returns true if **all** the values in the array pass the test implemented by the provided function

- **[`some`][]**, like [`_.some`][], returns true if **any** of the values in the array pass the test implemented by the provided function

- **[`forEach`][]**, like [`_.each`][], executes a provided function once for each array item

- **[`map`][]**, like [`_.map`][], returns a new array with the results of calling a provided function on each item of the array

- **[`filter`][]**, like [`_.filter`][], returns a new array with all array items that pass the given test function included.

- **[`reduce`][]** and **[`reduceRight`][]**, like [`_.reduce`][] and [`_.reduceRight`][], reduce a list of values into a single value using an accumulator function (either left-to-right or right-to-left)

## Miscellaneous

Here are a variety of other features that were added to ECMAScript 5, in addition to array helper functions:

- [`Object.keys`][], like [`_.keys`][], returns an array of a given object's enumerable properties

- [`Array.isArray`][], like [`_.isArray`][], returns `true` if a given object is an array

- [`Date.now`][], like [`_.now`][] returns the number of milliseconds elapsed since 1 January 1970 00:00:00 UTC

- [`JSON.stringify`][] converts JavaScript objects to JSON strings and [`JSON.parse`][] converts JSON strings to JavaScript objects.

- [`Function.prototype.bind`][], like [`_.bind`][], returns a function that when called has its `this` keyword argument set to the provided value

- [`String.prototype.trim`][], returns a copy of the string with whitespace removed from the beginning and end of the string

- [`parseInt`][] no longer treats strings starting with `0` as octal values

- Strict mode, Object.create, Object.seal, Object.freeze, getters/setters, and more were also added in ECMAScript 5

## Underscore.js vs Native

I try to use native array methods instead of their Underscore.js equivalents whenever possible.  However, these native array methods don't work in all cases.

### Not all enumerables are arrays

Here's two enumerable objects which are not arrays:

1. NodeList objects in the browser
2. File buffers in Node.js

You cannot use array methods like `forEach` on these enumerables, but you can the Underscore.js equivalents like `_.each`.

### So why not use Underscore for everything?

#### Native methods are more understandable

Web developers know JavaScript.  Web developers may not Underscore or your Underscore-like library of choice.  Don't stray far from vanilla JavaScript when you don't need to.

#### Underscore is less portable

Underscore doesn't come bundled with your rendering engine.

#### Native methods are future-proof

Underscore is cool today, but [lodash][] might be cooler tomorrow.  Or maybe you'd prefer to use [JFP][].

#### Native methods can be faster

As browser engines improve their optimization of native code, your code improves in speed.  Underscore's equivalents of these methods cannot be further optimized at the low-level as their native equivalents.

This claim as a theoretical one.  Here's some jsPerf links to test the real performance difference:

- [indexOf](http://jsperf.com/array-prototype-indexof-vs-indexof) and [lastIndexOf](http://jsperf.com/array-prototype-lastindexof-vs-lastindexof)
- [every](http://jsperf.com/array-prototype-every-vs-every)
- [some](http://jsperf.com/array-prototype-some-vs-some2)
- [forEach](http://jsperf.com/array-prototype-foreach-vs-each)
- [map](http://jsperf.com/array-prototype-map-vs-map)
- [filter](http://jsperf.com/array-prototype-filter-vs-filter)
- [reduce](http://jsperf.com/array-prototype-reduce-vs-reduce) and [reduceRight](http://jsperf.com/array-prototype-reduceright-vs-reduceright)


## What browsers support ECMAScript 5?

ECMAScript 5 is fully supported in Internet Explorer 10 and nearly fully supported in IE9.  Modern versions of Chrome and Firefox also fully support ECMAScript 5.

#### What if you need to support IE7 or IE8?

Fortunately, all of the array methods discussed above and some of the other ECMAScript 5 features can be [polyfilled][] using [es5-shim][].

#### ECMAScript 5 all the things!

With these pollyfills in place, you should be able to use the majority of ECMAScript 5 features everywhere.  Go forth and ES5-ify your code!

<aside>
This blog post was based on my ECMAScript 5 talk.  You can view the slides at http://treyhunner.com/es5-talk/
</aside>


[`indexOf`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf
[`lastIndexOf`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf
[`every`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
[`some`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
[`forEach`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
[`map`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
[`filter`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
[`reduce`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce
[`reduceRight`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduceRight
[`parseInt`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/parseInt
[`Function.prototype.bind`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind
[`String.prototype.trim`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/trim
[`JSON.parse`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
[`JSON.stringify`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify
[`Object.keys`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys
[`Array.isArray`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/isArray
[`Date.now`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/now

[`_.bind`]: http://underscorejs.org/#bind
[`_.each`]: http://underscorejs.org/#each
[`_.every`]: http://underscorejs.org/#every
[`_.filter`]: http://underscorejs.org/#filter
[`_.indexOf`]: http://underscorejs.org/#indexOf
[`_.isArray`]: http://underscorejs.org/#isArray
[`_.keys`]: http://underscorejs.org/#keys
[`_.lastIndexOf`]: http://underscorejs.org/#lastIndexOf
[`_.map`]: http://underscorejs.org/#map
[`_.now`]: http://underscorejs.org/#now
[`_.reduce`]: http://underscorejs.org/#reduce
[`_.reduceRight`]: http://underscorejs.org/#reduceRight
[`_.some`]: http://underscorejs.org/#some

[es5-shim]: https://github.com/es-shims/es5-shim
[JFP]: https://github.com/cmstead/JFP
[lodash]: https://github.com/lodash/lodash
[polyfilled]: https://remysharp.com/2010/10/08/what-is-a-polyfill
[Underscore.js]: http://underscorejs.org/
