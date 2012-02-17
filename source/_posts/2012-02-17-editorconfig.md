---
layout: post
title: Maintaining consistent coding conventions with EditorConfig
type: post
published: true
---

I often have indentation issues when coding because I work with many open
source (and closed source) projects that have different identation styles.  For
example, my [jQuery formrestrict][] uses 4 spaces for indentation,
[jQuery expander][] uses 2 spaces, and [jQuery pagination][] uses hard tabs. 
I don't want to change my text editor's indentation settings every time I open
one of these files and using a plugin to auto-detect indentation is only a
partial solution.  To solve this problem I started a project I call
EditorConfig.

[EditorConfig][] defines coding conventions for groups of files and instructs
text editors to adhere to these conventions.  To solve my problem, I just
create a file called `.editorconfig` that sets indentation for my files and
with my EditorConfig plugin installed Vim takes care of the rest.  Here's an
example `.editorconfig` file I could add to my project that uses
[jQuery expander][] and [jQuery pagination][]:

``` ini .editorconfig
    [*.js]
    indent_style = space
    indent_size = 4

    [jquery.expander.js]
    indent_style = space
    indent_size = 2

    [jquery.pagination.js]
    indent_style = tab
    indent_size = 4
```

With this `.editorconfig` file, all JavaScript files use 4 spaces for
indentation except for `jquery.expander.js` which uses 2 spaces and
`jquery.pagination.js` which uses hard tabs with a column width of 4.  If I put
my `.editorconfig` file under version control, other developers working on my
project can see the coding conventions I defined and if their text editor has
an EditorConfig plugin installed their editor will automatically use the
correct indentation as well.

Example EditorConfig files can be seen in my own projects (such as
[in my dotfiles repo][dotfiles editorconfig]) and in the
[various EditorConfig plugin codebases][github organization page].  More
information on EditorConfig can be found at the
[EditorConfig website][EditorConfig].

EditorConfig plugins are [available for 6 different editors][download plugins]
now.  If you like the idea, [try out EditorConfig][EditorConfig] for your
favorite editor and [tell us what you think][mailing list].  If you don't like
the idea or have a problem with EditorConfig please [submit an issue][issues],
add a thread to [the mailing list][mailing list], or send me an email voicing
your concern.

[EditorConfig]: http://editorconfig.org
[Github organization page]: https://github.com/treyhunner/dotfiles/blob/master/.editorconfig
[issues]: https://github.com/editorconfig/editorconfig/issues
[mailing list]: https://groups.google.com/forum/?fromgroups#!forum/editorconfig
[download plugins]: http://editorconfig.org/#download

[jQuery formrestrict]: https://github.com/treyhunner/jquery-formrestrict
[jQuery expander]: https://github.com/kswedberg/jquery-expander
[jQuery pagination]: https://github.com/gbirke/jquery_pagination
[dotfiles editorconfig]: https://github.com/treyhunner/dotfiles/blob/master/.editorconfig
