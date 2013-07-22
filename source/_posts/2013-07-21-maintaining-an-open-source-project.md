---
layout: post
title: Maintaining an open source project
type: post
published: true
---

This post contains some of my opinions on how to maintain an open source project well.  I've built up my opinions on this topic from maintaining and contributing to open source projects.  Keep in mind that I am not an expert on this topic.


## Structure your project logically

You shouldn't need to worry about structuring your project because others have done that work for you.  **Base your project's design on other well-organized projects.**

I compiled some tips I try to follow for open source Django projects I maintain in my [django-skeleton-app][] repository.  Check it out if you're starting a new Python project.


## Make it very easy to contribute

Document your process for contributing code, filing bugs, and maintaining other feedback.  Reference this process in your README file, your documentation, and your [CONTRIBUTING][] file.  If you need a place to discuss project development outside of the issue tracker, consider creating a mailing list.


## Be kind

Thank your contributors, appologize if you make a big mistake or say something rude, and be very courteous.  Add all your contributors to the AUTHORS file and grant push access to active contributors.


## Be Responsive

Don't have time to look over a new pull request this week?  Make a comment noting when you'll give your feedback.  This way your contributor can add a friendly reminder later without feeling rude.

Realized you forgot to respond to a 12 month old pull request?  Respond right now and ask whether the code or problem is still relevant.  A late response is better than none at all.

Don't know if you'll ever have time to look at an issue?  Say so!  **Do not leave your contributors in the dark!**


## Automate all the things

Use:

- [Travis CI][]: run continuous integration tests for all pushes and pull requests
- [Coveralls][]: measure code coverage while running your CI tests
- A documentation site like [Read The Docs][] which auto-updates on pushes


## Learn from others

I'm not the only one with opinions about open source.

Read more opinions on maintaining an open source project:

- [Tips for maintaining an Open-Source library][segment.io post]
- [Open Source Community, Simplified][code simplicity post]
- [How to Spead The Word About Your Code][mozilla post]

Watch some videos about maintaining an open source project:

- [Maintaining Your Sanity While Maintaining Your Open Source App][lavin talk]
- [Write the Docs][bennett talk]


[django-skeleton-app]: https://github.com/treyhunner/django-skeleton-app
[contributing]: https://github.com/blog/1184-contributing-guidelines
[travis ci]: https://travis-ci.org/
[coveralls]: https://coveralls.io/
[read the docs]: https://readthedocs.org/
[segment.io post]: https://segment.io/blog/tips-for-maintaining-an-open-source-library/
[mozilla post]: https://hacks.mozilla.org/2013/05/how-to-spread-the-word-about-your-code/
[code simplicity post]: http://www.codesimplicity.com/post/open-source-community-simplified/
[lavin talk]: http://www.youtube.com/watch?v=xgWFTrXn0_U
[bennett talk]: http://pyvideo.org/video/1795/write-the-docs
