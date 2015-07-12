---
title: Software Security Course Review
date: 2015-04-13 16:12 UTC
tags:
---

As a follow up to the [crypto course from earlier this year][1], I enrolled in the [software security course from the University of Maryland][2] for something a bit more hands-on.

I wanted to write up a short review of the course here, especially since I haven't seen many (any?) other security courses like this offered on Coursera.

### Overview

The syllabus is what you would expect in a security course:

1. Low-level, memory-based attacks
2. Defenses against memory-based attacks
3. Web security
4. Secure design
5. Automated code review with static analysis and symbolic execution
6. Penetration testing

You can see that the course is roughly divided up into two different sections: attacking, and defending. Each section goes over the ways certain areas of software can be exploited (say, via SQL injection), and then it is followed up by how you would defend against that problem (sanitizing user input in this case).

### Workload

The workload for this course was surprisingly light; I would often sit down early Monday morning and work through the week's content before lunch. The same can probably be said of other courses; with Software Security I enjoyed it enough that it was easy to just work through all of it at once.

Each week has the usual set of lecture videos paired with a quiz, and then every other week had an assignment to go with it. Each assignment involves firing up a Linux VM and running through some problems, like taking down a vulnerable web app or exploiting stack overflows via GDB.

### Final Notes

With courses I've taken in the past, I've gone the lone wolf approach and tried to do the content myself without asking for any help (besides reading books).

This time, I jumped into the ##softwaresec IRC channel on Freenode and got to know people there. Having to explain concepts to people was *far* more helpful at making sure I understood the material than simply taking notes and answering quiz questions.

This was a great course, and I'd love to see a follow-up to it in the future.

[1]:	https://samsymons.com/blog/dan-boneh-crypto-course/
[2]:	https://www.coursera.org/course/softwaresec