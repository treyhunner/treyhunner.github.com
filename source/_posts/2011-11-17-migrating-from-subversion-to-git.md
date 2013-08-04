---
layout: post
title: Migrating from Subversion to Git
type: post
published: true
comments: true
---

I recently migrated multiple Subversion repositories to Git.  I found
[this blog post][git-svn-abandon] very helpful during the process.  Here are
some tips I found helpful that were not mentioned in that post.


### Generating an authors file

Subversion denotes authors by usernames while Git uses name and email.  An
authors file can be used to map subversion usernames to Git authors when
creating the Git repository, like so:

    git-svn clone --stdlayout --authors-file=authors.txt http://your/svn/repo/url

The trickest part about [making an authors file][git-svn authors] was finding
all the authors.  I found this command useful for finding usernames of all
Subversion committers:

    svn log | awk '($0 ~ /^r/) {print $3}' | sort -u

A similar method of creating an authors file is
[presented here][creating svn.authorsfile].


### Removing git-svn-id messages

When migrating from Subversion, every commit messages has a `git-svn-id` line
appended to it like this one:

> git-svn-id: http://svn/repo/url/trunk@9837 1eab27b1-3bc6-4acd-4026-59d9a2a3569e

If you are planning on migrating away from your old Subversion repository
entirely, there's no need to keep these.  The following command (taken from the
[git filter-branch man page][git-filter-branch]) removes these `git-svn-id`
lines from all commit messages in the current branch:

    git filter-branch -f --msg-filter 'sed -e "/git-svn-id:/d"'


### Removing empty commit messages

Subversion allows empty commit messages, but Git does not.  Any empty commit
messages in your newly migrated git repository should be replaced so commands
like `git rebase` will work on these commits.

This command will replace all empty commit messages with <nobr>
"&lt;empty commit message&gt;"</nobr>:

    git filter-branch -f --msg-filter '
    read msg
    if [ -n "$msg" ] ; then
        echo "$msg"
    else
        echo "<empty commit message>"
    fi'


### Poking around

After you've cleaned up your new *master* branch, you should cleanup other
branches you plan to keep.  Just `git checkout` each branch and repeat the same
steps.  To find the remote subversion branches available for checkout use
`git branch -a`.

Migrating between version control systems may be a good time to permanently
cleanup commit history with a `git rebase` or eliminate large files
that were never used with a `git filter-branch`.  Just remember to make backups of
previous working versions of branches before changing them, just in case.

[git-svn-abandon]: http://blog.woobling.org/2009/06/git-svn-abandon.html "Migrating from Subversion to Git"
[git-filter-branch]: http://linux.die.net/man/1/git-filter-branch
[creating svn.authorsfile]: http://technicalpickles.com/posts/creating-a-svn-authorsfile-when-migrating-from-subversion-to-git/
[git-svn authors]: http://triptico.com/notes/8d4510bb.html
