---
layout: post
title: Test-Inspired Development
type: post
published: true
comments: true
---

You need to write tests for your code to demonstrate that it works as expected.  In this post I will note the method I usually use for writing code and writing tests.

I follow a method of development similar to test-driven development, which I call "test-inspired development".  Here's roughly what I do:

1. Write a bit of code
2. Write a bit of a unit test for your code
3. Ensure the test succeeds, but fails when the code is commented out or git stash-ed
4. Repeat steps 1, 2, and 3 as needed
5. Start writing an integration test, fleshing out as far as you can
6. Make sure the integration test fails at the correct point
7. Repeat steps 5 and 6 as needed
8. Make sure no commit you make along the way contains both tests and code
9. Use git rebase if necessary to ensure the test commits come before the code commits

Ideally I would write all of my test code first and then write my application code and ensure my tests pass.  That isn't what usually happens though.  I often find it tricky to write full tests before writing any code.  Even when writing code in small parts, sometimes my code gets written before the corresponding test code.

I write all of my code in feature branches (short-lived branches forked from master) and I often create a pull request (even against my own repository) when creating a new feature.  Because I commit the tests first, a code reviewer can easily confirm that all the new tests actually fail correctly without the code present by simply rolling back to the last test commit and running the tests.

I usually write my unit tests first and at or near the same time as my code because they help often help shape my code heavily.  The functional/integration tests are important for ensuring that the application actually works all the way through (working parts are useless on their own).

Have questions about my testing methodology?  Do you use a different technique?  Feel free to share your thoughts in the comments below.
