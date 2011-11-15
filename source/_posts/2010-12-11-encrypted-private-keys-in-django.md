---
layout: post
title: Encrypted private keys in Django
type: post
published: true
comments: true
---
Uniquely identifiable URLs are necessary for many web applications.  For example, a website that provides book reviews may identify the URL of a specific book like this: **www.example.com/books/8839/**.  The easiest way to identify entities in Django is to use the unique primary key of each object, which by default is an auto-incremented positive integer.

Revealing the primary key of an entity is often not desirable.  An astute visitor of the website mentioned above may be able to guess information from the URL such as how many book reviews are available on the website or how old specific reviews are.

The code snippet below demonstrates one way to use a unique but cryptic identifier for an object without needing to change the way primary keys are generated.  There are two notable extensions to the basic Django Model in the below code:

1. The encrypted_pk and encrypted_id model properties return an AES-encrypted version of the primary key as a 13 character base-36 string.
2. The get method of the default manager can be queried with an encrypted primary key by using the keyword argument encrypted_pk.

Feel free to use this code however you want.

{% gist 735861 %}
