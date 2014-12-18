---
layout: post
title: "Start using ECMAScript 5 already"
date: 2014-12-17 16:57:17 -0800
comments: true
categories: 
---

It's 2014.  ECMAScript 5 has been finalized for years now and yet the world still seems to be using ECMAScript 3.

## Don't use Underscore

Underscore Array methods you should stop using:

- \_.each -> Array.prototype.forEach
- \_.every -> Array.prototype.every
- \_.some -> Array.prototype.some
- \_.filter -> Array.prototype.filter
- \_.reduce -> Array.prototype.reduce
- \_.reduceRight -> Array.prototype.reduceRight
- \_.map -> Array.prototype.map
- \_.indexOf -> Array.prototype.indexOf
- \_.lastIndexOf -> Array.prototype.lastIndexOf


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
