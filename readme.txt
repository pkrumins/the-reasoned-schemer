This repository contains all the code examples from the book "The Reasoned
Schemer." The goal of the book is to show the beauty of relational
programming. The authors of the book believe that it is natural to extend
functional programming to relational programming. They demonstrate this by
extending Scheme with a few new constructs, thereby combining the benefits of
both styles. This extension also captures the essence of Prolog, the most
well-known logic programming language.

If you're interested, get the book from Amazon: http://bit.ly/89tulL

This book assumes that you know the basics of Scheme. The Reasoned Schemer 
can also be viewed as the 3rd book in the Schemer book series. The first two
books are  "The Little Schemer" (http://github.com/pkrumins/the-little-schemer)
and "The Seasoned Schemer" (http://github.com/pkrumins/the-seasoned-schemer).

The code examples were copied (and completed where necessary) from
"The Reasoned Schemer" by Peteris Krumins (peter@catonmat.net).

His blog is at http://www.catonmat.net  --  good coders code, great reuse.

------------------------------------------------------------------------------

Table of contents:
    [01] Chapter  1: Playthings
         01-playtings.ss
    [02] Chapter  2: Teaching Old Toys New Tricks
         02-old-toys.ss
    ...
    work in progress, adding new chapters every once in a while


[01]-Chapter-1-Playtings------------------------------------------------------

See 01-playtings.ss file for code examples.

Chapter 1 introduces the basic constructs of relational programming, they are
the goals #s for succeed and #u for fail, the fresh variables, the operators
==, fresh and conde.

The laws of operators fresh, == and conde are postulated:

.----------------------------------------------------------------------------.
|                                                                            |
| The law of fresh:                                                          |
|                                                                            |
| If x is fresh, then (== v x) succeeds and associates x with v.             |
|                                                                            |
'----------------------------------------------------------------------------'

.----------------------------------------------------------------------------.
|                                                                            |
| The law of ==:                                                             |
|                                                                            |
| (== v w) is the same as (== w v).                                          |
|                                                                            |
'----------------------------------------------------------------------------'

.----------------------------------------------------------------------------.
|                                                                            |
| The law of conde:                                                          |
|                                                                            |
| To get more values from conde, pretend that the successful conde line has  |
| failed, refreshing all variables that got an association from that line.   |
|                                                                            |
'----------------------------------------------------------------------------'

After you have read the chapter,

              go make yourself a peanut butter and jam sandwich!


[02]-Chapter-2-Teaching-Old-Toys-New-Tricks-----------------------------------

See 02-old-toys.ss file for code examples.

Chapter 2 teaches the old tricks from The Little Schemer. They are caro, cdro,
conso, nullo, eqo and pairo.


------------------------------------------------------------------------------

That's it. I hope you find these examples useful when reading "The Reasoned
Schemer" yourself! Go get it at http://bit.ly/89tulL, if you haven't already!


Sincerely,
Peteris Krumins
http://www.catonmat.net

