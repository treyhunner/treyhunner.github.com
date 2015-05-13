---
layout: post
title: "The Cabo card game"
date: 2015-05-08 18:11:22 -0700
comments: true
categories: 
---

About five years ago a friend taught me a card game called Cabo.  It was a memory game of sorts.  It plays quickly and is perfect while idling between activities.  I have spread this game to dozens of people at tech conferences, most recently during PyCon 2015.

I often use this game as an ice breaker.  The conversation usually goes something like this:

**Me**: Hi. Would you like to play a fairly quick card game?  It's called Cabo.  
**Them**: I've never heard of it.  
**Me**: I've never met anyone who has.  I'll teach you the rules.  
**Them**: What kind of game is it?  
**Me**: An information management game ("memory game" seems to discourage people)  
**Them**: Hm okay.  

Cabo did not have a Wikipedia article when I first learned about it and I couldn't find anything online about it.  There is now a [Wikipedia entry for Cabo][wikipedia] and I ran across a website selling special Cabo playing cards: [playcabo.com][playcabo.com].

I have thought about making an online version of this game, printing playing cards with custom Cabo-themed artwork, and making an open source program that knows the rules of Cabo so I could use it as a teaching tool.  After chatting with friends I met at PyCon, I looked into what it would take to print a custom card deck to sell or gift to friends.

I contacted the owner of [playcabo.com][playcabo.com] and asked whether Cabo was IP-protected and whether the origins of the game were known.  I had assumed Cabo was a folk card game of unknown origins, like [Big Two][], [Durak][], and [Egyptian Ratscrew][].  I was wrong.  This game has a known creator.

Hard work was put into the creation of this game.  This game was designed by Melissa Limes and Mandy Henning.  Melissa founded Eventide Games LLC, registered Cabo as a trademark, and registered a copyright for the rules.  I was a little disappointed to discover that Cabo is owned property, but I was very excited to discover the origins of this game.

The game I know as Cabo is a little different from the one that Melissa Limes sells.  Her game seems more kid-friendly and more beginner-friendly.  With Melissa's permission, I will now share with you the rules for a game I know as Cabo.

## Cabo: the rules I know

### Setup

Each player starts with four cards, placed face-down and arranged into a two-by-two grid.  No one may look at any cards.

In the beginning of the game all players will look at their bottom two cards (the ones closest to them) one time only.  Try to remember your cards.

### Objective

The objective is to end the game with the lowest score.  Score is determined by summing up the value of each of your cards.

Card values:

- Ace is worth 1
- Jack is worth 11
- Queen is worth 12
- King of diamonds (the one-eyed king) is worth 0 points
- The other three kings are worth 13 points

1 through 6 are the "low cards".  They have a low point value and are fairly desirable.

7 through Queen are the "power cards".  You will not want to keep them for their points, but if you draw one on your turn you can choose to use its power.  More on this below.

The one-eyed king is great but the other kings have no abilities and they are not particularly desirable.

### Gameplay

We never had a rule for who goes first, so the game starts by someone declaring that they are going first or pointing at someone else to indicate that they go first.

On your turn you may either:

- Draw a card from the deck (the face-down pile)
- Draw a card from the discard pile (which is face-up)

When drawing you may either:

1. Swap the drawn card with one of your own cards

   You pick one of your cards, discard it and put the card you just drew in its place.

2. Match the drawn card with any other cards you know with the same face

   You can match the drawn card with any cards on the table (not counting draw piles) with the same face (e.g. queens match queens, and fives match fives).  All matched cards are discarded.  All cards matched from other player's hands should be replaced with a card from your hand.  No one may look at the replaced cards when they are moved.  All matched cards are discarded.  Every card you match results in one less card in your hand.

   The card that initiated the matching goes on top of the discard pile after matching (this only matters when the one-eyed king is matched).

3. Discard the drawn card (just put it on top of the discard pile)

   This is a common move when drawing a king as they are worth 13 points and have no special powers.

4. Use the card you drew as a power card (for 7, 8, 9, 10, Jack, Queen)

   There are three types of power cards which you can remember with this rhyme:

   - **Seven or eight, know your fate**: look at one of your own cards and then put it back (only you get to see it)
   - **Nine or ten, know a friend**: look at one card from someone else and then put it back (only you get to see it)
   - **Jack or Queen, switch between**: trade the places of any two cards on the table (excluding draw piles)

   When using a power card, put the card in the discard pile and then use the power.  That's your whole turn.  **You may only use a card's power when drawing from the face-down pile.**

### End Game

If at any point during a person's turn they call "Cabo", everyone except for that person gets one more turn and then the game ends.

There are two other ways the game may end:

1. Someone runs out of cards (they match their last card)
2. The deck runs out (alternatively you could re-shuffle and keep playing)

The lowest total score wins (see objective).

## Buy a custom deck

The version of the game I know is played with a standard 52-card deck.  To play this version you need to remember the rules and the rhyme.

The official rules are slightly different.  If you want a deck custom-built for Cabo and play by the official rules, you can buy one from Eventide Games LLC at [PlayCabo.com][].

[wikipedia]: https://en.wikipedia.org/wiki/Cabo_(game)
[playcabo.com]: http://www.playcabo.com/
[big two]: https://en.wikipedia.org/wiki/Big_Two
[durak]: https://en.wikipedia.org/wiki/Durak
[egyptian ratscrew]: https://en.wikipedia.org/wiki/Egyptian_Ratscrew
