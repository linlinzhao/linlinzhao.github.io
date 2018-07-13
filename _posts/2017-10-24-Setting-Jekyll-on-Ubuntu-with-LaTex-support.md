---
layout: post
comment: true
title: Setting Jekyll on Ubuntu 16.04 with Latex support
key: 10003
tags: GitHub-Pages Jekyll LaTex
category: Tech
date: 2017-10-24
---
*Update July 2018*: 

This post is outdated as the issues stated at the time of writing are not issues anymore. It is still kept for potential interest. 

---

I did encounter a few stones on my way to adopt [Tian Qi's TeXt](https://tianqi.name/blog/)
for setting up my own GitHub Pages. I had just two basic requirements: 1. support LaTex syntax. 2. simple but functional. I know very few about web design, that is why even a little stone
could cost me half an hour to move it away.

- The first thing is about setting up both ruby and node.js environment on my Ubuntu machine.
Installing Ruby and gem went smoothly, therefore setting up Jekyll is easy. But when I tried
to install ``Node.js`` and ``npm``, my Ubuntu constantly complained that it could not install the current
 stable version of Node.js, and it installed ``Node 4.2.6`` instead, which in turn made the latest ``npm``
  refuse to work with the old ``Node 4.2.6``. Many people filed this
   [problem](https://askubuntu.com/questions/786272/why-does-installing-node-6-x-on-ubuntu-16-04-actually-install-node-4-2-6)
    already, but most of them did not work for me.

  The problem is caused by a discontinued ppa application, I need to remove it from ``/etc/apt/source.list`` and
  ``/etc/apt/source.list.d``. This is the detailed [solution](https://askubuntu.com/questions/65911/how-can-i-fix-a-404-error-when-using-a-ppa-or-updating-my-package-lists)

- The second thing is to make LaTex work in Markdown. [MathJax](http://docs.mathjax.org/en/latest/tex.html) is
the choice but there exists several ways to set up MathJax in [Jekyll](https://jekyllrb.com/docs/extras/), and
some of them just did not work for me. I did not have the time to dig out the reason but just wanted to find a
quick solution. Eventually I made it work with these settings:

  1. Using [kramdown](https://kramdown.gettalong.org/syntax.html#math-blocks) engine for markdown.
  2. Putting
  ``<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
  </script>``
  in TeXt theme's ``_layouts/page.html``. Be sure to use ``https``, otherwise the rendering online could fail.
  3. Then I could write equations in LaTex! For inline equations, the expressions need to be embraced with double dollar sign like this: ``$$x$$``.
  For independent lines, the expressions should start from a new line after ``$$``, and the ending ``$$`` should also stay in a new line.

Okay, that is it. I hope someone could find this post useful.
