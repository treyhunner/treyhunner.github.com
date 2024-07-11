---
layout: post
title: "GPT and Claude from your URL bar"
date: 2024-07-11 09:00:00 -0700
comments: true
categories: llm
---

I've been playing with using [Kagi][] and [Perplexity][] as my browser's default search engine recently.

Currently I have Kagi setup as my default search engine and I added a [custom bang][] command in my Kagi account so that **!x** will trigger a search with Perplexity.

This got me thinking... could I trigger a new [Chat GPT][] or [Claude][] chat from my browser's URL bar?


## How browsers query search engines

Whether you're using [Chrome][], [Firefox][], or some other browser (I'm trying [Vivaldi][]) you can add custom search engines to your browser.

Custom search engines use a template URL that looks something like this:

`https://duckduckgo.com/?q=%s`

Note that this URL is a *template* because of that `%s`.
That `%s` bit will be replaced by the actual query you search for.

So if Chat GPT and Claude have URLs that allow creating a new chat via a URL's query string (the thing after the `?`), then they could be used as search engines.

And it turns out... they do!


## Querying Chat GPT via a URL

To query Chat GPT via a URL query string, use:

`https://chatgpt.com/?q=%s`

Set that URL as a custom "search engine" in your browser.
Then whenever you'd like to start a new Chat GPT conversation, select your browser's URL bar, type the search engine prefix followed by a space, type your query, and hit Enter!


## Querying Claude via a URL

To query Claude via a URL query string, use:

`https://claude.ai/new?q=%s`

It works the same way as the Chat GPT URL.


## Querying Perplexity via a URL

This may be a bit redundant, as you may have thought to use Perplexity can be used as a "search engine" in your browser, but here's the URL in case you're looking for it:

`https://www.perplexity.ai/search?q=%s`


## Kagi bangs

If you're a [Kagi][] user, you can setup each of these as a custom bang.

**Chat GPT**

{% img /images/kagi-chatgpt-bang.png Screenshot of Chat GPT bang settings for Chat GPT %}

**Claude**

{% img /images/kagi-claude-bang.png Screenshot of Chat GPT bang settings for Claude %}

**Perplexity**

{% img /images/kagi-perplexity-bang.png Screenshot of Perplexity bang settings for Kagi %}

I'm not sure what bangs I ultimately want to use in the long-term.
Right now I have **!x** set to query Perplexity, **!c** set to query Chat GPT, and **!l** set to query Claude.

I was considering **!g** for Chat **G**PT but that searches Google already and I was considering **!c** for Claude, but I had already set that to search Chat GPT, so I went with **!l** for C**l**aude... or maybe it's **!l** for **L**LM. 🤔


## No Gemini "search" support

So Claude, Chat GPT, and Kagi can all initiate new conversations directly from your browser's URL bar using these 3 URLs:

- `https://chatgpt.com/?q=%s`
- `https://claude.ai/new?q=%s`
- `https://www.perplexity.ai/search?q=%s`

As far as I can tell, Gemini does not support starting a conversation via a query string.
Maybe this is related to Google embedding a similar feature [directly into Chrome](https://chromeunboxed.com/chromes-url-bar-is-getting-quick-access-to-gemini-ai/). 🤷


[kagi]: https://kagi.com
[perplexity]: https://www.perplexity.ai
[custom bang]: https://help.kagi.com/kagi/features/bangs.html#custom-bangs
[chat gpt]: https://chatgpt.com
[claude]: https://claude.ai
[chrome]: https://superuser.com/questions/1772248/how-to-add-custom-search-engine-to-chrome
[firefox]: https://support.mozilla.org/en-US/kb/change-your-default-search-settings-firefox
[vivaldi]: https://vivaldi.com/blog/search-favorite-websites-quickly/
