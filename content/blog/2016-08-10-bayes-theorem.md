---
title: "Bayes' Theorem"
date: "2016-08-10"
tags: [ "data science", "machine learning" ]
slug: "bayes-theorem"
---

One of the most useful and interesting theorems in statistics is [Bayes' Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem). I like it a lot because it can be used to solve interesting problems with very little effort — it boils down to one equation! I wanted to go over it and try to provide some intuition into how it works, and then why you would want to use it.

<!--more-->

### Conditional Probability

First, let's walk through some simple examples to get warmed up. What is the probability that a fair coin, when flipped, will result in heads? Easy enough: 50%!

$$
P(Heads) = 0.5
$$

There are two possible outcomes, heads and tails, each with an equal probability, so the chance of getting either one is 50%. 1 actual outcome divided by 2 possible (and equal, in this case) outcomes = 1/2 = 0.5. This is Probability 101, but it's worth recapping before jumping into _conditional_ probability.

Conditional probability is where you start to think about the chances of something happening, _provided_ something else has already happened. Let's look at coins again, and then try something more interesting. What are the chances of getting a heads, provided you just flipped a coin and got tails? This isn't much of a stretch from our previous work. A real statistician might write that like this:

$$
P(Heads|Tails) = P(Tails) \cdot P(Heads)
$$

This is a fancy way of saying _the probability of heads, given that we just got tails, is the chance of getting tails multiplied by the chance of getting heads_. You have a 50% chance of getting tails, and then after that you have _another_ 50% chance of getting heads, so the total here is 25%, or 1/4.

So that makes sense. There was a 50% chance of getting a result, and then a 50% chance on top of that of getting another result, leading to 25%. This math works because the probability of a coin flip is _independent_. Flipping a coin and getting heads does **not** affect the next coin flip, despite what [gamblers](https://en.wikipedia.org/wiki/Gambler%27s_fallacy#Coin_toss) may try to tell you. If I flip a fair coin and get three heads in a row, what are the chances of getting heads on the next flip? It's still 50%!

### Even More Conditional Probability

The coin example is a bit boring, so I'll try something else. Statisticians love marbles for some reason, and I'm in no position to argue, so say we have two bags of marbles. The first has 3 red marbles, and 1 blue marble. The second has 2 of each.

* Bag 1 = 3 red marbles, 1 blue marble
* Bag 2 = 2 red marbles, 2 blue marbles

Here's what I want to know: if I pick out a marble out of one of these bags at random, and it is _red_, what are the chances it came from bag 1? Or, in fancy notation:

$$
P(Bag 1|Red) = Something
$$

Given I have a red marble, this equation is the chance of the bag it came from being bag 1. Calculating this the other way around is straightforward — if you chose a marble from bag 1 and it happens to be red, the chance was 3/4, so \\(P(Red|Bag 1) = 0.75\\). Similarly, picking a red marble from bag 2 has a chance of 50%, since there are an even number of red and blue marbles. But how do we figure out which _bag_ we chose? This seems kinda difficult.

### Bayes' Theorem

Everything is fine. Let's just work through this marble example, and see how far we can get. We want to know the odds of us picking bag 1, knowing that the marble we have in our hands is red. To even think about picking a marble, we had to choose a bag at random. There are two bags, and each is just as likely to be selected, so there is a 50% chance of getting bag 1: \\(P(Bag1) = 0.5\\).

From here, each bag has a different probability of picking a red marble, since there are different numbers of red marbles in each. We care about bag 1 right now, so as mentioned earlier, \\(P(Red|Bag 1) = 0.75\\). So far we have this:

$$
P(Bag1) \\cdot P(Red|Bag 1)
$$

Since we picked a red, we have to consider _all_ red marbles, or \\(P(Red)\\). Since we are picking a few red marbles out of all possible red marbles, we can divide the previous value by the probability of red, like so:

$$
\frac{P(Bag1) \cdot P(Red|Bag1)}{P(Red)}
$$

Now we have the chance of choosing bag 1, multiplied by the chance that the marble picked inside bag 1 was red, divided by the chance of picking a red marble at all.

**Surprise!** That's Bayes' Theorem! Here it is from Wikipedia:

$$
P(A|B) = \frac{P(A) \cdot P(B|A)}{P(B)}
$$

That's honestly all there is to it. Pretty neat, huh? This theorem lets us figure out the probability of an event being in some category, given that it occurred.

### How Does This Even Help Me?

Alright, so maybe for some reason you're not sorting marbles regularly. Bayes' Theorem is equipped to handle more than that. One popular use of the theorem is for [classifying email into spam or not-spam](https://en.wikipedia.org/wiki/Naive_Bayes_spam_filtering).

As I mentioned, the theorem helps us figure out the probability of an event being in some category, given that it occurred. In this case, given that we received an email, what are the odds that it's spam?

In real life, the way we figure out whether an email is spam or not is just by reading it. If it talks about Viagra or distant relatives suddenly bequeathing large amounts of money (sometimes _both?_), it usually ends up in the trash. All we really have to go on is the text content of the email, so that's exactly how these email classifiers work. In the context of Bayes' Theorem, it looks like this:

$$
P(Spam|Words) = \frac{P(Spam) \cdot P(Words|Spam)}{P(Words)}
$$

The probability of an email being spam, given that it had these words in it, is the probability of getting a spam email multiplied by the probability of seeing these words in a spam email, divided by the odds of getting these words in any email. This is why sometimes you'll get spam email slip through your filter, and why spammers are regularly changing the language they use: it's all about probability, so by being unpredictable, you get into a user's inbox.

Actually building one of these classifiers is obviously a little more involved, but there is plenty of material out there to dig into. The point I wanted to get across is that Bayes' Theorem is really cool, and can help you solve interesting problems! Learn it! Use it!
