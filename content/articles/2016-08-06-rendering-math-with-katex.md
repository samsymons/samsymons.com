---
title: Rendering Math with KaTeX
date: "2016-08-06"
tags: math
---

The other day, I was looking into how easy it is to render LaTeX via a Markdown document. [MathML](https://www.w3.org/Math/) isn't yet widespread enough to use reliably, so instead I started looking at some of the third-party libraries available. I had looked at [KaTeX from Khan Academy](https://github.com/Khan/KaTeX) a few times in the past, and was happy to find that it was exactly what I wanted.

<!--more-->

To add support, all you need is KaTeX, auto render support, and the CSS file:

```
<script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.6.0/katex.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.6.0/contrib/auto-render.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.6.0/katex.min.css">
```

Then, in Markdown, you can write your LaTeX within `$$` blocks.

```
$$
a = \\sqrt{b^2 + c^3}
$$
```

This renders like so:

$$
a = \\sqrt{b^2 + c^3}
$$

The auto render plugin can be configured to ignore certain tags or check for custom delimiters; there's more about that in the [GitHub repo](https://github.com/Khan/KaTeX/tree/master/contrib/auto-render). KaTeX can also take a LaTeX string and spit out formatted HTML, which is probably the better option if you're happy to do a little more work for raw performance, but as it is, this works great.

Another option for this is using [Kramdown's LaTeX support with MathJax](http://blog.riemann.cc/style-features-demo/), but I had some issues getting it to render correctly in some cases (and it seems a bit slower than Khan Academy's alternative).
