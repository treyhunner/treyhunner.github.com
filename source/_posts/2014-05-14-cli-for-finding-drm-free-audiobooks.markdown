---
layout: post
title: "CLI for finding DRM-free Audiobooks"
date: 2014-05-14 12:31
comments: true
---

I recently acquired an appreciation for audiobooks.  I listen to multiple
audiobooks every month and I prefer DRM-free audiobooks so that I can listen
through my favorite audiobook reader on each of my devices.

[Downpour][] and [eMusic][] are the only services I know that provide a large
selection of DRM-free audiobooks.  Unfortunately not all audiobooks are
available on either of these sites, so I often end up searching both sites for
each book to discover what versions (if any) are available from each.  I got
sick of searching both websites all the time, so I just created a Python script
to do that work for me.

{% gist 21f307b975027be5162d %}

### Future Improvements

Some ideas for future improvements:

- Add [Audible] results when the book cannot be found in a DRM-free format
- Rewrite the script in JavaScript and create a Chrome extension out of it
- Use [clint][] to colorize the command-line output

[audible]: http://www.audible.com/
[clint]: https://github.com/kennethreitz/clint
[downpour]: http://www.downpour.com/
[emusic]: http://www.emusic.com/
