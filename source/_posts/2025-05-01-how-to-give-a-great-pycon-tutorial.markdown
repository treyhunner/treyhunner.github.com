---
layout: post
title: "How to give a great PyCon tutorial"
date: 2025-05-01 16:00:00 -0700
comments: true
categories: pycon
---

You've submitted a tutorial to PyCon and it was accepted.
Uh oh.

Now what?

In this post I'll be sharing my thoughts on giving a great PyCon tutorial.


## Readability counts

Be sure to consider readability when teaching a tutorial.
Talks usually involve slides and the default font size in presentation software is often pretty readable on a projector.
That's *not* usually the case for code editors, web browsers, and terminals.

Consider the size of the text you'll be displaying.
I tend to zoom in until my screen can just barely fit about 80 characters of text.

Also consider your color scheme.
When reading from a projector, black text on a white background is usually easier to read than black text on a white background.
So I recommend using a **light mode** color scheme even if you *usually* prefer dark mode.
And be sure to use a high contract color scheme!

Also consider how you'll share URLs.
Shortened URLs are easier to type.
QR codes can also help, but be sure to share the *actual* URL as some may not be able to scan QR codes.


## Engage students in attempted information retrieval

Have you ever heard the phrase "in one ear and the other"?
That's how lectures usually work.
Lectures tend to focus on putting information into our heads.
Unfortunately, our brain isn't designed to remember information that's presented to it.

We don't learn by putting information into our heads; we learn by trying to retrieve information from our heads.
Information retrieval attempts, even somewhat unsuccessful ones, are *very important* for helping our brain retain information.

So, how will your tutorial engage students in the act of attempted information retrieval?

You could:

- Group quiz: "what do you think might happen if...?"
- Silently quiz: present a quiz question every few minutes to work on individually
- Take 10 minute exercise breaks every 20 minutes so students can write code to apply what they've just seen

Give students a way to know whether they "did it right" as well.
But also keep in mind that the focus of any sort of quizzing should be on **taking a guess**, not on getting a grade.

We don't learn by watching, but by *doing*, so I recommend planning your tutorial around a *lot* of recall.


## Prepare for the unprepared

Since your tutorial is going to be hands-on (see the previous section), you'll probably need your students to set things up on their machines.

You could set aside the first 30 minutes of your 3 hour tutorial for setup steps, but I wouldn't recommend that.
Setup will take some students 5 minutes and others 25 minutes.
Expecting folks who are quick to idle for many minutes isn't ideal.

If possible, I would recommend writing up prerequisite setup instructions and asking students to perform necessary setup steps *before* PyCon.
A week or two before PyCon, email those installation and/or setup instructions.
Then email those instructions a couple more times.
Yes, that may seem redundant, but redundant reminders can be very helpful.

Some attendees will register after you send out your first instructions email, some will ignore or skip over emails, and some may even register for your tutorial *on the day of your tutorial*.

It's helpful to give any unprepared students some escape hatches to get caught up.

For example, you could let attendees know that:

1. You would like them to work through setup instructions by X date
2. You be available for asynchronous email-based assistance and they should email you if they get stuck
3. You will be in your tutorial room early and you can help anyone who also shows up 15 minutes early get setup

Inevitably, somewhere around 10% of your attendees will *not* work through the setup instructions in full before the start of your tutorial.

Please *do* provide help to these unprepared attendees, but don't punish the prepared ones, at least not too much.
For example, if you have a 15 minute exercise section near the beginning of your tutorial, float around the room during that time and make sure everyone has their machines setup.


## Expect the unexpected

What happens if an attendee's work laptop doesn't allow them to install or run certain programs?
What if an attendee brings a Chromebook and your installation instructions assume Linux, Mac, or Windows?
What if an attendee didn't bring a laptop?

What's your backup plan?

Can attendees use an online interface instead of working locally?
Do you have a spare laptop with a guest account they could use?
Could another attendee volunteer to have someone pair up with them?

And what happens if the Internet drops out?
Internet issues have plagued *many* a tutorial presenter in the past, especially for tutorials that involve dozens of attendees all downloading many megabytes at the same time.
Consider bringing a pre-loaded USB thumb drive or two as a backup plan.


## Have helpers, if you can

Having an exercise "break" early on allows those in need of extra setup help to catch up.

I also like to encouraging attendees to try helping each other out.
This can set a sort of "we're all in this together" atmosphere.
When an attendee helps a neighbor understand the instructions for an exercise, that may also help them solidify their understanding as well.

If you can find a volunteer **teaching assistant** (TA) or two who can familiarize themselves with your material even *just a little bit*, that can be very handy.
The primary role of a TA is to simply to act as another set of eyes and ears for attendees who need a bit of extra help.
This is *especially* helpful during the first exercise section or two, when everyone is getting setup and wading into the material.

During exercise breaks in my recorded PyCon tutorials (e.g. [here](https://youtu.be/_6U1XoxyyBY?feature=shared&t=2310) or [here](https://youtu.be/ixiRkUwPI2A?feature=shared&t=1078) or [here](https://youtu.be/6zu8lrYn6t8?feature=shared&t=1605)) you may notice me and my TAs wondering around the room helping folks who have stickies up (more on that below) and generally checking in on folks who have confused expressions on their faces.

For both you *and* your helpers, consider what it means to be a helpful helper.
You may want to watch my [Meaningful Mentoring Moments](https://treyhunner.com/mentoring/resources.html) talk or review some of the materials I link to in that talk.


## Seek advice from others

In each of my tutorials I give every attendee a sticky note.
I either put a sticky note at each chair before we begin, have a TA give a sticky notes to each person as they walk in, or I walk around the room and say hi to each person while giving them a sticky note.

After everyone has a sticky note, I explain their purpose: to flag down me (or a TA) during exercises when help is needed.
It's difficult to type on your keyboard while keeping a hand raised in the air for many many minutes.
Sticky notes allow attendees to signal that they need help *and* they allow me to quickly scan the room and see how many folks need help.

You probably wouldn't have thought of sticky notes.
I wouldn't have either!
I saw them used in an Open Hatch workshop many years ago and thought "that's genius".

Ask for advice from others who have taught live tutorials, workshops, and classes.
You may not find every bit of advice helpful, but most of us who have taught before are happy to share what works for us.


## Envision the moment

If we learn solely from experience, then the first time we do something we'd expect to fail miserably.
But that's (obviously) not what we *want* to happen.
We want our first tutorial to be a reasonably successful experience.

Fortunately, our brains are half decent reality simulators.
Let's use our brain's ability to simulate future possibilities to our advantage.

Imagine the world from the perspective of your attendees.
Where might they get stuck or frustrated?
If they don't feel comfortable speaking up, will you know about their frustrations?
Will you be deliberately polling the room to see how they're feeling?
When?
How often?
What will trigger you to poll the room?

Imagine when pulse checks might be helpful to see how your audience members are feeling.

Also, imagine how much of your curriculum you'll get through.
How might you meet your attendees' expectations if it takes twice the time to get through curriculum?
Is there anything that can be skipped?

What happens if you get to the end and you have 30 minutes left?
Could you add extra material that's *expected* to be skipped, but could be worked through if there's additional time?

What will the call-to-action be at the end of your tutorial?
Are there future projects attendees could work through?
Are there specific actions you would recommend attendees take next?


## Use checklists

One time I forgot to pack sticky notes and found myself frantically looking for a nearby office supplies store the morning of my tutorial.
And then I did that 2 more times. 😬

You can't keep everything in your head.
Use a checklist to keep yourself on track during your tutorial *and* leading up to your tutorial.


## Have compassion

Doing hard things is hard.
Explaining hard things is even harder.

Learning isn't easy either.

Be kind to your attendees and **be kind to yourself**.
Mistakes will happen.
Try to keep moving forward and do your best to make good use of the time you have.
