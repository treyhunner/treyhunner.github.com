---
layout: post
title: Replacement for jQuery AlphaNumeric plugin
type: post
published: true
comments: true
---
I recently inherited a codebase that used the [jQuery AlphaNumeric plugin][jquery-alphanumeric] extensively.  This plugin can be used to restrict users from entering certain characters into a form field.   The functions included for this plugin (**alphanumeric**, **alpha**, and **numeric**) claim to allow only alphabetic and/or numeric characters to be entered in the form field being acted on.

Unfortunately, this plugin is ineffectual.  I have witnessed unexpected behaviors of varying significance associated with this plugin:

1. Forbidden characters can be input by pasting with CTRL+V in Chrome
2. Forbidden characters can be input by selecting Edit-&gt;Paste in Firefox and IE
3. Forbidden characters can be input by middle-click pasting in Linux
4. The arrow keys, Home button, End button, and Delete button do not work in input fields using this plugin's functions in Firefox
5. The context menu is disabled (right clicking on an input field does nothing)
6. And most importantly, instead of using a list of allowed characters, a list of disallowed characters is used so these are the only characters that are actually forbidden:
   > !@#$%^&amp;*()+=[]';,/{}|":?~`.- 
    
The code is so brief that patching the current plugin would be pointless, so instead I wrote [a replacement][jquery-formrestrict] that acts similar enough that I did not have to change any of our pre-existing code that depended on the AlphaNumeric plugin.

First I created **restrict**, a very basic modifier function that takes a sanitizer function as an argument.  The sanitizer function should manipulate the string to be valid input (if it was not already) and return the valid version of this input.  The **restrict** function is triggered whenever the input field is altered and will immediately replace the text in the field with sanitized text.

Most of the restricts I would want to use on an input field can be represented by a regular expression, so I created the **regexRestrict** function that takes a regular expression as input and uses **restrict** to replace matches to this regular expression found in the string.

The **restrict** and **regexRestrict** functions provide every feature that the AlphaNumeric plugin promises, but they don't use the same syntax as the AlphaNumeric plugin.  To be able to drop this plugin into a codebase that currently uses the AlphaNumeric plugin, we'd need an equivalent to the **alphanumeric**, **alpha**, and **numeric** functions with all of their [stated features][alphanumeric features].  To allow the code that relied on the AlphaNumeric plugin to continue functioning, I created replacements for all three of these functions.  These functions take the same inputs as their AlphaNumeric plugin equivalents.

The restrict and regexRestrict functions and the alphanumeric plugin replacement that uses these functions can be [found on github][jquery-formrestrict].

[jquery-alphanumeric]: http://plugins.jquery.com/project/aphanumeric
[jquery-formrestrict]: http://github.com/treyhunner/jquery-formrestrict
[alphanumeric features]: http://itgroup.com.ph/alphanumeric/
