---
layout: post
title: Random name generator website
type: post
published: true
---

In my [last post][] I discussed the **names** Python library that generates
random names.  I've now used this Python library to make a basic Flask website
that generates random names.  You can visit it at:
[http://www.pseudorandom.name][]

## It's responsive

The font size and margin on pseudorandom.name change based on the web browser
width and height.  I determined the font sizes I wanted to use for each screen
width by using the longest first and last name in the name files I'm using (11
and 13 characters respectively).  The website looks reasonable on various
desktop resolutions and on phone screens.

## It's an HTTP API

If curl is used to access the site, plain text is returned instead of an HTML
webpage.  For example:

    curl www.pseudorandom.name

The site is hosted on Heroku which [doesn't support bare domains][apex].
Currently http://pseudorandom.name redirects to http://www.pseudorandom.name so
using the bare domain requires telling curl to follow redirects with `-L`:

    curl -L pseudorandom.name

## More to come?

It might be nice to allow generating multiple names at once, generating
gender-specific names, and maybe providing other content types (JSON).  The
HTML version could also use a cleaner, more feature-full design.

Also it would probably be more efficient to use a SQL database for querying
random names so I may eventually abandon the names library and use a database
for querying.

The website's source code is [hosted on Github][github] and provided under an
[MIT license][].  Feel free to fork it or submit an issue.

[last post]: /2013/02/random-name-generator/
[http://www.pseudorandom.name]: http://www.pseudorandom.name
[apex]: https://devcenter.heroku.com/articles/custom-domains#apex-domains-examplecom
[github]: https://github.com/treyhunner/pseudorandom.name
[mit license]: http://th.mit-license.org/2013
