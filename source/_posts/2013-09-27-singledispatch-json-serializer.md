---
layout: post
title: Extensible JSON encoder using single-dispatch functions
type: post
published: true
comments: true
---

Single-dispatch generic functions will be added to Python 3.4 (as proposed in [PEP 443][]).  When reading about single-dispatch functions I immediately thought of the difficulties I've had with custom JSON encoders.  Below I explain why custom JSON encoders can complicate your application and how single-dispatch functions could be used to create a simpler JSON encoder.

## JSON Encoding using the json library

With the current Python `json` library, using an extensible JSON encoder in your generic application may require some/all of the following:

- Allowing specification of custom encoder class by client applications
- Overriding the default JSON encoder class (or a client-specified one) for any further extensions
- Passing JSON encoder classes into other serialization libraries used by your application

### Combining JSON encoders

If you need to compose two custom JSON encoders specified in two different packages, you may need to:

- Use multiple inheritance and hope the encoders play nicely together
- Duplicate code from one of the packages and create a new serializer with single inheritance
- Monkey patch one or both of the libraries

## JSON encoder using single-dispatch generic functions

I created a wrapper around the `json` library to make a JSON encoder using single-dispatch generic functions.  Here's how to use it:

{% gist 6734816 example.py %}

As you can see, it's fairly easy to extend the encoder to understand serialization rules for new data types.

The impementation is fairly simple, albeit a hack:

{% gist 6734816 json_singledispatch.py %}

This code is intended as a proof-of-concept to demonstrate the power of single-dispatch generic functions.  Feel free to use it however you like.

## Related Links

- [What single-dispatch generic functios mean for you][1]
- [Python 3.4 single dispatch, a step into generic functions][2]

[pep 443]: http://www.python.org/dev/peps/pep-0443/
[1]: http://lukasz.langa.pl/8/single-dispatch-generic-functions/
[2]: http://julien.danjou.info/blog/2013/python-3.4-single-dispatch-generic-function
