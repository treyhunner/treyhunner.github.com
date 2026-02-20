---
layout: post
title: "On the enviromental impact of using LLMs for writing code"
date: 2026-02-20 14:30:00 -0800
comments: true
categories: 
---

I've had *many* conversations over the past year with friends and colleagues about LLMs.
Some conversations have focused on their uses and misuses and some have focused on big picture concerns.

There are many reasons to be concerned about LLMs: job displacement, intellectual property issues, moral hazards. The one I hear the most is the environmental impact.

**TL;DR**: I think the environmental impact of LLMs is primarily a climate change problem, that the impact of individual LLM use on this problem is relatively small, and that climate change is best addressed through collective action (ideally taxes, subsidies, and regulations). But since systemic solutions aren't coming soon, understanding the relative impact of specific activities (including LLM use) does matter.

## Energy use of individual LLM prompts

When thinking about the energy use of LLMs, I tend to agree with the framing that Hannah Ritchie takes: this *is* something to be concerned about, but many headlines are misleading.

Hannah Ritchie is a data scientist, deputy editor at Our World in Data, and co-host of the podcast Solving for Climate. In Hannah's [post about the overall energy demand from AI data centers](https://hannahritchie.substack.com/p/ai-energy-demand), she notes that data centers in general make up **a small fraction of the world's global electricity demand** and that they are estimated to be a fairly small portion of the growth in global electricity use until 2030.

That doesn't mean that the energy demand from data centers isn't a problem. But, as she notes, due to the very uneven distribution of data centers around the globe, this is **a very localized problem**:
> What’s crucial here is that the energy demands for AI are very localised. This means there can be severe strain on the grid at a highly localised level, even if the impact on total energy demand is small.

Hannah also has [a follow up post on individual LLM use](https://hannahritchie.substack.com/p/carbon-footprint-chatgpt) where she suggests that individual users should "stop stressing about the energy and carbon footprint" of LLMs.

In all of these posts, she attempts to put numbers into perspective:
> The reason we often think that ChatGPT is an energy guzzler is because of the initial statement: it uses 10 times more energy than a Google search. Even if this is accurate, what’s missing is the context that a Google search uses a really tiny amount of energy. Even 10 times a really tiny number is still tiny.

Hannah also published [a follow up to her follow up post](https://hannahritchie.substack.com/p/ai-footprint-august-2025) where she seriously questions the 3 Wh figure (10 times higher than a Google search) that's often used when discussing the energy use of LLM queries. She considers whether the median LLM query may use closer to 0.3 Wh of energy.

I lean heavily on Ritchie's analysis throughout this post because I think her data-oriented framing of this issue is helpful. That said, detailed energy data from AI companies is scarce so her estimates are inherently fuzzy.

## Energy use of coding agents

Hannah's posts about individual LLM usage focuses on the "median query" in an LLM... but using a coding agent (Claude Code, Codex, etc.) to navigate through a repository and generate lots of code likely involves quite a bit more usage than a "median query" does.

Simon P. Couch [recently wrote a post](https://www.simonpcouch.com/blog/2026-01-20-cc-impact/) about the energy use he estimates for his Claude Code usage. He estimates that **his Claude Code usage** results in approximately **1,300 Wh** of energy each day. That's quite a bit higher than either 0.3 Wh or 3 Wh for a median LLM query.

If heavy coding agent use results in 1,300 Wh of energy, that represents **3.7%** of the average American's daily electricity use (based on an [average electricity generation per person](https://ourworldindata.org/explorers/energy?Total+or+Breakdown=Total&Energy+or+Electricity=Electricity+only&Metric=Per+capita+generation&country=USA~GBR~CHN~OWID_WRL~IND~BRA~ZAF) of 12,712 kWh in the US). Increasing your energy use by 4% is *not* nothing... but how bad is it?

## Climate impact of coding agents

Increased energy usage isn't as concerning to me as the negative impacts that the energy usage might have on the climate.

Going with [Adam Masley's assumptions](https://andymasley.substack.com/p/whats-the-full-hidden-climate-cost) of 0.37 grams of carbon dioxide emissions per watt-hour (Wh) in the US and the assumption that data centers use energy that's 48% more carbon intensive than the average US power plant, **1,300 Wh per day of coding agent usage** could result in 0.5 grams of CO₂ per Wh, for about **715 grams of CO₂ emissions per day** from coding agent use.

The annual carbon footprint of the average American is [16,300 kg of CO₂](https://ourworldindata.org/explorers/co2?time=earliest..2022&focus=~USA&Gas+or+Warming=CO%E2%82%82&Accounting=Consumption-based&Fuel+or+Land+Use+Change=All+fossil+emissions&Count=Per+capita&country=CHN~USA~IND~GBR~OWID_WRL), which is about 44.7 kg of CO₂ per day. So 715 grams of CO₂ from a day of coding agent usage may be about **1.6% of the average American's daily carbon footprint** of 44.7 kg of CO₂.

Again, 1.6% is not nothing. It's not *enormous* but it's certainly measurable.

I think that any discussion about greenhouse gas emissions should be considered in the context of the rest of life and ideally in context of the social cost of those emissions. I haven't tried quantifying the social cost, but I have looked up other activities and their climate impact.

For the sake of comparison, here are some *very rough* estimates of carbon dioxide equivalent emissions (CO₂e) for various consumables and activities:

- one hour of Netflix: 50 grams CO₂e
- a banana: 80 grams CO₂e
- one hour of Zoom: 100 grams CO₂e
- half cup tofu: 300 grams CO₂e
- half cup (dairy) greek yogurt: 400 grams CO₂e
- driving 5 miles in an EV: 500 grams CO₂e
- 5 minute shower: 700 grams CO₂e
- **1 day of using a coding agent: 700 grams CO₂e** (based on [one user's estimate](https://www.simonpcouch.com/blog/2026-01-20-cc-impact/))
- driving 5 miles in a gas car: 1,500 grams CO₂e
- beef burger: 5,000 grams CO₂e
- flying SAN to ORD (one-way): 400,000 grams CO₂e

Treat those numbers as "likely correct within an order of magnitude". Most of those numbers have pretty large error bars, as the industries that have solid data on these figures rarely publish them and even when they do, the actual emissions can vary greatly due to the number of variables involved.

If you're curious about any specific measurement, compute them based on sources you trust. I recommend Our World in Data: [food](https://ourworldindata.org/grapher/ghg-per-kg-poore), [streaming video](https://greenly.earth/en-us/leaf-media/data-stories/the-carbon-cost-of-streaming#anchor-articles_content$d086800e-3afb-4608-9c27-1f13bc477813), [transportation](https://ourworldindata.org/travel-carbon-footprint).

Note that I am not saying "using LLMs is not bad because people eat beef", which would be [whataboutism](https://andymasley.substack.com/p/a-cheat-sheet-for-conversations-about?utm_source=publication-search). But I don't think that we should discuss the carbon emissions of any given activity in a vacuum.

## Water use

I'm going to mostly skip over the water use of LLMs because I find it far less concerning than the energy use. Based on Andy Masley's numbers (from his provocatively-titled post [The AI water issue is fake](https://andymasley.substack.com/p/the-ai-water-issue-is-fake)), a median LLM query uses around 2ml of water including offsite power generation (0.3mL of water if we don't count power generation). That means that a full day of coding agent use would consume about 6.5 liters of water (0.6 liters for everything but the power generation).

The average American's daily water footprint is 1,600 liters. So 6.5 liters of water (largely from offsite power generation) represents roughly **0.4% of the average American's daily water footprint**. 90% of that water comes from the water required for power generation because generating electricity from natural gas, coal, and nuclear all requires water.

Like energy use, water use is a very localized issue. Unlike energy use, water use doesn't also contribute to climate change. Water use is worth discussing, but I find the climate impact of coding agents much more concerning. I'm also not sure how much the local impact of water use should be a concern, since it matters what type of water is used, how much of that water is returned to the source, and what else that water would be used for. Hank Green recently released [an interesting video on water use](https://www.youtube.com/watch?v=H_c6MWk7PQc).


## Climate change requires collective action

The biggest environmental concern of LLMs is how much they contribute to climate change.

Climate change is a collective action problem. We need to greatly limit greenhouse gas emissions. And in a world of goods with variable market-based prices, a negative externality like greenhouse gas emissions warrants a tax. A carbon tax or a cap and trade program could go *very far* in accomplishing that, but I'm skeptical that we'll see either of those happen on a massive international scale (and especially not in the US) anytime soon.

**Aside**: did you know that the US had [an Interagency Working Group on the Social Cost of Greenhouse Gases](https://www.congress.gov/crs-product/IF12916) which published official estimates on the cost of carbon emissions? It was established under Obama, disbanded under Trump, reestablished under Biden, and then disbanded again under Trump. I really wish the US would implement a carbon tax so that we can stop focusing on specific carbon-emitting activities and instead properly price carbon emissions in aggregate.


## So why talk about LLMs specifically?

If climate change is best addressed by big picture solutions, like a tax on all greenhouse gas emissions, then why even look into the climate impact of specific activities, like LLM use?

Because we don't have a carbon tax. And we're probably not getting one anytime soon.

In the absence of systemic solutions, general sentiment about what's a *big* problem and what's a *small* problem shapes how we respond... as individuals, in communities, as consumers and workers within companies, and as citizens pressuring various levels of government.

We can't expect individuals to weigh the climate impact of every action they take (thinking of The Good Place's S03E11: The Book of Dougs). And hoping that corporations will grow a conscience is wishful thinking. But having a shared understanding of the relative impacts of various climate concerns *does* have *some* effect on what gets attention, what gets research, and what gets regulated.

So I think it's worth understanding the relative impact of different activities, including LLM use. Putting numbers in context helps us have better conversations and direct our collective energy more effectively.


## Global and local, individual and collective

There are two angles I see this problem from:

1. The global problem of climate change from greenhouse gas emissions
2. The local impacts caused by data centers

For climate change overall, I think we should:

- Pressure the companies that make LLMs to publish detailed information about carbon emissions
- Pressure our politicians to tax greenhouse gas emissions... or at least to tax activities that result in greenhouse gas emissions in a way that would mimic the outcome of a carbon tax
- Subsidize activities that lower greenhouse gas emissions, like increasing solar and battery technology use on the electrical grid
- Talk about climate change and encourage our colleagues and loved ones to talk about it

When it comes to AI data centers, I think focusing on their impacts to local grids makes more sense than focusing on their global impacts. The uneven distribution of data centers makes their local impacts disproportionately large in comparison to their global impacts. I see this as similar to the problem of pig farms. Eastern North Carolina has waste lagoons from pig farms that cause serious issues for nearby communities. Both data centers and pig farms are very unevenly distributed and both cause big problems for their neighboring communities.

On an individual level, I would rather see people eat less meat and dairy products than worry about the climate impact of using LLM coding agents. But more so than either of those, I would rather that we have hard and honest conversations with colleagues and loved ones and pressure our elected representatives in government to take action on this problem.

Americans have a habit of thinking about systemic problems through the lens of individual action. As I noted in [my lightning talk at PyCon last year](https://youtu.be/Uuhu-F05A7k?feature=shared&t=3173), system-level problems require system-level solutions. If the climate impact of LLMs concerns you, I'd encourage you to direct that energy toward the people and institutions that can change these systems.
