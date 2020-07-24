---
layout: post
comment: true
title: Bayesian basics I - the way of reasoning 
key: A10005
tags: probability bayesian
category: stats
date: 2015-07-12
---

One day after lunch, one of my colleagues spotted a man running outside of our windows where there is a fire escape balcony along the outside of our building. We immediately realized that he was probably a thief since we occasionally had heard of people from other labs losing expensive computers after seeing a man on the fire escape balcony. We then felt alarmed, called the police and alerted everybody to back up their data.

Why did we decide to call police immediately? What was going on in our brains? First let us assume

<!--more-->

>our world had been very peaceful and safe before we saw that guy running outside the window – in other words, no crimes at all and nobody had ever lost anything.

Then we would not find the running guy suspicious, and we wouldn’t be alarmed enough to call the police, since there could be many reasonable and logical ways to explain his behavior. He might just enjoy running around buildings, employ parkour as his exercise regimen, or maybe he dropped something from upstairs and had to get it back. The possibility of him being a thief would be one of many, and not a likely one under our assumption.

What if we add another observation?

>Before the incident where we saw the guy outside our window, another one of our colleagues saw him outside and then discovered that his laptop had been stolen.

Now it is very plausible that the running guy did something bad and some alert colleagues suspected that he was possibly a thief. Okay, what about adding more observations:

>After our colleague’s laptop was stolen, people always lost things if someone strange was spotted.

After these observations, normally we would have learned that we should call the police if some stranger showed up on our balconies.

Let’s have a close look and boil down the example. We first have an ‘observation’ — ‘a guy running outside of the window’, and some ‘prior knowledge’ — ‘no crimes in our past world’. Then we won’t connect this observation to stealing since our life experience leads us to believe that everyone is innocent. However this belief will be changed a bit — ‘some alert colleagues suspected that he is a thief’, after we know a new laptop was lost. And it has been changed continually as more and more observations tell us that a strange person showing up in our private balcony is a plausible sign of stealing. What we have learned from both prior knowledge and those observations is ‘posterior knowledge’.

Through this example, basic elements of Bayesian reasoning have been introduced: the prior, the observations and the posterior. The prior is the belief we have about the world before the observation; the posterior is the belief altered by the observations. So the posterior depends on both the prior and the observations.

I hope you would agree with me that Bayesian reasoning is very natural. Let me give another quick example. You see a beautiful girl on campus and feel like she is the type you really want to build a serious relationship with, maybe even a family. So you are too cautious and nervous to ask her for her number and ask to date her. Now your belief that she will agree to be your girlfriend is a bit low. But on one day, she makes eye contact with you and even says ‘Hi’. With this observation, you update your belief and think she will definitely agree to date you.  Then the following story is up to you:)

Bayesian reasoning fascinates me simply because it is such a natural way of learning and thinking.
I’ve no idea whether our universe follows a set of deterministic rules, but the sure thing is that our life is full of uncertainties. Usually a guy cannot be certain if the beautiful girl being asked would be willing to be his girlfriend; though we would like to know what the weather would be a month from now for our vacation in Barcelona, we cannot be certain what it will be; it is also very hard for us to choose one of many good job offers. Despite all sorts of uncertainties, we have to make decisions quickly (from an evolutionary point view). We all know that probability theory is the hammer for uncertainty, equipment we can use to infer and make decisions. Dr. H. Barlow said “The brain is nothing but a statistical decision organ”. Indeed, our brains are trained to get something useful out of our noisy surroundings. 
