---
title: De Morgan's Laws
date: 2013-12-20 20:38 UTC
wip: true
---

It's not uncommon to run into code featuring a few mind-bending conditional statements. More often than not, these can be clarified using two laws known as [De Morgan's laws](http://en.wikipedia.org/wiki/De_Morgan's_laws).

Here you can see De Morgan's laws in action.

```ruby
# First law:
!(a && b) == (!a || !b)

# Second law:
!(a || b) == (!a && !b)
```

This first rulenot (A and B)" is the same as "(not A) or (not B)"

